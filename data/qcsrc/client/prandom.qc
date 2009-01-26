// prandom - PREDICTABLE random number generator

float prandom_time, prandom_seed;
float prandom()
{
	float c;

	// reinitialize every frame to make it act similar every frame
	if(time != prandom_time)
		prandom_seed = prandom_time = time;
	
	c = crc16(FALSE, strcat(ftos(prandom_seed), ftos(prandom_seed + 3.1415926535)));
	prandom_seed = c;
	return c / 65536; // in [0..1[
}
