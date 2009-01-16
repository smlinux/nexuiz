.float count; // set if clientside projectile
.float cnt; // sound index
.float gravity;

void Projectile_Draw()
{
	vector oldorg;

	oldorg = self.origin;

	if(self.count & 0x80)
	{
		//self.move_flags &~= FL_ONGROUND;
		Movetype_Physics(TRUE);
		self.angles = vectoangles(self.velocity);
	}
	else
	{
		InterpolateOrigin_Do();
	}

	switch(self.cnt)
	{
		case PROJECTILE_ROCKET:
			trailparticles(self, particleeffectnum("TR_ROCKET"), oldorg, self.origin);
			break;
		case PROJECTILE_TAG:
			trailparticles(self, particleeffectnum("TR_VORESPIKE"), oldorg, self.origin);
			break;
		case PROJECTILE_ELECTRO_BEAM:
			trailparticles(self, particleeffectnum("TR_NEXUIZPLASMA"), oldorg, self.origin);
			break;
		case PROJECTILE_GRENADE:
			trailparticles(self, particleeffectnum("TR_KNIGHTSPIKE"), oldorg, self.origin);
			if(!(self.move_flags & FL_ONGROUND))
				self.angles -= '750 0 0' * time;
			break;
		case PROJECTILE_GRENADE_BOUNCING:
			trailparticles(self, particleeffectnum("TR_KNIGHTSPIKE"), oldorg, self.origin);
			if(!(self.move_flags & FL_ONGROUND))
				self.angles += '100 150 100' * time;
			break;
		default:
			break;
	}

	self.renderflags = 0;

	if(self.count & 0x80 || self.iflags & IFLAG_VALID)
		R_AddEntity(self);
}

void loopsound(entity e, float ch, string samp, float vol, float attn)
{
	if(csqc_flags & CSQC_FLAG_COLORCODES)
		sound(e, ch, samp, vol, attn);
}

void Ent_RemoveProjectile()
{
	if(self.cnt)
		loopsound(self, CHAN_PAIN, "misc/null.wav", VOL_BASE, ATTN_NORM);
}

void Ent_Projectile()
{
	float f;

	InterpolateOrigin_Undo();

	// projectile properties:
	//   kind (interpolated, or clientside)
	//
	//   modelindex
	//   origin
	//   scale
	//   if clientside:
	//     velocity
	//     gravity
	//   soundindex (hardcoded list)
	//   effects
	//
	// projectiles don't send angles, because they always follow the velocity
	
	f = ReadByte();
	self.count = (f & 0x80);
	self.iflags = IFLAG_AUTOANGLES | IFLAG_ANGLES;
	self.move_flags &~= FL_ONGROUND;
	self.solid = SOLID_TRIGGER;

	// sv_gameplayfix_delayprojectiles
	if(!self.move_time)
		self.move_time = time + ticrate;
	else
		self.move_time = max(self.move_time, time);

	if(self.count & 0x80)
		InterpolateOrigin_Undo();

	if(f & 1)
	{
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
		if(self.count & 0x80)
		{
			self.velocity_x = ReadCoord();
			self.velocity_y = ReadCoord();
			self.velocity_z = ReadCoord();
			self.gravity = ReadCoord();

			self.move_origin = self.origin;
			self.move_velocity = self.velocity;
		}
	}

	if(f & 2)
	{
		self.cnt = ReadByte();

		switch(self.cnt)
		{
			case PROJECTILE_ELECTRO: setmodel(self, "models/ebomb.mdl"); break;
			case PROJECTILE_ROCKET: setmodel(self, "models/rocket.md3"); break;
			case PROJECTILE_TAG: setmodel(self, "models/laser.mdl"); break;
			case PROJECTILE_BULLET: setmodel(self, "models/tracer.mdl"); break;
			case PROJECTILE_CRYLINK: setmodel(self, "models/plasmatrail.mdl"); break;
			case PROJECTILE_ELECTRO_BEAM: setmodel(self, "models/elaser.mdl"); break;
			case PROJECTILE_GRENADE: setmodel(self, "models/grenademodel.md3"); break;
			case PROJECTILE_GRENADE_BOUNCING: setmodel(self, "models/grenademodel.md3"); break;
			case PROJECTILE_LASER: setmodel(self, "models/laser.mdl"); break;
			case PROJECTILE_HLAC: setmodel(self, "models/hlac_bullet.md3"); break;
			default:
				error("Received invalid CSQC projectile, can't work with this!");
				break;
		}

		self.scale = 1;
		self.mins = '0 0 0';
		self.maxs = '0 0 0';
		self.move_movetype = MOVETYPE_TOSS;
		self.move_moveflags = MOVEFLAG_STOPONIMPACT;

		switch(self.cnt)
		{
			case PROJECTILE_ELECTRO:
				// only new engines support sound moving with object
				loopsound(self, CHAN_PAIN, "weapons/electro_fly.wav", VOL_BASE, ATTN_NORM);
				self.mins = '0 0 -3';
				self.maxs = '0 0 -3';
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_moveflags = 0;
				break;
			case PROJECTILE_ROCKET:
				loopsound(self, CHAN_PAIN, "weapons/rocket_fly.wav", VOL_BASE, ATTN_NORM);
				self.mins = '-3 -3 -3';
				self.maxs = '3 3 3';
				break;
			case PROJECTILE_TAG:
				loopsound(self, CHAN_PAIN, "weapons/tag_rocket_fly.wav", VOL_BASE, ATTN_NORM);
				self.mins = '-2 -2 -2';
				self.maxs = '2 2 2';
				break;
			case PROJECTILE_GRENADE:
				self.mins = '0 0 0';
				self.maxs = '0 0 0';
				break;
			case PROJECTILE_GRENADE_BOUNCING:
				self.mins = '0 0 -3';
				self.maxs = '0 0 -3';
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_moveflags = 0;
				break;
			default:
				break;
		}
	}

	if(self.count)
		InterpolateOrigin_Note();
	
	self.draw = Projectile_Draw;
}

void Projectile_Precache()
{
	precache_model("models/ebomb.mdl");
	precache_model("models/rocket.md3");
	precache_model("models/laser.mdl");
	precache_model("models/tracer.mdl");
	precache_model("models/plasmatrail.mdl");
	precache_model("models/elaser.mdl");
	precache_model("models/grenademodel.md3");
	precache_model("models/grenademodel.md3");
	precache_model("models/laser.mdl");
	precache_model("models/hlac_bullet.md3");
}
