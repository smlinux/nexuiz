void() rlauncher_ready_01;
void() rlauncher_fire1_01;
void() rlauncher_deselect_01;
void() rlauncher_select_01;

float() rlauncher_check =
{
	if (self.attack_finished > time  // don't switch while guiding a missile
		|| self.ammo_rockets >= 3)
		return TRUE;
	return FALSE;
};

void(float req) w_rlauncher =
{
	if (req == WR_IDLE)
		rlauncher_ready_01();
	else if (req == WR_FIRE1)
		weapon_prepareattack(rlauncher_check, rlauncher_check, rlauncher_fire1_01, cvar("g_balance_rocketlauncher_refire"));
	else if (req == WR_FIRE2 && cvar("g_homing_missile"))
	{
		if(self.exteriorweaponentity.attack_finished < time)
		{
			self.exteriorweaponentity.attack_finished = time + 0.4;
			self.laser_on = !self.laser_on;
			sound (self, CHAN_AUTO, "weapons/tink1.ogg", 1, ATTN_NORM);
		}
	}
	else if (req == WR_RAISE)
		rlauncher_select_01();
	else if (req == WR_UPDATECOUNTS)
		self.currentammo = self.ammo_rockets;
	else if (req == WR_DROP)
		rlauncher_deselect_01();
	else if (req == WR_SETUP)
		weapon_setup(WEP_ROCKET_LAUNCHER, "w_rl.zym", IT_ROCKETS);
	else if (req == WR_CHECKAMMO)
		weapon_hasammo = rlauncher_check();
};


void W_Rocket_Explode (void)
{
	vector	org2;
	org2 = findbetterlocation (self.origin);
	te_explosion (org2);
	effect (org2, "models/sprites/rockexpl.spr", 0, 12, 25);
	sound (self, CHAN_BODY, "weapons/rocket_impact.ogg", 1, ATTN_NORM);

	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, cvar("g_balance_rocketlauncher_damage"), cvar("g_balance_rocketlauncher_edgedamage"), cvar("g_balance_rocketlauncher_radius"), world, cvar("g_balance_rocketlauncher_force"), IT_ROCKET_LAUNCHER);

	if (self.owner.weapon == WEP_ROCKET_LAUNCHER)
	{
		if(cvar("g_homing_missile"))
				  self.owner.attack_finished = time + cvar("g_balance_rocketlauncher_refire");
	}

	remove (self);
}

entity FindLaserTarget(entity e, float dist_variance, float dot_variance)
{
	entity head, selected;
	vector dir;
	float dist, maxdist,// bestdist,
		dot,// bestdot,
		points, bestpoints;
	//bestdist = 9999;
	//bestdot = -2;
	bestpoints = 0;
	maxdist = 800;
	selected = world;

	makevectors(e.angles);

	head = find(world, classname, "laser_target");
	while(head)
	{
		points = 0;
		dir = normalize(head.origin - self.origin);
		dot = dir * v_forward;
		dist = vlen(head.origin - self.origin);
		if(dist > maxdist)
			dist = maxdist;

		// gain points for being in front
		points = points + ((dot+1)*0.5) * 500
			* (1 + crandom()*dot_variance);
		// gain points for being close away
		points = points + (1 - dist/maxdist) * 1000
			* (1 + crandom()*dot_variance);

		traceline(e.origin, head.origin, TRUE, self);
		if(trace_fraction < 1)
		{
			points = 0;
		}

		if(points > bestpoints)//random() > 0.5)//
		{
			bestpoints = points;
			selected = head;
		}


		/*
		dot = dir * v_forward;
		if(dot > bestdot * (1 + crandom()*dot_variance))
		{
			dist = vlen(head.origin - self.origin);
			if(dist < bestdist * (1 + crandom()*dist_variance))
			{
				traceline(e.origin, head.origin, TRUE, self);
				if(trace_fraction >= 1)
				{
				}
			}
		}
		*/
		head = find(head, classname, "laser_target");
	}

	//bprint(selected.owner.netname);
	//bprint("\n");
	return selected;
}

void W_Rocket_Think (void)
{
	entity e;
	vector desireddir, olddir, newdir;
	float turnrate;
	self.nextthink = time;
	if (time > self.cnt)
	{
		W_Rocket_Explode ();
		return;
	}
	if (self.owner.weapon == WEP_ROCKET_LAUNCHER)
	{
		if(cvar("g_homing_missile"))
		{
			if(!self.owner.button0)
				self.ltime = -1; // indicate that the player has let go of the button


			if (self.owner.button0 && self.ltime < 0) // if the player let go of the button and then pushed it again
			{
				  W_Rocket_Explode ();
				  return;
			}

			if(cvar("g_balance_rocketlauncher_homing_allow_steal"))
			{
				if(self.owner.laser_on)
				{
					if(self.attack_finished < time)
					{
						self.attack_finished = time + 0.2 + random()*0.3;
						self.enemy = FindLaserTarget(self, 0.7, 0.7);
					}

					if(!self.enemy)
						self.enemy = self.owner.weaponentity.lasertarget;
				}
				else self.enemy = world;
			}
			else // don't allow stealing: always target my owner's laser (if it exists)
				self.enemy = self.owner.weaponentity.lasertarget;

			if(self.enemy != world)
			{
				//bprint(strcat("Targeting ", self.enemy.owner.netname, "'s laser\n"));
				if(!self.speed)
					self.speed = vlen(self.velocity);
				e = self.enemy;//self.owner.weaponentity.lasertarget;
				turnrate = cvar("g_balance_rocketlauncher_homing_turnrate");//0.65;						// how fast to turn
				desireddir = normalize(e.origin - self.origin);		// get direction from my position to the laser target
				olddir = normalize(self.velocity);				// get my current direction
				newdir = normalize((olddir + desireddir * turnrate) * 0.5);	// take the average of the 2 directions; not the best method but simple & easy
				self.velocity = newdir * self.speed;			// make me fly in the new direction at my flight speed
				self.angles = vectoangles(self.velocity);			// turn model in the new flight direction

				self.owner.attack_finished = time + 0.2;
			}
		}
		else
		{
			if (self.owner.button3)
				  W_Rocket_Explode ();
		}
	}
}

void W_Rocket_Touch (void)
{
	if (pointcontents (self.origin) == CONTENT_SKY)
	{
		remove (self);
		return;
	}
	else
		W_Rocket_Explode ();
}

void W_Rocket_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	self.health = self.health - damage;
	if (self.health <= 0)
		W_Rocket_Explode();
}

void W_Rocket_Attack (void)
{
	local entity missile;
	local entity flash;
	local vector org;
	sound (self, CHAN_WEAPON, "weapons/rocket_fire.ogg", 1, ATTN_NORM);
	if (cvar("g_use_ammunition") && !cvar("g_rocketarena"))
		self.ammo_rockets = self.ammo_rockets - 3;
	self.punchangle_x = -4;
	org = self.origin + self.view_ofs + v_forward * 15 + v_right * 3 + v_up * -11;
	te_smallflash(org);

	missile = spawn ();
	missile.owner = self;
	missile.classname = "missile";

	missile.takedamage = DAMAGE_YES;
	missile.damageforcescale = 4;
	missile.health = 30;
	missile.event_damage = W_Rocket_Damage;

	missile.movetype = MOVETYPE_FLY;
	missile.solid = SOLID_BBOX;
	setmodel (missile, "models/rocket.md3");
	setsize (missile, '0 0 0', '0 0 0');

	setorigin (missile, org);
	if(cvar("g_homing_missile") && self.laser_on)
		missile.velocity = v_forward * cvar("g_balance_rocketlauncher_homing_speed");
	else
		missile.velocity = v_forward * cvar("g_balance_rocketlauncher_speed");
	missile.angles = vectoangles (missile.velocity);

	missile.touch = W_Rocket_Touch;
	missile.think = W_Rocket_Think;
	missile.nextthink = time;
	missile.cnt = time + 9;
	sound (missile, CHAN_BODY, "weapons/rocket_fly.wav", 0.4, ATTN_NORM);

	flash = spawn ();
	setorigin (flash, org);
	setmodel (flash, "models/flash.md3");
	flash.velocity = v_forward * 20;
	flash.angles = vectoangles (flash.velocity);
	SUB_SetFade (flash, time, 0.4);
	flash.effects = flash.effects | EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
}

// weapon frames

void()	rlauncher_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, rlauncher_ready_01); self.weaponentity.state = WS_READY;};
void()	rlauncher_select_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0'); self.laser_on = 1;};
void()	rlauncher_deselect_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);  self.laser_on = 0;};
void()	rlauncher_fire1_01 =
{
	weapon_doattack(rlauncher_check, rlauncher_check, W_Rocket_Attack);
	weapon_thinkf(WFRAME_FIRE1, 0.3, rlauncher_ready_01);
};
