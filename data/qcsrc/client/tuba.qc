//#define TUBA_STARTNOTE(n) strcat("weapons/tuba_startnote", ftos(n), ".wav")
//#define TUBA_STOPNOTE(n) strcat("weapons/tuba_stopnote", ftos(n), ".wav")
#define TUBA_STARTNOTE(n) strcat("weapons/tuba_note", ftos(n), ".wav")
#define TUBA_STOPNOTE(n) "" // this will be ignored (for actually stopping, use misc/null.wav)
.float cnt; // note

void Ent_TubaNote_UpdateSound()
{
	sound(self, CHAN_PROJECTILE, TUBA_STARTNOTE(self.cnt), bound(0, VOL_BASE * cvar("g_balance_tuba_volume"), 1), cvar("g_balance_tuba_attenuation"));
}

void Ent_TubaNote_StopSound()
{
	string s;
	s = TUBA_STOPNOTE(self.cnt);
	if(s != "")
		sound(self, CHAN_PROJECTILE, s, bound(0, VOL_BASE * cvar("g_balance_tuba_volume"), 1), cvar("g_balance_tuba_attenuation"));
}

void Ent_TubaNote(float bIsNew)
{
	float f, n;
	f = ReadByte();
	n = floor(f / 2) - 42;
	if(f & 1)
	{
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
		setorigin(self, self.origin);
	}
	self.think = Ent_TubaNote_StopSound;
	self.entremove = Ent_TubaNote_StopSound;
	self.nextthink = time + 10;
	if(n != self.cnt || bIsNew)
	{
		self.cnt = n;
		Ent_TubaNote_UpdateSound();
	}
}

void Tuba_Precache()
{
	float i;
	for(i = -18; i <= +27; ++i)
	{
		precache_sound(TUBA_STARTNOTE(i));
		if(TUBA_STOPNOTE(i) != "")
			precache_sound(TUBA_STOPNOTE(i));
	}
}
