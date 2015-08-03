/*
 * User space control program for the RPi camera attached to the
 * parallella board.
 *
 * Copyright (C) 2015  Sylvain Munaut
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301 USA.
 */

#include <errno.h>
#include <getopt.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/time.h>
#include <fcntl.h>

#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>

#include "i2c-dev.h"
#include "para_gpio.h"


/* Configuration constants */
#define I2C_BUS_DEV		"/dev/i2c-1"
#define I2C_ADDR		0x36
#define GPIO_ENABLE_NUM		74
#define GPIO_LED_NUM		76
#define FB_BASE			0x3e000000
#define FB_LEN			0x02000000
#define VDMA_BASE		0x43000000
#define VDMA_LEN		0x00010000
#define CSI_BASE		0x43C00000
#define CSI_LEN			0x00010000

#define USE_WRITE_OPT		1
//#define DEBUG			1


/* Declarations */
struct pix_fmt_desc;

struct rpi_cam
{
	para_gpio *gpio_enable;
	para_gpio *gpio_led;

	int i2c_sensor;

	int fd_mem;
	void *fb;
	void *vdma;
	void *csi;

	const struct pix_fmt_desc *pix_fmt;

	/* Sensor output */
	int w_sensor_px;
	int h_sensor_px;

	/* Video Pipeline output */
	int w_vpipe_bytes;
	int w_vpipe_px;
	int h_vpipe_px;

	/* FB state tracking */
	int fb_cur;
	int fb_len;
};

static void rpi_cam_release(struct rpi_cam *cam);


/* Helpers */
static inline void
reg_write(void *base, unsigned int reg, uint32_t val)
{
	*((volatile uint32_t *)(base + reg)) = val;
}

static inline uint32_t
reg_read(void *base, unsigned int reg)
{
	return *((volatile uint32_t *)(base + reg));
}


/* ------------------------------------------------------------------------ */
/* Pixel formats                                                            */
/* ------------------------------------------------------------------------ */

enum pix_fmt_mode
{
	PFM_RAW		= 0,
	PFM_UNPACK	= 1,
	PFM_DEBAYER	= 2,
};

struct pix_fmt_desc
{
	const char *name;
	uint32_t vpcr;
	int size_num;
	int size_denom;
	enum pix_fmt_mode mode;
};

static const struct pix_fmt_desc pix_fmts[] = {
	{ "sbggr10p",	0x000000, 5, 4, PFM_RAW },	/* x xx xxxxxxxx 00 00 */
	{ "sbggr10",	0xa00022, 2, 1, PFM_UNPACK },	/* 1 10 xxxxxxxx 10 10 */
	{ "sbggr8",	0x800023, 1, 1, PFM_UNPACK },	/* 1 00 xxxxxxxx 10 11 */
	{ "rgbz32",	0x803930, 4, 1, PFM_DEBAYER },	/* 1 xx 00111001 11 00 */
	{ "bgrz32",	0x801b30, 4, 1, PFM_DEBAYER },	/* 1 xx 00011011 11 00 */
	{ "gray8",	0x800233, 1, 1, PFM_DEBAYER },	/* 1 xx xxxxxx10 11 11 */
	{ "red8",	0x800133, 1, 1, PFM_DEBAYER },	/* 1 xx xxxxxx01 11 11 */
	{ "green8",	0x800233, 1, 1, PFM_DEBAYER },	/* 1 xx xxxxxx10 11 11 */
	{ "blue8",	0x800333, 1, 1, PFM_DEBAYER },	/* 1 xx xxxxxx11 11 11 */
	{ NULL, 0, 0, 0, 0 } /* Guard */
};

static const struct pix_fmt_desc *
pix_fmt_find(const char *name)
{
	int i;

	for (i=0; pix_fmts[i].name; i++)
		if (!strcmp(pix_fmts[i].name, name))
			return &pix_fmts[i];

	return NULL;
}

static int
pix_fmt_bytes_per_line(const struct pix_fmt_desc *pf, int width)
{
	return (width * pf->size_num + pf->size_denom - 1) / pf->size_denom;
}


/* ------------------------------------------------------------------------ */
/* CSI core                                                                 */
/* ------------------------------------------------------------------------ */

static void  __attribute__((unused))
csi_debug(struct rpi_cam *cam)
{
	uint32_t x;

	x = reg_read(cam->csi, 0x04);
	fprintf(stderr, "CSI SR: %08x [ %s%s%s%s%s]\n", x,
		(x & (1 << 31)) ? "PP_FIFO_empty ": "",
		(x & (1 << 30)) ? "Pkt_FIFO_empty " : "",
		(x & (1 << 17)) ? "PP_error_pending " : "",
		(x & (1 << 16)) ? "PP_running " : "",
		(x & (1 <<  0)) ? "PHY_running " : ""
	);

	x = reg_read(cam->csi, 0x08);
	fprintf(stderr, "CSI ER: %08x [ %s%s%s%s%s%s%s%s%s]\n", x,
		(x & (1 << 19)) ? "phy_overflow "  : "",
		(x & (1 << 18)) ? "phy_early_lp "  : "",
		(x & (1 << 17)) ? "phy_bad_ecc "   : "",
		(x & (1 << 16)) ? "phy_late_sync " : "",
		(x & (1 <<  4)) ? "pp_late_last "  : "",
		(x & (1 <<  3)) ? "pp_early_last " : "",
		(x & (1 <<  2)) ? "pp_unk_pkt "    : "",
		(x & (1 <<  1)) ? "pp_early_sof "  : "",
		(x & (1 <<  0)) ? "pp_no_hdr "     : ""
	);

}

static void
csi_reset(struct rpi_cam *cam)
{
	reg_write(cam->csi, 0x00, (1<<31));
}

static void
csi_start(struct rpi_cam *cam)
{
	int d, tl_bias = 2;

	switch (cam->pix_fmt->mode)
	{
	case PFM_RAW:		/* RAW: No cropping at all */
		reg_write(cam->csi, 0x20, 0x000);
		reg_write(cam->csi, 0x24, 0xfff);
		reg_write(cam->csi, 0x28, 0x000);
		reg_write(cam->csi, 0x2C, 0xfff);
		break;

	case PFM_DEBAYER:	/* Debayering active: skip 2 top lines and 2 left rows */
		tl_bias = 2;
		/* fall-thru */

	case PFM_UNPACK:	/* Normal */
		d = (tl_bias + (cam->w_sensor_px - cam->w_vpipe_px - tl_bias) / 2) & ~1;
		reg_write(cam->csi, 0x20, d);
		reg_write(cam->csi, 0x24, d + cam->w_vpipe_px - 1);

		d = (tl_bias + (cam->h_sensor_px - cam->h_vpipe_px - tl_bias) / 2) & ~1;
		reg_write(cam->csi, 0x28, d);
		reg_write(cam->csi, 0x2c, d + cam->h_vpipe_px - 1);

		break;
	}

	reg_write(cam->csi, 0x14, cam->pix_fmt->vpcr);	/* VPCR */
	reg_write(cam->csi, 0x00, 			/* CR */
		(1 << 16) |	/* PP active */
		(1 <<  1) |	/* Bypass LP detect */
		(1 <<  0)	/* PHY active */
	);
}

static void
csi_stop(struct rpi_cam *cam)
{
	reg_write(cam->csi, 0x00, 0x00);
}


/* ------------------------------------------------------------------------ */
/* Video DMA                                                                */
/* ------------------------------------------------------------------------ */

static void __attribute__((unused))
vdma_debug(struct rpi_cam *cam)
{
	uint32_t x;

	x = reg_read(cam->vdma, 0x34);
	fprintf(stderr, "SR: %08x [%s%s%s%s%s%s%s%s%s%s%s ]\n",
			x,
			(x & (1 << 15)) ? " EOLLateErr"  : "",
			(x & (1 << 14)) ? " ERR_IRQ"     : "",
			(x & (1 << 13)) ? " DlyCnt_IRQ"  : "",
			(x & (1 << 12)) ? " FrmCnt_IRQ"  : "",
			(x & (1 << 11)) ? " SOFLateErr"  : "",
			(x & (1 <<  8)) ? " EOLEarlyErr" : "",
			(x & (1 <<  7)) ? " SOFEarlyErr" : "",
			(x & (1 <<  6)) ? " VDMADecErr"  : "",
			(x & (1 <<  5)) ? " VDMASlvErr"  : "",
			(x & (1 <<  4)) ? " VDMAIntErr"  : "",
			(x & (1 <<  0)) ? " Halted"      : ""
	      );
}

static int
vdma_init(struct rpi_cam *cam)
{
	int retry = 100;

	/* Check version */
	if (reg_read(cam->vdma, 0x2C) != 0x62000050) {
		fprintf(stderr, "[!] Invalid VDMA version\n");
		return -ENODEV;
	}

	/* Perform a soft reset & clear all status */
	reg_write(cam->vdma, 0x30, 4);

	while (retry-- && reg_read(cam->vdma, 0x30) & 4)
		usleep(1000);

	if (retry <= 0) {
		fprintf(stderr, "[!] DMA reset timeout\n");
		return -ETIMEDOUT;
	}

	reg_write(cam->vdma, 0x34, 0x5990);

	/* Configure the frame buffer addresses (all the same ATM) */
	reg_write(cam->vdma, 0xAC, FB_BASE);
	reg_write(cam->vdma, 0xB0, FB_BASE);
	reg_write(cam->vdma, 0xB4, FB_BASE);
	reg_write(cam->vdma, 0xB8, FB_BASE);

	/* Setup run mode */
	reg_write(cam->vdma, 0x30, 0x0000000B);		/* RS=1 */

	/* Setup image dimensions */
	reg_write(cam->vdma, 0xA8, cam->w_vpipe_bytes);	/* Stride */
	reg_write(cam->vdma, 0xA4, cam->w_vpipe_bytes);	/* H size */
	reg_write(cam->vdma, 0xA0, cam->h_vpipe_px);	/* V size */
		/* The V size write will trigger the 'GO' */

	return 0;
}

static int
vdma_stop(struct rpi_cam *cam)
{
	/* Stop */
	reg_write(cam->vdma, 0x30, 0x00000000);

	return 0;
}

static void
vdma_fb_offset(struct rpi_cam *cam, uint32_t offset)
{
	/* Setup all new offsets */
	reg_write(cam->vdma, 0xAC, FB_BASE + offset);
	reg_write(cam->vdma, 0xB0, FB_BASE + offset);
	reg_write(cam->vdma, 0xB4, FB_BASE + offset);
	reg_write(cam->vdma, 0xB8, FB_BASE + offset);

	/* Rewrite VSIZE to latch new value */
	reg_write(cam->vdma, 0xA0, reg_read(cam->vdma, 0xA0));
}

static int
vdma_wait_one(struct rpi_cam *cam)
{
	int retry = 100;

	/* Clear current status */
	reg_write(cam->vdma, 0x34, 0x1000);

	/* Wait for next */
	while (retry-- && !(reg_read(cam->vdma, 0x34) & 0x1000))
		usleep(1000);

	if (retry <= 0) {
		fprintf(stderr, "[!] Timeout waiting for frame\n");
		return -ETIMEDOUT;
	}

	return 0;
}


/* ------------------------------------------------------------------------ */
/* Sensor                                                                   */
/* ------------------------------------------------------------------------ */

struct sensor_cmd {
	uint16_t reg;
	uint8_t val;
};

#include "sensor_config.h"

static uint8_t
sensor_reg_read(struct rpi_cam *cam, uint16_t reg)
{
	struct i2c_rdwr_ioctl_data args;
	struct i2c_msg msgs[2];
	char data[3];

	data[0] = (reg >> 8) & 0xff;
	data[1] =  reg       & 0xff;

	msgs[0].addr  = I2C_ADDR;
	msgs[0].flags = 0;
	msgs[0].len   = 2;
	msgs[0].buf   = data;

	msgs[1].addr  = I2C_ADDR;
	msgs[1].flags = I2C_M_RD;
	msgs[1].len   = 1;
	msgs[1].buf   = data + 2;

	args.msgs  = msgs;
	args.nmsgs = 2;

	ioctl(cam->i2c_sensor, I2C_RDWR, &args);

	return data[2];
}

static void
sensor_reg_write(struct rpi_cam *cam, uint16_t reg, uint8_t val)
{
	struct i2c_rdwr_ioctl_data args;
	struct i2c_msg msg;;
	char data[3];

	data[0] = (reg >> 8) & 0xff;
	data[1] =  reg       & 0xff;
	data[2] = val;

	msg.addr  = I2C_ADDR;
	msg.flags = 0;
	msg.len   = 3;
	msg.buf   = data;

	args.msgs  = &msg;
	args.nmsgs = 1;

	ioctl(cam->i2c_sensor, I2C_RDWR, &args);
}

static void
sensor_reg_write_set(struct rpi_cam *cam, struct sensor_cmd *set)
{
	int i;

	for (i=0; set[i].reg != 0; i++)
		sensor_reg_write(cam,
			set[i].reg,
			set[i].val
		);
}

static int
sensor_boot(struct rpi_cam *cam)
{
	/* Check sensor */
	if ((sensor_reg_read(cam, 0x300A) != 0x56) ||
	    (sensor_reg_read(cam, 0x300B) != 0x47))
	{
		fprintf(stderr, "[!] Unable to find sensor\n");
		return -ENODEV;
	}

	/* Disable */
	sensor_reg_write(cam, 0x0100, 0x00);

	/* Execute RESET */
	sensor_reg_write(cam, 0x0103, 0x01);
	usleep(10 * 1000);

	/* Load configuration */
	sensor_reg_write_set(cam, sensor_common);

	if ((cam->w_sensor_px == 2592) && (cam->h_sensor_px == 1944))
		sensor_reg_write_set(cam, sensor_2592_1944_15);
	else if ((cam->w_sensor_px == 1936) && (cam->h_sensor_px == 1088))
		sensor_reg_write_set(cam, sensor_1936_1088_30);
	else if ((cam->w_sensor_px == 1296) && (cam->h_sensor_px == 968))
		sensor_reg_write_set(cam, sensor_1296_968_30);
	else {
		fprintf(stderr, "[!] No sensor config available for selected resolution\n");
		return -ENOTSUP;
	}


	return 0;
}

static int
sensor_start(struct rpi_cam *cam)
{
	/* Enable */
	sensor_reg_write(cam, 0x0100, 0x01);

	return 0;
}

static int
sensor_stop(struct rpi_cam *cam)
{
	/* Disable */
	sensor_reg_write(cam, 0x0100, 0x00);

	return 0;
}


/* ------------------------------------------------------------------------ */
/* Camera                                                                   */
/* ------------------------------------------------------------------------ */

static int
_rpi_cam_refresh(struct rpi_cam *cam)
{
	/* Refresh derived params */
	cam->w_vpipe_bytes = pix_fmt_bytes_per_line(cam->pix_fmt, cam->w_vpipe_px);

	cam->fb_len = (cam->w_vpipe_bytes * cam->h_vpipe_px + 4095) & ~4095;

	/* Check */
	if (cam->w_vpipe_bytes & 7)
	{
		fprintf(stderr, "[!] Frame line size in bytes is not multiple of 64 bits !\n");
		return -EINVAL;
	}

	if ((2 * cam->fb_len) > FB_LEN)
	{
		fprintf(stderr, "[!] Frame buffer too small !\n");
		return -ENOMEM;
	}

	if (cam->pix_fmt->mode == PFM_RAW) {
		if ((cam->w_sensor_px != cam->w_vpipe_px) ||
		    (cam->h_sensor_px != cam->h_vpipe_px))
		{
			fprintf(stderr, "[!] Cropping not supported in RAW mode\n");
			return -ENOTSUP;
		}
	} else {
		int min = cam->pix_fmt->mode == PFM_DEBAYER ? 2 : 0;

		if ((cam->w_sensor_px - cam->w_vpipe_px < min) ||
		    (cam->h_sensor_px - cam->h_vpipe_px < min))
		{
			fprintf(stderr, "[!] Cropping size too small\n");
			return -EINVAL;
		}
	}

	return 0;
}

static struct rpi_cam *
rpi_cam_init(void)
{
	struct rpi_cam *cam;
	int rv;

	cam = calloc(1, sizeof(struct rpi_cam));
	if (!cam)
		return NULL;

	cam->i2c_sensor = -1;
	cam->fd_mem = -1;

	/* Default configuration */
	cam->pix_fmt = &pix_fmts[0];

	cam->w_sensor_px = 2592;
	cam->h_sensor_px = 1944;

	cam->w_vpipe_px = 2592;
	cam->h_vpipe_px = 1944;

	if (_rpi_cam_refresh(cam))
		goto error;

	/* Open GPIO */
	rv = para_initgpio(&cam->gpio_enable, 74);
	if (rv)
		goto error;

	rv = para_initgpio(&cam->gpio_led, 76);
	if (rv)
		goto error;

	/* Configure GPIO */
	para_setgpio(cam->gpio_enable, 0);
	para_dirgpio(cam->gpio_enable, para_dirout);

	para_setgpio(cam->gpio_led, 0);
	para_dirgpio(cam->gpio_led, para_dirout);

	/* Open I2C sensor */
	cam->i2c_sensor = open("/dev/i2c-1", O_RDWR);
	if (cam->i2c_sensor < 0)
		goto error;

	/* Configure target I2C address */
	rv = ioctl(cam->i2c_sensor, I2C_SLAVE, I2C_ADDR);
	if (rv < 0)
		goto error;

	/* Open /dev/mem */
	cam->fd_mem = open("/dev/mem", O_RDWR);
	if (cam->fd_mem < 0)
		goto error;

	/* Map frame buffer */
	cam->fb = mmap(NULL, FB_LEN, PROT_READ | PROT_WRITE, MAP_SHARED, cam->fd_mem, FB_BASE);
	if (!cam->fb)
		goto error;

	/* Map VDMA control */
	cam->vdma = mmap(NULL, VDMA_LEN, PROT_READ | PROT_WRITE, MAP_SHARED, cam->fd_mem, VDMA_BASE);
	if (!cam->vdma)
		goto error;

	/* Map MIPI CSI control */
	cam->csi = mmap(NULL, CSI_LEN, PROT_READ | PROT_WRITE, MAP_SHARED, cam->fd_mem, CSI_BASE);
	if (!cam->csi)
		goto error;

	return cam;

error:
	rpi_cam_release(cam);
	return NULL;
}

static void
rpi_cam_release(struct rpi_cam *cam)
{
	/* Unmap the memory zones */
	if (cam->csi)
		munmap(cam->csi, CSI_LEN);

	if (cam->vdma)
		munmap(cam->vdma, VDMA_LEN);

	if (cam->fb)
		munmap(cam->fb, FB_LEN);

	/* Release /dev/mem */
	if (cam->fd_mem >= 0)
		close(cam->fd_mem);

	/* Release I2C sensor */
	if (cam->i2c_sensor >= 0)
		close(cam->i2c_sensor);

	/* Release GPIOs */
	para_closegpio(cam->gpio_led);
	para_closegpio(cam->gpio_enable);
}

static int
rpi_cam_set_pix_fmt(struct rpi_cam *cam, const struct pix_fmt_desc *pf)
{
	cam->pix_fmt = pf;
	return 0;
}

static int
rpi_cam_set_sensor_config(struct rpi_cam *cam, int w, int h)
{
	uint32_t fmt;

	if ((w < 0) || (w > 65535) || (h < 0) || (h > 65535))
		fmt = 0;
	else
		fmt = ((w & 0xffff) << 16) | (h & 0xffff);

	switch (fmt)
	{
	case 0x0a200798: /* 2592 * 1944 */
	case 0x07900440: /* 1936 * 1088 */
	case 0x051003c8: /* 1296 *  968 */
		break;

	default:
		fprintf(stderr, "[!] Unsupported sensor resolution\n");
		return -ENOTSUP;
	}

	cam->w_sensor_px = w;
	cam->h_sensor_px = h;

	return 0;
}

static int
rpi_cam_set_output_config(struct rpi_cam *cam, int w, int h)
{
	if ((w < 0) || (w > 4095) || (h < 0) || (h > 4095)) {
		fprintf(stderr, "[!] Invalid video pipe resolution\n");
		return -EINVAL;
	}

	cam->w_vpipe_px = w;
	cam->h_vpipe_px = h;

	return 0;
}

static int
rpi_cam_start(struct rpi_cam *cam)
{
	int rv;

	/* Refresh state */
	rv = _rpi_cam_refresh(cam);
	if (rv)
		return rv;

	/* Enable power */
	para_setgpio(cam->gpio_enable, 1);

	/* Wait for startup */
	usleep(100 * 1000);

	/* Reset CSI core */
	csi_reset(cam);

	/* Start CSI core */
	csi_start(cam);

	/* Boot sensor */
	sensor_boot(cam);

	/* Start DMA */
	vdma_init(cam);

	/* Start sensor */
	sensor_start(cam);

	/* Turn on the LED */
	para_setgpio(cam->gpio_led, 1);

	return 0;
}

static int
rpi_cam_stop(struct rpi_cam *cam)
{
	/* Disable sensor */
	sensor_stop(cam);

	/* Disable CSI core */
	csi_stop(cam);

	/* Stop DMA */
	vdma_stop(cam);

	/* Turn off LED & Power */
	para_setgpio(cam->gpio_enable, 0);
	para_setgpio(cam->gpio_led, 0);

	return 0;
}

static void *
rpi_cam_framebuf_get(struct rpi_cam *cam, int front_back)
{
	return cam->fb + (((cam->fb_cur ^ front_back) & 1) * cam->fb_len);
}

static void
rpi_cam_framebuf_swap(struct rpi_cam *cam)
{
	cam->fb_cur ^= 1;
	vdma_fb_offset(cam, cam->fb_cur * cam->fb_len);
}


/* ------------------------------------------------------------------------ */
/* Main                                                                     */
/* ------------------------------------------------------------------------ */

/* Optimized write from shared mem ---------------------------------------- */

#define FW_LBUF_SIZE	8192

#ifdef USE_WRITE_OPT

static void
write_opt(int fd, void *data, int n)
{
	static void *lbuf = NULL;

	if ( (((uintptr_t)data) & 0x3f) || (n & 0x3f) )
		abort();

	if (!lbuf)
	{
		if (posix_memalign(&lbuf, 64, FW_LBUF_SIZE))
			abort();
	}

	while (n)
	{
		int bl = (n > FW_LBUF_SIZE) ? FW_LBUF_SIZE : n;

		asm volatile (
			"mov	r4, %[bl]		\n"
			"mov	r5, %[data]		\n"
			"mov	r6, %[lbuf]		\n"
			"1:				\n"
			"subs	r4, r4, #64		\n"
			"vldm	r5!, {q0-q3}		\n"
			"vstm	r6!, {q0-q3}		\n"
			"bgt	1b			\n"
			:
			: [data]"r"(data), [bl]"r"(bl), [lbuf]"r"(lbuf)
			: "r4", "r5", "r6", "q0", "q1", "q2", "q3"
		);

		n -= bl;
		data += bl;

		write(fd, lbuf, bl);
	}
}

#else

static void
write_opt(int fd, void *data, int n)
{
	write(fd, data, n);
}

#endif


/* Signal handling -------------------------------------------------------- */

static volatile sig_atomic_t g_active = 1;

static void
_signal_done(int dummy)
{
	g_active = 0;
}


/* Option parsing --------------------------------------------------------- */

struct options
{
	int w_sensor_px;
	int h_sensor_px;
	int w_output_px;
	int h_output_px;
	const struct pix_fmt_desc *pf;
	const char *filename;
	const char *hostname;
	const char *portname;
	int count;
	int benchmark;
};

static const char *short_options = "s:o:p:f:n:bh";
static struct option long_options[] = {
	{ "sensor-resolution",	required_argument, 0, 's' },
	{ "output-resolution",	required_argument, 0, 'o' },
	{ "pixel-format",	required_argument, 0, 'p' },
	{ "filename",		required_argument, 0, 'f' },
	{ "network",		required_argument, 0, 'n' },
	{ "count",		required_argument, 0, 'c' },
	{ "benchmark",		no_argument,       0, 'b' },
	{ "help",		no_argument,       0, 'h' },
	{ }
};

static void
options_help(const char *argv0)
{
	fprintf(stderr, "Usage: %s [options]\n", argv0);
	fprintf(stderr, "\n");
	fprintf(stderr, "RPi camera on parallella control software\n");
	fprintf(stderr, "(C) 2015 Sylvain Munaut\n");
	fprintf(stderr, "\n");
	fprintf(stderr, " -h, --help                   Prints this help text\n");
	fprintf(stderr, " -s, --sensor-resolution NxM  Sets sensor resolution\n");
	fprintf(stderr, " -o, --output-resolution NxM  Crops output to resolution\n");
	fprintf(stderr, " -p, --pixel-format FMT       Selects pixel format\n");
	fprintf(stderr, " -f, --filename FILENAME      Records data to file\n");
	fprintf(stderr, " -n, --network HOST:PORT      Sends data to TCP\n");
	fprintf(stderr, " -c, --count COUNT            Only records COUNT frames\n");
	fprintf(stderr, " -b, --bencmark               Benchmark mode, no data write\n");
	fprintf(stderr, "\n");
	fprintf(stderr, "Available pixel formats\n");
	fprintf(stderr, " sbggr10p - RAW CSI-10b packed pixels\n");
	fprintf(stderr, " sbggr10  - Unpacked bayer 10 bits per 16 bits, LSB aligned\n");
	fprintf(stderr, " sbggr8   - Unpacked bayer  8 bits\n");
	fprintf(stderr, " rgbz32   - Red Green Blue Zero per 32 bits word\n");
	fprintf(stderr, " bgrz32   - Blue Green Red Zero per 32 bits word\n");
	fprintf(stderr, " gray8    - Only intensity\n");
	fprintf(stderr, " red8     - Only red values\n");
	fprintf(stderr, " green8   - Only green values\n");
	fprintf(stderr, " blue8    - Only blue values\n");
	fprintf(stderr, "\n");
}

static int
options_parse_resolution(const char *str, int *w, int *h)
{
	int rv;

	rv = sscanf(str, "%dx%d", w, h);
	if (rv != 2)
		return -1;

	if ((*w < 0) || (*h < 0))
		return -1;

	return 0;
}

static int
options_parse(struct options *opts, int argc, char *argv[])
{
	char *sep;

	/* Default options */
	memset(opts, 0x00, sizeof(struct options));

	opts->w_output_px = 1280;
	opts->h_output_px =  960;
	opts->pf = pix_fmt_find("rgbz32");

	/* Parse */
	while (1) {
		int c, oidx;

		c = getopt_long(argc, argv, short_options, long_options, &oidx);
		if (c == -1)
			break;

		switch (c) {
		case 's':
			if (options_parse_resolution(optarg, &opts->w_sensor_px, &opts->h_sensor_px)) {
				fprintf(stderr, "[!] Unable to parse resolution '%s'\n", optarg);
				return -1;
			}
			break;

		case 'o':
			if (options_parse_resolution(optarg, &opts->w_output_px, &opts->h_output_px)) {
				fprintf(stderr, "[!] Unable to parse resolution '%s'\n", optarg);
				return -1;
			}
			break;

		case 'p':
			opts->pf = pix_fmt_find(optarg);
			if (!opts->pf) {
				fprintf(stderr, "[!] Invalid pixel format\n");
				return -1;
			}
			break;

		case 'f':
			opts->filename = optarg;
			break;

		case 'n':
			sep = strchr(optarg, ':');
			if (!sep) {
				fprintf(stderr, "[!] Invalid address\n");
				return -1;
			}
			*sep = '\0';
			opts->hostname = optarg;
			opts->portname = sep + 1;
			break;

		case 'c':
			opts->count = atoi(optarg);
			break;

		case 'b':
			opts->benchmark = 1;
			break;

		case 'h':
			return 1;

		default:
			fprintf(stderr, "[!] Bad option value %d\n", c);
		}
	}

	/* If no sensor resolution was picked, choose one */
	if (!opts->w_sensor_px || !opts->h_sensor_px)
	{
		if ((opts->w_output_px <= 1280) && (opts->h_output_px <= 960)) {
			opts->w_sensor_px = 1296;
			opts->h_sensor_px =  968;
		} else if ((opts->w_output_px <= 1920) && (opts->h_output_px <= 1080)) {
			opts->w_sensor_px = 1936;
			opts->h_sensor_px = 1088;
		} else if ((opts->w_output_px <= 2592) && (opts->h_output_px <= 1944)) {
			opts->w_sensor_px = 2592;
			opts->h_sensor_px = 1944;
		} else {
			fprintf(stderr, "[!] Unable to find suitable sensor resolution\n");
			return -1;
		}
	}

	return 0;
}


/* Main ------------------------------------------------------------------- */

int main(int argc, char *argv[])
{
#ifdef DEBUG
	struct timeval tv_s, tv_e;
#endif
	struct options _opts, *opts = &_opts;
	struct rpi_cam *cam;
	int rv, fd;

	/* Catch CTRL-C and PIPE errors */
	signal(SIGINT,  _signal_done);
	signal(SIGPIPE, _signal_done);

	/* Parse options */
	rv = options_parse(opts, argc, argv);
	if (rv == 1) {
		options_help(argv[0]);
		return 0;
	} else if (rv < 0)
		return rv;

	/* Print status */
	fprintf(stderr, "[+] Sensor resolution : %dx%d\n",
		opts->w_sensor_px, opts->h_sensor_px);
	fprintf(stderr, "[+] Output resolution : %dx%d\n",
		opts->w_output_px, opts->h_output_px);
	fprintf(stderr, "[+] Output format     : %s\n",
		opts->pf->name);

	/* Open output file */
	if (opts->benchmark)
	{
		fd = -1;
	}
	else if (opts->filename)
	{
		fd = open(opts->filename, O_WRONLY | O_CREAT | O_TRUNC, 0644);
		if (fd < 0) {
			fprintf(stderr, "[!] Unable to open output file\n");
			return -1;
		}
	}
	else if (opts->hostname)
	{
		struct addrinfo hints, *res;

		memset(&hints, 0, sizeof (hints));
		hints.ai_family = PF_UNSPEC;
		hints.ai_socktype = SOCK_STREAM;
		hints.ai_flags |= AI_CANONNAME;

		rv = getaddrinfo (opts->hostname, opts->portname, &hints, &res);
		if (rv < 0) {
			fprintf(stderr, "[!] Unable to resolve name: %s\n", gai_strerror(rv));
			return -1;
		}

		fd = socket(AF_INET, SOCK_STREAM, 0);
		if ( connect(fd, res->ai_addr, res->ai_addrlen) ) {
			perror("[!] Unable to connect");
			return -1;
		}
	}
	else
	{
		fd = STDOUT_FILENO ;
	}

	/* Init camera */
	cam = rpi_cam_init();
	if (!cam) {
		fprintf(stderr, "[!] Failed to open camera\n");
		return -1;
	}

	rpi_cam_set_pix_fmt(cam, opts->pf);
	rpi_cam_set_sensor_config(cam, opts->w_sensor_px, opts->h_sensor_px);
	rpi_cam_set_output_config(cam, opts->w_output_px, opts->h_output_px);

	/* Start */
	rv = rpi_cam_start(cam);
	if (rv) {
		fprintf(stderr, "[!] Failed to start camera\n");
		goto err;
	}

	/* Wait at least 500 ms to auto-exposure to do its job */
	usleep(500 * 1000);

	/* Start time */
#ifdef DEBUG
	gettimeofday(&tv_s, NULL);
#endif

	/* Main loop */
	while (g_active)
	{
		/* Switch buffer */
		rpi_cam_framebuf_swap(cam);

		/* Wait for a frame */
		rv = vdma_wait_one(cam);
		if (rv)
			break;

		/* Debug output */
#ifdef DEBUG
		gettimeofday(&tv_e, NULL);

		fprintf(stderr, "Frame @ %ld  us (remaining %d)\n",
			(tv_e.tv_sec - tv_s.tv_sec) * 1000000 + (tv_e.tv_usec - tv_s.tv_usec),
			opts->count
		);

		vdma_debug(cam);
		csi_debug(cam);
#endif

		/* Write out */
		if (fd > 0) {
			write_opt(fd,
				rpi_cam_framebuf_get(cam, 1),
				cam->w_vpipe_bytes * cam->h_vpipe_px
			);
		}

		/* End ? */
		if (opts->count && (--opts->count == 0))
			break;
	}

err:
	/* Stop */
	rpi_cam_stop(cam);

	/* Release camera */
	rpi_cam_release(cam);

	/* Close output file */
	if (fd >= 0)
		close(fd);

	/* Done */
	return 0;
}
