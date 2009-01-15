.float itime;
.float count; // set if clientside projectile
.float cnt; // sound index
.float gravity;

void Projectile_Draw()
{
	float dt;
	vector oldorg, org;

	oldorg = self.origin;

	if(self.count & 0x80)
	{
		dt = time - self.itime;
		self.velocity_z -= dt * self.gravity * getstatf(242); // STAT_MOVEVARS_GRAVITY
		org = self.origin + dt * self.velocity;
		self.itime = time;
		tracebox(self.origin, self.mins, self.maxs, org, MOVE_NORMAL, self);
		self.origin = trace_endpos;
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

void Ent_RemoveProjectile()
{
	if(csqc_flags & CSQC_FLAG_COLORCODES)
		if(self.cnt)
			sound(self, CHAN_PAIN, "misc/null.wav", VOL_BASE, ATTN_NORM);
}

void Ent_Projectile()
{
	float f;
	float sz;

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

	if(self.count & 0x80)
		InterpolateOrigin_Undo();

	if(f & 1)
	{
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
		if(self.count & 0x80)
		{
			self.itime = time;
			self.velocity_x = ReadCoord();
			self.velocity_y = ReadCoord();
			self.velocity_z = ReadCoord();
			self.gravity = ReadCoord();
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

		if(csqc_flags & CSQC_FLAG_COLORCODES)
			switch(self.cnt)
			{
				case PROJECTILE_ELECTRO:
					// only new engines support sound moving with object
					sound(self, CHAN_PAIN, "weapons/electro_fly.wav", VOL_BASE, ATTN_NORM);
					break;
				case PROJECTILE_ROCKET:
					sound(self, CHAN_PAIN, "weapons/rocket_fly.wav", VOL_BASE, ATTN_NORM);
					break;
				case PROJECTILE_TAG:
					sound(self, CHAN_PAIN, "weapons/tag_rocket_fly.wav", VOL_BASE, ATTN_NORM);
					break;
				default:
					break;
			}

		sz = ReadByte();
		switch(sz)
		{
			case 0:
			default:
				self.mins = self.maxs = '0 0 0';
				break;
		}
	}

	if(self.count)
		InterpolateOrigin_Note();
	
	self.draw = Projectile_Draw;
}
