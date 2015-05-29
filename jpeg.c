#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <fcntl.h>
#include <math.h>

#include <jpeglib.h>

/* Convert to grayscale float
 *
 * Assumes 8-bit grayscale input data
 *
 * @return TRUE on success. FALSE on failure.
 */
static inline bool to_float(struct jpeg_decompress_struct *cinfo,
			    uint8_t **bufs, size_t nbufs, float *bitmap,
			    size_t line)
{
	const float factor = 1.0f/255.0f;
	float *out;
	size_t i, j;

	/* Only support 8-bit grayscale for now */
	if (cinfo->data_precision != 8 || cinfo->output_components != 1) {
		fprintf(stderr, "%s:%s: Unsupported color format\n",
				__FILE__, __func__);
		return false;
	}

	/* Advance bitmap */
	out = bitmap + line * cinfo->output_width;

	for (i = 0; i < nbufs; i++) {
		for (j = 0; j < cinfo->output_width; j++)
			*out++ = ((float) bufs[i][j]) * factor;
	}
	return true;
}

/* Convert to grayscale 8-bit integer
 *
 * Assumes 8-bit grayscale input data
 *
 * @return TRUE on success. FALSE on failure.
 */
static inline bool to_int(struct jpeg_decompress_struct *cinfo,
			    uint8_t **bufs, size_t nbufs, uint8_t *bitmap,
			    size_t line)
{
	uint8_t *out;
	size_t i;

	/* Only support 8-bit grayscale for now */
	if (cinfo->data_precision != 8 || cinfo->output_components != 1) {
		fprintf(stderr, "%s:%s: Unsupported color format\n",
				__FILE__, __func__);
		return false;
	}

	/* Advance bitmap */
	out = bitmap + line * cinfo->output_width;

	for (i = 0; i < nbufs; i++) {
		memcpy(out, bufs[i], cinfo->output_width * sizeof(uint8_t));
		out += cinfo->output_width;
	}
	return true;
}

static inline float in_range(const float min, const float max, const float val)
{
	if (val < min)
		return min;
	if (val > max)
		return max;

	return val;
}

/* Convert from grayscale float
 *
 * Assumes 8-bit grayscale output data
 *
 * @return TRUE on success. FALSE on failure.
 */
static inline bool from_float(struct jpeg_compress_struct *cinfo,
			      uint8_t **bufs, size_t nbufs, float *bitmap,
			      size_t line)
{
	const float factor = 255.0f;
	float *in;
	size_t i, j;

	/* Only support 8-bit grayscale for now */
	if (cinfo->data_precision != 8 || cinfo->input_components != 1) {
		fprintf(stderr, "%s:%s: Unsupported color format\n",
				__FILE__, __func__);
		return false;
	}

	/* Advance bitmap */
	in = bitmap + line * cinfo->image_width;

	for (i = 0; i < nbufs; i++) {
		for (j = 0; j < cinfo->image_width; j++) {
			bufs[i][j] = (uint8_t)
				roundf(factor * in_range(0.0f, 1.0f, *in++));
		}
	}
	return true;
}

/* Decompress jpeg to raw float grayscale
 *
 * @fp  True if image should be converted to floating point
 *
 * @return pointer to data. Caller need to free data.
 */
void *jpeg_to_grayscale_(void *jpeg, size_t jpeg_size, int *width, int *height, bool fp)
{
	int ret, denom, line = 0;
	void *bitmap;
	uint8_t *buf, *bufs[1];
	bool decompress_fail = false;

	struct jpeg_decompress_struct cinfo;
	struct jpeg_error_mgr jerr;

	cinfo.err = jpeg_std_error(&jerr);
	jpeg_create_decompress(&cinfo);

	jpeg_mem_src(&cinfo, jpeg, jpeg_size);

	ret = jpeg_read_header(&cinfo, TRUE);
	if (ret != JPEG_HEADER_OK) {
		fprintf(stderr, "%s:%s: Not a JPEG\n", __FILE__, __func__);
		return NULL;
	}

	cinfo.out_color_space = JCS_GRAYSCALE;

	/* HACK: Scale image to max 64x64 (so it fits in Epiphany mem incl.
	 * zero padding...) */
	for (denom = 1;
	     cinfo.image_width / denom > 64 || cinfo.image_height / denom > 64;
	     denom *= 2)
		;
	cinfo.scale_num = 1;
	cinfo.scale_denom = denom;

	if (!jpeg_start_decompress(&cinfo)) {
		fprintf(stderr, "%s:%s: jpeg_start_decompress() failed\n",
			__FILE__, __func__);
		return NULL;
	}

	*width = cinfo.output_width;
	*height = cinfo.output_height;

	bitmap = calloc((*width) * (*height), fp ? sizeof(float) : sizeof(uint8_t));

	buf = calloc(*width, sizeof(uint8_t));
	bufs[0] = buf;

	while (cinfo.output_scanline < cinfo.output_height) {
		uint8_t *ptr = (uint8_t *) bitmap;

		/* We're only reading one scanline at a time so this should
		 * always be true */
		if (jpeg_read_scanlines(&cinfo, bufs, 1) != 1) {
			fprintf(stderr, "%s:%s: jpeg_read_scanlines() failed\n",
				__FILE__, __func__);
			decompress_fail = true;
			break;
		}

		if (fp) {
			if (!to_float(&cinfo, bufs, 1, bitmap, line)) {
				decompress_fail = true;
				break;
			}
		} else {
			if (!to_int(&cinfo, bufs, 1, bitmap, line)) {
				decompress_fail = true;
				break;
			}
		}
		line++;
	}

	jpeg_finish_decompress(&cinfo);

	jpeg_destroy_decompress(&cinfo);

	free(buf);

	if (decompress_fail) {
		free(bitmap);
		bitmap = NULL;
	}

	return bitmap;
}

float *jpeg_to_grayscale(void *jpeg, size_t jpeg_size, int *width, int *height)
{
	return jpeg_to_grayscale_(jpeg, jpeg_size, width, height, true);
}

uint8_t *jpeg_to_grayscale_int(void *jpeg, size_t jpeg_size, int *width, int *height)
{
	return jpeg_to_grayscale_(jpeg, jpeg_size, width, height, false);
}


/* In-memory conversion from float grayscale bitmap to grayscale JPEG
 *
 * @return pointer to JPEG data. Caller need to free data.
 */
void *grayscale_to_jpeg(float *bitmap, int width, int height,
			unsigned long *jpeg_size)
{
	uint8_t *buf, *bufs[1];
	uint8_t *jpeg;
	int line;
	bool convert_fail = false;

	struct jpeg_compress_struct cinfo;
	struct jpeg_error_mgr jerr;


	cinfo.err = jpeg_std_error(&jerr);
	jpeg_create_compress(&cinfo);

	jpeg_mem_dest(&cinfo, &jpeg, jpeg_size);

	cinfo.image_width = width;
	cinfo.image_height = height;
	cinfo.input_components = 1;
	cinfo.in_color_space = JCS_GRAYSCALE;

	jpeg_set_defaults(&cinfo);

	jpeg_start_compress(&cinfo, TRUE);

	buf = calloc(width, sizeof(uint8_t));
	for (line = 0; line < height; line++) {
		bufs[0] = buf;
		if (!from_float(&cinfo, bufs, 1, bitmap, line)) {
			convert_fail = true;
			break;
		}
		jpeg_write_scanlines(&cinfo, bufs, 1);
	}

	jpeg_finish_compress(&cinfo);
	jpeg_destroy_compress(&cinfo);

	free(buf);

	if (convert_fail) {
		free(jpeg);
		jpeg = NULL;
	}

	return jpeg;
}

/* Convert float bitmap to JPEG file
 *
 * @return True on success, False on failure
 */
bool grayscale_to_jpeg_file(float *bitmap, int width, int height, char *path)
{
	int fd;
	size_t i;
	ssize_t count;
	uint8_t *jpeg = NULL;
	unsigned long jpeg_size = 0;
	bool ret = true;

	jpeg = grayscale_to_jpeg(bitmap, width, height, &jpeg_size);
	if (!jpeg)
		return false;

	fd = open(path, O_WRONLY| O_CREAT, 0644);
	if (fd < 0) {
		fprintf(stderr, "%s: open: %s\n", path, strerror(errno));
		ret = false;
		goto out;
	}

	for (i = 0, count = 0; i < jpeg_size; i += count) {
		count = write(fd, &jpeg[i], jpeg_size - i);
		if (count < 0) {
			fprintf(stderr, "%s: write: %s\n",
				path, strerror(errno));
			ret = false;
			goto out;
		}
	}

out:
	free(jpeg);
	close(fd);
	return ret;
}

/* Decompress JPEG file to float bitmap
 *
 * @ fp True if output should be float. False and output will be uint8
 *
 * @return pointer to data. Caller need to free data.
 */
void *jpeg_file_to_grayscale_(char *path, int *width, int *height, float fp)
{
	int ret, fd;
	uint8_t *jpeg;
	size_t jpeg_size;
	struct stat file_stat;
	size_t i;
	ssize_t count;
	void *bitmap = NULL;

	ret = stat(path, &file_stat);
	if (ret) {
		fprintf(stderr, "%s: stat: %s\n", path, strerror(errno));
		return NULL;
	}

	jpeg_size = file_stat.st_size;
	jpeg = malloc(jpeg_size);

	fd = open(path, O_RDONLY);
	if (fd < 0) {
		fprintf(stderr, "%s: open: %s\n", path, strerror(errno));
		goto out;
	}

	for (i = 0, count = 0; i < jpeg_size; i += count) {
		count = read(fd, &jpeg[i], jpeg_size - i);
		if (count < 0) {
			fprintf(stderr, "%s: read: %s\n",
				path, strerror(errno));
			goto out;
		}
	}

	bitmap = jpeg_to_grayscale_(jpeg, jpeg_size, width, height, fp);

out:
	free(jpeg);
	close(fd);
	return bitmap;
}

float *jpeg_file_to_grayscale(char *path, int *width, int *height)
{
	return jpeg_file_to_grayscale_(path, width, height, true);
}

uint8_t *jpeg_file_to_grayscale_int(char *path, int *width, int *height)
{
	return jpeg_file_to_grayscale_(path, width, height, false);
}

