
/*
==================
SUB_Null

Do nothing
==================
*/
void SUB_Null (void)
{
	
}

/*
==================
SUB_Remove

Remove self
==================
*/
void SUB_Remove (void)
{
	remove (self);
}

void SUB_SetFade_Think (void)
{
	if (self.alpha < 0.06)	// don't let it reach 0, lest it become fully visible again
		remove (self);

	self.alpha = self.alpha - 0.05;

	self.think = SUB_SetFade_Think;
	self.nextthink = time + 0.1;
}

/*
==================
SUB_SetFade

Fade 'ent' out when time >= 'when'
==================
*/
void SUB_SetFade (entity ent, float when)
{
	if (when < time)
	{
			ent.think = SUB_Null;
			return;
	}
	
	ent.alpha = 1.0;

	ent.think = SUB_SetFade_Think;
	ent.nextthink = when;
}

/*
==================
main

unused but required by the engine
==================
*/
void main (void)
{
	
}

// Sound functions

/*
==================
PointSound

Play a sound at the given location
==================
*/
void PointSound (vector org, string snd, float vol, float attn)
{
	entity	speaker;
	
	speaker = spawn ();
	setorigin (speaker, org);
	sound (speaker, CHAN_BODY, snd, vol, attn);
	remove (speaker);
}

// Misc

/*
==================
traceline_hitcorpse

A version of traceline that must be used by SOLID_SLIDEBOX things that want to hit SOLID_CORPSE things with a trace attack
==================
*/
void traceline_hitcorpse (entity source, vector v1, vector v2, float nomonst, entity forent)
{
	float	oldsolid;
	
	oldsolid = source.solid;
	source.solid = SOLID_BBOX;
	
	traceline (v1, v2, nomonst, forent);
	
	source.solid = oldsolid;
}

/*
==================
crandom

Returns a random number between -1.0 and 1.0
==================
*/
float crandom (void)
{
	return 2 * (random () - 0.5);
}
