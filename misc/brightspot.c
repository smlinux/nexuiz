#include <stdio.h>
#include <math.h>

// USAGE:
//   for X in *.tga; do convert "$X" -geometry 512x512 -depth 8 GRAY:-; done > /tmp/foo
//   brightspot /tmp/foo
// It should output the right parameters for the sun direction in q3map2's format.
// But probably is broken.

#define false 0
#define true 1

int sides_alphabet[6] =
{
	2, // bk
	5, // dn
	3, // ft
	1, // lf
	0, // rt
	4  // up
};

int flip[6*3] =
{
	false, false,  true, // "rt"
	 true,  true,  true, // "lf"
	false,  true, false, // "bk"
	 true, false, false, // "ft"
	false, false,  true, // "up"
	false, false,  true  // "dn"
};

static const double skyboxvertex3f[6*4*3] =
{
        // skyside[0]
         16, -16,  16,
         16, -16, -16,
         16,  16, -16,
         16,  16,  16,
        // skyside[1]
        -16,  16,  16,
        -16,  16, -16,
        -16, -16, -16,
        -16, -16,  16,
        // skyside[2]
         16,  16,  16,
         16,  16, -16,
        -16,  16, -16,
        -16,  16,  16,
        // skyside[3]
        -16, -16,  16,
        -16, -16, -16,
         16, -16, -16,
         16, -16,  16,
        // skyside[4]
        -16, -16,  16,
         16, -16,  16,
         16,  16,  16,
        -16,  16,  16,
        // skyside[5]
         16, -16, -16,
        -16, -16, -16,
        -16,  16, -16,
         16,  16, -16
};

void MapCoord(int pic, int x, int y, double vec[3])
{
	int h;
	int flipx = flip[3*pic+0];
	int flipy = flip[3*pic+1];
	int flipdiag = flip[3*pic+2];

	double a[3] = { skyboxvertex3f[pic*4*3+0*3+0], skyboxvertex3f[pic*4*3+0*3+1], skyboxvertex3f[pic*4*3+0*3+2] };
	double b[3] = { skyboxvertex3f[pic*4*3+1*3+0], skyboxvertex3f[pic*4*3+1*3+1], skyboxvertex3f[pic*4*3+1*3+2] };
	double c[3] = { skyboxvertex3f[pic*4*3+2*3+0], skyboxvertex3f[pic*4*3+2*3+1], skyboxvertex3f[pic*4*3+2*3+2] };
	//double d[3] = { skyboxvertex3f[pic*4*3+3*3+0], skyboxvertex3f[pic*4*3+3*3+1], skyboxvertex3f[pic*4*3+3*3+2] };

	if(flipx)
	{
		x = 511 - x;
	}

	if(flipy)
	{
		y = 511 - y;
	}

	if(flipdiag)
	{
		h = x; x = y; y = h;
	}

	vec[0] = a[0] + (b[0] - a[0]) * (x + 0.5) / 512.0 + (c[0] - b[0]) * (y + 0.5) / 512.0;
	vec[1] = a[1] + (b[1] - a[1]) * (x + 0.5) / 512.0 + (c[1] - b[1]) * (y + 0.5) / 512.0;
	vec[2] = a[2] + (b[2] - a[2]) * (x + 0.5) / 512.0 + (c[2] - b[2]) * (y + 0.5) / 512.0;
}

int main(int argc, char **argv)
{
	FILE *f;
	int i, j, k;
	unsigned char picture[6][512][512];
	double brightvec[3];
	double pitch, yaw;

	if(argc != 2)
	{
		fprintf(stderr, "Usage: %s imagefile.gray\n", *argv);
		return 1;
	}

	f = fopen(argv[1], "rb");
	if(!f)
	{
		perror("fopen");
		return 1;
	}
	fread(&picture, sizeof(picture), 1, f);
	fclose(f);

	brightvec[0] = brightvec[1] = brightvec[2] = 0;
	for(i = 0; i < 6; ++i)
		for(j = 0; j < 512; ++j)
			for(k = 0; k < 512; ++k)
			{
				double vec[3], f;
				MapCoord(i, j, k, vec);
				f = exp(10 * (picture[i][j][k] - 255)) / sqrt(vec[0]*vec[0] + vec[1]*vec[1] + vec[2]*vec[2]);
				brightvec[0] += f * vec[0];
				brightvec[1] += f * vec[1];
				brightvec[2] += f * vec[2];
			}
	
	pitch = -atan2(brightvec[2], sqrt(brightvec[0]*brightvec[0] + brightvec[1]*brightvec[1]));
	yaw = atan2(brightvec[1], brightvec[0]);

	printf("%f %f\n", yaw * 180 / M_PI, pitch * 180 / M_PI);
	return 0;
}
