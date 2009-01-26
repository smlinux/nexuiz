// prandom - PREDICTABLE random number generator (not seeded yet)

float prandom_seed;
float prandom()
{
	float c;

	c = crc16(FALSE, strcat(ftos(prandom_seed), ftos(prandom_seed + 3.1415926535)));
	prandom_seed = c;
	return c / 65536; // in [0..1[
}
