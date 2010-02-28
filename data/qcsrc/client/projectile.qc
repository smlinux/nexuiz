.vector iorigin1, iorigin2;
.float spawntime;
.vector trail_oldorigin;
.float trail_oldtime;
.float fade_time, fade_rate;

void SUB_Null()
{
}

void SUB_Stop()
{
	self.move_velocity = self.move_avelocity = '0 0 0';
	self.move_movetype = MOVETYPE_NONE;
}

.float alphamod;
.float count; // set if clientside projectile
.float cnt; // sound index
.float gravity;
.float snd_looping;
.float silent;
.float traileffect;

void Projectile_DrawTrail(vector to)
{
	vector from;
	float t0;
	from = self.trail_oldorigin;
	t0 = self.trail_oldtime;
	self.trail_oldorigin = to;
	self.trail_oldtime = time;

	if (self.traileffect)
		trailparticles(self, self.traileffect, from, to);
}

void Projectile_Draw()
{
	vector rot;
	vector trailorigin;
	float f;
	float drawn;
	float t;
	float a;

	f = self.move_flags;

	if(self.count & 0x80)
	{
		//self.move_flags &~= FL_ONGROUND;
		Movetype_Physics_MatchServer(autocvar_cl_projectiles_sloppy);
		if(!(self.move_flags & FL_ONGROUND))
			self.angles = vectoangles(self.velocity);
	}
	else
	{
		InterpolateOrigin_Do();
	}

	if(self.count & 0x80)
	{
		drawn = (time >= self.spawntime - 0.02);
		t = max(time, self.spawntime);
	}
	else
	{
		drawn = (self.iflags & IFLAG_VALID);
		t = time;
	}

	if(!(f & FL_ONGROUND))
	{
		rot = '0 0 0';
		switch(self.cnt)
		{
			/*
			case PROJECTILE_GRENADE:
				rot = '-2000 0 0'; // forward
				break;
			*/
			case PROJECTILE_GRENADE_BOUNCING:
				rot = '0 -1000 0'; // sideways
				break;
			case PROJECTILE_HOOKBOMB:
				rot = '1000 0 0'; // forward
				break;
			default:
				break;
		}
		self.angles = AnglesTransform_ToAngles(AnglesTransform_Multiply(AnglesTransform_FromAngles(self.angles), rot * (t - self.spawntime)));
	}

	vector ang;
	ang = self.angles;
	ang_x = -ang_x;
	makevectors(ang);

	a = 1 - (time - self.fade_time) * self.fade_rate;
	if(a <= 0)
		drawn = 0;

	trailorigin = self.origin;
	switch(self.cnt)
	{
		case PROJECTILE_GRENADE:
		case PROJECTILE_GRENADE_BOUNCING:
			trailorigin += v_right * 1 + v_forward * -10;
			break;
		default:
			break;
	}
	if(drawn)
		Projectile_DrawTrail(trailorigin);
	else
	{
		self.trail_oldorigin = trailorigin;
		self.trail_oldtime = time;
	}

	if(!drawn)
		return;

	switch(self.cnt)
	{
		case PROJECTILE_BULLET_GLOWING:
		case PROJECTILE_BULLET_GLOWING_TRACER:
			R_AddDynamicLight(self.origin, 50 * a, '1 1 0');
			break;
		default:
			break;
	}

	self.alpha = self.alphamod * a;
	self.renderflags = 0;

	R_AddEntity(self);
}

void loopsound(entity e, float ch, string samp, float vol, float attn)
{
	if(self.silent)
		return;

	sound(e, ch, samp, vol, attn);
	e.snd_looping = 1;
}

void Ent_RemoveProjectile()
{
	if(self.snd_looping)
		sound(self, CHAN_PROJECTILE, "misc/null.wav", VOL_BASE, ATTN_NORM);

	if(self.count & 0x80)
	{
		tracebox(self.origin, self.mins, self.maxs, self.origin + self.velocity * 0.05, MOVE_NORMAL, self);
		Projectile_DrawTrail(trace_endpos);
	}
}

void Ent_Projectile()
{
	float f;

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
	self.iflags = (self.iflags & IFLAG_INTERNALMASK) | IFLAG_AUTOANGLES | IFLAG_ANGLES;
	self.solid = SOLID_TRIGGER;
	//self.effects = EF_NOMODELFLAGS;

	// this should make collisions with bmodels more exact, but it leads to
	// projectiles no longer being able to lie on a bmodel
	self.move_nomonsters = MOVE_WORLDONLY;
	if(f & 0x40)
		self.move_flags |= FL_ONGROUND;
	else
		self.move_flags &~= FL_ONGROUND;

	if(!self.move_time)
	{
		// for some unknown reason, we don't need to care for
		// sv_gameplayfix_delayprojectiles here.
		self.move_time = time;
		self.spawntime = time;
	}
	else
		self.move_time = max(self.move_time, time);

	if(!(self.count & 0x80))
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

		if(time == self.spawntime || (self.count & 0x80) || (f & 0x10))
		{
			self.trail_oldorigin = self.origin;
			if(!(self.count & 0x80))
				InterpolateOrigin_Reset();
		}

		if(f & 0x20)
		{
			self.fade_time = time + ReadByte() * ticrate;
			self.fade_rate = 1 / (ReadByte() * ticrate);
		}
		else
		{
			self.fade_time = 0;
			self.fade_rate = 0;
		}
	}

	if(f & 2)
	{
		self.cnt = ReadByte();

		self.silent = (self.cnt & 0x80);
		self.cnt = (self.cnt & 0x7F);

		self.scale = 1;
		self.traileffect = 0;
		switch(self.cnt)
		{
			case PROJECTILE_ELECTRO: setmodel(self, "models/ebomb.mdl");self.traileffect = particleeffectnum("TR_NEXUIZPLASMA"); break;
			case PROJECTILE_ROCKET: setmodel(self, "models/rocket.md3");self.traileffect = particleeffectnum("TR_ROCKET"); self.scale = 2; break;
			case PROJECTILE_BULLET: setmodel(self, "models/tracer.mdl");self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_BULLET_GLOWING: setmodel(self, "models/tracer.mdl");self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_BULLET_GLOWING_TRACER: setmodel(self, "models/tracer.mdl");self.traileffect = particleeffectnum("tr_rifle"); break;
			case PROJECTILE_CRYLINK: setmodel(self, "models/plasmatrail.mdl");self.traileffect = particleeffectnum("TR_CRYLINKPLASMA"); break;
			case PROJECTILE_CRYLINK_BOUNCING: setmodel(self, "models/plasmatrail.mdl");self.traileffect = particleeffectnum("TR_CRYLINKPLASMA"); break;
			case PROJECTILE_ELECTRO_BEAM: setmodel(self, "models/elaser.mdl");self.traileffect = particleeffectnum("TR_NEXUIZPLASMA"); break;
			case PROJECTILE_GRENADE: setmodel(self, "models/grenademodel.md3");self.traileffect = particleeffectnum("TR_GRENADE"); break;
			case PROJECTILE_GRENADE_BOUNCING: setmodel(self, "models/grenademodel.md3");self.traileffect = particleeffectnum("TR_GRENADE"); break;
			case PROJECTILE_LASER: setmodel(self, "models/laser.mdl");self.traileffect = particleeffectnum(""); break;
			case PROJECTILE_HLAC: setmodel(self, "models/hlac_bullet.md3");self.traileffect = particleeffectnum(""); break;
			case PROJECTILE_PORTO_RED: setmodel(self, "models/grenademodel.md3");self.traileffect = particleeffectnum("TR_WIZSPIKE"); self.scale = 4; break;
			case PROJECTILE_PORTO_BLUE: setmodel(self, "models/grenademodel.md3");self.traileffect = particleeffectnum("TR_WIZSPIKE"); self.scale = 4; break;
			case PROJECTILE_HOOKBOMB: setmodel(self, "models/grenademodel.md3");self.traileffect = particleeffectnum("TR_KNIGHTSPIKE"); break;
			case PROJECTILE_HAGAR: setmodel(self, "models/hagarmissile.mdl");self.traileffect = particleeffectnum("TR_GRENADE"); self.scale = 0.4; break;
			case PROJECTILE_HAGAR_BOUNCING: setmodel(self, "models/hagarmissile.mdl");self.traileffect = particleeffectnum("TR_GRENADE"); self.scale = 0.4; break;
			case PROJECTILE_FIREBALL: self.model = ""; self.modelindex = 0; self.traileffect = particleeffectnum("fireball"); break; // particle effect is good enough
			case PROJECTILE_FIREMINE: self.model = ""; self.modelindex = 0; self.traileffect = particleeffectnum("firemine"); break; // particle effect is good enough
			default:
				error("Received invalid CSQC projectile, can't work with this!");
				break;
		}

		self.mins = '0 0 0';
		self.maxs = '0 0 0';
		self.colormod = '0 0 0';
		self.move_touch = SUB_Stop;
		self.move_movetype = MOVETYPE_TOSS;
		self.alphamod = 1;

		switch(self.cnt)
		{
			case PROJECTILE_ELECTRO:
				// only new engines support sound moving with object
				loopsound(self, CHAN_PROJECTILE, "weapons/electro_fly.wav", VOL_BASE, ATTN_NORM);
				self.mins = '0 0 -3';
				self.maxs = '0 0 -3';
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = SUB_Null;
				break;
			case PROJECTILE_ROCKET:
				loopsound(self, CHAN_PROJECTILE, "weapons/rocket_fly.wav", VOL_BASE, ATTN_NORM);
				self.mins = '-3 -3 -3';
				self.maxs = '3 3 3';
				break;
			case PROJECTILE_GRENADE:
				self.mins = '0 0 -3';
				self.maxs = '0 0 -3';
				break;
			case PROJECTILE_GRENADE_BOUNCING:
				self.mins = '0 0 -3';
				self.maxs = '0 0 -3';
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = SUB_Null;
				break;
			case PROJECTILE_PORTO_RED:
				self.colormod = '2 1 1';
				self.alphamod = 0.5;
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = SUB_Null;
				break;
			case PROJECTILE_PORTO_BLUE:
				self.colormod = '1 1 2';
				self.alphamod = 0.5;
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = SUB_Null;
				break;
			case PROJECTILE_HAGAR_BOUNCING:
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = SUB_Null;
				break;
			case PROJECTILE_CRYLINK_BOUNCING:
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = SUB_Null;
				break;
			case PROJECTILE_FIREBALL:
				loopsound(self, CHAN_PROJECTILE, "weapons/fireball_fly2.wav", VOL_BASE, ATTN_NORM);
				self.mins = '-16 -16 -16';
				self.maxs = '16 16 16';
				break;
			case PROJECTILE_FIREMINE:
				loopsound(self, CHAN_PROJECTILE, "weapons/fireball_fly.wav", VOL_BASE, ATTN_NORM);
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = SUB_Null;
				self.mins = '-4 -4 -4';
				self.maxs = '4 4 4';
				break;
			default:
				break;
		}
	}

	if(self.gravity)
	{
		if(self.move_movetype == MOVETYPE_FLY)
			self.move_movetype = MOVETYPE_TOSS;
		if(self.move_movetype == MOVETYPE_BOUNCEMISSILE)
			self.move_movetype = MOVETYPE_BOUNCE;
	}
	else
	{
		if(self.move_movetype == MOVETYPE_TOSS)
			self.move_movetype = MOVETYPE_FLY;
		if(self.move_movetype == MOVETYPE_BOUNCE)
			self.move_movetype = MOVETYPE_BOUNCEMISSILE;
	}

	if(!(self.count & 0x80))
		InterpolateOrigin_Note();
	
	self.draw = Projectile_Draw;
	self.entremove = Ent_RemoveProjectile;
}

void Projectile_Precache()
{
	precache_model("models/ebomb.mdl");
	precache_model("models/elaser.mdl");
	precache_model("models/grenademodel.md3");
	precache_model("models/hagarmissile.mdl");
	precache_model("models/hlac_bullet.md3");
	precache_model("models/laser.mdl");
	precache_model("models/plasmatrail.mdl");
	precache_model("models/rocket.md3");
	precache_model("models/tracer.mdl");
	precache_sound("weapons/electro_fly.wav");
	precache_sound("weapons/rocket_fly.wav");
	precache_sound("weapons/fireball_fly.wav");
	precache_sound("weapons/fireball_fly2.wav");
}
