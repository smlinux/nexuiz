#define FOR_EACH_KH_KEY(v) for(v = kh_worldkeylist; v; v = v.kh_worldkeynext )

// #define KH_PLAYER_USE_ATTACHMENT
// #define KH_PLAYER_USE_CARRIEDMODEL
// #define KH_KEY_ATTACHMENT_DEBUG

#ifdef KH_PLAYER_USE_ATTACHMENT
vector KH_PLAYER_ATTACHMENT_DIST_ROTATED = '0 -4 0';
vector KH_PLAYER_ATTACHMENT_DIST = '4 0 0';
vector KH_PLAYER_ATTACHMENT = '0 0 0';
vector KH_PLAYER_ATTACHMENT_ANGLES = '0 0 0';
string KH_PLAYER_ATTACHMENT_BONE = "";
#else
float KH_KEY_ZSHIFT = 22;
float KH_KEY_XYDIST = 24;
float KH_KEY_XYSPEED = 45;
#endif
float KH_KEY_WP_ZSHIFT = 20;

vector KH_KEY_MIN = '-10 -10 -46';
vector KH_KEY_MAX = '10 10 3';
float KH_KEY_BRIGHTNESS = 2;

string kh_Controller_Waitmsg;
float kh_no_radar_circles;

// kh_state
//     bits  0- 4: team of key 1, or 0 for no such key, or 30 for dropped, or 31 for self
//     bits  5- 9: team of key 2, or 0 for no such key, or 30 for dropped, or 31 for self
//     bits 10-14: team of key 3, or 0 for no such key, or 30 for dropped, or 31 for self
//     bits 15-19: team of key 4, or 0 for no such key, or 30 for dropped, or 31 for self
.float kh_state;
.float siren_time;  //  time delay the siren
//.float stuff_time;  //  time delay to stuffcmd a cvar

float test[17] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
//test[0] = status of dropped keys, test[1 - 16] = player #
//replace 17 with cvar("maxplayers") or similar !!!!!!!!!
//for(i = 0; i < maxplayers; ++i)
//	test[i] = "0";

float kh_Team_ByID(float t)
{
	if(t == 0) return COLOR_TEAM1;
	if(t == 1) return COLOR_TEAM2;
	if(t == 2) return COLOR_TEAM3;
	if(t == 3) return COLOR_TEAM4;
	return 0;
}

entity kh_worldkeylist;
.entity kh_worldkeynext;
entity kh_controller;
float kh_tracking_enabled;
float kh_teams;
float kh_interferemsg_time, kh_interferemsg_team;
.entity kh_next, kh_prev; // linked list
.float kh_droptime;
.float kh_dropperteam;
.entity kh_previous_owner;
.float kh_previous_owner_playerid;

string kh_sound_capture = "kh/capture.wav";
string kh_sound_destroy = "kh/destroy.wav";
string kh_sound_drop = "kh/drop.wav";
string kh_sound_collect = "kh/collect.wav";
string kh_sound_alarm = "kh/alarm.wav";  // the new siren/alarm

float kh_key_dropped, kh_key_carried;

void kh_Controller_SetThink(float t, string msg, kh_Think_t func)  // runs occasionaly
{
	kh_Controller_Thinkfunc = func;
	kh_controller.cnt = ceil(t);
	if(kh_Controller_Waitmsg != "")
		strunzone(kh_Controller_Waitmsg);
	if(msg == "")
		kh_Controller_Waitmsg = "";
	else
		kh_Controller_Waitmsg = strzone(msg);
	if(t == 0)
		kh_controller.nextthink = time; // force
}

void kh_Controller_Think()  // called a lot
{
	entity e;
	if(intermission_running)
		return;
	if(self.cnt > 0)
	{
		if(kh_Controller_Waitmsg != "")
		{
			string s;
			if(substring(kh_Controller_Waitmsg, strlen(kh_Controller_Waitmsg)-1, 1) == " ")
				s = strcat(kh_Controller_Waitmsg, ftos(self.cnt));
			else
				s = kh_Controller_Waitmsg;

			//dprint(s, "\n");

			FOR_EACH_PLAYER(e)
				if(clienttype(e) == CLIENTTYPE_REAL)
					centerprint_atprio(e, CENTERPRIO_SPAM, s);
		}
		self.cnt -= 1;
	}
	else if(self.cnt == 0)
	{
		self.cnt -= 1;
		kh_Controller_Thinkfunc();
	}
	self.nextthink = time + 1;
}

// frags f: take from cvar * f
// frags 0: no frags
void kh_Scores_Event(entity player, entity key, string what, float frags_player, float frags_owner)  // update the score when a key is captured
{
	string s;
	if(intermission_running)
		return;

	if(frags_player)
		UpdateFrags(player, frags_player);

	if(key && key.owner && frags_owner)
		UpdateFrags(key.owner, frags_owner);

	if(!cvar("sv_eventlog"))  //output extra info to the console or text file
		return;

	s = strcat(":keyhunt:", what, ":", ftos(player.playerid), ":", ftos(frags_player));

	if(key && key.owner)
		s = strcat(s, ":", ftos(key.owner.playerid));
	else
		s = strcat(s, ":0");

	s = strcat(s, ":", ftos(frags_owner), ":");

	if(key)
		s = strcat(s, key.netname);

	GameLogEcho(s);
}

vector kh_AttachedOrigin(entity e)  // runs when a team captures the flag, it can run 2 or 3 times.
{
	if(e.tag_entity)
	{
		makevectors(e.tag_entity.angles);
		return e.tag_entity.origin + e.origin_x * v_forward - e.origin_y * v_right + e.origin_z * v_up;
	}
	else
		return e.origin;
}

void kh_Key_Attach(entity key)  // runs when a player picks up a key and several times when a key is assigned to a player at the start of a round
{
#ifdef KH_PLAYER_USE_ATTACHMENT
	entity first;
	first = key.owner.kh_next;
	if(key == first)
	{
		setattachment(key, key.owner, KH_PLAYER_ATTACHMENT_BONE);
		if(key.kh_next)
		{
			setattachment(key.kh_next, key, "");
			setorigin(key, key.kh_next.origin - 0.5 * KH_PLAYER_ATTACHMENT_DIST);
			setorigin(key.kh_next, KH_PLAYER_ATTACHMENT_DIST_ROTATED);
			key.kh_next.angles = '0 0 0';
		}
		else
			setorigin(key, KH_PLAYER_ATTACHMENT);
		key.angles = KH_PLAYER_ATTACHMENT_ANGLES;
	}
	else
	{
		setattachment(key, key.kh_prev, "");
		if(key.kh_next)
			setattachment(key.kh_next, key, "");
		setorigin(key, KH_PLAYER_ATTACHMENT_DIST_ROTATED);
		setorigin(first, first.origin - 0.5 * KH_PLAYER_ATTACHMENT_DIST);
		key.angles = '0 0 0';
	}
#else
	setattachment(key, key.owner, "");
	setorigin(key, '0 0 1' * KH_KEY_ZSHIFT);  // fixing x, y in think
	key.angles_y -= key.owner.angles_y;
#endif
	key.flags = 0;
	key.solid = SOLID_NOT;
	key.movetype = MOVETYPE_NONE;
	key.team = key.owner.team;
	key.nextthink = time;
	key.damageforcescale = 0;
	key.takedamage = DAMAGE_NO;
	key.modelindex = kh_key_carried;
}

void kh_Key_Detach(entity key) // runs every time a key is dropped or lost. Runs several times times when all the keys are captured
{
#ifdef KH_PLAYER_USE_ATTACHMENT
	entity first;
	first = key.owner.kh_next;
	if(key == first)
	{
		if(key.kh_next)
		{
			setattachment(key.kh_next, key.owner, KH_PLAYER_ATTACHMENT_BONE);
			setorigin(key.kh_next, key.origin + 0.5 * KH_PLAYER_ATTACHMENT_DIST);
			key.kh_next.angles = KH_PLAYER_ATTACHMENT_ANGLES;
		}
	}
	else
	{
		if(key.kh_next)
			setattachment(key.kh_next, key.kh_prev, "");
		setorigin(first, first.origin + 0.5 * KH_PLAYER_ATTACHMENT_DIST);
	}
	// in any case:
	setattachment(key, world, "");
	setorigin(key, key.owner.origin + '0 0 1' * (PL_MIN_z - KH_KEY_MIN_z));
	key.angles = key.owner.angles;
#else
	setorigin(key, key.owner.origin + key.origin_z * '0 0 1');
	setattachment(key, world, "");
	key.angles_y += key.owner.angles_y;
#endif
	key.flags = FL_ITEM;
	key.solid = SOLID_TRIGGER;
	key.movetype = MOVETYPE_TOSS;
	key.pain_finished = time + cvar("g_balance_keyhunt_delay_return");
	key.damageforcescale = cvar("g_balance_keyhunt_damageforcescale");
	key.takedamage = DAMAGE_YES;
	// let key.team stay
	key.modelindex = kh_key_dropped;
	key.kh_previous_owner = key.owner;
	key.kh_previous_owner_playerid = key.owner.playerid;
}

void kh_Key_AssignTo(entity key, entity player)  // runs every time a key is picked up or assigned. Runs prior to kh_key_attach
{
	entity k;
	float ownerteam0, ownerteam;
	if(key.owner == player)
		return;

	ownerteam0 = kh_Key_AllOwnedByWhichTeam();

	if(key.owner)
	{
		kh_Key_Detach(key);

		// remove from linked list
		if(key.kh_next)
			key.kh_next.kh_prev = key.kh_prev;
		key.kh_prev.kh_next = key.kh_next;
		key.kh_next = world;
		key.kh_prev = world;

		if(key.owner.kh_next == world)
		{
			// No longer a key carrier
			if(!kh_no_radar_circles)
				WaypointSprite_Ping(key.owner.waypointsprite_attachedforcarrier);
			WaypointSprite_DetachCarrier(key.owner);
		}
	}

	key.owner = player;

	if(player)
	{
		// insert into linked list
		key.kh_next = player.kh_next;
		key.kh_prev = player;
		player.kh_next = key;
		if(key.kh_next)
			key.kh_next.kh_prev = key;

		float i;
		i = test[key.owner.playerid];
			if(key.netname == "^1red key")
				i += 1;
			if(key.netname == "^4blue key")
				i += 2;
			if(key.netname == "^3yellow key")
				i += 4;
			if(key.netname == "^6pink key")
				i += 8;
		test[key.owner.playerid] = i;

		kh_Key_Attach(key);

		if(key.kh_next == world)
		{
			// player is now a key carrier
			WaypointSprite_AttachCarrier("", player);
			player.waypointsprite_attachedforcarrier.waypointsprite_visible_for_player = kh_KeyCarrier_waypointsprite_visible_for_player;
			WaypointSprite_UpdateRule(player.waypointsprite_attachedforcarrier, player.team, SPRITERULE_TEAMPLAY);
			if(player.team == COLOR_TEAM1)
				WaypointSprite_UpdateSprites(player.waypointsprite_attachedforcarrier, "keycarrier-red", "keycarrier-friend", "keycarrier-red");
			else if(player.team == COLOR_TEAM2)
				WaypointSprite_UpdateSprites(player.waypointsprite_attachedforcarrier, "keycarrier-blue", "keycarrier-friend", "keycarrier-blue");
			else if(player.team == COLOR_TEAM3)
				WaypointSprite_UpdateSprites(player.waypointsprite_attachedforcarrier, "keycarrier-yellow", "keycarrier-friend", "keycarrier-yellow");
			else if(player.team == COLOR_TEAM4)
				WaypointSprite_UpdateSprites(player.waypointsprite_attachedforcarrier, "keycarrier-pink", "keycarrier-friend", "keycarrier-pink");
			WaypointSprite_UpdateTeamRadar(player.waypointsprite_attachedforcarrier, RADARICON_FLAGCARRIER, colormapPaletteColor(player.team - 1, 0));
			if(!kh_no_radar_circles)
				WaypointSprite_Ping(player.waypointsprite_attachedforcarrier);
		}
	}

	// moved that here, also update if there's no player
	kh_update_state();

	key.pusher = world;

	ownerteam = kh_Key_AllOwnedByWhichTeam();
	if(ownerteam != ownerteam0)
	{
		if(ownerteam != -1)
		{
			kh_interferemsg_time = time + 0.2;
			kh_interferemsg_team = player.team;

			// audit all key carrier sprites, update them to RUN HERE
			FOR_EACH_KH_KEY(k)
			{
				if(k.owner)
					WaypointSprite_UpdateSprites(k.owner.waypointsprite_attachedforcarrier, k.owner.waypointsprite_attachedforcarrier.model1, "keycarrier-finish", k.owner.waypointsprite_attachedforcarrier.model3);
			}
		}
		else
		{
			kh_interferemsg_time = 0;

			// audit all key carrier sprites, update them to RUN HERE
			FOR_EACH_KH_KEY(k)
			{
				if(k.owner)
					WaypointSprite_UpdateSprites(k.owner.waypointsprite_attachedforcarrier, k.owner.waypointsprite_attachedforcarrier.model1, "keycarrier-friend", k.owner.waypointsprite_attachedforcarrier.model3);
			}
		}
	}
}

void kh_Key_Damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(self.owner)
		return;
	if(vlen(force) <= 0)
		return;
	if(time > self.pushltime)
		if(attacker.classname == "player")
			self.team = attacker.team;
}

void key_reset()
{
	kh_Key_AssignTo(self, world);
	kh_Key_Remove(self);
}

void kh_Key_Spawn(entity initial_owner, float angle, float i)  // runs every time a new flag is created, ie after all the keys have been collected
{
	entity key;
	key = spawn();
	key.count = i;
	key.classname = STR_ITEM_KH_KEY;
	key.touch = kh_Key_Touch;
	key.think = kh_Key_Think;
	key.nextthink = time;
	key.items = IT_KEY1 | IT_KEY2;
	key.cnt = angle;
	key.angles = '0 360 0' * random();
	key.event_damage = kh_Key_Damage;
	key.takedamage = DAMAGE_YES;
	key.modelindex = kh_key_dropped;
	key.model = "key";
	key.kh_dropperteam = 0;
	key.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_PLAYERCLIP;
	setsize(key, KH_KEY_MIN, KH_KEY_MAX);
	key.colormod = TeamColor(initial_owner.team) * KH_KEY_BRIGHTNESS;
	key.reset = key_reset;

	switch(initial_owner.team)
	{
		case COLOR_TEAM1:
			key.netname = "^1red key";
			break;
		case COLOR_TEAM2:
			key.netname = "^4blue key";
			break;
		case COLOR_TEAM3:
			key.netname = "^3yellow key";
			break;
		case COLOR_TEAM4:
			key.netname = "^6pink key";
			break;
		default:
			key.netname = "NETGIER key";
			break;
	}

	// link into key list
	key.kh_worldkeynext = kh_worldkeylist;
	kh_worldkeylist = key;

	centerprint(initial_owner, strcat("You are starting with the ", key.netname, "\n"));  // message to player at start of round

	WaypointSprite_Spawn("key-dropped", 0, 0, key, '0 0 1' * KH_KEY_WP_ZSHIFT, world, key.team, key, waypointsprite_attachedforcarrier, FALSE);
	key.waypointsprite_attachedforcarrier.waypointsprite_visible_for_player = kh_Key_waypointsprite_visible_for_player;
	WaypointSprite_UpdateTeamRadar(key.waypointsprite_attachedforcarrier, RADARICON_FLAG, '0 1 1');

	kh_Key_AssignTo(key, initial_owner);
}

void kh_Key_Remove(entity key)  // runs after when all the keys have been collected or when a key has been dropped for more than X seconds
{
	entity o;
	o = key.owner;
	kh_Key_AssignTo(key, world);
	if(o) // it was attached
		WaypointSprite_Kill(key.waypointsprite_attachedforcarrier);
	else // it was dropped
		WaypointSprite_DetachCarrier(key);

	// remove key from key list
	if (kh_worldkeylist == key)
		kh_worldkeylist = kh_worldkeylist.kh_worldkeynext;
	else
	{
		o = kh_worldkeylist;
		while (o)
		{
			if (o.kh_worldkeynext == key)
			{
				o.kh_worldkeynext = o.kh_worldkeynext.kh_worldkeynext;
				break;
			}
			o = o.kh_worldkeynext;
		}
	}

	remove(key);

	kh_update_state();
}

// -1 when no team completely owns all keys yet
float kh_Key_AllOwnedByWhichTeam()  // constantly called. check to see if all the keys are owned by the same team
{
	entity key;
	float teem;
	float keys;

	teem = -1;
	keys = kh_teams;
	FOR_EACH_KH_KEY(key)
	{
		if(!key.owner)
			return -1;
		if(teem == -1)
			teem = key.team;
		else if(teem != key.team)
			return -1;
		--keys;
	}
	if(keys != 0)
		return -1;
	return teem;
}

void kh_Key_Collect(entity key, entity player)  //a player picks up a dropped key
{
	sound(player, CHAN_AUTO, kh_sound_collect, VOL_BASE, ATTN_NORM);

	if(key.kh_dropperteam != player.team)
	{
		kh_Scores_Event(player, key, "collect", cvar("g_balance_keyhunt_score_collect"), 0);
		PlayerScore_Add(player, SP_KH_PICKUPS, 1);
	}
	key.kh_dropperteam = 0;
	bprint(player.netname, "^7 picked up the ", key.netname, "\n");

	kh_Key_AssignTo(key, player); // this also updates .kh_state
}

void kh_Key_DropAll(entity player, float suicide) // runs whenever a player dies
{
	entity key;
	entity mypusher;
	if(player.kh_next)
	{
		mypusher = world;
		if(player.pusher)
			if(time < player.pushltime)
				mypusher = player.pusher;
		while((key = player.kh_next))
		{
			kh_Scores_Event(player, key, "losekey", 0, 0);
			PlayerScore_Add(player, SP_KH_LOSSES, 1);
			bprint(player.netname, "^7 died and lost the ", key.netname, "\n");
			kh_Key_AssignTo(key, world);
			makevectors('-1 0 0' * (45 + 45 * random()) + '0 360 0' * random());
			key.velocity = W_CalculateProjectileVelocity(player.velocity, cvar("g_balance_keyhunt_dropvelocity") * v_forward);
			key.pusher = mypusher;
			key.pushltime = time + cvar("g_balance_keyhunt_protecttime");
			if(suicide)
				key.kh_dropperteam = player.team;
		}
		sound(player, CHAN_AUTO, kh_sound_drop, VOL_BASE, ATTN_NORM);
	}
}

void kh_Key_Touch()  // runs many, many times when a key has been dropped and can be picked up
{
	if(intermission_running)
		return;

	if(self.owner) // already carried
		return;
	if(other.classname != "player")
		return;
	if(other.deadflag != DEAD_NO)
		return;
	if(other == self.enemy)
		if(time < self.kh_droptime + cvar("g_balance_keyhunt_delay_collect"))
			return;  // you just dropped it!
	kh_Key_Collect(self, other);
}

void kh_Key_Think()  // runs all the time
{
	entity head;
	//entity player;  // needed by FOR_EACH_PLAYER

	if(intermission_running)
		return;

#ifdef KH_KEY_ATTACHMENT_DEBUG
	if(self.kh_prev == self.owner)
	{
		if(cvar_string("_angles") != "")
		{
			self.angles = stov(cvar_string("_angles"));
			setorigin(self, stov(cvar_string("_origin")));
		}
	}
#endif

	if(self.owner)
	{
#ifndef KH_PLAYER_USE_ATTACHMENT
		makevectors('0 1 0' * (self.cnt + mod(time, 360) * KH_KEY_XYSPEED));
		setorigin(self, v_forward * KH_KEY_XYDIST + '0 0 1' * self.origin_z);
#endif

		if(self.owner.BUTTON_USE)
		if(time >= self.owner.kh_droptime + cvar("g_balance_keyhunt_delay_drop"))
		{
			self.owner.kh_droptime = time;
			self.kh_droptime = time;  // prevent collecting this one for some time
			self.enemy = self.owner;
			self.pusher = world;
			kh_Scores_Event(self.owner, self, "dropkey", 0, 0);
			bprint(self.owner.netname, "^7 dropped the ", self.netname, "\n");
			sound(self.owner, CHAN_AUTO, kh_sound_drop, VOL_BASE, ATTN_NORM);
			makevectors(self.owner.v_angle);
			self.velocity = W_CalculateProjectileVelocity(self.owner.velocity, cvar("g_balance_keyhunt_throwvelocity") * v_forward);
			kh_Key_AssignTo(self, world);
			self.pushltime = time + cvar("g_balance_keyhunt_protecttime");
			self.kh_dropperteam = self.team;
		}
	}

	// if in nodrop or time over, end the round
	if(!self.owner)
		if(time > self.pain_finished)
			kh_LoserTeam(self.team, self);

	if(self.owner)
	if(kh_Key_AllOwnedByWhichTeam() != -1)
	{
		if(self.siren_time < time)
		{
			sound(self.owner, CHAN_AUTO, kh_sound_alarm, VOL_BASE, ATTN_NORM);  // play a simple alarm
			self.siren_time = time + 2.5;  // repeat every 2.5 seconds
		}

		entity key;
		vector p;
		p = self.owner.origin;
		FOR_EACH_KH_KEY(key)
			if(vlen(key.owner.origin - p) > cvar("g_balance_keyhunt_maxdist"))
				goto not_winning;
		kh_WinnerTeam(self.team);
:not_winning
	}

	if(kh_interferemsg_time && time > kh_interferemsg_time)
	{
		kh_interferemsg_time = 0;
		FOR_EACH_PLAYER(head)
		{
			if(head.team == kh_interferemsg_team)
				if(head.kh_next)
					centerprint(head, "All keys are in your team's hands!\n\nMeet the other key carriers ^1NOW^7!");
				else
					centerprint(head, "All keys are in your team's hands!\n\nHelp the key carriers to meet!");
			else
				centerprint(head, strcat("All keys are in the ", ColoredTeamName(kh_interferemsg_team), "^7's hands!\n\nInterfere ^1NOW^7!"));
		}
	}

	self.nextthink = time + 0.05;
}

void kh_WinnerTeam(float teem)  // runs when a team wins
{
	// all key carriers get some points
	vector firstorigin, lastorigin, midpoint;
	float first;
	entity key;
	float score;
	score = (kh_teams - 1) * cvar("g_balance_keyhunt_score_capture");
	DistributeEvenly_Init(score, kh_teams);
	// twice the score for 3 team games, three times the score for 4 team games!
	// note: for a win by destroying the key, this should NOT be applied
	FOR_EACH_KH_KEY(key)
	{
		float f;
		f = DistributeEvenly_Get(1);
		kh_Scores_Event(key.owner, key, "capture", f, 0);
		PlayerTeamScore_Add(key.owner, SP_KH_CAPS, ST_KH_CAPS, 1);
	}

	first = TRUE;
	FOR_EACH_KH_KEY(key)
		if(key.owner.kh_next == key)
		{
			if(!first)
				bprint("^7, ");
			bprint(key.owner.netname);
			first = FALSE;
		}
	bprint("^7 captured the keys for the ", ColoredTeamName(teem), "\n");

	first = TRUE;
	midpoint = '0 0 0';
	FOR_EACH_KH_KEY(key)
	{
		vector thisorigin;

		thisorigin = kh_AttachedOrigin(key);
		//dprint("Key origin: ", vtos(thisorigin), "\n");
		midpoint += thisorigin;

		if(!first)
			te_lightning2(world, lastorigin, thisorigin);
		lastorigin = thisorigin;
		if(first)
			firstorigin = thisorigin;
		first = FALSE;
	}
	if(kh_teams > 2)
	{
		te_lightning2(world, lastorigin, firstorigin);
	}
	midpoint = midpoint * (1 / kh_teams);
	te_customflash(midpoint, 1000, 1, TeamColor(teem) * 0.5 + '0.5 0.5 0.5');  // make the color >=0.5 in each component

	play2all(kh_sound_capture);
	kh_FinishRound();
}

void kh_LoserTeam(float teem, entity lostkey)  // runs when a player pushes a flag carrier off the map
{
	entity player, key, attacker;
	float players;
	float keys;
	float f;

	attacker = world;
	if(lostkey.pusher)
		if(lostkey.pusher.team != teem)
			if(lostkey.pusher.classname == "player")
				attacker = lostkey.pusher;

	players = keys = 0;

	if(attacker)
	{
		if(lostkey.kh_previous_owner)
			kh_Scores_Event(lostkey.kh_previous_owner, world, "pushed", 0, -cvar("g_balance_keyhunt_score_push"));
			// don't actually GIVE him the -nn points, just log
		kh_Scores_Event(attacker, world, "push", cvar("g_balance_keyhunt_score_push"), 0);
		PlayerScore_Add(attacker, SP_KH_PUSHES, 1);
		centerprint(attacker, "Your push is the best!");
		bprint("The ", ColoredTeamName(teem), "^7 could not take care of the ", lostkey.netname, "^7 when ", attacker.netname, "^7 came\n");
	}
	else
	{
		float of, fragsleft, i, j, thisteam;
		of = cvar("g_balance_keyhunt_score_destroyed_ownfactor");

		FOR_EACH_PLAYER(player)
			if(player.team != teem)
				++players;

		FOR_EACH_KH_KEY(key)
			if(key.owner && key.team != teem)
				++keys;

		if(lostkey.kh_previous_owner)
			kh_Scores_Event(lostkey.kh_previous_owner, world, "destroyed", 0, -cvar("g_balance_keyhunt_score_destroyed"));
			// don't actually GIVE him the -nn points, just log

		if(lostkey.kh_previous_owner.playerid == lostkey.kh_previous_owner_playerid)
			PlayerScore_Add(lostkey.kh_previous_owner, SP_KH_DESTROYS, 1);

		DistributeEvenly_Init(cvar("g_balance_keyhunt_score_destroyed"), keys * of + players);

		FOR_EACH_KH_KEY(key)
			if(key.owner && key.team != teem)
			{
				f = DistributeEvenly_Get(of);
				kh_Scores_Event(key.owner, world, "destroyed_holdingkey", f, 0);
			}

		fragsleft = DistributeEvenly_Get(players);

		// Now distribute these among all other teams...
		j = kh_teams - 1;
		for(i = 0; i < kh_teams; ++i)
		{
			thisteam = kh_Team_ByID(i);
			if(thisteam == teem) // bad boy, no cookie - this WILL happen
				continue;

			players = 0;
			FOR_EACH_PLAYER(player)
				if(player.team == thisteam)
					++players;

			DistributeEvenly_Init(fragsleft, j);
			fragsleft = DistributeEvenly_Get(j - 1);
			DistributeEvenly_Init(DistributeEvenly_Get(1), players);

			FOR_EACH_PLAYER(player)
				if(player.team == thisteam)
				{
					f = DistributeEvenly_Get(1);
					kh_Scores_Event(player, world, "destroyed", f, 0);
				}

			--j;
		}

		bprint("The ", ColoredTeamName(teem), "^7 could not take care of the ", lostkey.netname, "\n");
	}
	play2all(kh_sound_destroy);
	te_tarexplosion(lostkey.origin);

	kh_FinishRound();
}

void kh_FinishRound()  // runs when a team captures the keys
{
	// prepare next round
	kh_interferemsg_time = 0;
	entity key;

	kh_no_radar_circles = TRUE;
	FOR_EACH_KH_KEY(key)
		kh_Key_Remove(key);
	kh_no_radar_circles = FALSE;

	kh_Controller_SetThink(cvar("g_balance_keyhunt_delay_round"), "Round starts in ", kh_StartRound);
}

string kh_CheckEnoughPlayers()  // checks enough player are present, runs after every completed round
{
	float i, players, teem;
	entity player;
	string result;
	result = "";

	// find a random player per team
	for(i = 0; i < kh_teams; ++i)
	{
		teem = kh_Team_ByID(i);
		players = 0;
		FOR_EACH_PLAYER(player)
			if(player.deadflag == DEAD_NO)
				if(!player.BUTTON_CHAT)
					if(player.team == teem)
						++players;
		if(players == 0)
		{
			if(result != "")
				result = strcat(result, ", ");
			result = strcat(result, ColoredTeamName(teem));
		}
	}
	return result;
}

void kh_WaitForPlayers()  // delay start of the round until enough players are present
{
	string teams_missing;

	if(time < game_starttime)
	{
		kh_Controller_SetThink(game_starttime - time + 0.1, "", kh_WaitForPlayers);
		return;
	}

	teams_missing = kh_CheckEnoughPlayers();
	if(teams_missing == "")
		kh_Controller_SetThink(cvar("g_balance_keyhunt_delay_round"), "Round starts in ", kh_StartRound);
	else
		kh_Controller_SetThink(1, strcat("Waiting for players to join...\n\nNeed active players for: ", teams_missing), kh_WaitForPlayers);
}

void kh_StartRound()  // runs at the start of each round
{
	string teams_missing;
	float i, players, teem;
	entity player;

	if(time < game_starttime)
	{
		kh_Controller_SetThink(game_starttime - time + 0.1, "", kh_WaitForPlayers);
		return;
	}

	teams_missing = kh_CheckEnoughPlayers();
	if(teams_missing != "")
	{
		kh_Controller_SetThink(1, strcat("Waiting for players to join...\n\nNeed active players for: ", teams_missing), kh_WaitForPlayers);
		return;
	}

	FOR_EACH_PLAYER(player)
		if(clienttype(player) == CLIENTTYPE_REAL)
			centerprint_expire(player, CENTERPRIO_SPAM);

	for(i = 0; i < kh_teams; ++i)
	{
		teem = kh_Team_ByID(i);
		players = 0;
		entity my_player;
		FOR_EACH_PLAYER(player)
			if(player.deadflag == DEAD_NO)
				if(!player.BUTTON_CHAT)
					if(player.team == teem)
					{
						++players;
						if(random() * players <= 1)
							my_player = player;
					}
		kh_Key_Spawn(my_player, 360 * i / kh_teams, i);
	}

	kh_tracking_enabled = FALSE;
	kh_Controller_SetThink(cvar("g_balance_keyhunt_delay_tracking"), "Scanning frequency range...", kh_EnableTrackingDevice);
}

void kh_EnableTrackingDevice()  // runs after each round
{
	entity player;

	FOR_EACH_PLAYER(player)
		if(clienttype(player) == CLIENTTYPE_REAL)
			centerprint_expire(player, CENTERPRIO_SPAM);

	kh_tracking_enabled = TRUE;
}

float kh_Key_waypointsprite_visible_for_player(entity e) // ??
{
	if(!kh_tracking_enabled)
		return FALSE;
	if(!self.owner)
		return TRUE;
	if(!self.owner.owner)
		return TRUE;
	return FALSE;  // draw only when key is not owned
}

float kh_KeyCarrier_waypointsprite_visible_for_player(entity e)  // runs all the time
{
	if(e.classname != "player" || self.team != e.team)
		if(!kh_tracking_enabled)
			return FALSE;

	return TRUE;
}

float kh_HandleFrags(entity attacker, entity targ, float f)  // adds to the player score
{
	if(attacker == targ)
		return f;

	if(targ.kh_next)
	{
		if(attacker.team == targ.team)
		{
			entity k;
			float nk;
			nk = 0;
			for(k = targ.kh_next; k != world; k = k.kh_next)
				++nk;
			kh_Scores_Event(attacker, targ.kh_next, "carrierfrag", -nk * cvar("g_balance_keyhunt_score_collect"), 0);
		}
		else
		{
			kh_Scores_Event(attacker, targ.kh_next, "carrierfrag", cvar("g_balance_keyhunt_score_carrierfrag")-1, 0);
			PlayerScore_Add(attacker, SP_KH_KCKILLS, 1);
			// the frag gets added later
		}
	}

	return f;
}

void kh_init()  // sets up th KH environment
{
	precache_sound(kh_sound_capture);
	precache_sound(kh_sound_destroy);
	precache_sound(kh_sound_drop);
	precache_sound(kh_sound_collect);
	precache_sound(kh_sound_alarm);  // the new siren

#ifdef KH_PLAYER_USE_CARRIEDMODEL
	precache_model("models/keyhunt/key-carried.md3");
#endif
	precache_model("models/keyhunt/key.md3");

	// setup variables
	kh_teams = cvar("g_keyhunt_teams_override");
	if(kh_teams < 2)
		kh_teams = cvar("g_keyhunt_teams");
	kh_teams = bound(2, kh_teams, 4);

	// make a KH entity for controlling the game
	kh_controller = spawn();
	kh_controller.think = kh_Controller_Think;
	kh_Controller_SetThink(0, "", kh_WaitForPlayers);

	setmodel(kh_controller, "models/keyhunt/key.md3");
	kh_key_dropped = kh_controller.modelindex;
	/*
	dprint(vtos(kh_controller.mins));
	dprint(vtos(kh_controller.maxs));
	dprint("\n");
	*/
#ifdef KH_PLAYER_USE_CARRIEDMODEL
	setmodel(kh_controller, "models/keyhunt/key-carried.md3");
	kh_key_carried = kh_controller.modelindex;
#else
	kh_key_carried = kh_key_dropped;
#endif

	kh_controller.model = "";
	kh_controller.modelindex = 0;

	addstat(STAT_KH_KEYS, AS_INT, kh_state);

	ScoreRules_kh(kh_teams);
}

void kh_finalize()
{
	// to be called before intermission
	kh_FinishRound();
	remove(kh_controller);
	kh_controller = world;
}

void kh_update_state()
{
	entity player;
	entity key;
	float s;
	float f;

	s = 0;
	FOR_EACH_KH_KEY(key)
	{
		if(key.owner)
			f = key.team;
		else
			f = 30;
		s |= pow(32, key.count) * f;
	}

	FOR_EACH_CLIENT(player)
	{
		player.kh_state = s;
	}

	FOR_EACH_KH_KEY(key)
	{
		if(key.owner)
			key.owner.kh_state |= pow(32, key.count) * 31;
	}
	//print(ftos((nextent(world)).kh_state), "\n");
}
