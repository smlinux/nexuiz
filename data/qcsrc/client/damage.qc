/*
==================
findbetterlocation

Returns a point at least 12 units away from walls
(useful for explosion animations, although the blast is performed where it really happened)
Ripped from DPMod
==================
*/
vector findbetterlocation (vector org, float mindist)
{
	vector loc, norm, norm2;
	vector vec;
	float c;
	float h;

	norm = '0 0 1';

	vec = mindist * '1 0 0';
	c = 0;
	while (c < 6)
	{
		traceline (org, org + vec, MOVE_WORLDONLY, world);
		vec = vec * -1;
		if (trace_fraction < 1)
		{
			loc = trace_endpos;
			norm2 = trace_plane_normal;
			traceline (loc, loc + vec, MOVE_WORLDONLY, world);
			if (trace_fraction >= 1)
			{
				org = loc + vec;
				norm = norm2;
			}
		}
		if (c & 1)
		{
			h = vec_y;
			vec_y = vec_x;
			vec_x = vec_z;
			vec_z = h;
		}
		c = c + 1;
	}

	trace_plane_normal = norm;

	return org;
}

void Ent_DamageInfo()
{
	float hittype, dmg, rad, edge, thisdmg;
	vector force, org, thisforce;
	entity oldself;

	oldself = self;

	hittype = ReadShort();
	org_x = ReadCoord();
	org_y = ReadCoord();
	org_z = ReadCoord();

	dmg = ReadByte();
	rad = ReadByte();
	edge = ReadByte();
	force = decompressShortVector(ReadShort());

	for(self = findradius(org, rad); self; self = self.chain)
	{
		if(rad)
		{
			thisdmg = vlen(self.origin - org) / rad;
			if(thisdmg >= 1)
				continue;
			thisdmg = dmg + (edge - dmg) * thisdmg;
			thisforce = vlen(force) * normalize(self.origin - org);
		}
		else
		{
			thisdmg = dmg;
			thisforce = force;
		}

		if(self.damageforcescale)
			if(vlen(thisforce))
			{
				self.move_velocity = self.move_velocity + self.damageforcescale * thisforce;
				self.move_flags &~= FL_ONGROUND;
			}

		if(self.event_damage)
			self.event_damage(thisdmg, hittype, org, thisforce);
	}

	self = oldself;

	setorigin(self, org); // for sound() calls

	// TODO spawn particle effects and sounds based on hittype
	
	if(!DEATH_ISSPECIAL(hittype))
	{
		float hitwep, secondary, bounce, headshot;
		vector org2;
		float r;

		hitwep = DEATH_WEAPONOFWEAPONDEATH(hittype);
		secondary = hittype & HITTYPE_SECONDARY;
		bounce = hittype & HITTYPE_BOUNCE;
		headshot = hittype & HITTYPE_HEADSHOT;
		r = random();

		switch(hitwep)
		{
			case WEP_LASER:
				org2 = findbetterlocation (org, 8);
				pointparticles(particleeffectnum("laser_impact"), org2, trace_plane_normal * 1000, 1);
				sound (self, CHAN_PROJECTILE, "weapons/laserimpact.wav", VOL_BASE, ATTN_NORM);
				break;
			case WEP_SHOTGUN:
				org2 = findbetterlocation (org, 2);
				pointparticles(particleeffectnum("shotgun_impact"), org2, trace_plane_normal * 1000, 1);
				break;
			case WEP_UZI:
				org2 = findbetterlocation (org, 2);
				pointparticles(particleeffectnum("machinegun_impact"), org2, trace_plane_normal * 1000, 1);
				break;
			case WEP_GRENADE_LAUNCHER:
				org2 = findbetterlocation (org, 12);
				pointparticles(particleeffectnum("grenade_explode"), org2, '0 0 0', 1);
				sound (self, CHAN_PROJECTILE, "weapons/grenade_impact.wav", VOL_BASE, ATTN_NORM);
				break;
			case WEP_ELECTRO:
				org2 = findbetterlocation (org, 8);
				if(secondary)
				{
					sound (self, CHAN_PROJECTILE, "weapons/electro_impact.wav", VOL_BASE, ATTN_NORM);
					pointparticles(particleeffectnum("electro_ballexplode"), org2, '0 0 0', 1);
				}
				else
				{
					if(bounce)
					{
						// this is sent as "primary bounce" to distinguish it from secondary bounced balls
						sound (self, CHAN_PROJECTILE, "weapons/electro_impact_combo.wav", VOL_BASE, ATTN_NORM);
						pointparticles(particleeffectnum("electro_combo"), org2, '0 0 0', 1);
					}
					else
					{
						sound (self, CHAN_PROJECTILE, "weapons/electro_impact.wav", VOL_BASE, ATTN_NORM);
						pointparticles(particleeffectnum("electro_impact"), org2, '0 0 0', 1);
					}
				}
			case WEP_CRYLINK:
				if(secondary)
				{
					sound (self, CHAN_PROJECTILE, "weapons/crylink_impact2.wav", VOL_BASE, ATTN_NORM);
					pointparticles(particleeffectnum("crylink_impact"), org, '0 0 0', 1);
				}
				else
				{
					sound (self, CHAN_PROJECTILE, "weapons/crylink_impact.wav", VOL_BASE, ATTN_NORM);
					pointparticles(particleeffectnum("crylink_impactbig"), org, '0 0 0', 1);
				}
				break;
			case WEP_NEX:
				sound(self, CHAN_PROJECTILE, "weapons/neximpact.wav", VOL_BASE, ATTN_NORM);
				pointparticles(particleeffectnum("nex_impact"), org - normalize(force) * 6, '0 0 0', 1);
				break;
			case WEP_HAGAR:
				org2 = findbetterlocation (org, 12);
				if (r<0.15)
					sound (self, CHAN_PROJECTILE, "weapons/hagexp1.wav", VOL_BASE, ATTN_NORM);
				else if (r<0.7)
					sound (self, CHAN_PROJECTILE, "weapons/hagexp2.wav", VOL_BASE, ATTN_NORM);
				else
					sound (self, CHAN_PROJECTILE, "weapons/hagexp3.wav", VOL_BASE, ATTN_NORM);
				pointparticles(particleeffectnum("hagar_explode"), org2, '0 0 0', 1);
				break;
			case WEP_ROCKET_LAUNCHER:
				org2 = findbetterlocation (org, 16);
				sound (self, CHAN_PROJECTILE, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
				pointparticles(particleeffectnum("rocket_explode"), org2, '0 0 0', 1);
				break;
			case WEP_PORTO:
				print("Since when does Porto send DamageInfo?\n");
				break;
			case WEP_MINSTANEX:
				sound(self, CHAN_PROJECTILE, "weapons/neximpact.wav", VOL_BASE, ATTN_NORM);
				pointparticles(particleeffectnum("nex_impact"), org - normalize(force) * 6, '0 0 0', 1);
				break;
			case WEP_HOOK:
				org2 = findbetterlocation (org, 12);
				sound (self, CHAN_PROJECTILE, "weapons/hookbomb_impact.wav", VOL_BASE, ATTN_NORM);
				pointparticles(particleeffectnum("hookbomb_explode"), org2, '0 0 0', 1);
				break;
			case WEP_SEEKER:
				org2 = findbetterlocation (org, 12);
				if(secondary)
				{
					if (r<0.15)
						sound (self, CHAN_PROJECTILE, "weapons/flacexp1.wav", 1, ATTN_NORM);
					else if (r<0.7)
						sound (self, CHAN_PROJECTILE, "weapons/flacexp2.wav", 1, ATTN_NORM);
					else
						sound (self, CHAN_PROJECTILE, "weapons/flacexp3.wav", 1, ATTN_NORM);
					pointparticles(particleeffectnum("flac_explode"), org2, '0 0 0', 1);
				}
				else
				{
					if(bounce)
					{
						if (r<0.15)
							sound (self, CHAN_PROJECTILE, "weapons/tagexp1.wav", 1, ATTN_NORM);
						else if (r<0.7)
							sound (self, CHAN_PROJECTILE, "weapons/tagexp2.wav", 1, ATTN_NORM);
						else
							sound (self, CHAN_PROJECTILE, "weapons/tagexp3.wav", 1, ATTN_NORM);
						pointparticles(particleeffectnum("hagar_explode"), org2, '0 0 0', 1);
					}
					else if(headshot)
					{
						sound (self, CHAN_PROJECTILE, "weapons/tag_impact.wav", 1, ATTN_NORM);
					}
					else
					{
						if (r<0.15)
							sound (self, CHAN_PROJECTILE, "weapons/seekerexp1.wav", 1, ATTN_NORM);
						else if (r<0.7)
							sound (self, CHAN_PROJECTILE, "weapons/seekerexp2.wav", 1, ATTN_NORM);
						else
							sound (self, CHAN_PROJECTILE, "weapons/seekerexp3.wav", 1, ATTN_NORM);
						pointparticles(particleeffectnum("hagar_explode"), org2, '0 0 0', 1);
					}
				}
				break;
			case WEP_HLAC:
				org2 = findbetterlocation (org, 12);
				sound (self, CHAN_PROJECTILE, "weapons/laserimpact.wav", VOL_BASE, ATTN_NORM);
				pointparticles(particleeffectnum("laser_impact"), org2, trace_plane_normal * 1000, 1);
				break;
			case WEP_CAMPINGRIFLE:
				org2 = findbetterlocation (org, 2);
				pointparticles(particleeffectnum("machinegun_impact"), org, trace_plane_normal * 1000, 1);
				break;
			default:
				dprint("Unhandled damage of weapon ", ftos(hitwep), "\n");
				break;
		}
	}
}
