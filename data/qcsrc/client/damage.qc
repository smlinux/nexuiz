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
		print("findradius found something\n");

		if(rad)
		{
			thisdmg = vlen(self.origin - org) / rad;
			print("thisdmg = ", ftos(thisdmg), "\n");
			if(thisdmg >= 1)
				continue;
			thisdmg = dmg + (edge - dmg) * thisdmg;
			thisforce = force_z * normalize(self.origin - org);
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

	// TODO spawn particle effects and sounds based on hittype
	
	if(!DEATH_ISSPECIAL(hittype))
	{
		float hitwep, secondary;
		hitwep = DEATH_WEAPONOFWEAPONDEATH(hittype);
		secondary = hittype & HITTYPE_SECONDARY;

		switch(hitwep)
		{
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
		}
	}
}
