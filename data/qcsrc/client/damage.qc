void Ent_DamageInfo()
{
	float hittype, dmg, rad, edge, thisdmg, forcemul;
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

	if(rad < 0)
	{
		rad = -rad;
		forcemul = -1;
	}
	else
		forcemul = 1;

	for(self = findradius(org, rad); self; self = self.chain)
	{
		if(rad)
		{
			thisdmg = vlen(self.origin - org) / rad;
			if(thisdmg >= 1)
				continue;
			if(dmg)
			{
				thisdmg = dmg + (edge - dmg) * thisdmg;
				thisforce = forcemul * vlen(force) * (thisdmg / dmg) * normalize(self.origin - org);
			}
			else
			{
				thisdmg = 0;
				thisforce = forcemul * vlen(force) * normalize(self.origin - org);
			}
		}
		else
		{
			thisdmg = dmg;
			thisforce = forcemul * force;
		}

		//print("check ", ftos(num_for_edict(self)), " ", self.classname, "\n");
		//print(ftos(self.damageforcescale), "\n");
		//print(vtos(thisforce), "\n");
		if(self.damageforcescale)
			if(vlen(thisforce))
			{
				self.move_velocity = self.move_velocity + self.damageforcescale * thisforce;
				self.move_flags &~= FL_ONGROUND;
				//print("pushed ", ftos(num_for_edict(self)), " loose\n");
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
		vector org2, backoff;
		float r;

		hitwep = DEATH_WEAPONOFWEAPONDEATH(hittype);
		secondary = hittype & HITTYPE_SECONDARY;
		bounce = hittype & HITTYPE_BOUNCE;
		headshot = hittype & HITTYPE_HEADSHOT;
		r = prandom();

		traceline(org - normalize(force) * 16, org + normalize(force) * 16, MOVE_NOMONSTERS, world);
		if(trace_fraction < 1 && hitwep != WEP_NEX && hitwep != WEP_MINSTANEX)
			backoff = trace_plane_normal;
		else
			backoff = -1 * normalize(force);

		switch(hitwep)
		{
			case WEP_LASER:
				org2 = org + backoff * 6;
				pointparticles(particleeffectnum("laser_impact"), org2, backoff * 1000, 1);
				sound (self, CHAN_PROJECTILE, "weapons/laserimpact.wav", VOL_BASE, ATTN_NORM);
				break;
			case WEP_SHOTGUN:
				org2 = org + backoff * 2;
				pointparticles(particleeffectnum("shotgun_impact"), org2, backoff * 1000, 1);
				if(r < 0.05)
					sound(self, CHAN_PROJECTILE, "weapons/ric1.wav", VOL_BASE, ATTN_NORM);
				else if(r < 0.1)
					sound(self, CHAN_PROJECTILE, "weapons/ric2.wav", VOL_BASE, ATTN_NORM);
				else if(r < 0.2)
					sound(self, CHAN_PROJECTILE, "weapons/ric3.wav", VOL_BASE, ATTN_NORM);
				break;
			case WEP_UZI:
				org2 = org + backoff * 2;
				pointparticles(particleeffectnum("machinegun_impact"), org2, backoff * 1000, 1);
				if(r < 0.05)
					sound(self, CHAN_PROJECTILE, "weapons/ric1.wav", VOL_BASE, ATTN_NORM);
				else if(r < 0.1)
					sound(self, CHAN_PROJECTILE, "weapons/ric2.wav", VOL_BASE, ATTN_NORM);
				else if(r < 0.2)
					sound(self, CHAN_PROJECTILE, "weapons/ric3.wav", VOL_BASE, ATTN_NORM);
				break;
			case WEP_GRENADE_LAUNCHER:
				org2 = org + backoff * 12;
				pointparticles(particleeffectnum("grenade_explode"), org2, '0 0 0', 1);
				sound (self, CHAN_PROJECTILE, "weapons/grenade_impact.wav", VOL_BASE, ATTN_NORM);
				break;
			case WEP_ELECTRO:
				org2 = org + backoff * 6;
				if(secondary)
				{
					pointparticles(particleeffectnum("electro_ballexplode"), org2, '0 0 0', 1);
					sound (self, CHAN_PROJECTILE, "weapons/electro_impact.wav", VOL_BASE, ATTN_NORM);
				}
				else
				{
					if(bounce)
					{
						// this is sent as "primary bounce" to distinguish it from secondary bounced balls
						pointparticles(particleeffectnum("electro_combo"), org2, '0 0 0', 1);
						sound (self, CHAN_PROJECTILE, "weapons/electro_impact_combo.wav", VOL_BASE, ATTN_NORM);
					}
					else
					{
						pointparticles(particleeffectnum("electro_impact"), org2, '0 0 0', 1);
						sound (self, CHAN_PROJECTILE, "weapons/electro_impact.wav", VOL_BASE, ATTN_NORM);
					}
				}
				break;
			case WEP_CRYLINK:
				org2 = org + backoff * 2;
				if(secondary)
				{
					pointparticles(particleeffectnum("crylink_impact"), org2, '0 0 0', 1);
					sound (self, CHAN_PROJECTILE, "weapons/crylink_impact2.wav", VOL_BASE, ATTN_NORM);
				}
				else
				{
					pointparticles(particleeffectnum("crylink_impactbig"), org2, '0 0 0', 1);
					sound (self, CHAN_PROJECTILE, "weapons/crylink_impact.wav", VOL_BASE, ATTN_NORM);
				}
				break;
			case WEP_NEX:
				org2 = org + backoff * 6;
				pointparticles(particleeffectnum("nex_impact"), org2, '0 0 0', 1);
				sound(self, CHAN_PROJECTILE, "weapons/neximpact.wav", VOL_BASE, ATTN_NORM);
				break;
			case WEP_HAGAR:
				org2 = org + backoff * 6;
				pointparticles(particleeffectnum("hagar_explode"), org2, '0 0 0', 1);
				if (r<0.15)
					sound (self, CHAN_PROJECTILE, "weapons/hagexp1.wav", VOL_BASE, ATTN_NORM);
				else if (r<0.7)
					sound (self, CHAN_PROJECTILE, "weapons/hagexp2.wav", VOL_BASE, ATTN_NORM);
				else
					sound (self, CHAN_PROJECTILE, "weapons/hagexp3.wav", VOL_BASE, ATTN_NORM);
				break;
			case WEP_ROCKET_LAUNCHER:
				org2 = org + backoff * 12;
				pointparticles(particleeffectnum("rocket_explode"), org2, '0 0 0', 1);
				sound (self, CHAN_PROJECTILE, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
				break;
			case WEP_PORTO:
				print("Since when does Porto send DamageInfo?\n");
				break;
			case WEP_MINSTANEX:
				org2 = org + backoff * 6;
				pointparticles(particleeffectnum("nex_impact"), org2, '0 0 0', 1);
				sound(self, CHAN_PROJECTILE, "weapons/neximpact.wav", VOL_BASE, ATTN_NORM);
				break;
			case WEP_HOOK:
				org2 = org + backoff * 2;
				pointparticles(particleeffectnum("hookbomb_explode"), org2, '0 0 0', 1);
				sound (self, CHAN_PROJECTILE, "weapons/hookbomb_impact.wav", VOL_BASE, ATTN_NORM);
				break;
			case WEP_SEEKER:
				org2 = org + backoff * 6;
				if(secondary)
				{
					pointparticles(particleeffectnum("flac_explode"), org2, '0 0 0', 1);
					if (r<0.15)
						sound (self, CHAN_PROJECTILE, "weapons/flacexp1.wav", 1, ATTN_NORM);
					else if (r<0.7)
						sound (self, CHAN_PROJECTILE, "weapons/flacexp2.wav", 1, ATTN_NORM);
					else
						sound (self, CHAN_PROJECTILE, "weapons/flacexp3.wav", 1, ATTN_NORM);
				}
				else
				{
					if(bounce)
					{
						pointparticles(particleeffectnum("hagar_explode"), org2, '0 0 0', 1);
						if (r<0.15)
							sound (self, CHAN_PROJECTILE, "weapons/tagexp1.wav", 1, ATTN_NORM);
						else if (r<0.7)
							sound (self, CHAN_PROJECTILE, "weapons/tagexp2.wav", 1, ATTN_NORM);
						else
							sound (self, CHAN_PROJECTILE, "weapons/tagexp3.wav", 1, ATTN_NORM);
					}
					else if(headshot)
					{
						sound (self, CHAN_PROJECTILE, "weapons/tag_impact.wav", 1, ATTN_NORM);
					}
					else
					{
						pointparticles(particleeffectnum("hagar_explode"), org2, '0 0 0', 1);
						if (r<0.15)
							sound (self, CHAN_PROJECTILE, "weapons/seekerexp1.wav", 1, ATTN_NORM);
						else if (r<0.7)
							sound (self, CHAN_PROJECTILE, "weapons/seekerexp2.wav", 1, ATTN_NORM);
						else
							sound (self, CHAN_PROJECTILE, "weapons/seekerexp3.wav", 1, ATTN_NORM);
					}
				}
				break;
			case WEP_HLAC:
				org2 = org + backoff * 6;
				pointparticles(particleeffectnum("laser_impact"), org2, backoff * 1000, 1);
				sound (self, CHAN_PROJECTILE, "weapons/laserimpact.wav", VOL_BASE, ATTN_NORM);
				break;
			case WEP_CAMPINGRIFLE:
				org2 = org + backoff * 2;
				pointparticles(particleeffectnum("machinegun_impact"), org2, backoff * 1000, 1);
				if(r < 0.2)
					sound(self, CHAN_PROJECTILE, "weapons/ric1.wav", VOL_BASE, ATTN_NORM);
				else if(r < 0.4)
					sound(self, CHAN_PROJECTILE, "weapons/ric2.wav", VOL_BASE, ATTN_NORM);
				else if(r < 0.5)
					sound(self, CHAN_PROJECTILE, "weapons/ric3.wav", VOL_BASE, ATTN_NORM);
				break;
			case WEP_TUBA:
				break;
			default:
				dprint("Unhandled damage of weapon ", ftos(hitwep), "\n");
				break;
		}
	}
}

void DamageInfo_Precache()
{
	precache_sound("weapons/crylink_impact2.wav");
	precache_sound("weapons/crylink_impact.wav");
	precache_sound("weapons/electro_impact.wav");
	precache_sound("weapons/electro_impact_combo.wav");
	precache_sound("weapons/flacexp1.wav");
	precache_sound("weapons/flacexp2.wav");
	precache_sound("weapons/flacexp3.wav");
	precache_sound("weapons/grenade_impact.wav");
	precache_sound("weapons/hagexp1.wav");
	precache_sound("weapons/hagexp2.wav");
	precache_sound("weapons/hagexp3.wav");
	precache_sound("weapons/hookbomb_impact.wav");
	precache_sound("weapons/laserimpact.wav");
	precache_sound("weapons/neximpact.wav");
	precache_sound ("weapons/ric1.wav");
	precache_sound ("weapons/ric2.wav");
	precache_sound ("weapons/ric3.wav");
	precache_sound("weapons/rocket_impact.wav");
	precache_sound("weapons/seekerexp1.wav");
	precache_sound("weapons/seekerexp2.wav");
	precache_sound("weapons/seekerexp3.wav");
	precache_sound("weapons/tagexp1.wav");
	precache_sound("weapons/tagexp2.wav");
	precache_sound("weapons/tagexp3.wav");
	precache_sound("weapons/tag_impact.wav");
}
