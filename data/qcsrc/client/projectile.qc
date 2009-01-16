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
		case PROJECTILE_ELECTRO:
			break; // electro uses no trail
		case PROJECTILE_ROCKET:
			trailparticles(self, particleeffectnum("TR_ROCKET"), oldorg, self.origin); // rocket
			break;
		case PROJECTILE_TAG:
			trailparticles(self, particleeffectnum("TR_VORESPIKE"), oldorg, self.origin); // seeker
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
	self.count = (f & 0xC0);
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
		self.modelindex = ReadShort();
		if(f & 0x40)
		{
			self.scale = ReadByte() / 16.0;
			self.effects = ReadShort();
			self.effects |= 65536 * ReadByte();
		}
		else
		{
			self.scale = 1;
			self.effects = 0;
		}

		self.cnt = ReadShort();

		switch(self.cnt)
		{
			case PROJECTILE_ELECTRO:
				// only new engines support sound moving with object
				loopsound(self, CHAN_PAIN, "weapons/electro_fly.wav", VOL_BASE, ATTN_NORM);
				self.mins = '0 0 -3';
				self.maxs = '0 0 -3';
				self.move_movetype = MOVETYPE_BOUNCE;
				break;
			case PROJECTILE_ROCKET:
				loopsound(self, CHAN_PAIN, "weapons/rocket_fly.wav", VOL_BASE, ATTN_NORM);
				self.mins = '-3 -3 -3';
				self.maxs = '3 3 3';
				self.move_movetype = MOVETYPE_TOSS;
				break;
			case PROJECTILE_TAG:
				loopsound(self, CHAN_PAIN, "weapons/tag_rocket_fly.wav", VOL_BASE, ATTN_NORM);
				self.mins = '-2 -2 -2';
				self.maxs = '2 2 2';
				self.move_movetype = MOVETYPE_TOSS;
				break;
			default:
				self.mins = '0 0 0';
				self.maxs = '0 0 0';
				self.move_movetype = MOVETYPE_TOSS;
				break;
		}
	}

	if(self.count)
		InterpolateOrigin_Note();
	
	self.draw = Projectile_Draw;
}
