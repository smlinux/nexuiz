
.float rl_sound;

void W_Rocket_Explode (void)
{
	vector	org2;
	sound (self, CHAN_BODY, "weapons/rocket_impact.wav", 1, ATTN_NORM);
	org2 = findbetterlocation (self.origin, 16);

	//te_explosion (org2);
	// LordHavoc: TE_TEI_BIGEXPLOSION
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, 78);
	WriteCoord (MSG_BROADCAST, org2_x);
	WriteCoord (MSG_BROADCAST, org2_y);
	WriteCoord (MSG_BROADCAST, org2_z);

	//effect (org2, "models/sprites/rockexpl.spr", 0, 12, 35);
	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, cvar("g_balance_rocketlauncher_damage"), cvar("g_balance_rocketlauncher_edgedamage"), cvar("g_balance_rocketlauncher_radius"), world, cvar("g_balance_rocketlauncher_force"), IT_ROCKET_LAUNCHER);

	if (self.owner.weapon == WEP_ROCKET_LAUNCHER)
	{
		if(self.owner.ammo_rockets < cvar("g_balance_rocketlauncher_ammo"))
		{
			self.owner.cnt = WEP_ROCKET_LAUNCHER;
			self.owner.attack_finished = time;
			self.owner.switchweapon = w_getbestweapon(self.owner);
		}
		if(cvar("g_laserguided_missile"))
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
	float turnrate, velspeed;
	self.nextthink = time;
	if (time > self.cnt)
	{
		W_Rocket_Explode ();
		return;
	}

	if(cvar("g_laserguided_missile"))
	{
		// accelerate
		makevectors(self.angles_x * '-1 0 0' + self.angles_y * '0 1 0');
		velspeed = cvar("g_balance_rocketlauncher_laserguided_speed") - (self.velocity * v_forward);
		if (velspeed > 0)
			self.velocity = self.velocity + v_forward * min(cvar("g_balance_rocketlauncher_laserguided_speedaccel") * frametime, velspeed);
	}
	else
	{
		// accelerate
		makevectors(self.angles_x * '-1 0 0' + self.angles_y * '0 1 0');
		velspeed = cvar("g_balance_rocketlauncher_speed") - (self.velocity * v_forward);
		if (velspeed > 0)
			self.velocity = self.velocity + v_forward * min(cvar("g_balance_rocketlauncher_speedaccel") * frametime, velspeed);
	}

	// laser guided, or remote detonation
	if (self.owner.weapon == WEP_ROCKET_LAUNCHER)
	{
		if(cvar("g_laserguided_missile"))
		{
			if(!self.owner.button0)
				self.ltime = -1; // indicate that the player has let go of the button


			if(self.owner.deadflag == DEAD_NO)
			if (self.owner.button0 && self.ltime < 0) // if the player let go of the button and then pushed it again
			{
				  W_Rocket_Explode ();
				  return;
			}

			if(cvar("g_balance_rocketlauncher_laserguided_allow_steal"))
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
				//bprint("Targeting ", self.enemy.owner.netname, "'s laser\n");
				velspeed = vlen(self.velocity);
				e = self.enemy;//self.owner.weaponentity.lasertarget;
				turnrate = cvar("g_balance_rocketlauncher_laserguided_turnrate");//0.65;						// how fast to turn
				desireddir = normalize(e.origin - self.origin);		// get direction from my position to the laser target
				olddir = normalize(self.velocity);					// get my current direction
				newdir = normalize((olddir + desireddir * turnrate) * 0.5);	// take the average of the 2 directions; not the best method but simple & easy
				self.velocity = newdir * velspeed;					// make me fly in the new direction at my flight speed
				self.angles = vectoangles(self.velocity);			// turn model in the new flight direction

				self.owner.attack_finished = time + 0.2;
			}
		}
		else
		{
			if(self.owner.deadflag == DEAD_NO)
			if (self.owner.button3)
				  W_Rocket_Explode ();
		}
	}
}

void W_Rocket_Touch (void)
{
	if(self.owner && self.owner.lastrocket == self)
		self.owner.lastrocket = world;
	if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
	{
		sound (self, CHAN_BODY, "misc/null.wav", 1, ATTN_NORM);
		remove(self);
		return;
	}
	W_Rocket_Explode ();
}

void W_Rocket_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	self.health = self.health - damage;
	self.angles = vectoangles(self.velocity);
	if (self.health <= 0)
	{
		self.owner = attacker;
		W_Rocket_Explode();
	}
}

void W_Rocket_Attack (void)
{
	local entity missile;
	local entity flash, flash2;

	if (cvar("g_use_ammunition") && !cvar("g_rocketarena"))
		self.ammo_rockets = self.ammo_rockets - cvar("g_balance_rocketlauncher_ammo");

	W_SetupShot (self, '8 3 -8', FALSE, 5, "weapons/rocket_fire.wav");
	te_smallflash(w_shotorg);

	missile = spawn ();
	missile.owner = self;
	self.lastrocket = missile;
	missile.classname = "missile";
	missile.bot_dodge = TRUE;
	missile.bot_dodgerating = cvar("g_balance_rocketlauncher_primary_damage") * 2; // * 2 because it can be detonated inflight which makes it even more dangerous

	missile.takedamage = DAMAGE_YES;
	missile.damageforcescale = 4;
	missile.health = 30;
	missile.event_damage = W_Rocket_Damage;

	missile.movetype = MOVETYPE_FLY;
	missile.solid = SOLID_BBOX;
	setmodel (missile, "models/rocket.md3"); // precision set below
	setsize (missile, '-3 -3 -3', '3 3 3'); // give it some size so it can be shot

	setorigin (missile, w_shotorg);
	if(cvar("g_laserguided_missile") && self.laser_on)
		missile.velocity = w_shotdir * cvar("g_balance_rocketlauncher_laserguided_speedstart");
	else
		missile.velocity = w_shotdir * cvar("g_balance_rocketlauncher_speedstart");
	W_SetupProjectileVelocity(missile);
	missile.angles = vectoangles (missile.velocity);

	missile.touch = W_Rocket_Touch;
	missile.think = W_Rocket_Think;
	missile.nextthink = time;
	missile.cnt = time + cvar("g_balance_rocketlauncher_lifetime");
	missile.effects = EF_LOWPRECISION;
	sound (missile, CHAN_BODY, "weapons/rocket_fly.wav", 0.4, ATTN_NORM);
	missile.flags = FL_PROJECTILE;

	// muzzle flash for 1st person view
	flash = spawn ();
	flash.scale = 1.2;
	flash.angles_z = 180;
	flash.owner = self;
	flash.viewmodelforclient = self;
	flash.customizeentityforclient = CL_Weaponentity_CustomizeEntityForClient;
	setorigin (flash, '35 5 -12');
	setmodel (flash, "models/flash.md3"); // precision set below
	setattachment(flash, self.weaponentity, "bone01");
	SUB_SetFade (flash, time, 0.4);

	// muzzle flash for 3rd person view
	flash2 = spawn ();
	flash2.scale = 0.8;
	flash2.angles_y = 180;
	flash2.angles_z = 90;
	setorigin (flash2, '42 0 5');
	setmodel (flash2, "models/flash.md3"); // precision set below
	setattachment(flash2, self.exteriorweaponentity, "");
	SUB_SetFade (flash2, time, 0.4);

	// common properties
	flash.effects = flash2.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
}

float(float req) w_rlauncher =
{
	if (req == WR_AIM)
	{
		// aim and decide to fire if appropriate
		self.button0 = bot_aim(cvar("g_balance_rocketlauncher_speed"), 0, cvar("g_balance_rocketlauncher_lifetime"), FALSE);
		if(skill >= 2) // skill 0 and 1 bots won't detonate rockets!
		{
			// decide whether to detonate rockets
			local entity missile, targetlist, targ;
			local float edgedamage, coredamage, edgeradius, recipricoledgeradius, d;
			local float selfdamage, teamdamage, enemydamage;
			edgedamage = cvar("g_balance_rocketlauncher_edgedamage");
			coredamage = cvar("g_balance_rocketlauncher_damage");
			edgeradius = cvar("g_balance_rocketlauncher_radius");
			recipricoledgeradius = 1 / edgeradius;
			selfdamage = 0;
			teamdamage = 0;
			enemydamage = 0;
			targetlist = findchainfloat(bot_attack, TRUE);
			missile = find(world, classname, "missile");
			while (missile)
			{
				if (missile.owner != self)
				{
					missile = find(missile, classname, "missile");
					continue;
				}
				targ = targetlist;
				while (targ)
				{
					d = vlen(targ.origin + (targ.mins + targ.maxs) * 0.5 - missile.origin);
					d = bound(0, edgedamage + (coredamage - edgedamage) * sqrt(1 - d * recipricoledgeradius), 10000);
					// count potential damage according to type of target
					if (targ == self)
						selfdamage = selfdamage + d;
					else if (targ.team == self.team && teamplay)
						teamdamage = teamdamage + d;
					else if (bot_shouldattack(targ))
						enemydamage = enemydamage + d;
					targ = targ.chain;
				}
				missile = find(missile, classname, "missile");
			}
			local float desirabledamage;
			desirabledamage = enemydamage;
			if (teamplay != 1 && time > self.invincible_finished && time > self.spawnshieldtime)
				desirabledamage = desirabledamage - selfdamage * cvar("g_balance_selfdamagepercent");
			if (self.team && teamplay == 2)
				desirabledamage = desirabledamage - teamdamage;

			missile = find(world, classname, "missile");
			while (missile)
			{
				if (missile.owner != self)
				{
					missile = find(missile, classname, "missile");
					continue;
				}
				makevectors(missile.v_angle);
				targ = targetlist;
				if (skill > 9) // normal players only do this for the target they are tracking
				{
					targ = targetlist;
					while (targ)
					{
						if (
							(v_forward * normalize(missile.origin - targ.origin)< 0.1)
							&& desirabledamage > 0.1*coredamage
						)self.button3 = TRUE;
						targ = targ.chain;
					}
				}else{
					local float distance; distance= bound(300,vlen(self.origin-self.enemy.origin),30000);
					//As the distance gets larger, a correct detonation gets near imposible
					//Bots are assumed to use the rocket light to see if the rocket gets near a player
					if(v_forward * normalize(missile.origin - self.enemy.origin)< 0.1)
						if(self.enemy.classname == "player")
							if(desirabledamage >= 0.1*coredamage)
								if(random()/distance*300 > frametime*bound(0,(10-skill)*0.2,1))
									self.button3 = TRUE;
				//	dprint(ftos(random()/distance*300),">");dprint(ftos(frametime*bound(0,(10-skill)*0.2,1)),"\n");
				}

				missile = find(missile, classname, "missile");
			}
			// if we would be doing at X percent of the core damage, detonate it
			// but don't fire a new shot at the same time!
			if (desirabledamage >= 0.75 * coredamage) //this should do group damage in rare fortunate events
				self.button3 = TRUE;
			if ((skill > 6.5) && (selfdamage > self.health))
				self.button3 = FALSE;
			//if(self.button3 == TRUE)
			//	dprint(ftos(desirabledamage),"\n");
			if (self.button3 == TRUE) self.button0 = FALSE;
		}
	}
	else if (req == WR_THINK)
	{
		if (self.button0)
		if (weapon_prepareattack(0, cvar("g_balance_rocketlauncher_refire")))
		{
			W_Rocket_Attack();
			weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_rocketlauncher_animtime"), w_ready);
		}
		if (self.button3)
		if(time > self.rl_sound)
		{
			self.rl_sound = time + 1;
			sound (self, CHAN_BODY, "weapons/rocket_det.wav", 0.5, ATTN_NORM);
		}
		if (self.button3)
		if(cvar("g_laserguided_missile"))
		if(self.exteriorweaponentity.attack_finished < time)
		{
			self.exteriorweaponentity.attack_finished = time + 0.4;
			self.laser_on = !self.laser_on;
			sound (self, CHAN_AUTO, "weapons/tink1.wav", 1, ATTN_NORM);
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/flash.md3");
		precache_model ("models/rocket.md3");
		precache_model ("models/weapons/g_rl.md3");
		precache_model ("models/weapons/v_rl.md3");
		precache_model ("models/weapons/w_rl.zym");
		precache_sound ("weapons/rocket_det.wav");
		precache_sound ("weapons/rocket_fire.wav");
		precache_sound ("weapons/rocket_fly.wav");
		precache_sound ("weapons/rocket_impact.wav");
		if (cvar("g_laserguided_missile"))
			precache_model ("models/laser_dot.mdl"); // rocket launcher
	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_ROCKET_LAUNCHER, "rl", IT_ROCKETS);
	else if (req == WR_CHECKAMMO1)
	{
		// don't switch while guiding a missile
		if ((self.attack_finished <= time || self.weapon != WEP_ROCKET_LAUNCHER)
			&& self.ammo_rockets < cvar("g_balance_rocketlauncher_ammo"))
			return FALSE;
	}
	else if (req == WR_CHECKAMMO2)
		return FALSE;
	return TRUE;
};
