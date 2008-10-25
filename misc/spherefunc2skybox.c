#include <stdio.h>
#include <err.h>
#include <stdint.h>
#include <math.h>
#include <string.h>

typedef void (*mapfunc_t) (double x_in, double y_in, double *x_out, double *y_out, double *z_out);
typedef void (*colorfunc_t) (double x, double y, double z, double *r, double *g, double *b);

void color_test(double x, double y, double z, double *r, double *g, double *b)
{
	// put in a nice function here
	*r = 0.5 + 0.5 * x;
	*g = 0.5 + 0.5 * y;
	*b = 0.5 + 0.5 * z;
}

#define MAXITER 4096
double mandelbrot(double zx, double zy, double cx, double cy)
{
	double tmp;
	int i;

	for(i = 1; i < MAXITER; ++i)
	{
		tmp = zx;
		zx = zx * zx - zy * zy + cx;
		zy = 2 * tmp * zy + cy;
		if(zx * zx + zy * zy > 4)
			break;
	}

	return ((i - 1.0) * MAXITER) / (i * (MAXITER - 1.0));
	// i.e. 0 for i=1, 1 for i=maxiter
}

void color_mandelbrot(double x, double y, double z, double *r, double *g, double *b)
{
	double iterations = mandelbrot(0, z*0.5, x - 1, y);
	*r = pow(iterations, 100);
	*g = pow(iterations,  25);
	*b = pow(iterations,  10);
}

void map_back(double x_in, double y_in, double *x_out, double *y_out, double *z_out)
{
	*x_out = 2 * x_in - 1;
	*y_out = +1;
	*z_out = 1 - 2 * y_in;
}

void map_right(double x_in, double y_in, double *x_out, double *y_out, double *z_out)
{
	*x_out = +1;
	*y_out = 1 - 2 * x_in;
	*z_out = 1 - 2 * y_in;
}

void map_front(double x_in, double y_in, double *x_out, double *y_out, double *z_out)
{
	*x_out = 1 - 2 * x_in;
	*y_out = -1;
	*z_out = 1 - 2 * y_in;
}

void map_left(double x_in, double y_in, double *x_out, double *y_out, double *z_out)
{
	*x_out = -1;
	*y_out = 2 * x_in - 1;
	*z_out = 1 - 2 * y_in;
}

void map_up(double x_in, double y_in, double *x_out, double *y_out, double *z_out)
{
	*x_out = 2 * y_in - 1;
	*y_out = 1 - 2 * x_in;
	*z_out = +1;
}

void map_down(double x_in, double y_in, double *x_out, double *y_out, double *z_out)
{
	*x_out = 1 - 2 * y_in;
	*y_out = 1 - 2 * x_in;
	*z_out = -1;
}

#define WIDTH 512
#define HEIGHT 512

void writepic(colorfunc_t f, mapfunc_t m, const char *fn)
{
	int x, y;
	uint8_t tga[18];

	FILE *file = fopen(fn, "wb");
	if(!file)
		err(1, "fopen %s", fn);

	memset(tga, 0, sizeof(tga));
	tga[2] = 2;          // uncompressed type
	tga[12] = (WIDTH >> 0) & 0xFF;
	tga[13] = (WIDTH >> 8) & 0xFF;
	tga[14] = (HEIGHT >> 0) & 0xFF;
	tga[15] = (HEIGHT >> 8) & 0xFF;
	tga[16] = 24;        // pixel size

	fwrite(&tga, sizeof(tga), 1, file);
	for(y = HEIGHT-1; y >= 0; --y)
		for(x = 0; x < WIDTH; ++x)
		{
			uint8_t rgb[3];
			double rr, gg, bb;
			double xx, yy;
			double xxx, yyy, zzz;
			double r;
			xx = (x + 0.5) / WIDTH;
			yy = (y + 0.5) / HEIGHT;
			m(xx, yy, &xxx, &yyy, &zzz);
			r = sqrt(xxx*xxx + yyy*yyy + zzz*zzz);
			xxx /= r;
			yyy /= r;
			zzz /= r;
			f(xxx, yyy, zzz, &rr, &gg, &bb);
			rgb[2] = floor(0.5 + rr * 255);
			rgb[1] = floor(0.5 + gg * 255);
			rgb[0] = floor(0.5 + bb * 255);
			fwrite(rgb, sizeof(rgb), 1, file);
		}
	
	fclose(file);
}

void map_all(const char *fn, colorfunc_t f)
{
	char buf[1024];
	snprintf(buf, sizeof(buf), "%s_bk.tga", fn); buf[sizeof(buf) - 1] = 0; writepic(f, map_back, buf);
	snprintf(buf, sizeof(buf), "%s_ft.tga", fn); buf[sizeof(buf) - 1] = 0; writepic(f, map_front, buf);
	snprintf(buf, sizeof(buf), "%s_rt.tga", fn); buf[sizeof(buf) - 1] = 0; writepic(f, map_right, buf);
	snprintf(buf, sizeof(buf), "%s_lf.tga", fn); buf[sizeof(buf) - 1] = 0; writepic(f, map_left, buf);
	snprintf(buf, sizeof(buf), "%s_up.tga", fn); buf[sizeof(buf) - 1] = 0; writepic(f, map_up, buf);
	snprintf(buf, sizeof(buf), "%s_dn.tga", fn); buf[sizeof(buf) - 1] = 0; writepic(f, map_down, buf);
}

int main(int argc, char **argv)
{
	if(argc != 2)
		errx(1, "file name argument missing");
	map_all(argv[1], color_mandelbrot);
	return 0;
}
