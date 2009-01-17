void Gib_Touch()
{
	// TODO maybe bounce of walls, make more gibs, etc.
	
	sound(self, CHAN_PAIN, strcat("misc/gib_splat0", ftos(floor(random() * 4 + 1)), ".wav"), VOL_BASE, ATTN_NORM);
	pointparticles(particleeffectnum("blood"), self.origin + '0 0 1', '0 0 30', 10);

	remove(self);
}

void Gib_Draw()
{
	vector oldorg;
	oldorg = self.origin;

	Movetype_Physics(FALSE);
	
	trailparticles(self, particleeffectnum("TR_BLOOD"), oldorg, self.origin);

	self.renderflags = 0;
	self.alpha = bound(0, self.nextthink - time, 1);

	if(self.alpha == 0)
		remove(self);
	else
		R_AddEntity(self);
}

void TossGib (string mdlname, vector org, vector v, float destroyontouch)
{
	entity gib;

	// TODO remove some gibs according to cl_nogibs
	
	gib = spawn();
	gib.classname = "gib";
	gib.move_movetype = MOVETYPE_BOUNCE;
	gib.gravity = 1;
	gib.solid = SOLID_CORPSE;

	setmodel (gib, mdlname); // precision set above

	setsize (gib, '-8 -8 -8', '8 8 8');

	gib.draw = Gib_Draw;
	if(destroyontouch)
		gib.move_touch = Gib_Touch;

	gib.move_origin = org;
	gib.move_velocity = v + randomvec();
	gib.move_avelocity = randomvec() * vlen(gib.move_velocity);
	gib.move_time = time;
	gib.damageforcescale = 3.5;

	gib.nextthink = time + 12 + random () * 4;
}

void Ent_GibSplash()
{
	float amount, type, isgentle;
	vector org, vel, mi, ma;

	float c, gibfactor, randomvalue;

	amount = ReadByte() / 16.0; // gibbage amount
	type = ReadByte(); // gibbage type
	org_x = ReadShort() * 4 + 2;
	org_y = ReadShort() * 4 + 2;
	org_z = ReadShort() * 4 + 2;
	vel = decompressShortVector(ReadShort());
	mi = decompressShortVector(ReadShort());
	ma = decompressShortVector(ReadShort());

	isgentle = (type & 0x8000 || cvar("cl_gentle"));
	type = type & 0x7FFF;


	gibfactor = 1 - cvar("cl_nogibs");
	if(gibfactor <= 0)
		return;
	
	amount *= gibfactor;

	if(cvar("ekg"))
		amount *= 5;

	if(type == 1) // full gibbage
	{
		sound (self, CHAN_PAIN, "misc/gib.wav", VOL_BASE, ATTN_NORM);

		if(random() < amount)
			TossGib("models/gibs/eye.md3", org, vel + randomvec() * 150, 0);
		te_bloodshower(org + mi, org + ma, 1200, 1000 * amount);
		if(random() < amount)
			TossGib("models/gibs/bloodyskull.md3", org, vel, 0);

		for(c = 0; c < amount; ++c)
		{
			randomvalue = amount - c;
				
			if(random() < randomvalue)
				TossGib ("models/gibs/arm.md3", org, vel + randomvec() * (random() * 120 + 90),0);
			if(random() < randomvalue)
				TossGib ("models/gibs/arm.md3", org, vel + randomvec() * (random() * 120 + 90),0);
			if(random() < randomvalue)
				TossGib ("models/gibs/chest.md3", org + '0 0 -12', vel + randomvec() * (random() * 120 + 80),0);
			if(random() < randomvalue)
				TossGib ("models/gibs/smallchest.md3", org, vel + randomvec() * (random() * 120 + 80),0);
			if(random() < randomvalue)
				TossGib ("models/gibs/leg1.md3", org + '0 0 -5', vel + randomvec() * (random() * 120 + 85),0);
			if(random() < randomvalue)
				TossGib ("models/gibs/leg2.md3", org + '0 0 -9', vel + randomvec() * (random() * 120 + 85),0);

			// these splat on impact
			if(random() < randomvalue)
				TossGib ("models/gibs/chunk.mdl", org, vel + randomvec() * 450,1);
			if(random() < randomvalue)
				TossGib ("models/gibs/chunk.mdl", org, vel + randomvec() * 450,1);
			if(random() < randomvalue)
				TossGib ("models/gibs/chunk.mdl", org, vel + randomvec() * 450,1);
			if(random() < randomvalue)
				TossGib ("models/gibs/chunk.mdl", org, vel + randomvec() * 450,1);
		}
	}
	else if(type == 2) // just blood
	{
		pointparticles(particleeffectnum("blood"), org, vel, amount);
	}
	else if(type == 3) // single gib
	{
		TossGib ("models/gibs/chunk.mdl", org, vel, 1);
	}
}

void GibSplash_Precache()
{
	precache_model("models/gibs/chunk.mdl");
	precache_model("models/gibs/leg1.mdl");
	precache_model("models/gibs/leg2.mdl");
	precache_model("models/gibs/chest.mdl");
	precache_model("models/gibs/smallchest.mdl");
	precache_model("models/gibs/arm.mdl");
	precache_model("models/gibs/bloodyskull.mdl");
	precache_model("models/gibs/eye.mdl");
}
