#include "bot.qh"
#include "aim.qh"
#include "navigation.qh"
#include "waypoints.qh"

#include "aim.qc"
#include "navigation.qc"
#include "waypoints.qc"
#include "scripting.qc"

#include "havocbot/havocbot.qc"

entity bot_spawn()
{
	local entity oldself, bot;
	bot = spawnclient();
	if (bot)
	{
		currentbots = currentbots + 1;
		oldself = self;
		self = bot;
		bot_setnameandstuff();
		ClientConnect();
		PutClientInServer();
		self = oldself;
	}
	return bot;
};

void bot_think()
{
	if (self.bot_nextthink > time)
		return;

	self.flags &~= FL_GODMODE;
	if(cvar("bot_god"))
		self.flags |= FL_GODMODE;

	self.bot_nextthink = self.bot_nextthink + cvar("bot_ai_thinkinterval") * pow(0.5, self.bot_aiskill);
	//if (self.bot_painintensity > 0)
	//	self.bot_painintensity = self.bot_painintensity - (skill + 1) * 40 * frametime;

	//self.bot_painintensity = self.bot_painintensity + self.bot_oldhealth - self.health;
	//self.bot_painintensity = bound(0, self.bot_painintensity, 100);

	if(time < game_starttime || ((cvar("g_campaign") && !campaign_bots_may_start)))
	{
		self.nextthink = time + 0.5;
		return;
	}

	if (self.fixangle)
	{
		self.v_angle = self.angles;
		self.v_angle_z = 0;
		self.fixangle = FALSE;
	}

	self.dmg_take = 0;
	self.dmg_save = 0;
	self.dmg_inflictor = world;

	// calculate an aiming latency based on the skill setting
	// (simulated network latency + naturally delayed reflexes)
	//self.ping = 0.7 - bound(0, 0.05 * skill, 0.5); // moved the reflexes to bot_aimdir (under the name 'think')
	// minimum ping 20+10 random
	self.ping = bound(0,0.07 - bound(0, (skill + self.bot_pingskill) * 0.005,0.05)+random()*0.01,0.65); // Now holds real lag to server, and higer skill players take a less laggy server
	// skill 10 = ping 0.2 (adrenaline)
	// skill 0 = ping 0.7 (slightly drunk)

	// clear buttons
	self.BUTTON_ATCK = 0;
	self.button1 = 0;
	self.BUTTON_JUMP = 0;
	self.BUTTON_ATCK2 = 0;
	self.BUTTON_ZOOM = 0;
	self.BUTTON_CROUCH = 0;
	self.BUTTON_HOOK = 0;
	self.BUTTON_INFO = 0;
	self.button8 = 0;
	self.BUTTON_CHAT = 0;
	self.BUTTON_USE = 0;

	// if dead, just wait until we can respawn
	if (self.deadflag)
	{
		if (self.deadflag == DEAD_DEAD)
		{
			self.BUTTON_JUMP = 1; // press jump to respawn
			self.bot_strategytime = 0;
		}
	}

	// now call the current bot AI (havocbot for example)
	self.bot_ai();
};

void bot_setnameandstuff()
{
	string readfile, s;
	float file, tokens, prio;
	entity p;

	string bot_name, bot_model, bot_skin, bot_shirt, bot_pants;
	string name, prefix, suffix;

 	if(cvar("g_campaign"))
	{
		prefix = "";
		suffix = "";
	}
	else
	{
		prefix = cvar_string("bot_prefix");
		suffix = cvar_string("bot_suffix");
	}

	file = fopen(cvar_string("bot_config_file"), FILE_READ);

	if(file < 0)
		print(strcat("Error: Can not open the bot configuration file '",cvar_string("bot_config_file"),"'\n"));
	else
	{
		RandomSelection_Init();
		for(;;)
		{
			readfile = fgets(file);
			if(!readfile)
				break;
			if(substring(readfile, 0, 2) == "//")
				continue;
			if(substring(readfile, 0, 1) == "#")
				continue;
			tokens = tokenizebyseparator(readfile, "\t");
			s = argv(0);
			prio = 1;
			FOR_EACH_CLIENT(p)
			{
				if(strcat(prefix, s, suffix) == p.netname)
				{
					prio = 0;
					break;
				}
			}
			RandomSelection_Add(world, 0, readfile, 1, prio);
		}
		readfile = RandomSelection_chosen_string;
		fclose(file);
	}

	tokens = tokenizebyseparator(readfile, "\t");
	if(argv(0) != "") bot_name = argv(0);
	else bot_name = "Bot";

	if(argv(1) != "") bot_model = argv(1);
	else bot_model = "marine";

	if(argv(2) != "") bot_skin = argv(2);
	else bot_skin = "0";

	if(argv(3) != "" && stof(argv(3)) >= 0) bot_shirt = argv(3);
	else bot_shirt = ftos(floor(random() * 15));

	if(argv(4) != "" && stof(argv(4)) >= 0) bot_pants = argv(4);
	else bot_pants = ftos(floor(random() * 15));

	self.bot_forced_team = stof(argv(5));

	prio = 6;

	#define READSKILL(f,w,r) if(argv(prio) != "") self.f = stof(argv(prio)) * (w); else self.f = (!cvar("g_campaign")) * (2 * random() - 1) * (r) * (w); ++prio
	//print(bot_name, ": ping=", argv(9), "\n");

	READSKILL(havocbot_keyboardskill, 0.5, 0.5); // keyboard skill
	READSKILL(bot_moveskill, 2, 0); // move skill
	READSKILL(bot_dodgeskill, 2, 0); // dodge skill

	READSKILL(bot_pingskill, 0.5, 0); // ping skill

	READSKILL(bot_weaponskill, 2, 0); // weapon skill
	READSKILL(bot_aggresskill, 1, 0); // aggre skill
	READSKILL(bot_rangepreference, 1, 0); // read skill

	READSKILL(bot_aimskill, 2, 0); // aim skill
	READSKILL(bot_offsetskill, 2, 0.5); // offset skill
	READSKILL(bot_mouseskill, 1, 0.5); // mouse skill

	READSKILL(bot_thinkskill, 1, 0.5); // think skill
	READSKILL(bot_aiskill, 2, 0); // "ai" skill

	self.bot_config_loaded = TRUE;

	// this is really only a default, JoinBestTeam is called later
	setcolor(self, stof(bot_shirt) * 16 + stof(bot_pants));
	self.bot_preferredcolors = self.clientcolors;

	// pick the name
	if (cvar("bot_usemodelnames"))
		name = bot_model;
	else
		name = bot_name;

	// pick the model and skin
	if(substring(bot_model, -4, 1) != ".")
		bot_model = strcat(bot_model, ".zym");
	self.playermodel = self.playermodel_freeme = strzone(strcat("models/player/", bot_model));
	self.playerskin = self.playerskin_freeme = strzone(bot_skin);

	self.netname = self.netname_freeme = strzone(strcat(prefix, name, suffix));

	self.cvar_cl_accuracy_data_share = 1;  // share the bots weapon accuracy data with the world
	self.cvar_cl_accuracy_data_receive = 0;  // don't receive any weapon accuracy data
};

void bot_custom_weapon_priority_setup()
{
	local float tokens, i, c, w;

	bot_custom_weapon = FALSE;

	if(	cvar_string("bot_ai_custom_weapon_priority_far") == "" ||
		cvar_string("bot_ai_custom_weapon_priority_mid") == "" ||
		cvar_string("bot_ai_custom_weapon_priority_close") == "" ||
 		cvar_string("bot_ai_custom_weapon_priority_distances") == ""
	)
		return;

	// Parse distances
	tokens = tokenizebyseparator(cvar_string("bot_ai_custom_weapon_priority_distances")," ");

	if (tokens!=2)
		return;

	bot_distance_far = stof(argv(0));
	bot_distance_close = stof(argv(1));

	if(bot_distance_far < bot_distance_close){
		bot_distance_far = stof(argv(1));
		bot_distance_close = stof(argv(0));
	}

	// Initialize list of weapons
	bot_weapons_far[0] = -1;
	bot_weapons_mid[0] = -1;
	bot_weapons_close[0] = -1;

	// Parse far distance weapon priorities
	tokens = tokenizebyseparator(W_NumberWeaponOrder(cvar_string("bot_ai_custom_weapon_priority_far"))," ");

	c = 0;
	for(i=0; i < tokens && c < WEP_COUNT; ++i){
		w = stof(argv(i));
		if ( w >= WEP_FIRST && w <= WEP_LAST) {
			bot_weapons_far[c] = w;
			++c;
		}
	}
	if(c < WEP_COUNT)
		bot_weapons_far[c] = -1;

	// Parse mid distance weapon priorities
	tokens = tokenizebyseparator(W_NumberWeaponOrder(cvar_string("bot_ai_custom_weapon_priority_mid"))," ");

	c = 0;
	for(i=0; i < tokens && c < WEP_COUNT; ++i){
		w = stof(argv(i));
		if ( w >= WEP_FIRST && w <= WEP_LAST) {
			bot_weapons_mid[c] = w;
			++c;
		}
	}
	if(c < WEP_COUNT)
		bot_weapons_mid[c] = -1;

	// Parse close distance weapon priorities
	tokens = tokenizebyseparator(W_NumberWeaponOrder(cvar_string("bot_ai_custom_weapon_priority_close"))," ");

	c = 0;
	for(i=0; i < tokens && i < WEP_COUNT; ++i){
		w = stof(argv(i));
		if ( w >= WEP_FIRST && w <= WEP_LAST) {
			bot_weapons_close[c] = w;
			++c;
		}
	}
	if(c < WEP_COUNT)
		bot_weapons_close[c] = -1;

	bot_custom_weapon = TRUE;
};

void bot_endgame()
{
	local entity e;
	//dprint("bot_endgame\n");
	e = bot_list;
	while (e)
	{
		setcolor(e, e.bot_preferredcolors);
		e = e.nextbot;
	}
	// if dynamic waypoints are ever implemented, save them here
};

void bot_relinkplayerlist()
{
	local entity e;
	local entity prevbot;
	player_count = 0;
	currentbots = 0;
	player_list = e = findchainflags(flags, FL_CLIENT);
	bot_list = world;
	prevbot = world;
	while (e)
	{
		player_count = player_count + 1;
		e.nextplayer = e.chain;
		if (clienttype(e) == CLIENTTYPE_BOT)
		{
			if (prevbot)
				prevbot.nextbot = e;
			else
			{
				bot_list = e;
				bot_list.nextbot = world;
			}
			prevbot = e;
			currentbots = currentbots + 1;
		}
		e = e.chain;
	}
	dprint(strcat("relink: ", ftos(currentbots), " bots seen.\n"));
	bot_strategytoken = bot_list;
	bot_strategytoken_taken = TRUE;
};

void bot_clientdisconnect()
{
	if (clienttype(self) != CLIENTTYPE_BOT)
		return;
	if(self.netname_freeme)
		strunzone(self.netname_freeme);
	if(self.playermodel_freeme)
		strunzone(self.playermodel_freeme);
	if(self.playerskin_freeme)
		strunzone(self.playerskin_freeme);
	self.netname_freeme = string_null;
	self.playermodel_freeme = string_null;
	self.playerskin_freeme = string_null;
	remove(self.bot_cmd_current);
}

void bot_clientconnect()
{
	if (clienttype(self) != CLIENTTYPE_BOT)
		return;
	self.bot_preferredcolors = self.clientcolors;
	self.bot_nextthink = time - random();
	self.lag_func = bot_lagfunc;
	self.isbot = TRUE;
	self.createdtime = self.nextthink;

	if(!self.bot_config_loaded) // This is needed so team overrider doesn't break between matches
		bot_setnameandstuff();

	if(self.bot_forced_team==1)
		self.team = COLOR_TEAM1;
	else if(self.bot_forced_team==2)
		self.team = COLOR_TEAM2;
	else if(self.bot_forced_team==3)
		self.team = COLOR_TEAM3;
	else if(self.bot_forced_team==4)
		self.team = COLOR_TEAM4;
	else
		JoinBestTeam(self, FALSE, TRUE);

	havocbot_setupbot();
};

void bot_removefromlargestteam()
{
	local float besttime, bestcount, thiscount;
	local entity best, head;
	CheckAllowedTeams(world);
	GetTeamCounts(world);
	head = findchainfloat(isbot, TRUE);
	if (!head)
		return;
	best = head;
	besttime = head.createdtime;
	bestcount = 0;
	while (head)
	{
		if(head.team == COLOR_TEAM1)
			thiscount = c1;
		else if(head.team == COLOR_TEAM2)
			thiscount = c2;
		else if(head.team == COLOR_TEAM3)
			thiscount = c3;
		else if(head.team == COLOR_TEAM4)
			thiscount = c4;
		else
			thiscount = 0;
		if (thiscount > bestcount)
		{
			bestcount = thiscount;
			besttime = head.createdtime;
			best = head;
		}
		else if (thiscount == bestcount && besttime < head.createdtime)
		{
			besttime = head.createdtime;
			best = head;
		}
		head = head.chain;
	}
	currentbots = currentbots - 1;
	dropclient(best);
};

void bot_removenewest()
{
	local float besttime;
	local entity best, head;

	if(teams_matter)
	{
		bot_removefromlargestteam();
		return;
	}

	head = findchainfloat(isbot, TRUE);
	if (!head)
		return;
	best = head;
	besttime = head.createdtime;
	while (head)
	{
		if (besttime < head.createdtime)
		{
			besttime = head.createdtime;
			best = head;
		}
		head = head.chain;
	}
	currentbots = currentbots - 1;
	dropclient(best);
};

void autoskill(float factor)
{
	float bestbot;
	float bestplayer;
	entity head;

	bestbot = -1;
	bestplayer = -1;
	FOR_EACH_PLAYER(head)
	{
		if(clienttype(head) == CLIENTTYPE_REAL)
			bestplayer = max(bestplayer, head.totalfrags - head.totalfrags_lastcheck);
		else
			bestbot = max(bestbot, head.totalfrags - head.totalfrags_lastcheck);
	}

	dprint("autoskill: best player got ", ftos(bestplayer), ", ");
	dprint("best bot got ", ftos(bestbot), "; ");
	if(bestbot < 0 || bestplayer < 0)
	{
		dprint("not doing anything\n");
		// don't return, let it reset all counters below
	}
	else if(bestbot <= bestplayer * factor - 2)
	{
		if(cvar("skill") < 17)
		{
			dprint("2 frags difference, increasing skill\n");
			cvar_set("skill", ftos(cvar("skill") + 1));
			bprint("^2SKILL UP!^7 Now at level ", ftos(cvar("skill")), "\n");
		}
	}
	else if(bestbot >= bestplayer * factor + 2)
	{
		if(cvar("skill") > 0)
		{
			dprint("2 frags difference, decreasing skill\n");
			cvar_set("skill", ftos(cvar("skill") - 1));
			bprint("^1SKILL DOWN!^7 Now at level ", ftos(cvar("skill")), "\n");
		}
	}
	else
	{
		dprint("not doing anything\n");
		return;
		// don't reset counters, wait for them to accumulate
	}

	FOR_EACH_PLAYER(head)
		head.totalfrags_lastcheck = head.totalfrags;
}

void bot_serverframe()
{
	float realplayers, bots, activerealplayers;
	entity head;

	if (intermission_running)
		return;

	if (time < 2)
		return;

	stepheightvec = cvar("sv_stepheight") * '0 0 1';
	bot_navigation_movemode = ((cvar("bot_navigation_ignoreplayers")) ? MOVE_NOMONSTERS : MOVE_NORMAL);

	if(time > autoskill_nextthink)
	{
		float a;
		a = cvar("skill_auto");
		if(a)
			autoskill(a);
		autoskill_nextthink = time + 5;
	}

	activerealplayers = 0;
	realplayers = 0;

	FOR_EACH_REALCLIENT(head)
	{
		if(head.classname == "player" || g_lms || g_arena)
			++activerealplayers;
		++realplayers;
	}

	// add/remove bots if needed to make sure there are at least
	// minplayers+bot_number, or remove all bots if no one is playing
	// But don't remove bots immediately on level change, as the real players
	// usually haven't rejoined yet
	bots_would_leave = FALSE;
	if ((realplayers || cvar("bot_join_empty") || (currentbots > 0 && time < 5)))
	{
		float realminplayers, minplayers;
		realminplayers = cvar("minplayers");
		minplayers = max(0, floor(realminplayers));

		float realminbots, minbots;
		if(teamplay && cvar("bot_vs_human"))
			realminbots = ceil(fabs(cvar("bot_vs_human")) * activerealplayers);
		else
			realminbots = cvar("bot_number");
		minbots = max(0, floor(realminbots));

		bots = min(max(minbots, minplayers - activerealplayers), maxclients - realplayers);
		if(bots > minbots)
			bots_would_leave = TRUE;
	}
	else
	{
		// if there are no players, remove bots
		bots = 0;
	}

	bot_ignore_bots = cvar("bot_ignore_bots");

	// only add one bot per frame to avoid utter chaos
	if(time > botframe_nextthink)
	{
		//dprint(ftos(bots), " ? ", ftos(currentbots), "\n");
		while (currentbots < bots)
		{
			if (bot_spawn() == world)
			{
				bprint("Can not add bot, server full.\n");
				botframe_nextthink = time + 10;
				break;
			}
		}
		while (currentbots > bots)
			bot_removenewest();
	}

	if(botframe_spawnedwaypoints)
	{
		if(cvar("waypoint_benchmark"))
			localcmd("quit\n");
	}

	if (currentbots > 0 || cvar("g_waypointeditor"))
	if (botframe_spawnedwaypoints)
	{
		if(botframe_cachedwaypointlinks)
		{
			if(!botframe_loadedforcedlinks)
				waypoint_load_links_hardwired();
		}
		else
		{
			// TODO: Make this check cleaner
			local entity wp = findchain(classname, "waypoint");
			if(time - wp.nextthink > 10)
				waypoint_save_links();
		}
	}
	else
	{
		botframe_spawnedwaypoints = TRUE;
		waypoint_loadall();
		if(!waypoint_load_links())
			waypoint_schedulerelinkall();
	}

	if (bot_list)
	{
		// cycle the goal token from one bot to the next each frame
		// (this prevents them from all doing spawnfunc_waypoint searches on the same
		//  frame, which causes choppy framerates)
		if (bot_strategytoken_taken)
		{
			bot_strategytoken_taken = FALSE;
			if (bot_strategytoken)
				bot_strategytoken = bot_strategytoken.nextbot;
			if (!bot_strategytoken)
				bot_strategytoken = bot_list;
		}

		if (botframe_nextdangertime < time)
		{
			local float interval;
			interval = cvar("bot_ai_dangerdetectioninterval");
			if (botframe_nextdangertime < time - interval * 1.5)
				botframe_nextdangertime = time;
			botframe_nextdangertime = botframe_nextdangertime + interval;
			botframe_updatedangerousobjects(cvar("bot_ai_dangerdetectionupdates"));
		}
	}

	if (cvar("g_waypointeditor"))
		botframe_showwaypointlinks();

	if(time > bot_cvar_nextthink)
	{
		if(currentbots>0)
			bot_custom_weapon_priority_setup();
		bot_cvar_nextthink = time + 5;
	}
};
