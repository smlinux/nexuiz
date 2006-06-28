.float centermsg_expire[MAXCENTERMSG];
.string centermsg_text[MAXCENTERMSG];
.float centermsg_nextdisplay;

void centermsg_makedirty()
{
	self.centermsg_nextdisplay = time;
}

void centermsg_free(float lineno)
{
	if(self.(centermsg_expire[lineno]) > 0)
		strunzone(self.(centermsg_text[lineno]));
	self.(centermsg_expire[lineno]) = -1;
	self.(centermsg_text[lineno]) = "";
	centermsg_makedirty();
}

void centermsg_freefor(entity p, float lineno)
{
	entity oldself;
	oldself = self;
	self = p;
	centermsg_free(lineno);
	self = oldself;
}

void centermsg_set(float lineno, string text)
{
	centermsg_free(lineno);
	self.(centermsg_expire[lineno]) = time + self.cvar_scr_centertime;
	self.(centermsg_text[lineno]) = strzone(text);
	centermsg_makedirty();
}

void centermsg_setexpire(float lineno, string text, float expire)
{
	centermsg_free(lineno);
	self.(centermsg_expire[lineno]) = time + self.cvar_scr_centertime * expire;
	self.(centermsg_text[lineno]) = strzone(text);
	centermsg_makedirty();
}

void centermsg_setfor(entity p, float lineno, string text)
{
	entity oldself;
	oldself = self;
	self = p;
	centermsg_set(lineno, text);
	self = oldself;
}

float centermsg_checkexpire(float lineno)
{
	if(self.(centermsg_expire[lineno]) >= 0)
	{
		if(self.(centermsg_expire[lineno]) < time)
		{
			centermsg_free(lineno);
			return FALSE;
		}
		return TRUE;
	}
	return FALSE;
}

void centermsg_do()
{
	float i;
	float found;
	string out;
	found = 0;

	if(self.cvar_scr_centertime)
		self.centermsg_nextdisplay = time + self.cvar_scr_centertime * 0.8;

	for(i = 0; i < MAXCENTERMSG; ++i)
		if(centermsg_checkexpire(i))
			found = 1;

	if(!found)
		return;

	out = "\n\n\n\n\n\n\n\n\n\n\n\n\n";
	for(i = 0; i < MAXCENTERMSG; ++i)
	{
		out = strcat(out, "^7");
		if(self.centermsg_expire[i] >= 0)
			out = strcat(out, self.(centermsg_text[i]));
		out = strcat(out, "\n");
	}
	centerprint(self, out);
}

void centermsg_check()
{
	if(clienttype(self) != CLIENTTYPE_REAL)
		return;
	if(self.centermsg_nextdisplay && self.centermsg_nextdisplay <= time)
		centermsg_do();
}

void centermsg_reset()
{
	float i;
	self.centermsg_nextdisplay = 0;
	for(i = 0; i < MAXCENTERMSG; ++i)
		centermsg_free(i);
	centerprint(self, "");
}

void centermsg_setall(string s)
{
	float i;
	centerprint(self, s);
	self.centermsg_nextdisplay = 0;
	for(i = 0; i < MAXCENTERMSG; ++i)
		centermsg_free(i);
}

void centermsg_setallfor(entity p, string text)
{
	entity oldself;
	oldself = self;
	self = p;
	centermsg_setall(text);
	self = oldself;
}

