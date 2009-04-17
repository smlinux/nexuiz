float bgmscriptbuf;
float bgmscriptbufsize;
float bgmscriptbufloaded;

.float bgmscriptline;
.float bgmscriptline0;
.float bgmscriptvelocity;
.float bgmscripttime;
.float bgmscriptstate;
.float bgmscriptstatetime;
.float bgmscriptdelta;

float GetAttackDecaySustainAmplitude(float a, float d, float s, float t)
{
	// phase:
	//   attack: from 0 to 1, in time a for a full length
	//   decay: from 1 to s, in time d
	//   sustain: s
	
	if(a)
		if(t <= a)
			return max(0, t / a);

	if(d)
		if(t <= a + d)
			return max(0, ((t - a) / d)) * (s - 1) + 1;

	return s;
}

float GetReleaseAmplitude(float s, float r, float t)
{
	if(r)
		return s * (1 - min(1, t / r));
	
	return 0;
}

float GetAttackTime(float a, float amp)
{
	return amp * a;
}

float GetReleaseTime(float s, float r, float amp)
{
	if(s)
		return (1 - amp / s) * r;

	return 0;
}

void BGMScript_Init()
{
	string s;
	float fh;
	bgmscriptbuf = bgmscriptbufsize = 0;
	bgmscriptbufloaded = 1;
	s = strcat("maps/", mi_shortname, ".bgs");
	fh = fopen(s, FILE_READ);
	if(fh < 0)
		return;
	bgmscriptbuf = buf_create();
	while((s = fgets(fh)))
	{
		bufstr_set(bgmscriptbuf, bgmscriptbufsize, s);
		++bgmscriptbufsize;
	}
	fclose(fh);
}

void BGMScript_InitEntity(entity e)
{
	float l;
	string m;
	if(e.bgmscript != "")
	{
		if(!bgmscriptbufloaded)
			BGMScript_Init();

		float i;

		m = strcat(e.bgmscript, " ");
		l = strlen(m);

		e.bgmscriptline0 = -1;
		for(i = 0; i < bgmscriptbufsize; ++i)
		{
			if(substring(bufstr_get(bgmscriptbuf, i), 0, l) == m)
				break;
		}
		e.bgmscriptline = e.bgmscriptline0 = i;
		if(i >= bgmscriptbufsize)
		{
			print("func_pointparticles: bgmscript does not define ", e.bgmscript, "\n");
			e.bgmscript = "";
		}
	}
}

float BGMScript(entity e)
{
	float t;
	float amp;

	if(e.bgmscript == "")
		return 1;
	
	if(cvar("bgmvolume") <= 0)
		return -1;

	e.just_toggled = FALSE;

	t = gettime(GETTIME_CDTRACK);
	if(t < e.bgmscripttime)
	{
		e.bgmscriptline = e.bgmscriptline0;
		e.bgmscripttime = 0;
		e.bgmscriptstatetime = t - drawframetime - e.bgmscriptdelta; // FIXME this causes a tiny hitch
	}

	// find the CURRENT line
	for(;;)
	{
		tokenize_sane(bufstr_get(bgmscriptbuf, e.bgmscriptline));
		if(stof(argv(1)) >= t)
			break;
		if(argv(0) != e.bgmscript)
		{
			// end of bgmscript, will revert to beginning later
			break;
		}
		else if(t >= stof(argv(1)))
		{
			e.bgmscriptline += 1;
			e.bgmscripttime = stof(argv(1));

			if(e.bgmscriptstate)
				amp = GetAttackDecaySustainAmplitude(e.bgmscriptattack, e.bgmscriptdecay, e.bgmscriptsustain, e.bgmscripttime - e.bgmscriptstatetime) * e.bgmscriptvelocity;
			else
				amp = GetReleaseAmplitude(e.bgmscriptsustain, e.bgmscriptrelease, e.bgmscripttime - e.bgmscriptstatetime);

			// time code reached!
			e.bgmscriptvelocity = stof(argv(2));
			if(e.bgmscriptvelocity > 0)
				e.just_toggled = e.bgmscriptstate = TRUE;
			else
				e.just_toggled = e.bgmscriptstate = FALSE;

			if(e.bgmscriptstate)
				e.bgmscriptstatetime = e.bgmscripttime - GetAttackTime(e.bgmscriptattack, amp / e.bgmscriptvelocity);
			else
			{
				e.bgmscriptstatetime = e.bgmscripttime - GetReleaseTime(e.bgmscriptsustain, e.bgmscriptrelease, amp);
				amp = GetReleaseAmplitude(e.bgmscriptsustain, e.bgmscriptrelease, e.bgmscripttime - e.bgmscriptstatetime);
			}
		}
	}

	if(e.bgmscriptstate)
	{
		// attack, decay or sustain
		e.bgmscriptdelta = t - e.bgmscriptstatetime;
		return GetAttackDecaySustainAmplitude(e.bgmscriptattack, e.bgmscriptdecay, e.bgmscriptsustain, e.bgmscriptdelta) * e.bgmscriptvelocity;
	}
	else
	{
		// release
		e.bgmscriptdelta = t - e.bgmscriptstatetime;
		return GetReleaseAmplitude(e.bgmscriptsustain, e.bgmscriptrelease, self.bgmscriptdelta);
	}
}

