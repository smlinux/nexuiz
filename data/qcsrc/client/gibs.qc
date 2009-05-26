string species_prefix(float specnum)
{
	switch(specnum)
	{
		case SPECIES_HUMAN:       return "";
		case SPECIES_ALIEN:       return "alien_";
		case SPECIES_ROBOT_SHINY: return "robot_";
		case SPECIES_ROBOT_RUSTY: return "robot_"; // use the same effects, only different gibs
		case SPECIES_ANIMAL:      return "animal_";
		case SPECIES_RESERVED:    return "reserved_";
		default:         return "";
	}
}

void SUB_RemoveOnNoImpact()
{
	if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
		remove(self);
}

void Gib_Touch()
{
	// TODO maybe bounce of walls, make more gibs, etc.

	if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
	{
		remove(self);
		return;
	}
	
	sound(self, CHAN_PAIN, strcat("misc/gib_splat0", ftos(floor(prandom() * 4 + 1)), ".wav"), VOL_BASE, ATTN_NORM);
	pointparticles(particleeffectnum(strcat(species_prefix(self.cnt), "blood")), self.origin + '0 0 1', '0 0 30', 10);

	remove(self);
}

void Gib_Draw()
{
	vector oldorg;
	oldorg = self.origin;

	Movetype_Physics(FALSE);
	if(wasfreed(self))
		return;
	
	if(self.touch == Gib_Touch) // don't do this for the "chunk" thingie...
		trailparticles(self, particleeffectnum(strcat(species_prefix(self.cnt), "TR_SLIGHTBLOOD")), oldorg, self.origin);
	else
		trailparticles(self, particleeffectnum(strcat(species_prefix(self.cnt), "TR_BLOOD")), oldorg, self.origin);

	self.renderflags = 0;
	self.alpha = bound(0, self.nextthink - time, 1);

	if(self.alpha < ALPHA_MIN_VISIBLE)
		remove(self);
	else
		R_AddEntity(self);
}

void TossGib (string mdlname, vector org, vector vconst, vector vrand, float specnum, float destroyontouch)
{
	entity gib;

	// TODO remove some gibs according to cl_nogibs
	
	gib = spawn();
	gib.classname = "gib";
	gib.move_movetype = MOVETYPE_BOUNCE;
	gib.gravity = 1;
	gib.solid = SOLID_CORPSE;
	gib.cnt = specnum;

	setmodel (gib, mdlname); // precision set above
	gib.skin = specnum;

	setsize (gib, '-8 -8 -8', '8 8 8');
                                          
	gib.draw = Gib_Draw;
	if(destroyontouch)
		gib.move_touch = Gib_Touch;
	else
		gib.move_touch = SUB_RemoveOnNoImpact;

	gib.move_origin = gib.origin = org;
	gib.move_velocity = vconst * cvar_or("cl_gibs_velocity_scale", 1) + vrand * cvar_or("cl_gibs_velocity_random", 1) + '0 0 1' * cvar("cl_gibs_velocity_up");
	gib.move_avelocity = prandomvec() * vlen(gib.move_velocity);
	gib.move_time = time;
	gib.damageforcescale = cvar_or("cl_gibs_damageforcescale", 3.5);

	gib.nextthink = time + cvar_or("cl_gibs_lifetime", 14) * (1 + prandom() * 0.15);
}

void Ent_GibSplash()
{
	float amount, type, specnum;
	vector org, vel, mi, ma;
	string specstr;

	float c, gibfactor, randomvalue;

	type = ReadByte(); // gibbage type
	amount = ReadByte() / 16.0; // gibbage amount
	org_x = ReadShort() * 4 + 2;
	org_y = ReadShort() * 4 + 2;
	org_z = ReadShort() * 4 + 2;
	vel = decompressShortVector(ReadShort());
	mi = decompressShortVector(ReadShort());
	ma = decompressShortVector(ReadShort());

	if(cvar("cl_gentle"))
		type |= 0x80; // set gentle bit
	
	gibfactor = 1 - cvar("cl_nogibs");
	if(gibfactor <= 0)
		return;
	
	amount *= gibfactor;

	if(cvar("ekg"))
		amount *= 5;
	
	self.origin = org; // for the sounds

	specnum = (type & 0x78) / 8; // blood/gibmodel type: using four bits (0..15, bit indexes 3,4,5,6)
	type = type & 0x87; // remove the species bits: bit 7 = gentle, bit 0,1,2 = kind of gib
	specstr = species_prefix(specnum);

	switch(type)
	{
		case 0x01:
			sound (self, CHAN_PAIN, "misc/gib.wav", VOL_BASE, ATTN_NORM);

			if(prandom() < amount)
				TossGib ("models/gibs/eye.md3", org, vel, prandomvec() * 150, specnum, 0);
			te_bloodshower(org + mi, org + ma, 1200, 1000 * amount);
			if(prandom() < amount)
				TossGib ("models/gibs/bloodyskull.md3", org, vel, prandomvec() * 100, specnum, 0);

			for(c = 0; c < amount; ++c)
			{
				randomvalue = amount - c;
					
				if(prandom() < randomvalue)
					TossGib ("models/gibs/arm.md3", org, vel, prandomvec() * (prandom() * 120 + 90), specnum,0);
				if(prandom() < randomvalue)
					TossGib ("models/gibs/arm.md3", org, vel, prandomvec() * (prandom() * 120 + 90), specnum,0);
				if(prandom() < randomvalue)
					TossGib ("models/gibs/chest.md3", org + '0 0 -12', vel, prandomvec() * (prandom() * 120 + 80), specnum,0);
				if(prandom() < randomvalue)
					TossGib ("models/gibs/smallchest.md3", org, vel, prandomvec() * (prandom() * 120 + 80), specnum,0);
				if(prandom() < randomvalue)
					TossGib ("models/gibs/leg1.md3", org + '0 0 -5', vel, prandomvec() * (prandom() * 120 + 85), specnum,0);
				if(prandom() < randomvalue)
					TossGib ("models/gibs/leg2.md3", org + '0 0 -9', vel, prandomvec() * (prandom() * 120 + 85), specnum,0);

				// these splat on impact
				if(prandom() < randomvalue)
					TossGib ("models/gibs/chunk.mdl", org, vel, prandomvec() * 450, specnum,1);
				if(prandom() < randomvalue)
					TossGib ("models/gibs/chunk.mdl", org, vel, prandomvec() * 450, specnum,1);
				if(prandom() < randomvalue)
					TossGib ("models/gibs/chunk.mdl", org, vel, prandomvec() * 450, specnum,1);
				if(prandom() < randomvalue)
					TossGib ("models/gibs/chunk.mdl", org, vel, prandomvec() * 450, specnum,1);
			}
			break;
		case 0x02:
			pointparticles(particleeffectnum(strcat(specstr, "blood")), org, vel, amount * 16);
			break;
		case 0x03:
			if(prandom() < amount)
				TossGib ("models/gibs/chunk.mdl", org, vel, prandomvec() * (prandom() * 30 + 20), specnum, 1); // TODO maybe adjust to more randomization?
			break;
		case 0x81:
			pointparticles(particleeffectnum("damage_dissolve"), org, vel, amount);
			break;
		case 0x82:
			pointparticles(particleeffectnum("damage_hit"), org, vel, amount * 16);
			break;
		case 0x83:
			// no gibs in gentle mode, sorry
			break;
	}
}

void GibSplash_Precache()
{
	precache_model("models/gibs/chunk.mdl");
	precache_model("models/gibs/leg1.md3");
	precache_model("models/gibs/leg2.md3");
	precache_model("models/gibs/chest.md3");
	precache_model("models/gibs/smallchest.md3");
	precache_model("models/gibs/arm.md3");
	precache_model("models/gibs/bloodyskull.md3");
	precache_model("models/gibs/eye.md3");

	precache_sound ("misc/gib.wav");
    precache_sound ("misc/gib_splat01.wav");
    precache_sound ("misc/gib_splat02.wav");
    precache_sound ("misc/gib_splat03.wav");
    precache_sound ("misc/gib_splat04.wav");
}
