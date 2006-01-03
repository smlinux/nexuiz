void (entity bld) CheckBelowBuilding;
void (entity gunhead) CheckSentry;
void () Sentry_Rotate;
float () Sentry_FindTarget;
void () Sentry_FoundTarget;
void () Sentry_HuntTarget;
void () Sentry_Pain;
void () Sentry_Die;
float () Sentry_Fire;
void () Sentry_MuzzleFlash;
void () lvl1_sentry_atk3;

float(entity targ) tfvisible = 
{
	local vector spot1;
	local vector spot2;
	spot1 = self.origin + '0 0 20' + self.view_ofs + '0 0 20';
	spot2 = targ.origin + targ.view_ofs;
	traceline(spot1, spot2, TF_FLARE_OFF, self);
	if (trace_inopen && trace_inwater)
	{
		return TF_FLARE_LIT;
	}
	if (trace_fraction == TF_FLARE_OFF)
	{
		return TF_FLARE_OFF;
	}
	return TF_FLARE_LIT;
};


void () lvl1_sentry_stand = [ 0, lvl1_sentry_stand ]
{
	Sentry_Rotate ();
};

void () lvl1_sentry_atk1 = [ 1, lvl1_sentry_atk3 ]
{
	ai_face ();

	local vector temp;
	temp = vectoangles(self.enemy.origin - self.origin);
	self.barrel_ent.angles_x = -temp_x;

	if (((((self.enemy == world) || (self.enemy.health <= 0)) || !tfvisible (self.enemy)) || (self.enemy.has_disconnected == 1)))
	{
		lvl1_sentry_stand ();
	}
	else
	{
		if ((self.ammo_shells <= 0))
		{
			lvl1_sentry_stand ();
		}
		else
		{
			if ((Sentry_Fire () == 0))
			{
				lvl1_sentry_atk3 ();
			}
		}
	}
};

void () lvl1_sentry_atk2 = [ 2, lvl1_sentry_atk3 ]
{
	ai_face ();
	Sentry_Fire ();
};

void () lvl1_sentry_atk3 = [ 0, lvl1_sentry_atk1 ]
{
	ai_face ();
};
void () lvl2_sentry_atk3;

void () lvl2_sentry_stand = [ 3, lvl2_sentry_stand ]
{
	Sentry_Rotate ();
};

void () lvl2_sentry_atk1 = [ 4, lvl2_sentry_atk2 ]
{
	ai_face ();
	if (((((self.enemy == world) || (self.enemy.health <= 0)) || !tfvisible (self.enemy)) || (self.enemy.has_disconnected == 1)))
	{
		lvl2_sentry_stand ();
	}
	else
	{
		if ((self.ammo_shells <= 0))
		{
			lvl2_sentry_stand ();
		}
		else
		{
			if ((Sentry_Fire () == 0))
			{
				lvl2_sentry_atk3 ();
			}
		}
	}
};

void () lvl2_sentry_atk2 = [ 5, lvl2_sentry_atk3 ]
{
	ai_face ();
	Sentry_Fire ();
};

void () lvl2_sentry_atk3 = [ 3, lvl2_sentry_atk1 ]
{
	ai_face ();
	Sentry_Fire ();
};
void () lvl3_sentry_atk3;

void () lvl3_sentry_stand = [ 6, lvl3_sentry_stand ]
{
	Sentry_Rotate ();
};

void () lvl3_sentry_atk1 = [ 7, lvl3_sentry_atk2 ]
{
	ai_face ();
	if (((((self.enemy == world) || (self.enemy.health <= 0)) || !tfvisible (self.enemy)) || (self.enemy.has_disconnected == 1)))
	{
		lvl3_sentry_stand ();
	}
	else
	{
		if (((self.ammo_shells <= 0) && (self.ammo_rockets <= 0)))
		{
			lvl3_sentry_stand ();
		}
		else
		{
			if ((Sentry_Fire () == 0))
			{
				lvl3_sentry_atk3 ();
			}
		}
	}
};

void () lvl3_sentry_atk2 = [ 8, lvl3_sentry_atk3 ]
{
	ai_face ();
	Sentry_Fire ();
};

void () lvl3_sentry_atk3 = [ 6, lvl3_sentry_atk1 ]
{
	ai_face ();
	Sentry_Fire ();
};

void () Sentry_Rotate =
{
	local float ay;
	local entity gunhead;

	CheckSentry (self);
	if (Sentry_FindTarget ())
	{
		return;
	}
	if ((self.heat == 0))
	{
		self.ideal_yaw = self.waitmin;
		ChangeYaw ();
		ay = anglemod (self.angles_y);
		ay = rint (ay);
		if ((ay == rint (self.waitmin)))
		{
			CheckBelowBuilding (self.trigger_field);
			self.heat = 1;
			if ((random () < 0.1))
			{
				sound (self, 3, "weapons/turridle.wav", 1, 1);
			}
		}
	}
	else
	{
		self.ideal_yaw = self.waitmax;
		ChangeYaw ();
		ay = anglemod (self.angles_y);
		ay = rint (ay);
		if ((ay == rint (self.waitmax)))
		{
			CheckBelowBuilding (self.trigger_field);
			self.heat = 0;
		}
	}

/*	local entity oldself;
	oldself = self;
//	self.barrel_ent.ideal_yaw = self.ideal_yaw;
	self = self.barrel_ent;
	self.ideal_yaw = anglemod(newmis.angles_z + 50);
	ChangeYaw();
	self = oldself;*/

};

float () Sentry_FindTarget =
{
	local entity client;
	local float r;
	local float gotone;
	local float loopc;

	r = 0;
	loopc = 0;
	gotone = 0;
	client = findradius (self.origin + '20 0 0', 480);
	while (((client != world) && (gotone != 1)))
	{
		gotone = 1;
		if (!client)
		{
			gotone = 0;
		}
		if ((client == self))
		{
			gotone = 0;
		}
		if ((client.has_disconnected == 1))
		{
			gotone = 0;
		}
		if (!client.takedamage)
		{
			gotone = 0;
		}
/*		if (teamplay)
		{
			if (((client.team_no == self.team_no) && (self.team_no != 0)))
			{
				gotone = 0;
			}
			// replace this with undercover as cloaking code
			if (((client.undercover_team == self.team_no) && (self.team_no != 0)))
			{
				gotone = 0;
			}
		}*/
/*		if ((client == self.real_owner))
		{
			gotone = 0;
		}*/
/*		if (client.is_feigning)				// we gonna add feigning?
		{
			gotone = 0;
		}*/
		if ((client.flags & 128))
		{
			gotone = 0;
		}
		if ((client.items & 524288))
		{
			gotone = 0;
		}
		if (!tfvisible (client))
		{
			gotone = 0;
		}
		r = range (client);
		if ((r == 3))
		{
			gotone = 0;
		}
		else
		{
			if (((r == 2) && !infront (client)))
			{
				gotone = 0;
			}
		}
		if (!gotone)
		{
			client = client.chain;
		}
	}
	if (!gotone)
	{
		return (0);
	}
	self.enemy = client;
	Sentry_FoundTarget ();
	return (1);
};

void () Sentry_FoundTarget =
{
	if (((self.ammo_shells > 0) || ((self.ammo_rockets > 0) && (self.weapon == 3))))
	{
		sound (self, 2, "weapons/turrspot.wav", 1, 1);
	}
	Sentry_HuntTarget ();
	if ((self.super_damage_finished < time))
	{
		self.super_damage_finished = (time + 0.5);
	}
};

void () Sentry_HuntTarget =
{
	self.goalentity = self.enemy;
	if ((self.weapon == 1))
	{
		self.think = lvl1_sentry_atk1;
	}
	else
	{
		if ((self.weapon == 2))
		{
			self.think = lvl2_sentry_atk1;
		}
		else
		{
			self.think = lvl3_sentry_atk1;
		}
	}
	self.ideal_yaw = vectoyaw ((self.enemy.origin - self.origin));

	local vector temp;
	temp = vectoangles(self.enemy.origin - self.origin);
	self.barrel_ent.angles_x = -temp_x;

/*	if (temp_x > 30)
		temp_x = 30;
	if (temp_x < -30)
		temp_x = -30;*/

	/*zchange = ((self.enemy.origin - self.barrel_ent.origin) * .1);
	if (zchange > 30)
	{
		self.barrel_ent.angles_x = 30;
	}
	else if (zchange < 30)
	{
		self.barrel_ent.angles_x = -30;
	}
	else
	{
		self.barrel_ent.angles_x = zchange;
	}*/

	//self.barrel_ent.angles_z = self.barrel_ent.ideal_yaw_z;

//	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
//	self.ideal_yaw = anglemod(self.ideal_yaw);

	self.nextthink = (time + 0.1);
	SUB_AttackFinished (1);
};

void () Sentry_Pain =
{
	self.real_owner.StatusRefreshTime = (time + 0.2);
};

void () Sentry_Explode =
{
/*	ThrowGib ("progs/tgib1.mdl", -70);			// reokace with throw metal chunks code.
	ThrowGib ("progs/tgib2.mdl", -70);
	ThrowGib ("progs/tgib3.mdl", -70);*/
	if ((self.real_owner.has_disconnected != 1))
	{
		deathmsg = 38;
		T_RadiusDamage (self, self.real_owner, (75 + (self.ammo_rockets * 8)), self);
	}
	if ((self.classname == "building_sentrygun_base"))
	{
		if (self.oldenemy)
		{
			dremove (self.oldenemy);
		}
	}
	else
	{
		dremove (self.trigger_field);
	}
	WriteByte (0, 23);
	WriteByte (0, 3);
	WriteCoord (0, self.origin_x);
	WriteCoord (0, self.origin_y);
	WriteCoord (0, self.origin_z);
	BecomeExplosion ();
};

void () Sentry_Die =
{
	sprint (self.real_owner, "Your sentry gun was destroyed.\n");
	self.real_owner.has_sentry = 0;
	self.think = Sentry_Explode;
	self.nextthink = (time + 0.1);
};

void W_Sentry_Fire(vector org, vector vel, float damage)
{
	entity spike;
	spike = spawn ();
	spike.enemy = self.owner;
	spike.owner = self;
	spike.classname = "spike";

	spike.movetype = MOVETYPE_FLY;
	spike.solid = SOLID_BBOX;
	setmodel(spike, "models/plasmatrail.mdl");
	setsize(spike, '0 0 0', '0 0 0');
	setorigin(spike, org);

	spike.dmg = damage;

	spike.nextthink = time + 3 + random()*0.5;
	spike.think = SUB_Remove;
	spike.touch = W_NailGrenade_Spike_Poke;
	spike.velocity = vel * 6;
	spike.angles = vectoangles (spike.velocity);
//	spike.scale = 0.75;

//	setattachment(spike, self.barrel_ent, "tag_body_barrel");
}

float () Sentry_Fire =
{
	self.ammo_shells = 50;		//temp

	local vector dir;

	dir = (self.enemy.origin - self.origin);
	if ((((self.ideal_yaw - anglemod (self.angles_y)) < -10) || ((self.ideal_yaw - anglemod (self.angles_y)) > 10)))
	{
		return (0);
	}
	if ((((self.weapon == 3) && (self.ammo_rockets > 0)) && (self.super_damage_finished < time)))
	{
		Sentry_MuzzleFlash ();
		sound (self, 1, "weapons/rocket1i.wav", 1, 1);
		newmis = spawn ();
		newmis.owner = self;
		newmis.movetype = 9;
		newmis.solid = 2;
		newmis.velocity = (normalize ((self.enemy.origin - self.origin)) * 800);
		newmis.angles = vectoangles (newmis.velocity);
		newmis.weapon = 34;
//		newmis.touch = T_MissileTouch;
		newmis.touch = W_Rocket_Touch;
		newmis.nextthink = (time + 5);
		newmis.think = SUB_Remove;
		setmodel (newmis, "progs/missile.mdl");
		setsize (newmis, '0 0 0', '0 0 0');
		setorigin (newmis, ((self.origin + (v_forward * 8)) + '0 0 16'));
		self.super_damage_finished = (time + 3);
		self.ammo_rockets = (self.ammo_rockets - 1);
		if ((self.ammo_rockets == 10))
		{
			sprint (self.real_owner, "Sentry Gun is low on rockets.\n");
		}
	}
	self.ammo_shells = (self.ammo_shells - 1);
	if ((self.ammo_shells < 0))
	{
		self.ammo_shells = 0;
		return (0);
	}
	Sentry_MuzzleFlash ();
	sound (self, 1, "weapons/sniper.wav", 1, 1);
	deathmsg = 27;

	local float barrel_tag;
	local vector fire_from;

//	barrel_tag = gettagindex (self.barrel_ent, "tag_bullet");
	barrel_tag = gettagindex (self.barrel_ent, "tag_barrel_bullet1");
	fire_from = gettaginfo (self.barrel_ent, barrel_tag);


/*	bprint (ftos(barrel_tag));
	bprint ("   \n");
	bprint (vtos(fire_from));
	bprint ("\n");*/

//fire_from = fire_from + v_forward + v_up + v_right;
//void fireBullet (vector start, vector dir, float spread, float damage, float dtype, float tracer);
	//(entity targ, entity inflictor, entity attacker, float damage) T_Damage
//	fireBullet (fire_from, dir, .1, 2, 666, 1);
//	T_Damage(self.enemy, self, self, 4);
//fire_from = fire_from + self.barrel_ent.view_ofs + v_forward + v_right + v_up;

local entity testent;
local entity testent2;

testent = spawn ();
testent.movetype = 0;
testent.solid = SOLID_BBOX;
setmodel(testent, "models/sentry/bullet.MD3");
//setorigin(testent, fire_from);
setattachment(testent, self.barrel_ent, "tag_barrel_bullet1");

barrel_tag = gettagindex (testent, "");
fire_from = gettaginfo (testent, barrel_tag);
dir = (self.enemy.origin - fire_from);


//barrel_tag = gettagindex (testent, "tag_bullet");
//fire_from = gettaginfo (testent, testent.tag_index);
//dir = (self.enemy.origin - fire_from);

/*testent2 = spawn ();
testent2.movetype = 0;
testent2.solid = SOLID_BBOX;
//testent2.scale = 5;
setmodel(testent2, "models/plasmatrail.mdl");
setorigin(testent2, fire_from);*/


	W_Sentry_Fire(fire_from, dir, 4);

//	FireBullets (4, dir, '0.1 0.1 0');
	if (((self.ammo_shells == 0) && (random () < 0.1)))
	{
		sprint (self.real_owner, "Sentry Gun is out of shells.\n");
	}
	else
	{
		if ((self.ammo_shells == 20))
		{
			sprint (self.real_owner, "Sentry Gun is low on shells.\n");
		}
	}
	if ((((self.ammo_rockets == 0) && (self.weapon == 3)) && (random () < 0.1)))
	{
		sprint (self.real_owner, "Sentry Gun is out of rockets.\n");
	}
	return (1);
};

void () Sentry_MuzzleFlash =
{
	self.effects = (self.effects | 2);
};
