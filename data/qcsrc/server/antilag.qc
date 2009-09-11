#define ANTILAG_MAX_ORIGINS 64
.vector antilag_origins[ANTILAG_MAX_ORIGINS];
.float antilag_times[ANTILAG_MAX_ORIGINS];
.float antilag_index;
.vector antilag_saved_origin;

.float antilag_debug;

void antilag_dummy()
{
	self.antilag_times = 0;
	self.antilag_origins = '0 0 0';
}

void antilag_record(entity e, float t)
{
	if(time < e.(antilag_times[e.antilag_index]))
		return;
	e.antilag_index = e.antilag_index + 1;
	if(e.antilag_index >= ANTILAG_MAX_ORIGINS)
		e.antilag_index = 0;
	e.(antilag_times[e.antilag_index]) = t;
	e.(antilag_origins[e.antilag_index]) = e.origin;

	if(e.antilag_debug)
		te_spark(antilag_takebackorigin(e, t - e.antilag_debug), '0 0 0', 32);
}

// finds the index BEFORE t
float antilag_find(entity e, float t)
{
	float i;

	for(i = e.antilag_index; i > 0; --i)
		if(e.(antilag_times[i]) >= t)
			if(e.(antilag_times[i - 1]) < t)
				return i - 1;

	if(e.(antilag_times[0]) >= t)
		if(e.(antilag_times[ANTILAG_MAX_ORIGINS - 1]) < t)
			return ANTILAG_MAX_ORIGINS - 1;

	for(i = ANTILAG_MAX_ORIGINS - 1; i > e.antilag_index + 1; --i)
		if(e.(antilag_times[i]) >= t)
			if(e.(antilag_times[i - 1]) < t)
				return i - 1;

	// if we get here, t is sandwiched nowhere, so let's assume it's in the present
	return -1;
}

vector lerp(float t0, vector v0, float t1, vector v1, float t)
{
	return v0 + (v1 - v0) * ((t - t0) / (t1 - t0));
}

vector antilag_takebackorigin(entity e, float t)
{
	float i0, i1;

	i0 = antilag_find(e, t);
	if(i0 < 0)
	{
		i0 = e.antilag_index - 1;
		if(i0 < 0)
			i0 = ANTILAG_MAX_ORIGINS - 1;
	}
	i1 = i0 + 1;
	if(i1 >= ANTILAG_MAX_ORIGINS)
		i1 = 0;

	return lerp(e.(antilag_times[i0]), e.(antilag_origins[i0]), e.(antilag_times[i1]), e.(antilag_origins[i1]), t);
}

void antilag_takeback(entity e, float t)
{
	e.antilag_saved_origin = e.origin;
	setorigin(e, antilag_takebackorigin(e, t));
}

void antilag_restore(entity e)
{
	setorigin(e, e.antilag_saved_origin);
}
