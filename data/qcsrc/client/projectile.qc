.float spawntime;
.vector trail_oldorigin;

void SUB_Null()
{
}

void SUB_Stop()
{
	self.move_velocity = self.move_avelocity = '0 0 0';
	self.move_movetype = MOVETYPE_NONE;
}

.float count; // set if clientside projectile
.float cnt; // sound index
.float gravity;
.float snd_looping;

void Projectile_DrawTrail(vector to)
{
	vector from;
	from = self.trail_oldorigin;
	self.trail_oldorigin = to;
	switch(self.cnt)
	{
		case PROJECTILE_ROCKET:
			trailparticles(self, particleeffectnum("TR_ROCKET"), from, to);
			break;
		case PROJECTILE_TAG:
			trailparticles(self, particleeffectnum("TR_VORESPIKE"), from, to);
			break;
		case PROJECTILE_ELECTRO_BEAM:
			trailparticles(self, particleeffectnum("TR_NEXUIZPLASMA"), from, to);
			break;
		case PROJECTILE_GRENADE:
			trailparticles(self, particleeffectnum("TR_KNIGHTSPIKE"), from, to);
			break;
		case PROJECTILE_GRENADE_BOUNCING:
			trailparticles(self, particleeffectnum("TR_KNIGHTSPIKE"), from, to);
			break;
		case PROJECTILE_PORTO_RED:
			trailparticles(self, particleeffectnum("TR_WIZSPIKE"), from, to);
			break;
		case PROJECTILE_PORTO_BLUE:
			trailparticles(self, particleeffectnum("TR_WIZSPIKE"), from, to);
			break;
		case PROJECTILE_FLAC:
			trailparticles(self, particleeffectnum("TR_VORESPIKE"), from, to);
			break;
		case PROJECTILE_SEEKER:
			trailparticles(self, particleeffectnum("TR_ROCKET"), from, to);
			break;
		case PROJECTILE_HOOKBOMB:
			trailparticles(self, particleeffectnum("TR_KNIGHTSPIKE"), from, to);
			break;
		case PROJECTILE_HAGAR:
			trailparticles(self, particleeffectnum("TR_GRENADE"), from, to);
			break;
		case PROJECTILE_HAGAR_BOUNCING:
			trailparticles(self, particleeffectnum("TR_GRENADE"), from, to);
			break;
		default:
			break;
	}

}

void Projectile_Draw()
{
	vector rot;
	vector trailorigin;

	if(self.count & 0x80)
	{
		//self.move_flags &~= FL_ONGROUND;
		Movetype_Physics(TRUE);
		if(!(self.move_flags & FL_ONGROUND))
			self.angles = vectoangles(self.velocity);
	}
	else
	{
		InterpolateOrigin_Do();
	}

	if(!(self.move_flags & FL_ONGROUND))
	{
		rot = '0 0 0';
		switch(self.cnt)
		{
			case PROJECTILE_GRENADE:
				rot = '-2000 0 0';
				break;
			case PROJECTILE_GRENADE_BOUNCING:
				rot = '0 -2000 0';
				break;
			case PROJECTILE_HOOKBOMB:
				rot = '0 1000 0';
				break;
			default:
				break;
		}
		self.angles = AnglesTransform_Multiply(self.angles, rot * (time - self.spawntime));

		fixedmakevectors(self.angles);

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
		Projectile_DrawTrail(trailorigin);
	}

	switch(self.cnt)
	{
		case PROJECTILE_BULLET_GLOWING:
			R_AddDynamicLight(self.origin, 50, '1 1 0');
			break;
		default:
			break;
	}

	self.renderflags = 0;

	if((self.count & 0x80) || (self.iflags & IFLAG_VALID))
		R_AddEntity(self);
}

void loopsound(entity e, float ch, string samp, float vol, float attn)
{
	if(csqc_flags & CSQC_FLAG_COLORCODES)
	{
		sound(e, ch, samp, vol, attn);
		e.snd_looping = 1;
	}
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
	self.iflags = (self.iflags & IFLAG_INTERNALMASK) | IFLAG_AUTOANGLES | IFLAG_ANGLES;
	self.move_flags &~= FL_ONGROUND;
	self.solid = SOLID_TRIGGER;
	//self.effects = EF_NOMODELFLAGS;

	// sv_gameplayfix_delayprojectiles
	if(!self.move_time)
	{
		self.move_time = time + ticrate;
		self.spawntime = time + ticrate;
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

		self.trail_oldorigin = self.origin;
	}

	if(f & 2)
	{
		self.cnt = ReadByte();

		self.scale = 1;
		switch(self.cnt)
		{
			case PROJECTILE_ELECTRO: setmodel(self, "models/ebomb.mdl"); break;
			case PROJECTILE_ROCKET: setmodel(self, "models/rocket.md3"); self.scale = 4; break;
			case PROJECTILE_TAG: setmodel(self, "models/laser.mdl"); break;
			case PROJECTILE_BULLET: setmodel(self, "models/tracer.mdl"); break;
			case PROJECTILE_BULLET_GLOWING: setmodel(self, "models/tracer.mdl"); break;
			case PROJECTILE_CRYLINK: setmodel(self, "models/plasmatrail.mdl"); break;
			case PROJECTILE_ELECTRO_BEAM: setmodel(self, "models/elaser.mdl"); break;
			case PROJECTILE_GRENADE: setmodel(self, "models/grenademodel.md3"); break;
			case PROJECTILE_GRENADE_BOUNCING: setmodel(self, "models/grenademodel.md3"); break;
			case PROJECTILE_LASER: setmodel(self, "models/laser.mdl"); break;
			case PROJECTILE_HLAC: setmodel(self, "models/hlac_bullet.md3"); break;
			case PROJECTILE_SEEKER: setmodel(self, "models/tagrocket.md3"); self.scale = 2; break;
			case PROJECTILE_FLAC: setmodel(self, "models/hagarmissile.mdl"); self.scale = 0.4; break;
			case PROJECTILE_PORTO_RED: setmodel(self, "models/grenademodel.md3"); self.scale = 4; break;
			case PROJECTILE_PORTO_BLUE: setmodel(self, "models/grenademodel.md3"); self.scale = 4; break;
			case PROJECTILE_HOOKBOMB: setmodel(self, "models/grenademodel.md3"); break;
			case PROJECTILE_HAGAR: setmodel(self, "models/hagarmissile.mdl"); self.scale = 0.4; break;
			case PROJECTILE_HAGAR_BOUNCING: setmodel(self, "models/hagarmissile.mdl"); self.scale = 0.4; break;
			default:
				error("Received invalid CSQC projectile, can't work with this!");
				break;
		}

		self.mins = '0 0 0';
		self.maxs = '0 0 0';
		self.colormod = '0 0 0';
		self.move_touch = SUB_Stop;
		self.move_movetype = MOVETYPE_TOSS;

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
			case PROJECTILE_TAG:
				loopsound(self, CHAN_PROJECTILE, "weapons/tag_rocket_fly.wav", VOL_BASE, ATTN_NORM);
				self.mins = '-2 -2 -2';
				self.maxs = '2 2 2';
				break;
			case PROJECTILE_GRENADE_BOUNCING:
				self.mins = '0 0 -3';
				self.maxs = '0 0 -3';
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = SUB_Null;
				break;
			case PROJECTILE_SEEKER:
				self.mins = '-2 -2 -2';
				self.maxs = '2 2 2';
				break;
			case PROJECTILE_PORTO_RED:
				self.colormod = '2 1 1';
				self.alpha = 0.5;
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = SUB_Null;
				break;
			case PROJECTILE_PORTO_BLUE:
				self.colormod = '1 1 2';
				self.alpha = 0.5;
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = SUB_Null;
				break;
			case PROJECTILE_HAGAR_BOUNCING:
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = SUB_Null;
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
	precache_model("models/tagrocket.md3");
	precache_model("models/tracer.mdl");
	precache_sound("weapons/electro_fly.wav");
	precache_sound("weapons/rocket_fly.wav");
	precache_sound("weapons/tag_rocket_fly.wav");
}
