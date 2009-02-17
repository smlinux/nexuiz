/*
===========================================================================

  CLIENT WEAPONSYSTEM CODE
  Bring back W_Weaponframe

===========================================================================
*/

void W_SwitchWeapon_Force(entity e, float w)
{
	e.cnt = e.switchweapon;
	e.switchweapon = w;
}

.float antilag_debug;

// VorteX: static frame globals
float WFRAME_FIRE1 = 0;
float WFRAME_FIRE2 = 1;
float WFRAME_IDLE = 2;
float WFRAME_RELOAD = 3;

void(float fr, float t, void() func) weapon_thinkf;

vector w_shotorg;
vector w_shotdir;

// this function calculates w_shotorg and w_shotdir based on the weapon model
// offset, trueaim and antilag, and won't put w_shotorg inside a wall.
// make sure you call makevectors first (FIXME?)
void W_SetupShot(entity ent, vector vecs, float antilag, float recoil, string snd)
{
	float nudge = 1; // added to traceline target and subtracted from result
	local vector trueaimpoint;
	local float oldsolid;
	oldsolid = self.dphitcontentsmask;
	self.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	traceline(self.origin + self.view_ofs, self.origin + self.view_ofs + v_forward * MAX_SHOT_DISTANCE, MOVE_NOMONSTERS, self);
	trueaimpoint = trace_endpos;

	if(debug_shotorg != '0 0 0')
		vecs = debug_shotorg;

	if (cvar("g_shootfromeye"))
		w_shotorg = ent.origin + ent.view_ofs;
	else if (cvar("g_shootfromcenter"))
		w_shotorg = ent.origin + ent.view_ofs + '0 0 1' * vecs_z;
	else
		w_shotorg = ent.origin + ent.view_ofs + v_right * vecs_y + v_up * vecs_z;
	// now move the shotorg forward as much as requested if possible
	traceline(w_shotorg, w_shotorg + v_forward * (vecs_x + nudge), MOVE_NORMAL, self);
	w_shotorg = trace_endpos - v_forward * nudge;
	// calculate the shotdir from the chosen shotorg
	w_shotdir = normalize(trueaimpoint - w_shotorg);

#if 0
	// explanation of g_antilag:
	// if client reports it was aiming at a player, and the serverside trace
	// says it would miss, change the aim point to the player's new origin,
	// but only if the shot at the player's new origin would hit of course
	//
	// FIXME: a much better method for bullet weapons would be to leave a
	// trail of lagged 'ghosts' behind players, and see if the bullet hits the
	// ghost corresponding to this player's ping time, and if so it would do
	// damage to the real player
	if (antilag)
	if (self.cursor_trace_ent)                 // client was aiming at someone
	if (self.cursor_trace_ent != self)         // just to make sure
	if (self.cursor_trace_ent.takedamage)      // and that person is killable
	if (self.cursor_trace_ent.classname == "player") // and actually a player
	if (cvar("g_antilag") == 1)
	{
		// verify that the shot would miss without antilag
		// (avoids an issue where guns would always shoot at their origin)
		traceline(w_shotorg, w_shotorg + w_shotdir * MAX_SHOT_DISTANCE, MOVE_NORMAL, self);
		if (!trace_ent.takedamage)
		{
			// verify that the shot would hit if altered
			traceline(w_shotorg, self.cursor_trace_ent.origin, MOVE_NORMAL, self);
			if (trace_ent == self.cursor_trace_ent)
			{
				// verify that the shot would hit in the past
				if(self.antilag_debug)
					antilag_takeback(self.cursor_trace_ent, time - self.antilag_debug);
				else
					antilag_takeback(self.cursor_trace_ent, time - ANTILAG_LATENCY(self));

				traceline(self.origin + self.view_ofs, self.origin + self.view_ofs + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, self);
				antilag_restore(self.cursor_trace_ent);

				if(trace_ent == self.cursor_trace_ent)
				{
					// HIT!
					w_shotdir = normalize(self.cursor_trace_ent.origin - w_shotorg);
					dprint("ANTILAG HIT for ", self.netname, "\n");
				}
				else
				{
					// prydon cursor aimbot or odd network conditions
					dprint("WARNING: antilag ghost trace for ", self.netname, " failed!\n");
				}

				if(cvar("developer") >= 2)
				{
					vector v, vplus, vel;
					float X;
					v     = antilag_takebackorigin(self.cursor_trace_ent, time - (ANTILAG_LATENCY(self)       ));
					vplus = antilag_takebackorigin(self.cursor_trace_ent, time - (ANTILAG_LATENCY(self) + 0.01));
					vel = (vplus - v) * (1 / 0.01);
					// solve: v + X * vel = closest to self.origin + self.view_ofs, v_forward axis
					v     -= (self.origin + self.view_ofs);
					// solve: v + X * vel = closest to v_forward axis
					// project into 2D by subtracting v_forward components:
					v   -= (v   * v_forward) * v_forward;
					vel -= (vel * v_forward) * v_forward;
					// solve: v + X * vel = closest to origin
					// (v + X * vel)^2 closest to 0
					// v^2 + 2 * X * (v * vel) + X^2 * vel^2 closest to 0
					X = -(v * vel) / (vel * vel);
					dprint("dead center needs adjustment of ", ftos(X), " (that is, ", ftos(ANTILAG_LATENCY(self) + X), " instead of ", ftos(ANTILAG_LATENCY(self)), "\n");
				}
			}
		}
	}
#else
	if (antilag)
	{
		if (cvar("g_antilag") == 1) // switch to "ghost" if not hitting original
		{
			traceline(w_shotorg, w_shotorg + w_shotdir * MAX_SHOT_DISTANCE, MOVE_NORMAL, self);
			if (!trace_ent.takedamage)
			{
				traceline_antilag_force (self, w_shotorg, w_shotorg + w_shotdir * MAX_SHOT_DISTANCE, MOVE_NORMAL, self, ANTILAG_LATENCY(self));
				if (trace_ent.takedamage && trace_ent.classname == "player")
				{
					entity e;
					e = trace_ent;
					traceline(w_shotorg, e.origin, MOVE_NORMAL, self);
					if(trace_ent == e)
						w_shotdir = normalize(trace_ent.origin - w_shotorg);
				}
			}
		}
		else if(cvar("g_antilag") == 3) // client side hitscan
		{
			if (self.cursor_trace_ent)                 // client was aiming at someone
			if (self.cursor_trace_ent != self)         // just to make sure
			if (self.cursor_trace_ent.takedamage)      // and that person is killable
			if (self.cursor_trace_ent.classname == "player") // and actually a player
			{
				// verify that the shot would miss without antilag
				// (avoids an issue where guns would always shoot at their origin)
				traceline(w_shotorg, w_shotorg + w_shotdir * MAX_SHOT_DISTANCE, MOVE_NORMAL, self);
				if (!trace_ent.takedamage)
				{
					// verify that the shot would hit if altered
					traceline(w_shotorg, self.cursor_trace_ent.origin, MOVE_NORMAL, self);
					if (trace_ent == self.cursor_trace_ent)
						w_shotdir = normalize(self.cursor_trace_ent.origin - w_shotorg);
					else
						print("antilag fail\n");
				}
			}
		}
	}
#endif

	self.dphitcontentsmask = oldsolid; // restore solid type (generally SOLID_SLIDEBOX)

	if (!g_norecoil)
		self.punchangle_x = recoil * -1;

	if (snd != "")
	{
		sound (self, CHAN_WEAPON, snd, VOL_BASE, ATTN_NORM);
	}

	if (self.items & IT_STRENGTH)
	if (!g_minstagib)
		sound (self, CHAN_AUTO, "weapons/strength_fire.wav", VOL_BASE, ATTN_NORM);
};

void LaserTarget_Think()
{
	entity e;
	vector offset;
	float uselaser;
	uselaser = 0;

	// list of weapons that will use the laser, and the options that enable it
	if(self.owner.laser_on && self.owner.weapon == WEP_ROCKET_LAUNCHER && g_laserguided_missile)
		uselaser = 1;
	// example
	//if(self.owner.weapon == WEP_ELECTRO && cvar("g_laserguided_electro"))
	//	uselaser = 1;



	// if a laser-enabled weapon isn't selected, delete any existing laser and quit
	if(!uselaser)
	{
		// rocket launcher isn't selected, so no laser target.
		if(self.lasertarget != world)
		{
			remove(self.lasertarget);
			self.lasertarget = world;
		}
		return;
	}

	if(!self.lasertarget)
	{
		// we don't have a lasertarget entity, so spawn one
		//bprint("create laser target\n");
		e = self.lasertarget = spawn();
		e.owner = self.owner;			// Its owner is my owner
		e.classname = "laser_target";
		e.movetype = MOVETYPE_NOCLIP;	// don't touch things
		setmodel(e, "models/laser_dot.mdl");	// what it looks like, precision set below
		e.scale = 1.25;				// make it larger
		e.alpha = 0.25;				// transparency
		e.colormod = '255 0 0' * (1/255) * 8;	// change colors
		e.effects = EF_FULLBRIGHT | EF_LOWPRECISION;
		// make it dynamically glow
		// you should avoid over-using this, as it can slow down the player's computer.
		e.glow_color = 251; // red color
		e.glow_size = 12;
	}
	else
		e = self.lasertarget;

	// move the laser dot to where the player is looking

	makevectors(self.owner.v_angle); // set v_forward etc to the direction the player is looking
	offset = '0 0 26' + v_right*3;
	traceline(self.owner.origin + offset, self.owner.origin + offset + v_forward * MAX_SHOT_DISTANCE, FALSE, self); // trace forward until you hit something, like a player or wall
	setorigin(e, trace_endpos + v_forward*8); // move me to where the traceline ended
	if(trace_plane_normal != '0 0 0')
		e.angles = vectoangles(trace_plane_normal);
	else
		e.angles = vectoangles(v_forward);
}

float CL_Weaponentity_CustomizeEntityForClient()
{
	self.viewmodelforclient = self.owner;
	if(other.classname == "spectator")
		if(other.enemy == self.owner)
			self.viewmodelforclient = other;
	return TRUE;
}

.string weaponname;
void CL_Weaponentity_Think()
{
	float tb;
	self.nextthink = time;
	if (intermission_running)
		self.frame = WFRAME_IDLE;
	if (self.owner.weaponentity != self)
	{
		remove(self);
		return;
	}
	if (self.owner.deadflag != DEAD_NO)
	{
		self.model = "";
		return;
	}
	if (self.cnt != self.owner.weapon || self.dmg != self.owner.modelindex || self.deadflag != self.owner.deadflag)
	{
		self.cnt = self.owner.weapon;
		self.dmg = self.owner.modelindex;
		self.deadflag = self.owner.deadflag;
		if (self.owner.weaponname != "")
			setmodel(self, strcat("models/weapons/w_", self.owner.weaponname, ".zym")); // precision set below
		else
			self.model = "";
	}

	tb = (self.effects & EF_TELEPORT_BIT);
	self.effects = self.owner.effects | EF_LOWPRECISION;
	self.effects &~= EF_FULLBRIGHT; // can mask team color, so get rid of it
	self.effects &~= EF_TELEPORT_BIT;
	self.effects |= tb;

	if(self.owner.alpha != 0)
		self.alpha = self.owner.alpha;
	else
		self.alpha = 1;
	
	self.colormap = self.owner.colormap;

	self.angles = '0 0 0';
	local float f;
	f = 0;
	if (self.state == WS_RAISE)
		f = (self.owner.weapon_nextthink - time) / cvar("g_balance_weaponswitchdelay");
	else if (self.state == WS_DROP)
		f = 1 - (self.owner.weapon_nextthink - time) / cvar("g_balance_weaponswitchdelay");
	else if (self.state == WS_CLEAR)
		f = 1;
	self.angles_x = -90 * f * f;

	// create or update the lasertarget entity
	LaserTarget_Think();
};

void CL_ExteriorWeaponentity_Think()
{
	float tag_found;
	self.nextthink = time;
	if (self.owner.exteriorweaponentity != self)
	{
		remove(self);
		return;
	}
	if (self.owner.deadflag != DEAD_NO)
	{
		self.model = "";
		return;
	}
	if (self.cnt != self.owner.weapon || self.dmg != self.owner.modelindex || self.deadflag != self.owner.deadflag)
	{
		self.cnt = self.owner.weapon;
		self.dmg = self.owner.modelindex;
		self.deadflag = self.owner.deadflag;
		if (self.owner.weaponname != "")
			setmodel(self, strcat("models/weapons/v_", self.owner.weaponname, ".md3")); // precision set below
		else
			self.model = "";

		if((tag_found = gettagindex(self.owner, "tag_weapon")))
		{
			self.tag_index = tag_found;
			self.tag_entity = self.owner;
		}
		else
			setattachment(self, self.owner, "bip01 r hand");

		// if that didn't find a tag, hide the exterior weapon model
		if (!self.tag_index)
			self.model = "";
	}
	self.effects = self.owner.effects | EF_LOWPRECISION;
	self.effects = self.effects & EFMASK_CHEAP; // eat performance
	if(self.owner.alpha != 0)
		self.alpha = self.owner.alpha;
	else
		self.alpha = 1;
	
	self.colormap = self.owner.colormap;
};

// spawning weaponentity for client
void CL_SpawnWeaponentity()
{
	self.weaponentity = spawn();
	self.weaponentity.classname = "weaponentity";
	self.weaponentity.solid = SOLID_NOT;
	self.weaponentity.owner = self;
	self.weaponentity.weaponentity = self.weaponentity;
	setmodel(self.weaponentity, ""); // precision set when changed
	self.weaponentity.origin = '0 0 0';
	self.weaponentity.angles = '0 0 0';
	self.weaponentity.viewmodelforclient = self;
	self.weaponentity.flags = 0;
	self.weaponentity.think = CL_Weaponentity_Think;
	self.weaponentity.customizeentityforclient = CL_Weaponentity_CustomizeEntityForClient;
	self.weaponentity.nextthink = time;
	self.weaponentity.scale = 0.61;

	self.exteriorweaponentity = spawn();
	self.exteriorweaponentity.classname = "exteriorweaponentity";
	self.exteriorweaponentity.solid = SOLID_NOT;
	self.exteriorweaponentity.exteriorweaponentity = self.exteriorweaponentity;
	self.exteriorweaponentity.owner = self;
	self.exteriorweaponentity.origin = '0 0 0';
	self.exteriorweaponentity.angles = '0 0 0';
	self.exteriorweaponentity.think = CL_ExteriorWeaponentity_Think;
	self.exteriorweaponentity.nextthink = time;
};

.float hasweapon_complain_spam;

float client_hasweapon(entity cl, float wpn, float andammo, float complain)
{
	local float weaponbit, f;
	local entity oldself;

	if(time < self.hasweapon_complain_spam)
		complain = 0;
	if(complain)
		self.hasweapon_complain_spam = time + 0.2;

	if (wpn < WEP_FIRST || wpn > WEP_LAST)
	{
		if (complain)
			sprint(self, "Invalid weapon\n");
		return FALSE;
	}
	weaponbit = W_WeaponBit(wpn);
	if (cl.weapons & weaponbit)
	{
		if (andammo)
		{
			if(cl.items & IT_UNLIMITED_WEAPON_AMMO)
			{
				f = 1;
			}
			else
			{
				oldself = self;
				self = cl;
				f = weapon_action(wpn, WR_CHECKAMMO1);
				f = f + weapon_action(wpn, WR_CHECKAMMO2);
				self = oldself;
			}
			if (!f)
			{
				if (complain)
					sprint(cl, strcat("You don't have any ammo for the ^2", W_Name(wpn), "\n"));
				return FALSE;
			}
		}
		return TRUE;
	}
	if (complain)
	{
		// DRESK - 3/16/07
		// Report Proper Weapon Status / Modified Weapon Ownership Message
		if(weaponsInMap & weaponbit)
		{
			sprint(cl, strcat("You do not have the ^2", W_Name(wpn), "\n") );

			if(cvar("g_showweaponspawns"))
			{
				entity e;
				string s;

				e = get_weaponinfo(wpn);
				s = e.model2;

				for(e = world; (e = findfloat(e, weapons, weaponbit)); )
				{
					if(e.classname == "droppedweapon")
						continue;
					if not(e.flags & FL_ITEM)
						continue;
					WaypointSprite_Spawn(
						s,
						1, 0,
						world, e.origin,
						self, 0,
						world, enemy,
						0
					);
				}
			}
		}
		else
			sprint(cl, strcat("The ^2", W_Name(wpn), "^7 is ^1NOT AVAILABLE^7 in this map\n") );
	}
	return FALSE;
};

// Weapon subs
void w_clear()
{
	if (self.weapon != -1)
		self.weapon = 0;
	if (self.weaponentity)
	{
		self.weaponentity.state = WS_CLEAR;
		self.weaponentity.effects = 0;
	}
};

void w_ready()
{
	if (self.weaponentity)
		self.weaponentity.state = WS_READY;
	weapon_thinkf(WFRAME_IDLE, 1000000, w_ready);
};

// Setup weapon for client (after this raise frame will be launched)
void weapon_setup(float windex)
{
	entity e;
	e = get_weaponinfo(windex);
	self.items &~= IT_AMMO;
	self.items = self.items | e.items;

	// the two weapon entities will notice this has changed and update their models
	self.weapon = windex;
	self.weaponname = e.mdl;
	self.bulletcounter = 0;
};

// perform weapon to attack (weaponstate and attack_finished check is here)
.float race_penalty;
float weapon_prepareattack(float secondary, float attacktime)
{
	//if sv_ready_restart_after_countdown is set, don't allow the player to shoot
	//if all players readied up and the countdown is running
	if (cvar("sv_ready_restart_after_countdown"))
		if(time < game_starttime || time < self.race_penalty) {
			return FALSE;
		}
	
	if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
	if (!weapon_action(self.weapon, WR_CHECKAMMO1 + secondary))
	{
		W_SwitchWeapon_Force(self, w_getbestweapon(self));
		return FALSE;
	}

	if (timeoutStatus == 2) //don't allow the player to shoot while game is paused
		return FALSE;

	// do not even think about shooting if switching
	if(self.switchweapon != self.weapon)
		return FALSE;

	// don't fire if previous attack is not finished
	if(attacktime >= 0)
		if (ATTACK_FINISHED(self) > time + frametime * 0.5)
			return FALSE;
	// don't fire while changing weapon
	if (self.weaponentity.state != WS_READY)
		return FALSE;
	self.weaponentity.state = WS_INUSE;

	self.spawnshieldtime = min(self.spawnshieldtime, time); // kill spawn shield when you fire

	// if the weapon hasn't been firing continuously, reset the timer
	if(attacktime >= 0)
	{
		if (ATTACK_FINISHED(self) < time - frametime * 1.5)
		{
			ATTACK_FINISHED(self) = time;
			//dprint("resetting attack finished to ", ftos(time), "\n");
		}
		ATTACK_FINISHED(self) = ATTACK_FINISHED(self) + attacktime;
	}
	self.bulletcounter += 1;
	//dprint("attack finished ", ftos(ATTACK_FINISHED(self)), "\n");
	return TRUE;
};

void weapon_thinkf(float fr, float t, void() func)
{
	if (fr >= 0)
	{
		if (self.weaponentity != world)
		{
			if(fr == WFRAME_FIRE1 || fr == WFRAME_FIRE2)
			{
				BITXOR_ASSIGN(self.weaponentity.effects, EF_TELEPORT_BIT);
			}
			self.weaponentity.frame = fr;
		}
	}

	if(self.weapon_think == w_ready && func != w_ready && self.weaponentity.state == WS_RAISE)
	{
		backtrace("Tried to override initial weapon think function - should this really happen?");
	}

	if(g_runematch)
	{
		if(self.runes & RUNE_SPEED)
		{
			if(self.runes & CURSE_SLOW)
				t = t * cvar("g_balance_rune_speed_combo_atkrate");
			else
				t = t * cvar("g_balance_rune_speed_atkrate");
		}
		else if(self.runes & CURSE_SLOW)
		{
			t = t * cvar("g_balance_curse_slow_atkrate");
		}
	}

	// VorteX: haste can be added here
	if (self.weapon_think == w_ready)
	{
		self.weapon_nextthink = time;
		//dprint("started firing at ", ftos(time), "\n");
	}
	if (self.weapon_nextthink < time - frametime * 1.5 || self.weapon_nextthink > time + frametime * 1.5)
	{
		self.weapon_nextthink = time;
		//dprint("reset weapon animation timer at ", ftos(time), "\n");
	}
	self.weapon_nextthink = self.weapon_nextthink + t;
	self.weapon_think = func;
	//dprint("next ", ftos(self.weapon_nextthink), "\n");

	if (fr == WFRAME_FIRE1 || fr == WFRAME_FIRE2)
	if (t)
	if (!self.crouch) // shoot anim stands up, this looks bad
	{
		local vector anim;
		anim = self.anim_shoot;
		anim_z = anim_y / t;
		player_setanim(anim, FALSE, TRUE, TRUE);
	}
};

void weapon_boblayer1(float spd, vector org)
{
	// VorteX: haste can be added here
};

vector W_CalculateProjectileVelocity(vector pvelocity, vector mvelocity)
{
	vector mdirection;
	float mspeed;
	float outspeed;
	float nstyle;
	vector outvelocity;

	mdirection = normalize(mvelocity);
	mspeed = vlen(mvelocity);

	nstyle = cvar("g_projectiles_newton_style");
	if(nstyle == 0)
	{
		// absolute velocity
		outvelocity = mvelocity;
	}
	else if(nstyle == 1)
	{
		// true Newtonian projectiles
		outvelocity = pvelocity + mvelocity;
	}
	else if(nstyle == 2)
	{
		// true Newtonian projectiles with automatic aim adjustment
		//
		// solve: |outspeed * mdirection - pvelocity| = mspeed
		// outspeed^2 - 2 * outspeed * (mdirection * pvelocity) + pvelocity^2 - mspeed^2 = 0
		// outspeed = (mdirection * pvelocity) +- sqrt((mdirection * pvelocity)^2 - pvelocity^2 + mspeed^2)
		// PLUS SIGN!
		// not defined?
		// then...
		// pvelocity^2 - (mdirection * pvelocity)^2 > mspeed^2
		// velocity without mdirection component > mspeed
		// fire at smallest possible mspeed that works?
		// |(mdirection * pvelocity) * pvelocity - pvelocity| = mspeed

		float D;
		float p;
		float q;
		p = mdirection * pvelocity;
		q = pvelocity * pvelocity - mspeed * mspeed;
		D = p * p - q;
		if(D < 0)
		{
			//dprint("impossible shot, adjusting\n");
			D = 0;
		}
		outspeed = p + sqrt(D);
		outspeed = bound(mspeed * 0.7, outspeed, mspeed * 5.0);
		outvelocity = mdirection * outspeed;
	}
	else if(nstyle == 3)
	{
		// pseudo-Newtonian:
		outspeed = mspeed + mdirection * pvelocity;
		outspeed = bound(mspeed * 0.7, outspeed, mspeed * 5.0);
		outvelocity = mdirection * outspeed;
	}
	else if(nstyle == 4)
	{
		// tZorkian:
		outspeed = mspeed + vlen(pvelocity);
		outvelocity = mdirection * outspeed;
	}
	else
		error("g_projectiles_newton_style must be 0 (absolute), 1 (Newtonian), 2 (Newtonian + aimfix), 3 (pseudo Newtonian) or 4 (tZorkian)!");

	return outvelocity;
}

void W_SetupProjectileVelocity(entity missile)
{
	if(missile.owner == world)
		error("Unowned missile");

	missile.velocity = W_CalculateProjectileVelocity(missile.owner.velocity, missile.velocity);
}
