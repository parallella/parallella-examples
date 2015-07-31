/*
 *
 */

#include <errno.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>



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
	int w_bytes;
	int w_px;
	int h_px;
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

struct pix_fmt_desc
{
	const char *name;
	uint32_t vpcr;
	int size_num;
	int size_denom;
};

static const struct pix_fmt_desc pix_fmts[] = {
	{ "sbggr10p",	0x000000, 5, 4 },	/* x xx xxxxxxxx 00 00 */
	{ "sbggr10",	0xa00022, 2, 1 },	/* 1 10 xxxxxxxx 10 10 */
	{ "sbggr8",	0x800023, 1, 1 },	/* 1 00 xxxxxxxx 10 11 */
	{ "rgbz32",	0x803930, 4, 1 },	/* 1 xx 00111001 11 00 */
	{ "bgrz32",	0x801b30, 4, 1 },	/* 1 xx 00011011 11 00 */
	{ "gray8",	0x800233, 1, 1 },	/* 1 xx xxxxxx10 11 11 */
	{ "red8",	0x800133, 1, 1 },	/* 1 xx xxxxxx01 11 11 */
	{ "green8",	0x800233, 1, 1 },	/* 1 xx xxxxxx10 11 11 */
	{ "blue8",	0x800333, 1, 1 },	/* 1 xx xxxxxx11 11 11 */
	{ NULL, 0, 0, 0 } /* Guard */
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
	printf("CSI SR: %08x [ %s%s%s%s%s]\n", x,
		(x & (1 << 31)) ? "PP_FIFO_empty ": "",
		(x & (1 << 30)) ? "Pkt_FIFO_empty " : "",
		(x & (1 << 17)) ? "PP_error_pending " : "",
		(x & (1 << 16)) ? "PP_running " : "",
		(x & (1 <<  0)) ? "PHY_running " : ""
	);

	x = reg_read(cam->csi, 0x08);
	printf("CSI ER: %08x [ %s%s%s%s%s%s%s%s%s]\n", x,
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
	printf("SR: %08x [%s%s%s%s%s%s%s%s%s%s%s ]\n",
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
	reg_write(cam->vdma, 0xA8, cam->w_bytes);	/* Stride */
	reg_write(cam->vdma, 0xA4, cam->w_bytes);	/* H size */
	reg_write(cam->vdma, 0xA0, cam->h_px);		/* V size */
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

static int
sensor_boot(struct rpi_cam *cam)
{
	int i;

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
	for (i=0; sensor_boot_seq[i].reg != 0; i++)
		sensor_reg_write(cam,
			sensor_boot_seq[i].reg,
			sensor_boot_seq[i].val
		);

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

static struct rpi_cam *
rpi_cam_init(const struct pix_fmt_desc *pf)
{
	struct rpi_cam *cam;
	int rv;

	cam = calloc(1, sizeof(struct rpi_cam));
	if (!cam)
		return NULL;

	cam->i2c_sensor = -1;
	cam->fd_mem = -1;

	/* Format */
	cam->pix_fmt = pf;
	cam->w_px = 1296;
	cam->h_px =  972;
	cam->w_bytes = pix_fmt_bytes_per_line(pf, cam->w_px);

	/* Check */
	if (cam->w_bytes & 7)
	{
		fprintf(stderr, "[!] Frame line size in bytes is not multiple of 64 bits !\n");
		goto error;
	}

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
rpi_cam_start(struct rpi_cam *cam)
{
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


/* ------------------------------------------------------------------------ */
/* Main                                                                     */
/* ------------------------------------------------------------------------ */

#define FW_LBUF_SIZE	8192

static void
fast_write(int fd, void *data, int n)
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

#if 0
		memcpy(lbuf, data, bl);
#else
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
#endif

		n -= bl;
		data += bl;

		write(fd, lbuf, bl);
	}

}


static int g_active = 1;

static void
_signal_sigint(int dummy)
{
	g_active = 0;
}

int main(int argc, char *argv[])
{
	const struct pix_fmt_desc *pf;
	struct rpi_cam *cam;
	int rv, fd, N, b = 0;

	/* Catch CTRL-C */
	signal(SIGINT, _signal_sigint);

	/* Pixel format */
	pf = pix_fmt_find(argc > 1 ? argv[1] : "rgbz32");
	if (!pf) {
		fprintf(stderr, "Invalid pixel format\n");
		return -1;
	}
	fprintf(stderr, "Selected pixel format: %s\n", pf->name);

	/* Open output file */
	if (argc > 2) {
		fd = open(argv[2], O_WRONLY | O_CREAT | O_TRUNC, 0644);
		if (fd < 0) {
			fprintf(stderr, "[!] Unable to open output file\n");
			return -1;
		}
	} else
		fd = -1;

	/* How many frames to grab ? */
	N = (argc > 3) ? atoi(argv[3]) : 1;

	/* Init camera */
	cam = rpi_cam_init(pf);
	if (!cam) {
		fprintf(stderr, "[!] Failed to open camera\n");
		return -1;
	}

	/* Start */
	rv = rpi_cam_start(cam);
	if (rv) {
		fprintf(stderr, "[!] Failed to start camera\n");
		goto err;
	}

	/* Wait at least 500 ms to auto-exposure to do its job */
	usleep(500 * 1000);

	/* Main loop */
	while (g_active)
	{
		/* Switch buffer */
		b ^= 1;
		vdma_fb_offset(cam, b * (6 * 1024 * 1024));

		/* Wait for a frame */
		rv = vdma_wait_one(cam);
		if (rv)
			break;

		/* Write out */
#if 0
		write(fd, cam->fb + (b ^ 1) * (6 * 1024 * 1024), cam->w_bytes * cam->h_px);
#else
		fast_write(fd, cam->fb + (b ^ 1) * (6 * 1024 * 1024), cam->w_bytes * cam->h_px);
#endif

		fprintf(stderr, "Frame ! [ %d ]\n", N);

#if 0
		vdma_debug(cam);
		csi_debug(cam);
#endif

		/* End ? */
		if (N && (--N == 0))
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
