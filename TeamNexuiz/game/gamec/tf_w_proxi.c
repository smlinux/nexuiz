/*-==============================
		MegaTF Proxi Grenade
==============================-*/

void () s_explode1 = [ 0, s_explode2 ]
{
};

void () s_explode2 = [ 1, s_explode3 ]
{
};

void () s_explode3 = [ 2, s_explode4 ]
{
};

void () s_explode4 = [ 3, s_explode5 ]
{
};

void () s_explode5 = [ 4, s_explode6 ]
{
};

void () s_explode6 = [ 5, SUB_Remove ]
{
};

void () s2_explode1 = [ 0, s2_explode2 ]
{
};

void () s2_explode2 = [ 1, s2_explode3 ]
{
};

void () s2_explode3 = [ 2, s2_explode4 ]
{
};

void () s2_explode4 = [ 3, s2_explode5 ]
{
};

void () s2_explode5 = [ 4, s2_explode6 ]
{
};

void () s2_explode6 = [ 5, s2_explode7 ]
{
};

void () s2_explode7 = [ 6, s2_explode8 ]
{
};

void () s2_explode8 = [ 7, SUB_Remove ]
{
};

void () MushroomFlame =
{
	local entity t_ent;

	t_ent = spawn ();
	t_ent.real_owner = self;
	t_ent.movetype = 9;
	t_ent.solid = 0;
	t_ent.classname = "flamerflame";
//	t_ent.effects = 4;
	if ((self.classname == "airstrike"))
	{
		t_ent.velocity_x = (random () * 1000);
	}
	vector	org2;
	org2 = findbetterlocation (t_ent.origin);
	te_explosion (org2);
	effect (org2, "models/sprites/rocketexplosion.spr32", 0, 20, 40);

	t_ent.velocity_y = (random () * 1000);
	t_ent.velocity_z = 200;
	t_ent.think = s_explode1;
	t_ent.nextthink = (time + 0.300000);
	setmodel (t_ent, "progs/s_explod.spr");
//	setmodel (t_ent, "models/sprites/rocketexplosion.spr32");
	
	setsize (t_ent, '0 0 0', '0 0 0');
	setorigin (t_ent, (self.origin + '0 0 16'));


};

void () Prox_Disarm =
{
	if ((other.classname != "player"))
	{
		return;
	}
	if (((other.playerclass == 1) && (other.team_no != self.team_no)))
	{
		sprint (self.real_owner, "Your Proxi Mine Has Been Disarmed...\n");
		bprint (self.real_owner.netname);
		bprint ("'s proxi was defused by ");
		bprint (self.enemy.netname);
		bprint ("\n");
		//logfrag (self.real_owner, self.enemy.real_owner);
		self.enemy.real_frags = (self.enemy.real_frags + 1);
		if (!(toggleflags & 128))
		{
			self.enemy.frags = self.enemy.real_frags;
		}
		dremove (self);
	}
	return;
};

void () ProxiDie =
{
	vector	org2;
	org2 = findbetterlocation (self.origin);
	te_explosion (org2);
	effect (org2, "models/sprites/rocketexplosion.spr32", 0, 20, 40);

	self.effects = 4;
	//make_explosion ();
	self.takedamage = 0;
	deathmsg = 45;
	T_RadiusDamage (self, self.real_owner, 200, world);
	sprint (self.real_owner, "Your Proxi Mine is gone...\n");
	dremove (self);
};

void () FoundBastard =
{
	local float dist;

	self.touch = Prox_Disarm;
	sound (self, 3, "sound/proxi/beep.wav", 1, 1);
	self.skin = (self.real_owner.team_no + 3);
	dist = vlen ((self.enemy.origin - self.origin));
	if ((dist <= self.height))
	{
		self.height = dist;
		self.nextthink = (time + ((dist / 1000) * 1.5));
		self.think = FoundBastard;
	}
	else
	{
		self.effects = 4;
		//make_explosion ();
		MushroomFlame ();
		WriteByte (4, 23);
		WriteByte (4, 3);
		WriteCoord (4, self.origin_x);
		WriteCoord (4, self.origin_y);
		WriteCoord (4, self.origin_z);
		//multicast (self.origin, 1);
		deathmsg = 45;
		sprint (self.real_owner, "Proxi Mine is gone...\n");
		self.takedamage = 0;
		T_RadiusDamage (self, self.real_owner, 200, world);
		dremove (self);
	}
};

void () ProxArmed =
{
	local entity te;
	local entity tl;
	local vector dist;

	self.velocity = '0 0 0';
	self.nextthink = (time + 1);
	self.think = ProxArmed;
	sound (self, 3, "sound/proxi/beep.wav", 0.3, 1);
	self.playerclass = (self.playerclass + 1);
/*	if ((self.skin == self.real_owner.team_no))
	{
		self.skin = 0;
	}
	else
	{
		self.skin = self.real_owner.team_no;
	}*/
	//self.colormap = self.real_owner.colormap;
	te = find (world, classname, "player");
	while (te)
	{
		if ((self.real_owner != te))
		{
			if (((te.team_no != 0) && (te.team_no != self.team_no)))
			{
				if ((te.health > 1))
				{
					if (visible (te))
					{
						if ((te.undercover_team != self.team_no))
						{
							dist = (te.origin - self.origin);
							if ((vlen (dist) < 200))
							{
								self.height = vlen (dist);
								self.enemy = te;
								self.nextthink = 0.2;
								self.think = FoundBastard;
							}
						}
					}
				}
			}
		}
		te = find (te, classname, "player");
	}
	if (((self.playerclass > 300) || (self.real_owner.playerclass != 3)))
	{
		sprint (self.real_owner, "Your Proxi Mine Fizzled...\n");
		dremove (self);
	}
};

void () ProxAttach =
{
	self.touch = SUB_Null;
	self.think = ProxArmed;
	self.nextthink = (time + 0.5);
	sound (newmis, 0, "buttons/switch02.wav", 1, 1);
};

void () Prox =
{
	local vector org;
	local vector stopspot;
	local entity te;
	local float proxicount;

	te = find (world, classname, "bot");
	while (te)
	{
		if ((te.real_owner == self))
		{
			proxicount = (proxicount + 1);
		}
		if ((proxicount >= 2))
		{
			sprint (self, "2 proximity grenades at a time!\n");
			return;
		}
		te = find (te, classname, "bot");
	}
	if ((self.no_grenades_2 < 2))
	{
		sprint (self, "Not enough type 2 grenades... get more\n");
		if ((self.weaponmodel == "progs/proxgren.mdl"))
		{
			self.weaponmodel = "progs/v_rock2.mdl";
			self.currentammo = self.ammo_rockets;
			//Attack_Finished (0.7);
			self.impulse = 0;
			self.StatusRefreshTime = (time + 0.1);
			self.tfstate = (self.real_owner.tfstate - (self.real_owner.tfstate & 2));
		}
		return;
	}/*
	if ((self.weaponmodel != "progs/proxgren.mdl"))
	{
		self.tfstate = (self.tfstate | 2);
		self.currentammo = 1;
		self.weaponmodel = "progs/proxgren.mdl";
		self.weaponframe = 0;
		return;
	}*/
	makevectors (self.v_angle);
	org = (self.origin + (v_forward * 10));
	org_z = (self.absmin_z + (self.size_z * 0.7));
	traceline (org, (org + (v_forward * 70)), 0, self);
	stopspot = (trace_endpos - (v_forward * 8));
	if ((trace_fraction != 1))
	{
		sound (self, 3, "buttons/switch02.wav", 1, 1);
		sprint (self, "Proximity mine set!\n");
		self.no_grenades_2 = (self.no_grenades_2 - 2);
		newmis = spawn ();
		setsize(newmis, '-16 -16 0', '16 16 48');
//		newmis.owner = self;
		newmis.real_owner = self;
		newmis.weapon = 41;
		newmis.movetype = 0;//0;
		newmis.solid = SOLID_BBOX;
		newmis.classname = "bot";
		newmis.netname = "proxi";
		newmis.team_no = self.team_no;
		newmis.health = 30;
		newmis.takedamage = 2;
		newmis.th_die = ProxiDie;
		setsize (newmis, '-2 -2 -2', '2 2 2');
		newmis.angles = '0 0 0';
		newmis.nextthink = (time + 0.5);
		newmis.playerclass = 0;
		newmis.think = ProxAttach;
		newmis.skin = 0;
		newmis.frame = 1;
		newmis.colormap = self.colormap;
		setmodel (newmis, "models/proxi/proxymine2.md3");
		setorigin (newmis, stopspot - '0 0 4');
		self.tfstate = (self.tfstate - (self.tfstate & 2));
		self.weaponmodel = "progs/v_rock2.mdl";
		self.currentammo = self.ammo_rockets;
		//Attack_Finished (0.7);
		self.impulse = 0;
		self.StatusRefreshTime = (time + 0.1);
	}
};