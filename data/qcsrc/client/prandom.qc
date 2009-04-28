// prandom - PREDICTABLE random number generator (not seeded yet)

#ifdef USE_PRANDOM
float prandom_seed;
float prandom()
{
	float c;
	string s1, s2;
	s1 = ftos(prandom_seed);
	s2 = ftos(prandom_seed + 3.1415926535);
	c = crc16(FALSE, strcat(s1, s2)); // fteqcc sucks
	prandom_seed = c;

#ifdef USE_PRANDOM_DEBUG
	print("RANDOM -> ", ftos(c), "\n");
#endif

	return c / 65536; // in [0..1[
}

vector prandomvec()
{
	vector v;

	do
	{
		v_x = prandom();
		v_y = prandom();
		v_z = prandom();
	}
	while(v * v > 1);

	return v;
}

void psrandom(float seed)
{
	prandom_seed = seed;
#ifdef USE_PRANDOM_DEBUG
	print("SRANDOM ", ftos(seed), "\n");
#endif
}

#ifdef USE_PRANDOM_DEBUG
void prandom_debug()
{
	print("Current random seed = ", ftos(prandom_seed), "\n");
}
#endif
#endif
