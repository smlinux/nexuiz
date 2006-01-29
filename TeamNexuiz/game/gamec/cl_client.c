void info_player_start (void)
{
	if (self.allowteams != "")
	{
		if (self.allowteams == "blue")
			self.team_no = 1;
		if (self.allowteams == "red")
			self.team_no = 2;
		if (!self.goal_state)
			self.goal_state = 1;
		if (!self.group_no)
			self.group_no = 1;
		i_p_t();
		return;
	}
	else
	{
		self.classname = "info_player_deathmatch";
	}
};

void info_player_deathmatch (void)
{
}
/*
===============
 Find Team Spawn Point (NexTF!)
				 ===============
*/
entity (float team_num) FindTeamSpawnPoint =
{
	local entity spot;
	local entity at_spot;
	local float spot_found;
	local float attempts;

	if ((team_num == 1))
	{
		spot = lastspawn_team1;
		attempts = 0;
		while (1)
		{
			attempts = (attempts + 1);
			spot = find (spot, team_str_home, "ts1");
			if ((spot == world))
			{
				spot = find (world, team_str_home, "ts1");
			}
			if ((spot == world))
			{
				return (world);
			}
			at_spot = findradius (spot.origin, 40);
			spot_found = 1;
			while ((at_spot != world))
			{
				if (((at_spot.classname == "player") && (at_spot.deadflag == 0)))
				{
					spot_found = 0;
				}
				at_spot = at_spot.chain;
			}
			if (!Activated (spot, self))
			{
				spot_found = 0;
			}
			if ((spot_found || (attempts >= 30)))
			{
				lastspawn_team1 = spot;
				return (spot);
			}
		}
	}
	else
	{
		if ((team_num == 2))
		{
			spot = lastspawn_team2;
			attempts = 0;
			while (1)
			{
				attempts = (attempts + 1);
				spot = find (spot, team_str_home, "ts2");
				if ((spot == world))
				{
					spot = find (world, team_str_home, "ts2");
				}
				if ((spot == world))
				{
					return (world);
				}
				at_spot = findradius (spot.origin, 40);
				spot_found = 1;
				while ((at_spot != world))
				{
					if (((at_spot.classname == "player") && (at_spot.deadflag == 0)))
					{
						spot_found = 0;
					}
					at_spot = at_spot.chain;
				}
				if (!Activated (spot, self))
				{
					spot_found = 0;
				}
				if ((spot_found || (attempts >= 30)))
				{
					lastspawn_team2 = spot;
					return (spot);
				}
			}
		}
		else
		{
			if ((team_num == 3))
			{
				spot = lastspawn_team3;
				attempts = 0;
				while (1)
				{
					attempts = (attempts + 1);
					spot = find (spot, team_str_home, "ts3");
					if ((spot == world))
					{
						spot = find (world, team_str_home, "ts3");
					}
					if ((spot == world))
					{
						return (world);
					}
					at_spot = findradius (spot.origin, 40);
					spot_found = 1;
					while ((at_spot != world))
					{
						if (((at_spot.classname == "player") && (at_spot.deadflag == 0)))
						{
							spot_found = 0;
						}
						at_spot = at_spot.chain;
					}
					if (!Activated (spot, self))
					{
						spot_found = 0;
					}
					if ((spot_found || (attempts >= 30)))
					{
						lastspawn_team3 = spot;
						return (spot);
					}
				}
			}
			else
			{
				if ((team_num == 4))
				{
					spot = lastspawn_team4;
					attempts = 0;
					while (1)
					{
						attempts = (attempts + 1);
						spot = find (spot, team_str_home, "ts4");
						if ((spot == world))
						{
							spot = find (world, team_str_home, "ts4");
						}
						if ((spot == world))
						{
							return (world);
						}
						at_spot = findradius (spot.origin, 40);
						spot_found = 1;
						while ((at_spot != world))
						{
							if (((at_spot.classname == "player") && (at_spot.deadflag == 0)))
							{
								spot_found = 0;
							}
							at_spot = at_spot.chain;
						}
						if (!Activated (spot, self))
						{
							spot_found = 0;
						}
						if ((spot_found || (attempts >= 30)))
						{
							lastspawn_team4 = spot;
							return (spot);
						}
					}
				}
			}
		}
	}
	return (world);
};

/*
=============
SelectSpawnPoint

Finds a point to respawn
=============
*/
entity () SelectSpawnPoint =
{
	local entity spot;
	local entity at_spot;
	local float spot_found;
	local float attempts;

	if (self.team_no < 1)
	{
//		self.origin_z = self.origin_z + 30;
		if (!cvar("g_teamnexuiz_version"))
			self.current_menu = MENU_NEED_TN;

		stuffcmd(self, "alias menu_showteamselect \"set scmenu_directmenu TeamSelect; togglemenu\"\n");
		stuffcmd(self, "set scmenu_directmenu TeamSelect; togglemenu\n");

		stuffcmd(self, "alias classmenu \"impulse 73\"\n");
//		spot = find (world, classname, "item_tfgoal");
//		return (spot);
	}
	self.is_dead = 0;		//TEMP

	if ((self.team_no != 0))
	{
		spot = FindTeamSpawnPoint (self.team_no);
		if ((spot != world))
		{
			return (spot);
		}
	}
	if (coop)
	{
		lastspawn = find (lastspawn, classname, "info_player_coop");
		if ((lastspawn == world))
		{
			lastspawn = find (world, classname, "info_player_coop");
		}
		if ((lastspawn != world))
		{
			return (lastspawn);
		}
	}
	else
	{
		if (deathmatch)
		{
			spot = find (lastspawn, classname, "info_player_deathmatch");
			if ((spot == world))
			{
				spot = find (world, classname, "info_player_deathmatch");
			}
			attempts = 0;
			while (((spot != world) && (attempts < 100)))
			{
				attempts = (attempts + 1);
				at_spot = findradius (spot.origin, 40);
				spot_found = 1;
				while (at_spot)
				{
					if (((at_spot.classname == "player") && (at_spot.deadflag == 0)))
					{
						spot_found = 0;
					}
					at_spot = at_spot.chain;
				}
				if ((spot_found || (attempts >= 10)))
				{
					lastspawn = spot;
					return (spot);
				}
				spot = find (spot, classname, "info_player_deathmatch");
				if ((spot == world))
				{
					spot = find (world, classname, "info_player_deathmatch");
				}
			}
		}
	}
	if (serverflags)
	{
		spot = find (world, classname, "info_player_start2");
		if (spot)
		{
			return (spot);
		}
	}
	spot = find (world, classname, "info_player_start");
	if (!spot)
	{
		spot = find (world, is_converted_goal, "yes");
	}
	if (!spot)
	{
		spot = find (world, classname, "info_tfgoal");
	}
	if (!spot)
	{
		error ("PutClientInServer: no info_player_start on level\n");
	}
	return (spot);
};

/*entity SelectSpawnPoint (void)		// Old, non-tf code
{
	local entity spot, thing;
	local float pcount;

	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;

	spot = lastspawn;
	while (1)
	{
		spot = find(spot, classname, "info_player_deathmatch");
		if (spot != world)
		{
			if (spot == lastspawn)
				return lastspawn;
			pcount = 0;
			thing = findradius(spot.origin, 70);
			while(thing)
			{
				if (thing.classname == "player")
					pcount = pcount + 1;
				thing = thing.chain;
			}
			if (pcount == 0)
			{
				lastspawn = spot;
				return spot;
			}
		}
	}

	spot = find (world, classname, "info_player_start");
	if (!spot)
		error ("PutClientInServer: no info_player_start on level");

	return spot;
}*/

/*
=============
CheckPlayerModel

Checks if the argument string can be a valid playermodel.
Returns a valid one in doubt.
=============
*/
string CheckPlayerModel(string playermodel) {
	if( substring(playermodel,0,13) != "models/class/") playermodel = "models/class/scout.zym";

	/* Possible Fixme: Check if server can open the model?
	   This would kill custom models, however. */

	return playermodel;
}


/*
=============
PutClientInServer

Called when a client spawns in the server
=============
*/
void PutClientInServer (void)
{
	entity	spot;
	float oldcl;
	if (self.team_no < 1)
	{
	self.movetype = 0;
	self.solid = 0;
	self.flags = FL_CLIENT;
	self.takedamage = DAMAGE_AIM;
	self.effects = 0;
	self.health = cvar("g_balance_health_start");
	self.max_health = cvar("g_balance_health_stable");
	self.armorvalue = cvar("g_balance_armor_start");
	self.max_armor = self.armorvalue;
	self.damageforcescale = 2;
	self.death_time = 0;
	self.dead_time = 0;
	self.dead_frame = 0;
	self.die_frame = 0;
	self.alpha = 0;
	self.scale = 0;
	self.fade_time = 0;
	self.pain_frame = 0;
	self.pain_finished = 0;
	self.strength_finished = 0;
	self.invincible_finished = 0;
	//self.speed_finished = 0;
	//self.slowmo_finished = 0;
	// players have no think function
	self.think = SUB_Null;
	self.nextthink = 0;
	self.speed = -1;
	self.jump_pad = 0;
	spot = SelectSpawnPoint();
//	setorigin (self, spot.origin + '0 0 1' * (1 - self.mins_z + 24));
	setorigin (self, spot.origin + '-2 0 4' * (1 - self.mins_z + 24));
	self.angles_y = self.angles_y + 180;
	return;
	}
	if (self.playerclass < 1)
	{
		stuffcmd(self, "set scmenu_directmenu ClassSelect; togglemenu\n");
		return;
	}

	// fixme: are these the right teams & colors?
	/*if(self.team == 5)		// Wazat -- I'm using TeamFortress_TeamSet for this now
	{
		self.team_no = 1;
	}
	if(self.team == 14)
	{
		self.team_no = 2;
	}
	if(self.team == 4)
	{
		self.team_no = 3;
	}
	if(self.team == 13)
	{
		self.team_no = 4;
	}*/

	DoTFAliases ();

//	spot = SelectSpawnPoint ();		// moved down
	self.classname = "player";
	self.movetype = MOVETYPE_WALK;
	self.solid = SOLID_SLIDEBOX;
	self.flags = FL_CLIENT;
	self.takedamage = DAMAGE_AIM;
	self.effects = 0;
	self.health = cvar("g_balance_health_start");
	self.max_health = cvar("g_balance_health_stable");
	self.armorvalue = cvar("g_balance_armor_start");
	self.max_armor = self.armorvalue;
	self.damageforcescale = 2;
	self.death_time = 0;
	self.dead_time = 0;
	self.dead_frame = 0;
	self.die_frame = 0;
	self.alpha = 0;
	self.scale = 0;
	self.fade_time = 0;
	self.pain_frame = 0;
	self.pain_finished = 0;
	self.strength_finished = 0;
	self.invincible_finished = 0;
	//self.speed_finished = 0;
	//self.slowmo_finished = 0;
	// players have no think function
	self.think = SUB_Null;
	self.nextthink = 0;
	self.speed = -1;
	self.jump_pad = 0;
	//self.wpn5 = 0; // not carrying an extra weapon
	ResetExtraWeapon(); // not carrying an extra weapon

	DelayHealthRegen(self);
	DelayArmorRegen(self);
	DelayHealthRot(self);
	DelayArmorRot(self);


	self.special_active = 0;
	self.special_time = 0;

	self.grenade_time = 0;

	if(self.onfire != world)
		remove(self.onfire);
	self.onfire = world;
	self.flame_heat = 0;
	self.flame_heat_time = 0;

	self.poison_damage = 0;
	self.poison_rate = 0;

	self.is_feigning = 0;
	self.current_menu = 0;

	// if the player is supposed to change model (and hence class) on respawn, do it.
	if(self.change_mdl_on_respawn != "")
	{
		self.playermodel = self.change_mdl_on_respawn;
		//strunzone(self.change_mdl_on_respawn); // can't unzone or it'll crash later
	}
	// set the class.  If he changed classes while dead it will take effect now.
	oldcl = self.class;
	self.class = GetPlayerClass();
	Do_TFClass_Conversion();
	ChangeClass((oldcl != self.class), FALSE);



	self.deadflag = DEAD_NO;

	spot = SelectSpawnPoint ();		// maybe temp
	self.angles = spot.angles;
	self.fixangle = TRUE; // turn this way immediately
	self.velocity = '0 0 0';
	self.avelocity = '0 0 0';
	self.punchangle = '0 0 0';
	self.punchvector = '0 0 0';

	self.viewzoom = 0.6;


	self.playermodel = CheckPlayerModel(self.playermodel);

	precache_model (self.playermodel);
	setmodel (self, self.playermodel);
	self.skin = stof(self.playerskin);
	self.mdl = strzone(self.playermodel);

	self.crouch = FALSE;
	self.view_ofs = PL_VIEW_OFS;
	setsize (self, PL_MIN, PL_MAX);
	setorigin (self, spot.origin + '0 0 1' * (1 - self.mins_z - 24));
	// don't reset back to last position, even if new position is stuck in solid
	self.oldorigin = self.origin;

//	self.items = IT_LASER | IT_UZI| IT_SHOTGUN | IT_GRENADE_LAUNCHER | IT_ELECTRO | IT_CRYLINK | IT_NEX | IT_HAGAR | IT_ROCKET_LAUNCHER;
//	self.weapon = IT_UZI;


	// fixme: move this to Become<Class> code
/*	self.items = IT_WEP1 | IT_WEP2 | IT_WEP3 | IT_WEP4;
	//self.weapon = 1;
	self.switchweapon = IT_WEP2;
	self.ammo_shells = 50;
	self.ammo_nails = 0;
	self.ammo_rockets = 0;
	self.ammo_cells = 0;*/

	if (cvar("g_fullbrightplayers") == 1)
		self.effects = EF_FULLBRIGHT;

	self.event_damage = PlayerDamage;

	self.statdraintime = time + 5;
	self.button0 = self.button1 = self.button2 = self.button3 = 0;

	/*
	W_UpdateWeapon();
	W_UpdateAmmo();
	*/
	CL_SpawnWeaponentity();
	self.weaponentity.alpha = self.exteriorweaponentity.alpha = 0;
	self.weaponentity.colormod = '0 0 0';
	self.weaponentity.scale = 0;

	//stuffcmd(self, "chase_active 0");
}

/*
=============
SetNewParms
=============
*/
void SetNewParms (void)
{

}

/*
=============
SetChangeParms
=============
*/
void SetChangeParms (void)
{

}

/*
=============
ClientKill

Called when a client types 'kill' in the console
=============
*/
void ClientKill (void)
{
	Damage(self, self, self, 100000, DEATH_KILL, self.origin, '0 0 0');
}

/*
=============
ClientConnect

Called when a client connects to the server
=============
*/
void ClientConnect (void)
{
	//ClientInRankings();
	bprint ("^4",self.netname);
	bprint (" connected\n");
	stuffcmd(self, strcat("exec maps/", mapname, ".cfg\n"));
	// send prediction settings to the client
	stuffcmd(self, strcat("cl_movement_maxspeed ", ftos(cvar("sv_maxspeed")), "\n"));
	stuffcmd(self, strcat("cl_movement_maxairspeed ", ftos(cvar("sv_maxairspeed")), "\n"));
	stuffcmd(self, strcat("cl_movement_accelerate ", ftos(cvar("sv_accelerate")), "\n"));
	stuffcmd(self, strcat("cl_movement_friction ", ftos(cvar("sv_friction")), "\n"));
	stuffcmd(self, strcat("cl_movement_stopspeed ", ftos(cvar("sv_stopspeed")), "\n"));
	stuffcmd(self, strcat("cl_movement_jumpvelocity ", ftos(cvar("g_balance_jumpheight")), "\n"));
	stuffcmd(self, strcat("cl_movement_stepheight ", ftos(cvar("sv_stepheight")), "\n"));
	stuffcmd(self, strcat("cl_movement_edgefriction 0\n"));
			// TEMP FOR TESTING PURPOSES!
	//teamplay = 21?TeamFortress;
	DecodeLevelParms ();
	//cvar_set ("teamplay", "21?TeamFortress");
	//	teamplay = cvar ("teamplay");

/*	joinorder = joinorder + 1;			// old temp autoteam, but now we have a menu instead :P
	if (joinorder == 1 || joinorder == 3 || joinorder == 5 || joinorder == 7)
		TeamFortress_TeamSet (1);
	else {
		TeamFortress_TeamSet (2);
	}*/
}

/*
=============
ClientDisconnect

Called when a client disconnects from the server
=============
*/
.entity chatbubbleentity;
void ClientDisconnect (void)
{
	//ClientDisconnected();
	self.has_disconnected = 1;
	bprint ("^4",self.netname);
	bprint (" disconnected\n");

	if (self.chatbubbleentity)
	{
		remove (self.chatbubbleentity);
		self.chatbubbleentity = world;
	}
	
	if (self.teambubble_friendly)
	{
		remove (self.teambubble_friendly);
		self.teambubble_friendly = world;
	}
	if (self.teambubble_needhealth)
	{
		remove (self.teambubble_needhealth);
		self.teambubble_needhealth = world;
	}
}

.entity chatbubbleentity;
.float buttonchat;
void() ChatBubbleThink =
{
	self.nextthink = time;
	if (!self.owner.modelindex || self.owner.chatbubbleentity != self)
	{
		remove(self);
		return;
	}
	setorigin(self, self.owner.origin + '0 0 15' + self.owner.maxs_z * '0 0 1');
	if (self.owner.buttonchat)
		self.effects = 0;
	else
		self.effects = EF_NODRAW;
};

void() UpdateChatBubble =
{
	if (!self.modelindex)
		return;
	// spawn a chatbubble entity if needed
	if (!self.chatbubbleentity)
	{
		self.chatbubbleentity = spawn();
		self.chatbubbleentity.owner = self;
		self.chatbubbleentity.think = ChatBubbleThink;
		self.chatbubbleentity.nextthink = time;
		setmodel(self.chatbubbleentity, "models/misc/chatbubble.spr");
		setorigin(self.chatbubbleentity, self.origin + '0 0 15' + self.maxs_z * '0 0 1');
		self.chatbubbleentity.effects = EF_NODRAW;
	}
}

// LordHavoc: this hack will be removed when proper _pants/_shirt layers are
// added to the model skins
void() UpdateColorModHack =
{
	local float c;
	c = self.clientcolors & 15;
	// LordHavoc: only bothering to support white, green, red, yellow, blue
	     if (teamplay == 0) self.colormod = '0 0 0';
	else if (c ==  0) self.colormod = '1.00 1.00 1.00';
	else if (c ==  3) self.colormod = '0.10 1.73 0.10';
	else if (c ==  4) self.colormod = '1.73 0.10 0.10';
	else if (c == 12) self.colormod = '1.22 1.22 0.10';
	else if (c == 13) self.colormod = '0.10 0.10 1.73';
	else self.colormod = '1 1 1';
};

/*
=============
PlayerJump

When you press the jump key
=============
*/
void PlayerJump (void)
{
	if (self.waterlevel >= 2)
	{
		if (self.watertype == CONTENT_WATER)
			self.velocity_z = 200;
		else if (self.watertype == CONTENT_SLIME)
			self.velocity_z = 80;
		else
			self.velocity_z = 50;

		return;
	}
	if(self.jump_pad)
		return;

//	self.jump_pad = 0;
	CapPlayerVelocity(self, self.speed);


	if (!(self.flags & FL_ONGROUND))
		return;

	if (!(self.flags & FL_JUMPRELEASED))
		return;

	self.velocity_z = self.velocity_z + cvar("g_balance_jumpheight");

	self.flags = self.flags - FL_ONGROUND;
	self.flags = self.flags - FL_JUMPRELEASED;
}

.float watersound_finished;
void() WaterMove =
{
	if (self.movetype == MOVETYPE_NOCLIP)
		return;
	if (self.health < 0)
		return;

	if (self.waterlevel != 3)
	{
		self.air_finished = time + 12;
		self.dmg = 2;
	}
	else if (self.air_finished < time)
	{	// drown!
		if (self.pain_finished < time)
		{
			Damage (self, world, world, 5, DEATH_DROWN, self.origin, '0 0 0');
			self.pain_finished = time + 0.5;
		}
	}

	if (!self.waterlevel)
	{
		if (self.flags & FL_INWATER)
		{
			// play leave water sound
			self.flags = self.flags - FL_INWATER;
		}
		return;
	}

	if (self.watersound_finished < time)
	{
		self.watersound_finished = time + 0.5;
		if (self.watertype == CONTENT_LAVA)
			sound (self, CHAN_BODY, "player/lava.wav", 1, ATTN_NORM);
		if (self.watertype == CONTENT_SLIME)
			sound (self, CHAN_BODY, "player/slime.wav", 1, ATTN_NORM);
		//if (self.watertype == CONTENT_WATER)
		//	sound (self, CHAN_BODY, "player/water.wav", 1, ATTN_NORM);
	}

	if (self.watertype == CONTENT_LAVA)
	{	// do damage

		// lava sets me to the maximum heat level, so I'll catch fire easily
		self.flame_heat = cvar("g_balance_maxheat");

		if (self.dmgtime < time)
		{
			self.dmgtime = time + 0.1;
			Damage (self, world, world, 3 * self.waterlevel, DEATH_LAVA, self.origin, '0 0 0');
		}
	}
	else if (self.watertype == CONTENT_SLIME)
	{	// do damage

		// cool me off
		self.flame_heat = 0;

		if (self.dmgtime < time)
		{
			self.dmgtime = time + 0.1;
			Damage (self, world, world, 1 * self.waterlevel, DEATH_SLIME, self.origin, '0 0 0');
		}
	}
	else if (self.watertype == CONTENT_WATER)
	{
		// cool me off
		self.flame_heat = 0;
	}

	if ( !(self.flags & FL_INWATER) )
	{

		//if (self.watertype == CONTENT_LAVA)
		//	sound (self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM);
		//if (self.watertype == CONTENT_WATER)
		//	sound (self, CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM);
		//if (self.watertype == CONTENT_SLIME)
		//	sound (self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM);

		self.flags = self.flags + FL_INWATER;
		self.dmgtime = 0;
	}
};

void() CheckWaterJump =
{
	local vector start, end;

// check for a jump-out-of-water
	makevectors (self.angles);
	start = self.origin;
	start_z = start_z + 8;
	v_forward_z = 0;
	normalize(v_forward);
	end = start + v_forward*24;
	traceline (start, end, TRUE, self);
	if (trace_fraction < 1)
	{	// solid at waist
		start_z = start_z + self.maxs_z - 8;
		end = start + v_forward*24;
		self.movedir = trace_plane_normal * -50;
		traceline (start, end, TRUE, self);
		if (trace_fraction == 1)
		{	// open at eye level
			self.flags = self.flags | FL_WATERJUMP;
			self.velocity_z = 225;
			self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
			self.teleport_time = time + 2;	// safety net
			return;
		}
	}
};


void respawn(void)
{
	CopyBody(1);
	PutClientInServer();
}

void player_powerups (void)
{
	self.effects = self.effects - (self.effects & (EF_RED | EF_BLUE | EF_ADDITIVE | EF_FULLBRIGHT));
	if (self.items & IT_STRENGTH)
	{
		self.effects = self.effects | (EF_BLUE | EF_ADDITIVE | EF_FULLBRIGHT);
		if (time > self.strength_finished)
		{
			self.items = self.items - (self.items & IT_STRENGTH);
			sprint(self, "^3Strength has worn off\n");
		}
	}
	else
	{
		if (time < self.strength_finished)
		{
			self.items = self.items | IT_STRENGTH;
			sprint(self, "^3Strength infuses your weapons with devestating power\n");
		}
	}
	if (self.items & IT_INVINCIBLE)
	{
		self.effects = self.effects | (EF_RED | EF_ADDITIVE | EF_FULLBRIGHT);
		if (time > self.invincible_finished)
		{
			self.items = self.items - (self.items & IT_INVINCIBLE);
			sprint(self, "^3Shield has worn off\n");
		}
	}
	else
	{
		if (time < self.invincible_finished)
		{
			self.items = self.items | IT_INVINCIBLE;
			sprint(self, "^3Shield surrounds you\n");
		}
	}
}

void player_regen_health (float maxh, float regen_rate_mod)
{
	if (self.health < maxh && time > self.health_regen_delay && self.health > 2)		// dont regen is HP is 2
		self.health = bound(0, self.health + regen_rate_mod*(maxh- self.health) * cvar("g_balance_health_regen") * frametime, 1000);
}
void player_rot_health (float maxh, float rot_rate_mod)
{
	if (self.health > maxh && time > self.health_rot_delay)
		self.health = bound(0, self.health + rot_rate_mod*(maxh - self.health) * cvar("g_balance_health_rot") * frametime, 1000);
}
void player_regen_armor (float maxa, float regen_rate_mod)
{
	if (self.armorvalue < maxa && time > self.armor_regen_delay)
		self.armorvalue = bound(0, self.armorvalue + regen_rate_mod*(maxa - self.armorvalue) * cvar("g_balance_armor_regen") * frametime, 1000);
}
void player_rot_armor (float maxa, float regen_rot_mod)
{
	if (self.armorvalue > maxa && time > self.armor_rot_delay)
		self.armorvalue = bound(0, self.armorvalue + regen_rot_mod*(maxa - self.armorvalue) * cvar("g_balance_armor_rot") * frametime, 1000);
}

void player_clearpoison(entity targ)
{
	targ.poison_damage = targ.poison_rate = 0;
}

void DelayHealthRegen(entity e)	{	e.health_regen_delay = time + cvar("g_balance_regen_wait");}
void DelayHealthRot(entity e)	{	e.health_rot_delay = time + cvar("g_balance_rot_wait");}
void DelayArmorRegen(entity e)	{	e.armor_regen_delay = time + cvar("g_balance_regen_wait");}
void DelayArmorRot(entity e)	{	e.armor_rot_delay = time + cvar("g_balance_rot_wait");}


void player_takepoison()
{
	float oldhealth, take;
	if(self.health <= 5)
	{
		player_clearpoison(self);
		return;
	}
	oldhealth = self.health;

	take = bound(0, self.poison_rate * frametime, self.health - 5);
	if(take <= 0)
	{
		player_clearpoison(self);
		return;
	}

	DelayHealthRegen(self);
	self.health = self.health - take;
	self.poison_damage = self.poison_damage - take;

	if(self.health <= 5 || self.poison_damage <= 0)
	{
		player_clearpoison(self);
		return;
	}
}

// cool off so you're not so vulnerable to fire
void player_cooloff ()
{
	if(self.flame_heat_time > time)//heat up
		self.flame_heat = bound(0, self.flame_heat + self.flame_heat * cvar("g_balance_heatup_rate")  * frametime, cvar("g_balance_maxheat"));
	else//cool off
		self.flame_heat = bound(0, self.flame_heat - self.flame_heat * cvar("g_balance_cooloff_rate") * frametime, cvar("g_balance_maxheat"));
}

void player_regen (void)
{
	local float maxh;
	local float maxa;
	maxh = self.max_health;//cvar("g_balance_health_stable");
	maxa = self.max_armor;//cvar("g_balance_armor_stable");

	if(self.poison_damage)
	{
		player_takepoison();
		return;
	}

	if(self.class == CLASS_SPY)
	{// don't let spy regenerate if cloaked, but do allow rot if above max
		if(self.special_active)
		{
			//if(self.health > maxh)
				player_rot_health(maxh, 1.0);
			//if(self.armorvalue > maxa)
				player_rot_armor(maxa, 1.0);
		}
		else
		{
			player_regen_health(maxh, 0.1); // spies regenerate slowly, and mostly rely on health packs
			player_regen_armor(maxa, 1.0);
			player_rot_health(maxh, 1.0);
			player_rot_armor(maxa, 1.0);
		}
	}
	else
	{
		player_regen_health(maxh, 1.0);
		player_regen_armor(maxa, 1.0);
		player_rot_health(maxh, 1.0);
		player_rot_armor(maxa, 1.0);
	}

	player_cooloff();
}

/*
=============
PlayerPreThink

Called every frame for each client before the physics are run
=============
*/
.float attack_finished;
void PlayerPreThink (void)
{
	local vector m1, m2;

	CheckRules_Player();

	if (intermission_running)
	{
		IntermissionThink ();	// otherwise a button could be missed between
		return;					// the think tics
	}

	if (self.deadflag != DEAD_NO)
	{
		player_anim();
		weapon_freeze();
		if (self.deadflag == DEAD_DYING)
		{
			if (time > self.dead_time)
				self.deadflag = DEAD_DEAD;
		}
		else if (self.deadflag == DEAD_DEAD)
		{
			if (!self.button0 && !self.button2 && !self.button3)
				self.deadflag = DEAD_RESPAWNABLE;
		}
		else if (self.deadflag == DEAD_RESPAWNABLE)
		{
			if (self.button0 || self.button2 || self.button3  || self.button4)
				respawn();
		}
		return;
	}

	if (self.button5)
	{
		if (!self.crouch)
		{
			self.crouch = TRUE;
			self.view_ofs = PL_CROUCH_VIEW_OFS;
			setsize (self, PL_CROUCH_MIN, PL_CROUCH_MAX);
		}
	}
	else
	{
		if (self.crouch)
		{
			tracebox(self.origin, PL_MIN, PL_MAX, self.origin, FALSE, self);
			if (!trace_startsolid)
			{
				self.crouch = FALSE;
				self.view_ofs = PL_VIEW_OFS;
				setsize (self, PL_MIN, PL_MAX);
			}
		}
	}

	if (self.playermodel != self.mdl)
	{
		//bprint("playermodel changed\n");
		self.playermodel = CheckPlayerModel(self.playermodel);
		if(CheckForClassChange()) // check if we'll allow it
			return; // if there's a return value, drop what you're doing and let the player respawn

		if(self.playermodel != self.mdl) // if change has been allowed
		{
			m1 = self.mins;
			m2 = self.maxs;
			precache_model (self.playermodel);
			if(self.model != "")
			{
				setmodel (self, self.playermodel);
				setsize (self, m1, m2);
			}
			self.mdl = strzone(self.playermodel);
		}
	}

	ClassPreThink();

	if (self.skin != stof(self.playerskin))
		self.skin = stof(self.playerskin);

	if(self.class == CLASS_SCOUT)
		GrapplingHookFrame();

	W_WeaponFrame();

	if (self.button4 || (self.weapon == WEP_NEX && self.button3))
	{
		if (self.viewzoom > 0.4)
			self.viewzoom = max (0.4, self.viewzoom - frametime * 2);
	}
	else if (self.viewzoom < 1.0)
		self.viewzoom = min (1.0, self.viewzoom + frametime);


	if (self.button2)
		PlayerJump ();
	else
		self.flags = self.flags | FL_JUMPRELEASED;


	player_powerups();
	player_regen();
	player_anim();

	//self.angles_y=self.v_angle_y + 90;   // temp

	WaterMove ();
	if (self.waterlevel == 2)
		CheckWaterJump ();

	//if (TetrisPreFrame()) return;

	PlayerLasergatePreThink();
}

/*
=============
PlayerPostThink

Called every frame for each client after the physics are run
=============
*/
void PlayerPostThink (void)
{
	float soundrandom;
	CheckRules_Player();
	UpdateChatBubble();
	UpdateColorModHack();
	UpdateTeamBubble();
	if (self.deadflag == DEAD_NO)
	if (self.impulse)
		ImpulseCommands ();
	if (intermission_running)
		return;		// intermission or finale

	// VorteX: landing on floor, landing damage etc.
	// LordHavoc: removed 'big fall' death code that VorteX added
	if (self.flags & FL_ONGROUND || (self.waterlevel >= 2 && self.velocity_z <= 0))
			self.jump_pad = 0;

	if (self.flags & FL_ONGROUND)
	{
		CapPlayerVelocity(self, self.speed);

		if (self.jump_flag < -100 && !self.watertype == CONTENT_WATER) // HitGround
		{
			soundrandom = random() * 4;

			self.air_time = time;		//temp BH var

			if (soundrandom < 1)
				sound (self, CHAN_BODY, "misc/hitground1.wav", 1, ATTN_NORM);
			else if (soundrandom < 2)
				sound (self, CHAN_BODY, "misc/hitground2.wav", 1, ATTN_NORM);
			else if (soundrandom < 3)
				sound (self, CHAN_BODY, "misc/hitground3.wav", 1, ATTN_NORM);
			else if (soundrandom < 4)
				sound (self, CHAN_BODY, "misc/hitground4.wav", 1, ATTN_NORM);
			if (self.jump_flag < -650) // landing damage
			{
				local float dm;
				dm = bound(0, 0.1*(fabs(self.jump_flag) - 600), 5);
				Damage (self, world, world, dm, DEATH_FALL, self.origin, '0 0 0');
			}
			self.jump_flag = 0;
		}
	}
	else
		self.jump_flag = self.velocity_z;

	ClassPostThink();

	//if (TetrisPostFrame()) return;
	PlayerLasergatePostThink();
}

// Parse team join, class etc.
void SV_ParseClientCommand (string s)
{
	local float args;
//	local float h;
	local string c;
	local string d;
	local string f;
	local string g;
	local string i;
	args = tokenize(s);
	c = argv(0);
	d = argv(1);
	f = argv(2);
	g = argv(3);
	i = argv(4);

	if (c == "join")
    {
		return;
	}
	if (c == "changeclass")
	{
		stuffcmd(self, "set scmenu_directmenu ClassSelect; togglemenu\n");
		return;
	}
	if (c == "selectteam")
    {
		if (self.team_no > 0)
		{
			sprint(self, "You are already on a team!\n");
			return;
		}
		if (d == "auto" || d == "5")
		{
			TeamFortress_TeamPutPlayerInTeam();
			PutClientInServer ();
		}
		if (d == "blue" || d == "1")
		{
			TeamFortress_TeamSet (1);
			PutClientInServer ();
		}
		if (d == "red" || d == "2")
		{
			TeamFortress_TeamSet (2);
			PutClientInServer ();
		}
		if (d == "yellow" || d == "3")
		{
			TeamFortress_TeamSet (3);
			PutClientInServer ();
		}
		if (d == "green" || d == "pink" || d == "4")		// Morphed set it to Pink in the menus. I think
		{													// we should make it white instead.
			TeamFortress_TeamSet (4);
			PutClientInServer ();
		}
		return;
	}
	if (c == "selectclass")
    {
		if (self.team_no < 1)
		{
			sprint(self, "You must select a team to join first!\n");
			return;
		}
		if (TeamFortress_TeamIsCivilian (self.team_no))
		{
			self.impulse = 1;
			TeamFortress_ChangeClass ();
			return;
		}
		if (self.playerclass > 0)		// if a class is already chosen
		{
			self.tfstate = self.tfstate - (self.tfstate & 8);
			local string cname;
			if (d == ftos(TF_CLASS_SCOUT))
			{
				cname = "scout";
			}
			if (d == ftos(TF_CLASS_SOLDIER))
			{
				cname = "soldier";
			}
			if (d == ftos(TF_CLASS_MEDIC))
			{
				cname = "medic";
			}
			if (d == ftos(TF_CLASS_PYRO))
			{
				cname = "pyro";
			}
			if (d == ftos(TF_CLASS_ENGINEER))
			{
				cname = "engineer";
			}
			if (d == ftos(TF_CLASS_SPY))
			{
				cname = "spy";
			}
			if (d == ftos(TF_CLASS_RANDOM))
			{
				self.tfstate = self.tfstate | 8;
				sprint(self, "You will respawn as a random class.\n");
			}
			if (cname != "")
			{
//				stuffcmd(self, "_cl_playermodel \"models/class/");
//				stuffcmd(self, cname);
//				stuffcmd(self, "_mechanical.zym\"\n");
				if (cname == "engineer")
				{
					self.playermodel = strcat("models/class/",cname,"_other.zym");
				}
				else
				{
					self.playermodel = strcat("models/class/",cname,"_mechanical.zym");
				}
				if (self.is_dead == 1)		// if player is dead, can change class
					CheckForClassChange();
			}
		}
		else			// if no class is chosen
		{
			if (d == ftos(TF_CLASS_SCOUT))
			{
				self.impulse = TF_CLASS_SCOUT;
			}
			if (d == ftos(TF_CLASS_SOLDIER))
			{
				self.impulse = TF_CLASS_SOLDIER;
			}
			if (d == ftos(TF_CLASS_MEDIC))
			{
				self.impulse = TF_CLASS_MEDIC;
			}
			if (d == ftos(TF_CLASS_PYRO))
			{
				self.impulse = TF_CLASS_PYRO;
			}
			if (d == ftos(TF_CLASS_ENGINEER))
			{
				self.impulse = TF_CLASS_ENGINEER;
			}
			if (d == ftos(TF_CLASS_SPY))
			{
				self.impulse = TF_CLASS_SPY;
			}
			if (d == ftos(TF_CLASS_RANDOM))
			{
				self.impulse = TF_CLASS_RANDOM;
			}
			TeamFortress_ChangeClass();
		}
		return;
	}
	else if (c == "check_val")
	{
		if (d == "r_bloom")
		{
			if (f == "1")
				self.uses_bloom = 1;
			else
				self.uses_bloom = 0;
		}
	}
	else
	{
		clientcommand(self, s);
	}
};