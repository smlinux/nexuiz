//***********************
//NEX FORT ENTITIES
//***********************

float LGATE_START_OFF		= 1;
float LGATE_TOGGLE			= 2;
float LGATE_ADDITIVE_BLEND	= 4;
float LGATE_INSTANT_KILL	= 8;	// fixme: not done yet
float LGATE_FULLBRIGHT		= 16;

//float	STATE_ACTIVE;
//float	STATE_INACTIVE;

void PlayerLasergatePreThink ()
{
	// player is starting his movement code.
	// set owner of all friendly lasergates to player so he can pass through them.

	entity e;
	e=world;
	do
	{
		e = find(e, classname, "func_lasergate");
		if(e)
		{
			if(e.team_no && e.team_no == self.team_no)
			{
				//bprint("found a lasergate\n");
				e.owner = self;
			}
		}
	}while(e);
}

void PlayerLasergatePostThink ()
{
	// player is starting his movement code.
	// set owner of all friendly lasergates to player so he can pass through them.

	entity e;
	e=world;
	do
	{
		e = find(e, classname, "func_lasergate");
		if(e)
			e.owner = world;
	}while(e);
}

void lasergate_touch()
{
	//if(self.state != STATE_ACTIVE)
	//	return; // lasergate is inactive

	//bprint("touch\n");
	if(other == self.owner)
		return; // don't hurt the guy that's moving at the moment

	//bprint("not owner\n");
	if(self.team_no && other.team_no == self.team_no)
		return;	// don't hurt teammates if it does touch them somehow

	//bprint("not team\n");
	if(!self.dmg)
		return; // no damage to deal

	//bprint("have damage\n");
	if(self.respawntime > time)
		return; // don't damage every frame

	//bprint("hurt player!\n");
	self.respawntime = time + self.attack_finished;


	Damage (other, self, self, self.dmg, DEATH_LASERGATE, 0.5*(self.absmin+self.absmax), '0 0 0');
}

void lasergate_activate()
{
//	if(self.state)
//		return;
//	bprint("lasergate_activate\n");
	self.state=1;
	setorigin(self, self.origin);
	setmodel(self, self.mdl);
	setsize (self, self.mins , self.maxs);
	self.touch = lasergate_touch;
}

void lasergate_deactivate()
{
//	if(!self.state)
//		return;
//	bprint("lasergate_deactivate\n");
	self.state=0;
	setmodel(self, "");
	self.touch = SUB_Null;
}

void lasergate_use()
{
	if(self.spawnflags & LGATE_TOGGLE)
	{
		if(self.state)
			lasergate_deactivate();
		else
			lasergate_activate();
		return;
	}

	if(self.spawnflags & LGATE_START_OFF)
	{
		lasergate_activate();
		self.think = lasergate_deactivate;
		self.nextthink = self.ltime + self.wait;
	}
	else
	{
		lasergate_deactivate();
		self.think = lasergate_activate;
		self.nextthink = self.ltime + self.wait;
	}
}

void func_lasergate()
{
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;

	self.use = lasergate_use;
	self.mdl = self.model;

	// testing
	//self.dmg = 999;

	if(!self.attack_finished)
		self.attack_finished = 1;
	if(!self.wait)
		self.wait = 5;
	if(!self.message)
		self.message = " tried to cross a lasergate";

	if(self.spawnflags & LGATE_ADDITIVE_BLEND)
		self.effects = self.effects | EF_ADDITIVE;

	if(self.spawnflags & LGATE_FULLBRIGHT)
		self.effects = self.effects | EF_FULLBRIGHT;

	if(self.spawnflags & LGATE_START_OFF)
		lasergate_deactivate();
	else
		lasergate_activate();
}







void trigger_gravity_use() =
{
	if(activator.classname != "player")
		return;

	if(self.gravity)
		activator.gravity = self.gravity;
	else if(self.speed)
	{
		activator.gravity = self.speed / cvar("sv_gravity");
	}
}

void trigger_gravity_touch() =
{
	if (other.classname != "player")
		return;

	activator = other;
	self.use();
}


void trigger_gravity() =
{
	if(!self.gravity && !self.speed)
		self.gravity = 0.5;

	self.use = trigger_gravity_use;
	self.touch = trigger_gravity_touch;

	InitTrigger ();

}

