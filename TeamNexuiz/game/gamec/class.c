
void PlayerKilled (float unnatural_death, entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force);



/*
=============
NameOfClass

Translates class number to a string for printing
=============
*/
string NameOfClass(float cl)
{
	if(cl == CLASS_SCOUT)
		return "Scout";
	if(cl == CLASS_SPY)
		return "Spy";
	if(cl == CLASS_SOLDIER)
		return "Soldier";
	if(cl == CLASS_PYRO)
		return "Pryo";
	if(cl == CLASS_MEDIC)
		return "Medic";
	if(cl == CLASS_ENGINEER)
		return "Engineer";
	if(cl == CLASS_CIVILIAN)
		return "Civilian";
	return "Invalid Class";
}

/*
=============
GetPlayerClass

Returns the player's class by checking his model name
=============
*/
float GetPlayerClass()
{
	//string s;
	//s = substring(self.playermodel,13,3);

	//bprint("Class Prefix: ");
	//bprint(s);
	//bprint("\n");

	// only the prefix matters;
	// thus, you could have multiple medic models, such as a male and female.
	if(substring(self.playermodel,13,5)
		== "scout")
		return CLASS_SCOUT;
	if(substring(self.playermodel,13,3)
		== "spy")
		return CLASS_SPY;
	if(substring(self.playermodel,13,7)
		== "soldier")
		return CLASS_SOLDIER;
	if(substring(self.playermodel,13,4)
		== "pyro")
		return CLASS_PYRO;
	if(substring(self.playermodel,13,5)
		== "medic")
		return CLASS_MEDIC;
	if(substring(self.playermodel,13,8)
		== "engineer")
		return CLASS_ENGINEER;

	return -1;
}

/*
=============
ChangeClass

Changes the player's class
=============
*/

void ChangeClass(float announce_change, float instant_change)
{
	float portion, aportion;
	if(announce_change)
		bprint(self.netname, " becomes a ", NameOfClass(self.class), "\n");

	portion = 1.0;

	if(instant_change)
	{
		// health
		if(self.health < self.max_health)
			aportion = self.health / self.max_health;
		else
			aportion = 1.0;

		if(aportion < portion)
			portion = aportion;

		// armor
		if(self.armorvalue < self.max_armor)
			aportion = self.armorvalue / self.max_armor;
		else
			aportion = 1.0;

		if(aportion < portion)
			portion = aportion;
	}

	if(self.class == CLASS_SCOUT)
		BecomeScout(portion);

	if(self.class == CLASS_SPY)
		BecomeSpy(portion);

	if(self.class == CLASS_SOLDIER)
		BecomeSoldier(portion);

	if(self.class == CLASS_PYRO)
		BecomePyro(portion);

	if(self.class == CLASS_MEDIC)
		BecomeMedic(portion);

	if(self.class == CLASS_ENGINEER)
		BecomeEngineer(portion);

	if(self.class == CLASS_CIVILIAN)
		BecomeCivilian(portion);


	// set starting health
	if(!instant_change)//portion == 1.0)
		self.health = ceil(self.max_health * 1.2);
	else
		self.health = self.max_health;
	// set starting armor
	if(!instant_change)//portion == 1.0)
		self.armorvalue = ceil(self.max_armor * 1.2);
	else
		self.armorvalue = self.max_armor;

	// test code
	//if(instant_change)
	//	self.health = 2 + self.health * 0.8;
};

float SetPlayerMass(entity pl)
{
	float m, extra_mass;
	if(self.class == CLASS_SCOUT)
	{
		m = cvar("g_balance_class_scout_mass");
	}
	else if(self.class == CLASS_SPY)
	{
		m = cvar("g_balance_class_spy_mass");
	}
	else if(self.class == CLASS_SOLDIER)
	{
		m = cvar("g_balance_class_soldier_mass");
	}
	else if(self.class == CLASS_PYRO)
	{
		m = cvar("g_balance_class_pyro_mass");
	}
	else if(self.class == CLASS_MEDIC)
	{
		m = cvar("g_balance_class_medic_mass");
	}
	else if(self.class == CLASS_ENGINEER)
	{
		m = cvar("g_balance_class_engineer_mass");
	}
	else
		m = cvar("sv_maxspeed");

	// fixme: if I'm carrying a flag or extra weapon, add that mass
	extra_mass = 0;

	if(self.wpn5.mass)
		extra_mass = extra_mass + self.wpn5.mass;


	self.mass = m + extra_mass;

	return m; // return what my natural mass is
};

void SetPlayerSpeed(entity pl)
{
	local float s, m, plmass;
	string temp;
	if(self.class == CLASS_SCOUT)
	{
		s = cvar("g_balance_class_scout_speed");
		//m = cvar("g_balance_class_scout_mass");
	}
	else if(self.class == CLASS_SPY)
	{
		s = cvar("g_balance_class_spy_speed");
		//m = cvar("g_balance_class_spy_mass");
	}
	else if(self.class == CLASS_SOLDIER)
	{
		s = cvar("g_balance_class_soldier_speed");
		//m = cvar("g_balance_class_soldier_mass");
	}
	else if(self.class == CLASS_PYRO)
	{
		s = cvar("g_balance_class_pyro_speed");
		//m = cvar("g_balance_class_pyro_mass");
	}
	else if(self.class == CLASS_MEDIC)
	{
		s = cvar("g_balance_class_medic_speed");
		//m = cvar("g_balance_class_medic_mass");
	}
	else if(self.class == CLASS_ENGINEER)
	{
		s = cvar("g_balance_class_engineer_speed");
		//m = cvar("g_balance_class_engineer_mass");
	}
	else if(self.class == CLASS_CIVILIAN)
	{
		s = cvar("g_balance_class_civilian_speed");
	}



	// fixme: if I'm in a manned turret, set my speed to 0
	// fixme: if I'm piloting a vehicle, what to do?


	// if my mass is different because of what I'm carrying,
	// slow me down

	m = SetPlayerMass(pl);

	if(pl.mass == 0)
		plmass = 1;
	else
		plmass = pl.mass;
	s = ceil( s * (m / plmass ) );

	if(s != pl.speed)
	{
		//bprint("debug: adjusting speed\n");
		temp = ftos(s);
		
		//stuffcmd( pl, strcat("cl_movement_maxspeed ", temp , "\n"));
		//stuffcmd( pl, strcat("cl_movement_maxairspeed ", temp , "\n"));

		//stuffcmd( pl, strcat("cl_forwardspeed ", temp , "\n"));
		//stuffcmd( pl, strcat("cl_backspeed ", temp , "\n"));
		//stuffcmd( pl, strcat("cl_sidespeed ", temp , "\n"));
		//stuffcmd( pl, strcat("cl_upspeed ", temp , "\n"));
	}

	pl.speed = s;
}



/*
=============
ResetPlayerModel

Resets the player's model to what it should be when returning from invisibility,
 or trying to change class but not being allowed.
=============
*/

void ResetPlayerModel(entity pl)
{
	local vector m1, m2;
	m1 = pl.mins;
	m2 = pl.maxs;
	//precache_model (self.playermodel); needed?
	setmodel (pl, pl.playermodel);
	setsize (pl, m1, m2);
}

/*
=============
CheckForClassChange

Returns the player's class by checking his model.
Called from PlayerPreThink whenever the player changes his model, before change is made.
=============
*/

void() respawn;
float CheckForClassChange()
{
	float cl;
	float tfcl;

	// FIXME: need an option to not allow class changes at all once the player has changed once

	//bprint("check if allow change\n");

	// don't monitor the player's model when he's dead.
	// this means he can change class when dead and respawn as the new class.
	//if(self.health <= 0) // fixme: or if player is an observer
	//	return 0;

//	bprint("healthy\n");

	if(self.playermodel == self.mdl)
		return 0; // haven't changed models since last legitimate change

	//bprint("model has changed\n");

	cl = GetPlayerClass();
	if(self.class == cl) // changed models, but it didn't affect my class
	{
		if(self.change_mdl_on_respawn) // if was going to change class, but I just switched models of the same class I'm in now, undo the future class change
			self.change_mdl_on_respawn = "";
		return 0;
	}

	//bprint("class changed\n");


	// it's changed; now figure out what to do about it

	// don't allow player class
	if(cvar("g_classchange_not_allowed"))
	{
		self.playermodel = self.mdl;	// return to old model
		ResetPlayerModel(self);

		/*local vector m1, m2;
		self.playermodel = self.model;	// return to old model
		m1 = self.mins;
		m2 = self.maxs;
		//precache_model (self.playermodel); needed?
		setmodel (self, self.playermodel);
		setsize (self, m1, m2);*/
		return 0;
	}

	if (cl == CLASS_SCOUT)
	{
		tfcl = TF_CLASS_SCOUT;
	}
	else if (cl == CLASS_SOLDIER)
	{
		tfcl = TF_CLASS_SOLDIER;
	}
	else if (cl == CLASS_MEDIC)
	{
		tfcl = TF_CLASS_MEDIC;
	}
	else if (cl == CLASS_PYRO)
	{
		tfcl = TF_CLASS_PYRO;
	}
	else if (cl == CLASS_ENGINEER)
	{
		tfcl = TF_CLASS_ENGINEER;
	}
	else if (cl == CLASS_SPY)
	{
		tfcl = TF_CLASS_SPY;
	}

	if (self.lives == 0)
	{
		self.playermodel = self.mdl;	// return to old model
		ResetPlayerModel(self);
		sprint(self, "You have no lives left.\n");
		return 0;
	}
	if (!IsLegalClass(tfcl))		// Checks if class is legal for the map
	{
		self.playermodel = self.mdl;	// return to old model
		ResetPlayerModel(self);
		sprint(self, "You cannot play that playerclass on this map. \n");
		TeamFortress_DisplayLegalClasses();
		return 0;
	}
	self.respawn_as_new_class = tfcl;	// makes sure conversion from TF .playerclass goes through

	// allow change, but don't take effect until death
	if(cvar("g_classchange_delay_until_death"))
	{
		self.change_mdl_on_respawn = self.playermodel;
		self.change_mdl_on_respawn = strzone(self.change_mdl_on_respawn);
		self.playermodel = self.model;
		if (self.team_no > 0)
		{
			sprint (self, "After dying, you will return as a ");
			TeamFortress_PrintClassName (self, cl, (self.tfstate & 8));
		}
//			sprint(self, "You will change class after you die\n");
		return 0;
	}

	// allow change, possibly with stipulations (like force respawn)

	//bprint("allowing change\n");

	if(self.class == CLASS_SPY)
		SpyDecloak();

	self.class = cl;
	//self.mdl = strzone(self.playermodel);


	// allow change, but instant kill & respawn
	if(cvar("g_classchange_force_respawn"))
	{
		PlayerKilled(TRUE, world, world, 1, DEATH_CLASSCHANGE, '0 0 0', '0 0 0');
		respawn();
		return 1;
	}

	// allow class change without a hitch
	ChangeClass(TRUE, TRUE);
	return 0;
}

void ClassSpecial()
{
	if(self.class == CLASS_SCOUT)
		ScoutSpecial();
	if(self.class == CLASS_SPY)
		SpySpecial();
	if(self.class == CLASS_SOLDIER)
		SoldierSpecial();
	if(self.class == CLASS_PYRO)
		PyroSpecial();
	if(self.class == CLASS_MEDIC)
		MedicSpecial();
	if(self.class == CLASS_ENGINEER)
		EngineerSpecial();
}

void ClassGrenade(float req)
{
	if(self.grenade_time > time)
		return;

	if(self.class == CLASS_SCOUT)
		ScoutGrenade(req);
	if(self.class == CLASS_SPY)
		SpyGrenade(req);
	if(self.class == CLASS_SOLDIER)
		SoldierGrenade(req);
	if(self.class == CLASS_PYRO)
		PyroGrenade(req);
	if(self.class == CLASS_MEDIC)
		MedicGrenade(req);
	if(self.class == CLASS_ENGINEER)
		EngineerGrenade(req);
}

void ClassPreThink()
{
	if(self.class == CLASS_SCOUT)
		ScoutPreThink();
	if(self.class == CLASS_SPY)
		SpyPreThink();
	if(self.class == CLASS_SOLDIER)
		SoldierPreThink();
	if(self.class == CLASS_PYRO)
		PyroPreThink();
	if(self.class == CLASS_MEDIC)
		MedicPreThink();
	if(self.class == CLASS_ENGINEER)
		EngineerPreThink();
	if(self.class == CLASS_CIVILIAN)
		EngineerPreThink();
}

void ClassPostThink()
{
	if(self.class == CLASS_SCOUT)
		ScoutPostThink();
	if(self.class == CLASS_SPY)
		SpyPostThink();
	if(self.class == CLASS_SOLDIER)
		SoldierPostThink();
	if(self.class == CLASS_PYRO)
		PyroPostThink();
	if(self.class == CLASS_MEDIC)
		MedicPostThink();
	if(self.class == CLASS_ENGINEER)
		EngineerPostThink();
	if(self.class == CLASS_CIVILIAN)
		CivilianPostThink();
}

/*
=========================
 Set MaxAmmo for classes
  Wazat - edit these values to whatever
			   =========================
*/
void (float classnum) SetMaxAmmoFor =
{
	self.is_feigning = 0;
	self.leg_damage = 0;		//temp here //so leg damage doesnt stay on player respawn
	// if no class is found, it will just default to these
	self.maxammo_shells = 200;
	self.maxammo_nails = 200;
	self.maxammo_cells = 40;
	self.maxammo_rockets = 40;
	self.maxammo_metal = 0;
	self.no_grenades_1 = 4;
	self.clip_rockets = CLIP_MAX_ROCKETS;
	self.clip_pistol = CLIP_MAX_PISTOL;
	self.tp_grenades_1 = 1;
	self.tp_grenades_2 = 0;

	if (classnum == CLASS_SCOUT)		// Scout Supplies
	{
		self.maxammo_shells = 200;
		self.maxammo_nails = 200;
		self.maxammo_cells = 40;
		self.maxammo_rockets = 45;
		self.clip_crylink = CLIP_MAX_CRYLINK;
		self.tp_grenades_1 = 9;
	}
	else if (classnum == CLASS_SPY) {		// Spy supplies
		self.maxammo_shells = 150;
		self.maxammo_nails = 200;		// MAC10 uses nails
		self.maxammo_cells = 70;
		self.maxammo_rockets = 15;
		self.ammo_nails = 100;
		self.tp_grenades_1 = 9;
		self.no_grenades_2 = 1;
	}
	else if (classnum == CLASS_SOLDIER) {
		self.ammo_rockets = 62;			//translates to 20
		self.maxammo_rockets = 40;
		self.tp_grenades_2 = 3;
		self.no_grenades_2 = 1;
	}
	else if (classnum == CLASS_PYRO) {
		self.clip_pipegrenades = 6;
	}
	else if (classnum == CLASS_ENGINEER) {
		self.maxammo_cells = 200;
		self.ammo_cells = 100;
		self.ammo_metal = 0;
		self.maxammo_metal = 200;
	}
};
