string STR_ITEM_KH_KEY = "item_kh_key";
#define FOR_EACH_KH_KEY(v) for(v = world; (v = find(v, classname, STR_ITEM_KH_KEY)); )

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
float KH_KEY_BRIGHTNESS = 4;

typedef void(void) kh_Think_t;
var kh_Think_t kh_Controller_Thinkfunc;
string kh_Controller_Waitmsg;

float kh_Team_ByID(float t)
{
	if(t == 0) return COLOR_TEAM1;
	if(t == 1) return COLOR_TEAM2;
	if(t == 2) return COLOR_TEAM3;
	if(t == 3) return COLOR_TEAM4;
	return 0;
}

entity kh_controller;
float kh_tracking_enabled;
float kh_teams;
float kh_interferemsg_time, kh_interferemsg_team;
.entity kh_next, kh_prev; // linked list
.float kh_droptime;
.float kh_dropperteam;
.entity kh_previous_owner;

string kh_sound_capture = "sound/kh/capture.wav";
string kh_sound_destroy = "sound/kh/destroy.wav";
string kh_sound_drop = "sound/kh/drop.wav";
string kh_sound_collect = "sound/kh/collect.wav";

float kh_sprite_dropped, kh_sprite_finish, kh_sprite_red, kh_sprite_blue, kh_sprite_pink, kh_sprite_yellow, kh_sprite_friend;
float kh_key_dropped, kh_key_carried;

float kh_GetCarrierSprite(float t, float e)
{
	if(t == e)           return kh_sprite_friend;
	if(t == COLOR_TEAM1) return kh_sprite_red;
	if(t == COLOR_TEAM2) return kh_sprite_blue;
	if(t == COLOR_TEAM3) return kh_sprite_yellow;
	if(t == COLOR_TEAM4) return kh_sprite_pink;
	return 0;
}

void kh_Controller_SetThink(float t, string msg, kh_Think_t func)
{
	kh_Controller_Thinkfunc = func;
	kh_controller.cnt = t;
	if(kh_Controller_Waitmsg != "")
		strunzone(kh_Controller_Waitmsg);
	if(msg == "")
		kh_Controller_Waitmsg = "";
	else
		kh_Controller_Waitmsg = strzone(msg);
	if(t == 0)
		kh_controller.nextthink = time; // force
}

void kh_Controller_Think()
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
void kh_Scores_Event(entity player, entity key, string what, float frags_player, float frags_owner)
{
	string s;
	if(intermission_running)
		return;
	if(frags_player)
		player.frags = player.frags + floor(0.5 + frags_player);
	if(key && key.owner && frags_owner)
		key.owner.frags = key.owner.frags + floor(0.5 + frags_owner);
	if(!cvar("sv_eventlog"))
		return;
	s = strcat(":keyhunt:", what, ":", ftos(player.playerid));
	s = strcat(s, ":", ftos(frags_player));
	if(key && key.owner)
		s = strcat(s, ":", ftos(key.owner.playerid));
	else
		s = strcat(s, ":0");
	s = strcat(s, ":", ftos(frags_owner), ":");
	if(key)
		s = strcat(s, key.netname);
	GameLogEcho(s, FALSE);
}

vector kh_AttachedOrigin(entity e)
{
	if(e.tag_entity)
	{
		makevectors(e.tag_entity.angles);
		return e.tag_entity.origin + e.origin_x * v_forward - e.origin_y * v_right + e.origin_z * v_up;
	}
	else
		return e.origin;
}

void kh_Key_Attach(entity key)
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
	setorigin(key, '0 0 1' * KH_KEY_ZSHIFT); // fixing x, y in think
	key.angles_y -= key.owner.angles_y;
#endif
	key.flags = 0;
	key.solid = SOLID_NOT;
	key.movetype = MOVETYPE_NONE;
	key.team = key.owner.team;
	key.nextthink = time;
	key.damageforcescale = 0;
	key.modelindex = kh_key_carried;
}

void kh_Key_Detach(entity key)
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
	key.aiment = world;
	key.flags = FL_ITEM;
	key.solid = SOLID_TRIGGER;
	key.movetype = MOVETYPE_TOSS;
	key.pain_finished = time + cvar("g_balance_keyhunt_delay_return");
	key.damageforcescale = cvar("g_balance_keyhunt_damageforcescale");
	// let key.team stay
	key.modelindex = kh_key_dropped;
	key.kh_previous_owner = key.owner;
}

void kh_Key_AssignTo(entity key, entity player)
{
	if(key.owner == player)
		return;

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

		kh_Key_Attach(key);

		if(key.kh_next == world)
		{
			// player is now a key carrier
			WaypointSprite_AttachCarrier("", player);
			player.waypointsprite_attachedforcarrier.waypointsprite_for_player = kh_KeyCarrier_waypointsprite_for_player;
			player.waypointsprite_attachedforcarrier.team = player.team;
		}
	}

	key.pusher = world;
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

vector kh_TeamColor(float teem)
{
	switch(teem)
	{
		case COLOR_TEAM1:
			//return '103 0 0' / 255.0;
			return '0.4039 0.0000 0.0000';
		case COLOR_TEAM2:
			//return '35 35 191' / 255.0;
			return '0.1373 0.1373 0.7490';
		case COLOR_TEAM3:
			//return '187 167 15' / 255.0;
			return '0.7333 0.6549 0.0588';
		case COLOR_TEAM4:
			//return '139 79 107' / 255.0;
			return '0.5451 0.3099 0.4196';
		default:
			return '1 1 1';
	}
}

void kh_Key_Spawn(entity initial_owner, float angle)
{
	entity key;
	key = spawn();
	key.classname = STR_ITEM_KH_KEY;
	key.touch = kh_Key_Touch;
	key.think = kh_Key_Think;
	key.nextthink = time;
	key.items = IT_KEY1 | IT_KEY2;
	key.cnt = angle;
	key.angles = '0 360 0' * random();
	key.event_damage = kh_Key_Damage;
	key.modelindex = kh_key_dropped;
	key.model = "key";
	key.kh_dropperteam = 0;
	key.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_PLAYERCLIP;
	setsize(key, KH_KEY_MIN, KH_KEY_MAX);
	key.colormod = kh_TeamColor(initial_owner.team) * KH_KEY_BRIGHTNESS;

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

	sprint(initial_owner, strcat("You got the ^2", key.netname, "\n"));

	WaypointSprite_Spawn("", 0, 0, key, '0 0 1' * KH_KEY_WP_ZSHIFT, world, key.team, key, waypointsprite_attachedforcarrier, FALSE);
	key.waypointsprite_attachedforcarrier.waypointsprite_for_player = kh_Key_waypointsprite_for_player;

	kh_Key_AssignTo(key, initial_owner);
}

void kh_Key_Remove(entity key)
{
	entity o;
	o = key.owner;
	kh_Key_AssignTo(key, world);
	if(o) // it was attached
		WaypointSprite_Kill(key.waypointsprite_attachedforcarrier);
	else // it was dropped
		WaypointSprite_DetachCarrier(key);

	remove(key);
}

// -1 when no team completely owns all keys yet
float kh_Key_AllOwnedByWhichTeam()
{
	entity key;
	float teem;

	teem = -1;
	FOR_EACH_KH_KEY(key)
	{
		if(!key.owner)
			return -1;
		if(teem == -1)
			teem = key.team;
		else if(teem != key.team)
			return -1;
	}
	return teem;
}

void kh_Key_Collect(entity key, entity player)
{
	sound(player, CHAN_AUTO, kh_sound_collect, 1, ATTN_NORM);

	if(key.kh_dropperteam != player.team)
		kh_Scores_Event(player, key, "collect", cvar("g_balance_keyhunt_score_collect"), 0);
	key.kh_dropperteam = 0;
	bprint(player.netname, "^7 collected the ", key.netname, "\n");
	kh_Key_AssignTo(key, player);

	if(kh_Key_AllOwnedByWhichTeam() != -1)
	{
		kh_interferemsg_time = time + 0.2;
		kh_interferemsg_team = player.team;
	}
}

void kh_Key_DropAll(entity player, float suicide)
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
			bprint(player.netname, "^7 lost the ", key.netname, "\n");
			kh_Key_AssignTo(key, world);
			makevectors('-1 0 0' * (45 + 45 * random()) + '0 360 0' * random());
			key.velocity = W_CalculateProjectileVelocity(player.velocity, cvar("g_balance_keyhunt_dropvelocity") * v_forward);
			key.pusher = mypusher;
			key.pushltime = time + cvar("g_balance_keyhunt_protecttime");
			if(suicide)
				key.kh_dropperteam = player.team;
		}
		sound(player, CHAN_AUTO, kh_sound_drop, 1, ATTN_NORM);
	}
}

void kh_Key_Touch()
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
			return; // you just dropped it!
	kh_Key_Collect(self, other);
}

void kh_Key_Think()
{
	entity head;

	if(intermission_running)
		return;

#ifdef KH_KEY_ATTACHMENT_DEBUG
	if(self.kh_prev == self.owner)
	{
		if(cvar_string("_angles") != "")
		{
			self.angles = stov(cvar_string("_angles"));
			self.origin = stov(cvar_string("_origin"));
		}
	}
#endif

	if(self.owner)
	{
#ifndef KH_PLAYER_USE_ATTACHMENT
		makevectors('0 1 0' * (self.cnt + math_mod(time, 360) * KH_KEY_XYSPEED));
		setorigin(self, v_forward * KH_KEY_XYDIST + '0 0 1' * self.origin_z);
#endif

		if(self.owner.buttonuse)
		if(time >= self.owner.kh_droptime + cvar("g_balance_keyhunt_delay_drop"))
		{
			self.owner.kh_droptime = time;
			self.kh_droptime = time; // prevent collecting this one for some time
			self.enemy = self.owner;
			self.pusher = world;
			kh_Scores_Event(self.owner, self, "dropkey", 0, 0);
			bprint(self.owner.netname, "^7 dropped the ", self.netname, "\n");
			sound(self.owner, CHAN_AUTO, kh_sound_drop, 1, ATTN_NORM);
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
					centerprint(head, "All keys are in your team's hands!\n\nMeet the other key carriers ^1NOW^7!\n");
				else
					centerprint(head, "All keys are in your team's hands!\n\nHelp the key carriers to meet!\n");
			else
				centerprint(head, strcat("All keys are in the ", ColoredTeamName(kh_interferemsg_team), "^7's hands!\n\nInterfere ^1NOW^7!\n"));
		}
	}

	self.nextthink = time + 0.05;
}

void kh_WinnerTeam(float teem)
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
		kh_Scores_Event(key.owner, key, "capture", DistributeEvenly_Get(1), 0);

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
	te_customflash(midpoint, 1000, 1, kh_TeamColor(teem) * 0.5 + '0.5 0.5 0.5'); // make the color >=0.5 in each component

	sound(world, CHAN_AUTO, kh_sound_capture, 1, ATTN_NONE);
	kh_FinishRound();
}

void kh_LoserTeam(float teem, entity lostkey)
{
	entity player, key, attacker;
	float players;
	float keys;

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
		centerprint(attacker, "Your push is the best!\n\n\n");
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

		DistributeEvenly_Init(cvar("g_balance_keyhunt_score_destroyed"), keys * of + players);

		FOR_EACH_KH_KEY(key)
			if(key.owner && key.team != teem)
				kh_Scores_Event(key.owner, world, "destroyed_holdingkey", DistributeEvenly_Get(of), 0);

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
					kh_Scores_Event(player, world, "destroyed", DistributeEvenly_Get(1), 0);

			--j;
		}

		bprint("The ", ColoredTeamName(teem), "^7 could not take care of the ", lostkey.netname, "\n");
	}
	sound(world, CHAN_AUTO, kh_sound_destroy, 1, ATTN_NONE);
	te_tarexplosion(lostkey.origin);

	kh_FinishRound();
}

void kh_FinishRound()
{
	// prepare next round
	kh_interferemsg_time = 0;
	entity key;
	FOR_EACH_KH_KEY(key)
		kh_Key_Remove(key);

	kh_Controller_SetThink(cvar("g_balance_keyhunt_delay_round"), "Round starts in ", kh_StartRound);
}

string kh_CheckEnoughPlayers()
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
				if(!player.buttonchat)
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

void kh_WaitForPlayers()
{
	string teams_missing;
	teams_missing = kh_CheckEnoughPlayers();
	if(teams_missing == "")
		kh_Controller_SetThink(cvar("g_balance_keyhunt_delay_round"), "Round starts in ", kh_StartRound);
	else
		kh_Controller_SetThink(1, strcat("Waiting for players to join...\n\nNeed active players for: ", teams_missing), kh_WaitForPlayers);
}

void kh_StartRound()
{
	string teams_missing;
	float i, players, teem;
	entity player;

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
				if(!player.buttonchat)
					if(player.team == teem)
					{
						++players;
						if(random() * players <= 1)
							my_player = player;
					}
		kh_Key_Spawn(my_player, 360 * i / kh_teams);
		//kh_Key_Spawn(my_player, 360 * i / kh_teams);
		//kh_Key_Spawn(my_player, 360 * i / kh_teams);
	}

	kh_tracking_enabled = FALSE;
	kh_Controller_SetThink(cvar("g_balance_keyhunt_delay_tracking"), "Scanning frequency range...", kh_EnableTrackingDevice);
}

void kh_setstatus()
{
	if(kh_teams)
	{
		float kh_KEY;
		kh_KEY = (IT_RED_FLAG_TAKEN | IT_RED_FLAG_LOST | IT_BLUE_FLAG_TAKEN | IT_BLUE_FLAG_LOST); // the one impossible combination
		if(self.kh_next)
			self.items = self.items | kh_KEY;
		else
			self.items = self.items - (self.items & kh_KEY);
	}
}

void kh_EnableTrackingDevice()
{
	entity player;

	FOR_EACH_PLAYER(player)
		if(clienttype(player) == CLIENTTYPE_REAL)
			centerprint_expire(player, CENTERPRIO_SPAM);

	kh_tracking_enabled = TRUE;
}

float kh_Key_waypointsprite_for_player(entity e)
{
	if(!kh_tracking_enabled)
		return 0;
	if(!self.owner)
		return kh_sprite_dropped;
	if(!self.owner.owner)
		return kh_sprite_dropped;
	return 0; // draw only when key is not owned
}

float kh_KeyCarrier_waypointsprite_for_player(entity e)
{
	if(e.classname != "player" || self.team != e.team)
		if(!kh_tracking_enabled)
			return 0;

	// e is spectator? That's no team mate...
	if(e.classname != "player")
		return kh_GetCarrierSprite(self.team, -1);
	
	// e is no key carrier: simple case...
	if(!e.kh_next)
		return kh_GetCarrierSprite(self.team, e.team);
	
	// e is a key carrier: if any key is dropped or owned by another team, show
	// the carrier sprite; otherwise show run here
	if(kh_Key_AllOwnedByWhichTeam() == e.team)
		return kh_sprite_finish;

	return kh_GetCarrierSprite(self.team, e.team);
}

float kh_HandleFrags(entity attacker, entity targ, float f)
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
		}
	}

	return f;
}

void kh_init()
{
	precache_sound(kh_sound_capture);
	precache_sound(kh_sound_destroy);
	precache_sound(kh_sound_drop);
	precache_sound(kh_sound_collect);

	precache_model("models/sprites/key-dropped.sp2");
	precache_model("models/sprites/keycarrier-finish.sp2");
	precache_model("models/sprites/keycarrier-friend.sp2");
	precache_model("models/sprites/keycarrier-red.sp2");
	precache_model("models/sprites/keycarrier-blue.sp2");
	precache_model("models/sprites/keycarrier-yellow.sp2");
	precache_model("models/sprites/keycarrier-pink.sp2");
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
	setmodel(kh_controller, "models/sprites/key-dropped.sp2");
	kh_sprite_dropped = kh_controller.modelindex;
	setmodel(kh_controller, "models/sprites/keycarrier-finish.sp2");
	kh_sprite_finish = kh_controller.modelindex;
	setmodel(kh_controller, "models/sprites/keycarrier-friend.sp2");
	kh_sprite_friend = kh_controller.modelindex;
	setmodel(kh_controller, "models/sprites/keycarrier-red.sp2");
	kh_sprite_red = kh_controller.modelindex;
	setmodel(kh_controller, "models/sprites/keycarrier-blue.sp2");
	kh_sprite_blue = kh_controller.modelindex;
	setmodel(kh_controller, "models/sprites/keycarrier-pink.sp2");
	kh_sprite_pink = kh_controller.modelindex;
	setmodel(kh_controller, "models/sprites/keycarrier-yellow.sp2");
	kh_sprite_yellow = kh_controller.modelindex;
	setmodel(kh_controller, "");
}

void kh_finalize()
{
	// to be called before intermission
	kh_FinishRound();
	remove(kh_controller);
	kh_controller = world;
}
