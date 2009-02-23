//.float speed; = switchweapon
//.float proxytime; = autoswitch
//.float tl; = wait

void Seeker_Missile_Explode ()
{
	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, cvar("g_balance_seeker_missile_damage"), cvar("g_balance_seeker_missile_edgedamage"), cvar("g_balance_seeker_missile_radius"), world, cvar("g_balance_seeker_missile_force"), self.projectiledeathtype, other);

	remove (self);
}

void Seeker_Missile_Touch()
{
	PROJECTILE_TOUCH;

	Seeker_Missile_Explode();
}

void Seeker_Missile_Think()
{
	entity e;
	vector desireddir, olddir, newdir, eorg;
	float turnrate;
	float dist;

	if (time > self.cnt)
		Seeker_Missile_Explode();

	if (!self.switchweapon)
		self.switchweapon = cvar("g_balance_seeker_missile_speed");

	if ((self.switchweapon < cvar("g_balance_seeker_missile_speed_max")) && cvar("g_balance_seeker_missile_speed_accel"))
		self.switchweapon = self.switchweapon * cvar("g_balance_seeker_missile_accel");

	if (self.switchweapon > cvar("g_balance_seeker_missile_speed_max"))
		self.switchweapon = self.switchweapon * cvar("g_balance_seeker_missile_decel");

	if (self.enemy != world)
		if (self.enemy.takedamage != DAMAGE_AIM || self.enemy.deadflag != DEAD_NO)
			self.enemy = world;

	if (self.enemy != world)
	{
		e               = self.enemy;
		eorg            = 0.5 * (e.absmin + e.absmax);
		turnrate        = cvar("g_balance_seeker_missile_turnrate");		    // how fast to turn
		desireddir      = normalize(eorg - self.origin);
		olddir          = normalize(self.velocity);				            // get my current direction
		dist            = vlen(eorg - self.origin);

		// Do evasive maneuvers for world objects? ( this should be a cpu hog. :P )
		if (cvar("g_balance_seeker_missile_smart") && (dist > cvar("g_balance_seeker_missile_smart_mindist")))
		{
			// Is it a better idea (shorter distance) to trace to the target itself?
			if ( vlen(self.origin + olddir * self.wait) < dist)
				traceline(self.origin, self.origin + olddir * self.wait, FALSE, self);
			else
				traceline(self.origin, eorg, FALSE, self);

			// Setup adaptive tracelength
			self.wait = vlen(self.origin - trace_endpos);
			if (self.wait < cvar("g_balance_seeker_missile_smart_trace_min")) self.wait = cvar("g_balance_seeker_missile_smart_trace_min");
			if (self.wait > cvar("g_balance_seeker_missile_smart_trace_max")) self.wait = cvar("g_balance_seeker_missile_smart_trace_max");

			// Calc how important it is that we turn and add this to the desierd (enemy) dir.
			desireddir  = normalize(((trace_plane_normal * (1 - trace_fraction)) + (desireddir * trace_fraction)) * 0.5);
		}

		//newdir = normalize((olddir + desireddir * turnrate) * 0.5);// take the average of the 2 directions; not the best method but simple & easy
		newdir = normalize(olddir + desireddir * turnrate);// take the average of the 2 directions; not the best method but simple & easy

		self.velocity = newdir * self.switchweapon;			                    // make me fly in the new direction at my flight speed
	}

	// Proxy
	if (cvar("g_balance_seeker_missile_proxy"))
	{
		if ( dist <= cvar("g_balance_seeker_missile_proxy_maxrange"))
		{
			if (self.autoswitch == 0)
			{
				self.autoswitch = time + cvar("g_balance_seeker_missile_proxy_delay");
			}
			else
			{
				if (self.autoswitch <= time)
				{
					Seeker_Missile_Explode();
					self.autoswitch = 0;
				}
			}
		}
		else
		{
			if (self.autoswitch != 0)
				self.autoswitch = 0;
		}
	}
	///////////////

	if (self.enemy.deadflag != DEAD_NO)
	{
		self.enemy = world;
		self.cnt = time + 1 + (random() * 4);
		self.nextthink = self.cnt;
		return;
	}

	self.angles = vectoangles(self.velocity);			// turn model in the new flight direction
	self.nextthink = time + 0.05;

	UpdateCSQCProjectile(self);
}



void Seeker_Missile_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	float d;
	d = damage;

	if (self.owner == attacker)
		d = d * 0.25;

	self.health = self.health - d;

	if (self.health <= 0)
		W_PrepareExplosionByDamage(attacker, Seeker_Missile_Explode);
}

void Seeker_Missile_Animate()
{
	self.frame = self.frame +1;
	self.nextthink = time + 0.05;

	if (self.enemy != world)
		if (self.enemy.takedamage != DAMAGE_AIM || self.enemy.deadflag != DEAD_NO)
			self.enemy = world;

	if(self.frame == 5)
	{
		self.think           = Seeker_Missile_Think;
		self.nextthink       = time;// + cvar("g_balance_seeker_missile_activate_delay"); // cant dealy with csqc projectiles

		if (cvar("g_balance_seeker_guided_proxy"))
			self.movetype    = MOVETYPE_BOUNCEMISSILE;
		else
			self.movetype    = MOVETYPE_FLYMISSILE;
	}

	UpdateCSQCProjectile(self);
}

void Seeker_Fire_Missile(vector f_org)
{
	local entity missile;

	if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
		self.ammo_rockets = self.ammo_rockets - cvar("g_balance_seeker_missile_ammo");

	makevectors(self.v_angle);
	W_SetupShot (self, f_org, FALSE, 2, "weapons/seeker_fire.wav");
	pointparticles(particleeffectnum("seeker_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	//self.detornator         = FALSE;

	missile                 = spawn();
	missile.owner           = self;
	missile.classname       = "seeker_missile";
	missile.bot_dodge       = TRUE;
	missile.bot_dodgerating = cvar("g_balance_seeker_missile_damage");

	missile.think           = Seeker_Missile_Animate;

	//if (!cvar("g_balance_seeker_missile_proxy"))
	missile.touch           = Seeker_Missile_Touch;

	missile.event_damage    = Seeker_Missile_Damage;
	missile.nextthink       = time;// + 0.2;// + cvar("g_balance_seeker_missile_activate_delay");
	missile.cnt             = time + cvar("g_balance_seeker_missile_lifetime");
	missile.enemy           = self.enemy;
	missile.switchweapon           = cvar("g_balance_seeker_missile_speed");
	missile.solid           = SOLID_BBOX;
	missile.scale           = 2;
	missile.takedamage          = DAMAGE_YES;
	missile.damageforcescale    = 4;
	missile.health              = 5;
	missile.projectiledeathtype = WEP_SEEKER;

	setorigin (missile, w_shotorg);
	setsize (missile, '-2 -2 -2', '2 2 2');


	missile.movetype    = MOVETYPE_FLYMISSILE;// MOVETYPE_TOSS;

	missile.flags       = FL_PROJECTILE;

	missile.velocity    = (w_shotdir + '0 0 0.45') * missile.switchweapon;
	W_SetupProjectileVelocity(missile);

	missile.switchweapon = vlen(missile.velocity);
	missile.angles = vectoangles (missile.velocity);

	CSQCProjectile(missile, FALSE, PROJECTILE_SEEKER, TRUE);
}

void Seeker_Vollycontroler_Think()
{
	float c;
	entity oldself,oldenemy;
	self.cnt = self.cnt - 1;

	if ((self.owner.ammo_rockets < cvar("g_balance_seeker_missile_ammo")) || (self.cnt <= -1) || (self.owner.deadflag != DEAD_NO))
	{
		remove(self);
		return;
	}

	self.nextthink = time + cvar("g_balance_seeker_missile_delay");

	oldself = self;
	self = self.owner;

	oldenemy = self.enemy;
	self.enemy = oldself.enemy;

	c = mod(oldself.cnt, 4);
	switch(c)
	{
		case 0:
			Seeker_Fire_Missile('37.5 17 -22');
			break;
		case 1:
			Seeker_Fire_Missile('37.5 9.5 -22');
			break;
		case 2:
			Seeker_Fire_Missile('40 17 -29');
			break;
		case 3:
		default:
			Seeker_Fire_Missile('40 9.5 -29');
			break;
	}

	self.enemy = oldenemy;
	self = oldself;
}

void Seeker_Tag_Explode ()
{
	//if(other==self.owner)
	//    return;
	Damage_DamageInfo(self.origin, 0, 0, 0, self.velocity, WEP_SEEKER | HITTYPE_BOUNCE);

	remove (self);
}

void Seeker_Tag_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	self.health = self.health - damage;
	if (self.health <= 0)
		Seeker_Tag_Explode();
}

void Seeker_Tag_Think()
{
	remove(self);
	return;
}

void Seeker_Tag_Touch()
{
	vector dir;
	vector org2;

	dir     = normalize (self.owner.origin - self.origin);
	org2    = findbetterlocation (self.origin, 8);

	te_knightspike(org2);

	self.event_damage = SUB_Null;
	Damage_DamageInfo(self.origin, 0, 0, 0, self.velocity, WEP_SEEKER | HITTYPE_HEADSHOT);

	if (other.takedamage == DAMAGE_AIM && other.deadflag == DEAD_NO)
	{
		entity e;
		e           = spawn();
		e.cnt       = cvar("g_balance_seeker_missile_count");
		e.owner     = self.owner;
		e.enemy     = other;
		e.think     = Seeker_Vollycontroler_Think;
		e.nextthink = time;

		//sprint(self.owner, "^1Target lock ^3[^7 ",other.netname, " ^3]^1 acquired - autofire activated.\n");
		//sprint(other,"^1You are targeted!\n");

		// stuffcmd(other,"play2 weapons/zany-alarm4.ogg\n");
		// stuffcmd(self.owner, "play2 weapons/zany-lock4.ogg\n");
	}

	remove(self);
	return;
}



void Seeker_Fire_Tag()
{
	local entity missile;
	if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
		self.ammo_rockets = self.ammo_rockets - cvar("g_balance_seeker_tag_ammo");

	W_SetupShot (self, '56 13 -15', FALSE, 2, "weapons/tag_fire.wav");

	missile                 = spawn();
	missile.owner           = self;
	missile.classname       = "seeker_tag";
	missile.bot_dodge       = TRUE;
	missile.bot_dodgerating = 50;
	missile.touch           = Seeker_Tag_Touch;
	missile.think           = Seeker_Tag_Think;
	missile.nextthink       = time + 15;
	missile.movetype        = MOVETYPE_FLY;
	missile.solid           = SOLID_BBOX;
	missile.owner           = self;

	missile.takedamage       = DAMAGE_YES;
	missile.event_damage    = Seeker_Tag_Explode;
	missile.health          = 5;

	setorigin (missile, w_shotorg);

	missile.flags       = FL_PROJECTILE;

	missile.velocity    = w_shotdir  * cvar("g_balance_seeker_tag_speed");
	missile.movetype    = MOVETYPE_BOUNCEMISSILE;
	W_SetupProjectileVelocity(missile);
	missile.angles = vectoangles (missile.velocity);

	CSQCProjectile(missile, TRUE, PROJECTILE_TAG, FALSE); // has sound
}


void Seeker_Flac_Explode ()
{
	self.event_damage = SUB_Null;

	RadiusDamage (self, self.owner, cvar("g_balance_seeker_flac_damage"), cvar("g_balance_seeker_flac_edgedamage"), cvar("g_balance_seeker_flac_radius"), world, cvar("g_balance_seeker_flac_force"), self.projectiledeathtype, other);

	remove (self);
}

void Seeker_Flac_Touch()
{
	PROJECTILE_TOUCH;

	Seeker_Flac_Explode();
}

void Seeker_Fire_Flac()
{
	local entity missile;
	vector f_org;
	float c;

	if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
		self.ammo_rockets = self.ammo_rockets - cvar("g_balance_seeker_flac_ammo");

	c = mod(self.bulletcounter, 4);
	switch(c)
	{
		case 1:
			f_org = '37.5 17 -22';
			break;
		case 2:
			f_org = '37.5 9.5 -22';
			break;
		case 3:
			f_org = '40 17 -29';
			break;
		case 0:
		default:
			f_org = '40 9.5 -29';
			break;
	}
	W_SetupShot (self, f_org, FALSE, 2, "weapons/flac_fire.wav");

	pointparticles(particleeffectnum("hagar_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	missile = spawn ();
	missile.owner = missile.realowner = self;
	missile.classname = "missile";
	missile.bot_dodge = TRUE;
	missile.bot_dodgerating = cvar("g_balance_seeker_flac_damage");
	missile.touch = Seeker_Flac_Explode;
	missile.use = Seeker_Flac_Explode;
	missile.think = Seeker_Flac_Explode;
	missile.nextthink = time + cvar("g_balance_seeker_flac_lifetime") + cvar("g_balance_seeker_flac_lifetime_rand");
	missile.solid = SOLID_BBOX;
	missile.scale = 0.4; // BUG: the model is too big
	missile.projectiledeathtype = WEP_SEEKER;
	setorigin (missile, w_shotorg);
	missile.projectiledeathtype = WEP_SEEKER | HITTYPE_SECONDARY;

	missile.movetype = MOVETYPE_FLY;
	w_shotdir = w_shotdir + '0 0 0.3';
	missile.velocity    = (w_shotdir  + randomvec() * cvar("g_balance_seeker_flac_spread")) * cvar("g_balance_seeker_flac_speed");

	W_SetupProjectileVelocity(missile);

	missile.angles = vectoangles (missile.velocity);
	missile.flags = FL_PROJECTILE;

	CSQCProjectile(missile, TRUE, PROJECTILE_FLAC, TRUE);
}

void spawnfunc_weapon_seeker (void)
{
	weapon_defaultspawnfunc(WEP_SEEKER);
}

float w_seeker(float req)
{
	if (req == WR_AIM)
		self.BUTTON_ATCK = bot_aim(cvar("g_balance_seeker_tag_speed"), 0, 20, FALSE);

	else if (req == WR_THINK)
	{
		if (self.BUTTON_ATCK)
			if (weapon_prepareattack(0, cvar("g_balance_seeker_tag_refire")))
			{
				Seeker_Fire_Tag();
				weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_seeker_tag_animtime"), w_ready);
			}

		if (self.BUTTON_ATCK2)
			if (weapon_prepareattack(1, cvar("g_balance_seeker_flac_refire")))
			{
				Seeker_Fire_Flac();
				weapon_thinkf(WFRAME_FIRE2, cvar("g_balance_seeker_flac_animtime"), w_ready);
			}

	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_seeker.md3");
		precache_model ("models/weapons/v_seeker.md3");
		precache_model ("models/weapons/w_seeker.zym");
		precache_sound ("weapons/tag_fire.wav");
		precache_sound ("weapons/flac_fire.wav");
		precache_sound ("weapons/seeker_fire.wav");
	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_SEEKER);
	else if (req == WR_CHECKAMMO1)
		return self.ammo_rockets >= cvar("g_balance_seeker_tag_ammo") + cvar("g_balance_seeker_missile_ammo");
	else if (req == WR_CHECKAMMO2)
		return self.ammo_rockets >= cvar("g_balance_seeker_flac_ammo");
	else if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = "played with tiny rockets";
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_SECONDARY)
			w_deathtypestring = "ran into #'s flac";
		else
			w_deathtypestring = "was tagged by";
	}
	return TRUE;
};

