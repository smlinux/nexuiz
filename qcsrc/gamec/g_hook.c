/*============================================

      Wazat's Nexuiz Grappling Hook

        Contact: Wazat1@gmail.com


Installation instructions:
--------------------------

1. Place hook.c in your gamec source directory with the other source files.

2. Add this line to the bottom of progs.src:

gamec/hook.c

3. Open defs.h and add these lines to the very bottom:

// Wazat's grappling hook
.entity		hook;
void GrapplingHookFrame();
void RemoveGrapplingHook(entity pl);
void SetGrappleHookBindings();
// hook impulses
float GRAPHOOK_FIRE		= 20;
float GRAPHOOK_RELEASE		= 21;
// (note: you can change the hook impulse #'s to whatever you please)

4. Open client.c and add this to the top of PutClientInServer(): 

	RemoveGrapplingHook(self); // Wazat's Grappling Hook

5. Find ClientConnect() (in client.c) and add these lines to the bottom:

	// Wazat's grappling hook
	SetGrappleHookBindings();

6. Still in client.c, find PlayerPreThink and add this line just above the call to W_WeaponFrame:

 	GrapplingHookFrame();

7. Build and test the mod.  You'll want to bind a key to "+hook" like this:
bind ctrl "+hook"

And you should be done!


============================================*/

void RemoveGrapplingHook(entity pl)
{
	if(pl.hook == world)
		return;
	remove(pl.hook);
	pl.hook = world;
	if(pl.movetype == MOVETYPE_FLY)
		pl.movetype = MOVETYPE_WALK;

	pl.hook_time = time + 0.5;
}

void GrapplingHookThink()
{
	float spd, dist, minlength, pullspeed;
	vector dir, org, end;
	if(self.owner.health <= 0 || self.owner.hook != self)	// how did that happen?
	{														// well, better fix it anyway
		remove(self);
		return;
	}

	self.nextthink = time + 0.1;

	makevectors(self.owner.v_angle);
	org = self.owner.origin + self.owner.view_ofs + v_forward * 15 - v_right * 5 + v_up * -12;

	if(self.state == 1)
	{
		pullspeed = 1000;
		minlength = 50;
		dir = self.origin - org;
		dist = vlen(dir);
		dir = normalize(dir);

		end = self.origin - dir*minlength;
		
		dist = vlen(end - org);

		if(dist < 200)
			spd = dist * (pullspeed / 200);
		else
			spd = pullspeed;
		if(spd < 50)
			spd = 0;

		self.owner.velocity = dir*spd;
		self.owner.movetype = MOVETYPE_FLY;
		self.owner.flags = self.owner.flags - (self.owner.flags & FL_ONGROUND);

		org = org + dir*50; // get the beam out of the player's eyes
	}

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_BEAM);
	WriteEntity (MSG_BROADCAST, self);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
}

void GrapplingHookTouch (void)
{
	if (other == self.owner)
		return;
	else if (pointcontents (self.origin) == CONTENT_SKY)
	{
		RemoveGrapplingHook(self.owner);
		return;
	}

	self.event_damage = SUB_Null; // fixme: ability to dislodge a player by damaging hook?
	sound (self, CHAN_BODY, "weapons/laserimpact.wav", 1, ATTN_NORM);

	self.state = 1;
	self.think = GrapplingHookThink;
	self.nextthink = time + 0.1;
	self.touch = SUB_Null;
	self.velocity = '0 0 0';
	self.movetype = MOVETYPE_NONE;
}

void FireGrapplingHook (void)
{
	local entity missile;
	local vector org;

	makevectors(self.v_angle);

	sound (self, CHAN_WEAPON, "weapons/lasergun_fire.wav", 1, ATTN_NORM);
	org = self.origin + self.view_ofs + v_forward * 15 - v_right * 5 + v_up * -12;
	te_customflash(org, 160, 0.2, '1 0 0');

	missile = spawn ();
	missile.owner = self;
	self.hook = missile;
	missile.classname = "laserbolt";

	missile.movetype = MOVETYPE_FLY;
	missile.solid = SOLID_BBOX;

	setmodel (missile, "models/ebomb.mdl");//laser.mdl");
	setsize (missile, '0 0 0', '0 0 0');
	setorigin (missile, org);

	missile.state = 0; // not latched onto anything

	missile.velocity = v_forward * 1200;//cvar("g_balance_grapplehook_speed");
	missile.angles = vectoangles (missile.velocity);
	//missile.glow_color = 250; // 244, 250
	//missile.glow_size = 120;
	missile.touch = GrapplingHookTouch;
	missile.think = GrapplingHookThink;
	missile.nextthink = time + 0.1;

	missile.effects = EF_FULLBRIGHT | EF_ADDITIVE | EF_LOWPRECISION;
}

void GrapplingHookFrame()
{
	// if I have no hook or it's not pulling yet, make sure I'm not flying!
	if((self.hook == world || !self.hook.state) && self.movetype == MOVETYPE_FLY)
	{
		self.movetype = MOVETYPE_WALK;
	}
	if(self.impulse == GRAPHOOK_FIRE && self.hook_time <= time && cvar("g_grappling_hook"))
	{
		// fire hook
		FireGrapplingHook();
		return;
	}
	else if(self.impulse == GRAPHOOK_RELEASE)
	{
		// remove hook, reset movement type
		RemoveGrapplingHook(self);
		return;
	}
	/*else // make sure the player's movetype is correct
	{
		//if(self.hook == world && self.movetype == MOVETYPE_FLY)
		if((self.hook == world || !self.hook.state) && self.movetype == MOVETYPE_FLY)
		{
			self.movetype = MOVETYPE_WALK;
		}
	}*/
	// note: The hook entity does the actual pulling
}

void SetGrappleHookBindings()
{
	stuffcmd(self, strcat("alias +hook \"impulse ", ftos(GRAPHOOK_FIRE),	"\"\n"));
	stuffcmd(self, strcat("alias -hook \"impulse ", ftos(GRAPHOOK_RELEASE),	"\"\n"));
}
