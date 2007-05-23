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

.float rope_length;
.float button6_pressed_before;

void RemoveGrapplingHook(entity pl)
{
	if(pl.hook == world)
		return;
	remove(pl.hook);
	pl.hook = world;
	if(pl.movetype == MOVETYPE_FLY)
		pl.movetype = MOVETYPE_WALK;

	pl.hook_time = time + 0.0;

	//pl.disableclientprediction = FALSE;
}

void GrapplingHookThink()
{
	float spd, dist, minlength, pullspeed, ropestretch, ropeairfriction, rubberforce, newlength, rubberforce_overstretch;
	vector dir, org, end;
	if(self.owner.health <= 0 || self.owner.hook != self)	// how did that happen?
	{														// well, better fix it anyway
		remove(self);
		return;
	}

	self.nextthink = time;

	makevectors(self.owner.v_angle);
	org = self.owner.origin + self.owner.view_ofs + v_forward * 8 - v_right * 8 + v_up * -12;

	if(self.rope_length < 0)
		self.rope_length = vlen(org - self.origin);

	if(self.state == 1)
	{
		pullspeed = cvar("g_balance_grapplehook_speed_pull");//2000;
		// speed the rope is pulled with

		rubberforce = cvar("g_balance_grapplehook_force_rubber");//2000;
		// force the rope will use if it is stretched

		rubberforce_overstretch = cvar("g_balance_grapplehook_force_rubber_overstretch");//1000;
		// force the rope will use if it is stretched

		minlength = cvar("g_balance_grapplehook_length_min");//100;
		// minimal rope length
		// if the rope goes below this length, it isn't pulled any more

		ropestretch = cvar("g_balance_grapplehook_stretch");//400;
		// if the rope is stretched by more than this amount, more rope is
		// given to you again

		ropeairfriction = cvar("g_balance_grapplehook_airfriction");//0.2
		// while hanging on the rope, this friction component will help you a
		// bit to control the rope

		dir = self.origin - org;
		dist = vlen(dir);
		dir = normalize(dir);

		if(cvar("g_grappling_hook_tarzan"))
		{
			newlength = self.rope_length;

			// first pull the rope...
			newlength = max(newlength - pullspeed * frametime, minlength);

			if(newlength < dist - ropestretch) // overstretched?
			{
				newlength = dist - ropestretch;
				if(self.owner.velocity * dir < 0) // only if not already moving in hook direction
					self.owner.velocity = self.owner.velocity + frametime * dir * rubberforce_overstretch;
			}

			if(!self.owner.button5) // crouch key = don't pull
				self.rope_length = newlength;

			// then pull the player
			spd = bound(0, (dist - self.rope_length) / ropestretch, 1);
			self.owner.velocity = self.owner.velocity * (1 - frametime * ropeairfriction);
			self.owner.velocity = self.owner.velocity + frametime * dir * spd * rubberforce;
		}
		else
		{
			end = self.origin - dir*50;
			dist = vlen(end - org);
			if(dist < 200)
				spd = dist * (pullspeed / 200);
			else
				spd = pullspeed;
			if(spd < 50)
				spd = 0;
			self.owner.velocity = dir*spd;
			self.owner.movetype = MOVETYPE_FLY;
		}

		self.owner.flags = self.owner.flags - (self.owner.flags & FL_ONGROUND);

		org = org + dir*50; // get the beam out of the player's eyes
	}

	makevectors(self.angles_x * '-1 0 0' + self.angles_y * '0 1 0');
	te_beam(self, self.origin + v_forward * (-9), org);
}

void GrapplingHookTouch (void)
{
	if (other == self.owner)
		return;
	// altered for Nexuiz
	//else if (pointcontents (self.origin) == CONTENT_SKY)
	else if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
	{
		RemoveGrapplingHook(self.owner);
		return;
	}

	sound (self, CHAN_BODY, "weapons/hook_impact.wav", 1, ATTN_NORM);

	self.state = 1;
	self.think = GrapplingHookThink;
	self.nextthink = time;
	self.touch = SUB_Null;
	self.velocity = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.rope_length = -1;

	//self.owner.disableclientprediction = TRUE;
}

void GrapplingHook_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(self.health > 0)
	{
		self.health = self.health - damage;
		if (self.health <= 0)
		{
			if(attacker != self.owner)
			{
				self.owner.pusher = attacker;
				self.owner.pushltime = time + cvar("g_maxpushtime");
			}
			RemoveGrapplingHook(self.owner);
		}
	}
}

void FireGrapplingHook (void)
{
	local entity missile;
	local vector org;

	if(arena_roundbased)
	if(time < warmup)
		return;

	makevectors(self.v_angle);

	sound (self, CHAN_WEAPON, "weapons/hook_fire.wav", 1, ATTN_NORM);
	org = self.origin + self.view_ofs + v_forward * 8 - v_right * 8 + '0 0 -12';
	te_customflash(org, 160, 0.2, '1 0 0');

	missile = spawn ();
	missile.owner = self;
	self.hook = missile;
	missile.classname = "grapplinghook";

	missile.movetype = MOVETYPE_FLY;
	missile.solid = SOLID_BBOX;

	setmodel (missile, "models/hook.md3"); // precision set below
	setsize (missile, '-3 -3 -3', '3 3 3');
	setorigin (missile, org);

	missile.state = 0; // not latched onto anything

	missile.velocity = v_forward * cvar("g_balance_grapplehook_speed_fly");
	W_SetupProjectileVelocity(missile);

	missile.angles = vectoangles (missile.velocity);
	//missile.glow_color = 250; // 244, 250
	//missile.glow_size = 120;
	missile.touch = GrapplingHookTouch;
	missile.think = GrapplingHookThink;
	missile.nextthink = time + 0.1;

	missile.effects = /*EF_FULLBRIGHT | EF_ADDITIVE |*/ EF_LOWPRECISION;

	missile.health = cvar("g_balance_grapplehook_health");//120
	missile.event_damage = GrapplingHook_Damage;
	missile.takedamage = DAMAGE_AIM;
	missile.damageforcescale = 0;
}

void GrapplingHookFrame()
{
	// this function has been modified for Nexuiz
	if (self.button6 && cvar("g_grappling_hook"))
	{
		if (!self.hook && self.hook_time <= time && !self.button6_pressed_before)
			FireGrapplingHook();
	}
	else
	{
		if (self.hook)
			RemoveGrapplingHook(self);
	}
	self.button6_pressed_before = self.button6;
	/*
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
	else if(self.hookimpulse == GRAPHOOK_RELEASE)
	{
		// remove hook, reset movement type
		RemoveGrapplingHook(self);
		return;
	}
	*/
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
	// this function has been modified for Nexuiz
	// don't remove these lines! old server or demos coud overwrite the new aliases
	stuffcmd(self, "alias +hook +button6\n");
	stuffcmd(self, "alias -hook -button6\n");
}
