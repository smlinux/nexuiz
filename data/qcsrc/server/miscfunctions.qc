var void remove(entity e);
void objerror(string s);
void droptofloor();
.vector dropped_origin;

void traceline_antilag (entity source, vector v1, vector v2, float nomonst, entity forent, float lag);
void crosshair_trace(entity pl)
{
	traceline_antilag(pl, pl.cursor_trace_start, pl.cursor_trace_start + normalize(pl.cursor_trace_endpos - pl.cursor_trace_start) * MAX_SHOT_DISTANCE, MOVE_NORMAL, pl, ANTILAG_LATENCY(pl));
}
void WarpZone_traceline_antilag (entity source, vector v1, vector v2, float nomonst, entity forent, float lag);
void WarpZone_crosshair_trace(entity pl)
{
	WarpZone_traceline_antilag(pl, pl.cursor_trace_start, pl.cursor_trace_start + normalize(pl.cursor_trace_endpos - pl.cursor_trace_start) * MAX_SHOT_DISTANCE, MOVE_NORMAL, pl, ANTILAG_LATENCY(pl));
}

void() spawnfunc_info_player_deathmatch; // needed for the other spawnpoints
void() spawnpoint_use;
float race_GetTime(float pos);
string race_GetName(float pos);
string race_PlaceName(float pos);
string GetMapname();
string ColoredTeamName(float t);

string admin_name(void)
{
	if(cvar_string("sv_adminnick") != "")
		return cvar_string("sv_adminnick");
	else
		return "SERVER ADMIN";
}

float DistributeEvenly_amount;
float DistributeEvenly_totalweight;
void DistributeEvenly_Init(float amount, float totalweight)
{
    if (DistributeEvenly_amount)
    {
        dprint("DistributeEvenly_Init: UNFINISHED DISTRIBUTION (", ftos(DistributeEvenly_amount), " for ");
        dprint(ftos(DistributeEvenly_totalweight), " left!)\n");
    }
    if (totalweight == 0)
        DistributeEvenly_amount = 0;
    else
        DistributeEvenly_amount = amount;
    DistributeEvenly_totalweight = totalweight;
}
float DistributeEvenly_Get(float weight)
{
    float f;
    if (weight <= 0)
        return 0;
    f = floor(0.5 + DistributeEvenly_amount * weight / DistributeEvenly_totalweight);
    DistributeEvenly_totalweight -= weight;
    DistributeEvenly_amount -= f;
    return f;
}

#define move_out_of_solid(e) WarpZoneLib_MoveOutOfSolid(e)


string STR_PLAYER = "player";
string STR_SPECTATOR = "spectator";
string STR_OBSERVER = "observer";

#if 0
#define FOR_EACH_CLIENT(v) for(v = world; (v = findflags(v, flags, FL_CLIENT)) != world; )
#define FOR_EACH_REALCLIENT(v) FOR_EACH_CLIENT(v) if(clienttype(v) == CLIENTTYPE_REAL)
#define FOR_EACH_PLAYER(v) for(v = world; (v = find(v, classname, STR_PLAYER)) != world; )
#define FOR_EACH_REALPLAYER(v) FOR_EACH_PLAYER(v) if(clienttype(v) == CLIENTTYPE_REAL)
#else
#define FOR_EACH_CLIENTSLOT(v) for(v = world; (v = nextent(v)) && (num_for_edict(v) <= maxclients); )
#define FOR_EACH_CLIENT(v) FOR_EACH_CLIENTSLOT(v) if(v.flags & FL_CLIENT)
#define FOR_EACH_REALCLIENT(v) FOR_EACH_CLIENT(v) if(clienttype(v) == CLIENTTYPE_REAL)
#define FOR_EACH_PLAYER(v) FOR_EACH_CLIENT(v) if(v.classname == STR_PLAYER)
#define FOR_EACH_REALPLAYER(v) FOR_EACH_REALCLIENT(v) if(v.classname == STR_PLAYER)
#endif

// copies a string to a tempstring (so one can strunzone it)
string strcat1(string s) = #115; // FRIK_FILE

float logfile_open;
float logfile;

string GetAdvancedDeathReports(entity enPlayer) // Extra fragmessage information
{
	local float nPlayerHealth = rint(enPlayer.health);
	local float nPlayerArmor = rint(enPlayer.armorvalue);
	local float nPlayerHandicap = enPlayer.cvar_cl_handicap;
	local float nPlayerPing = rint(enPlayer.ping);
	local string strPlayerPingColor;
	local string strMessage;
	if(nPlayerPing >= 150)
		strPlayerPingColor = "^1";
	else
		strPlayerPingColor = "^2";

	if((cvar("sv_fragmessage_information_stats")) && (enPlayer.health >= 1))
		strMessage = strcat(strMessage, "\n^7(Health ^1", ftos(nPlayerHealth), "^7 / Armor ^2", ftos(nPlayerArmor), "^7)");

	if(cvar("sv_fragmessage_information_ping")) {
		if(clienttype(enPlayer) == CLIENTTYPE_BOT) // Bots have no ping
			strMessage = strcat(strMessage, "\n^7(^2Bot");
		else
			strMessage = strcat(strMessage, "\n^7(Ping ", strPlayerPingColor, ftos(nPlayerPing), "ms");
		if(cvar("sv_fragmessage_information_handicap"))
			if(cvar("sv_fragmessage_information_handicap") == 2)
				if(nPlayerHandicap <= 1)
					strMessage = strcat(strMessage, "^7 / Handicap ^2Off^7)");
				else
					strMessage = strcat(strMessage, "^7 / Handicap ^2", ftos(nPlayerHandicap), "^7)");
			else if not(nPlayerHandicap <= 1)
				strMessage = strcat(strMessage, "^7 / Handicap ^2", ftos(nPlayerHandicap), "^7)");
		else
			strMessage = strcat(strMessage, "^7)");
	} else if(cvar("sv_fragmessage_information_handicap")) {
		if(cvar("sv_fragmessage_information_handicap") == 2)
			if(nPlayerHandicap <= 1)
				strMessage = strcat(strMessage, "\n^7(Handicap ^2Off^7)");
			else
				strMessage = strcat(strMessage, "\n^7(Handicap ^2", ftos(nPlayerHandicap), "^7)");
		else if(nPlayerHandicap > 1)
			strMessage = strcat(strMessage, "\n^7(Handicap ^2", ftos(nPlayerHandicap), "^7)");
	}
	return strMessage;
}
void bcenterprint(string s)
{
    // TODO replace by MSG_ALL (would show it to spectators too, though)?
    entity head;
    FOR_EACH_PLAYER(head)
    if (clienttype(head) == CLIENTTYPE_REAL)
        centerprint(head, s);
}

void GameLogEcho(string s)
{
    string fn;
    float matches;

    if (cvar("sv_eventlog_files"))
    {
        if (!logfile_open)
        {
            logfile_open = TRUE;
            matches = cvar("sv_eventlog_files_counter") + 1;
            cvar_set("sv_eventlog_files_counter", ftos(matches));
            fn = ftos(matches);
            if (strlen(fn) < 8)
                fn = strcat(substring("00000000", 0, 8 - strlen(fn)), fn);
            fn = strcat(cvar_string("sv_eventlog_files_nameprefix"), fn, cvar_string("sv_eventlog_files_namesuffix"));
            logfile = fopen(fn, FILE_APPEND);
            fputs(logfile, ":logversion:3\n");
        }
        if (logfile >= 0)
        {
            if (cvar("sv_eventlog_files_timestamps"))
                fputs(logfile, strcat(":time:", strftime(TRUE, "%Y-%m-%d %H:%M:%S", "\n", s, "\n")));
            else
                fputs(logfile, strcat(s, "\n"));
        }
    }
    if (cvar("sv_eventlog_console"))
    {
        print(s, "\n");
    }
}

void GameLogInit()
{
    logfile_open = 0;
    // will be opened later
}

void GameLogClose()
{
    if (logfile_open && logfile >= 0)
    {
        fclose(logfile);
        logfile = -1;
    }
}

vector PL_VIEW_OFS;
vector PL_MIN;
vector PL_MAX;
vector PL_CROUCH_VIEW_OFS;
vector PL_CROUCH_MIN;
vector PL_CROUCH_MAX;

float spawnpoint_nag;
void relocate_spawnpoint()
{
    PL_VIEW_OFS                             = stov(cvar_string("sv_player_viewoffset"));
    PL_MIN                                  = stov(cvar_string("sv_player_mins"));
    PL_MAX                                  = stov(cvar_string("sv_player_maxs"));
    PL_CROUCH_VIEW_OFS                      = stov(cvar_string("sv_player_crouch_viewoffset"));
    PL_CROUCH_MIN                           = stov(cvar_string("sv_player_crouch_mins"));
    PL_CROUCH_MAX                           = stov(cvar_string("sv_player_crouch_maxs"));

    // nudge off the floor
    setorigin(self, self.origin + '0 0 1');

    tracebox(self.origin, PL_MIN, PL_MAX, self.origin, TRUE, self);
    if (trace_startsolid)
    {
        vector o;
        o = self.origin;
        self.mins = PL_MIN;
        self.maxs = PL_MAX;
        if (!move_out_of_solid(self))
            objerror("could not get out of solid at all!");
        print("^1NOTE: this map needs FIXING. Spawnpoint at ", vtos(o - '0 0 1'));
        print(" needs to be moved out of solid, e.g. by '", ftos(self.origin_x - o_x));
        print(" ", ftos(self.origin_y - o_y));
        print(" ", ftos(self.origin_z - o_z), "'\n");
        if (cvar("g_spawnpoints_auto_move_out_of_solid"))
        {
            if (!spawnpoint_nag)
                print("\{1}^1NOTE: this map needs FIXING (it contains spawnpoints in solid, see server log)\n");
            spawnpoint_nag = 1;
        }
        else
        {
            setorigin(self, o);
            self.mins = self.maxs = '0 0 0';
            objerror("player spawn point in solid, mapper sucks!\n");
            return;
        }
    }

    if (cvar("g_spawnpoints_autodrop"))
    {
        setsize(self, PL_MIN, PL_MAX);
        droptofloor();
    }

    self.use = spawnpoint_use;
    self.team_saved = self.team;
    if (!self.cnt)
        self.cnt = 1;

    if (have_team_spawns != 0)
        if (self.team)
            have_team_spawns = 1;

    if (cvar("r_showbboxes"))
    {
        // show where spawnpoints point at too
        makevectors(self.angles);
        entity e;
        e = spawn();
        e.classname = "info_player_foo";
        setorigin(e, self.origin + v_forward * 24);
        setsize(e, '-8 -8 -8', '8 8 8');
        e.solid = SOLID_TRIGGER;
    }
}

#define strstr strstrofs
/*
// NOTE: DO NOT USE THIS FUNCTION TOO OFTEN.
// IT WILL MOST PROBABLY DESTROY _ALL_ OTHER TEMP
// STRINGS AND TAKE QUITE LONG. haystack and needle MUST
// BE CONSTANT OR strzoneD!
float strstr(string haystack, string needle, float offset)
{
	float len, endpos;
	string found;
	len = strlen(needle);
	endpos = strlen(haystack) - len;
	while(offset <= endpos)
	{
		found = substring(haystack, offset, len);
		if(found == needle)
			return offset;
		offset = offset + 1;
	}
	return -1;
}
*/

float NUM_NEAREST_ENTITIES = 4;
entity nearest_entity[NUM_NEAREST_ENTITIES];
float nearest_length[NUM_NEAREST_ENTITIES];
entity findnearest(vector point, .string field, string value, vector axismod)
{
    entity localhead;
    float i;
    float j;
    float len;
    vector dist;

    float num_nearest;
    num_nearest = 0;

    localhead = find(world, field, value);
    while (localhead)
    {
        if ((localhead.items == IT_KEY1 || localhead.items == IT_KEY2) && localhead.target == "###item###")
            dist = localhead.oldorigin;
        else
            dist = localhead.origin;
        dist = dist - point;
        dist = dist_x * axismod_x * '1 0 0' + dist_y * axismod_y * '0 1 0' + dist_z * axismod_z * '0 0 1';
        len = vlen(dist);

        for (i = 0; i < num_nearest; ++i)
        {
            if (len < nearest_length[i])
                break;
        }

        // now i tells us where to insert at
        //   INSERTION SORT! YOU'VE SEEN IT! RUN!
        if (i < NUM_NEAREST_ENTITIES)
        {
            for (j = NUM_NEAREST_ENTITIES - 1; j >= i; --j)
            {
                nearest_length[j + 1] = nearest_length[j];
                nearest_entity[j + 1] = nearest_entity[j];
            }
            nearest_length[i] = len;
            nearest_entity[i] = localhead;
            if (num_nearest < NUM_NEAREST_ENTITIES)
                num_nearest = num_nearest + 1;
        }

        localhead = find(localhead, field, value);
    }

    // now use the first one from our list that we can see
    for (i = 0; i < num_nearest; ++i)
    {
        traceline(point, nearest_entity[i].origin, TRUE, world);
        if (trace_fraction == 1)
        {
            if (i != 0)
            {
                dprint("Nearest point (");
                dprint(nearest_entity[0].netname);
                dprint(") is not visible, using a visible one.\n");
            }
            return nearest_entity[i];
        }
    }

    if (num_nearest == 0)
        return world;

    dprint("Not seeing any location point, using nearest as fallback.\n");
    /* DEBUGGING CODE:
    dprint("Candidates were: ");
    for(j = 0; j < num_nearest; ++j)
    {
    	if(j != 0)
    		dprint(", ");
    	dprint(nearest_entity[j].netname);
    }
    dprint("\n");
    */

    return nearest_entity[0];
}

void spawnfunc_target_location()
{
    self.classname = "target_location";
    // location name in netname
    // eventually support: count, teamgame selectors, line of sight?
};

void spawnfunc_info_location()
{
    self.classname = "target_location";
    self.message = self.netname;
};

string NearestLocation(vector p)
{
    entity loc;
    string ret;
    ret = "somewhere";
    loc = findnearest(p, classname, "target_location", '1 1 1');
    if (loc)
    {
        ret = loc.message;
    }
    else
    {
        loc = findnearest(p, target, "###item###", '1 1 4');
        if (loc)
            ret = loc.netname;
    }
    return ret;
}

string formatmessage(string msg)
{
	float p, p1, p2;
	float n;
	vector cursor;
	entity cursor_ent;
	string escape;
	string replacement;
	p = 0;
	n = 7;

	WarpZone_crosshair_trace(self);
	cursor = trace_endpos;
	cursor_ent = trace_ent;

	while (1) {
		if (n < 1)
			break; // too many replacements

		n = n - 1;
		p1 = strstr(msg, "%", p); // NOTE: this destroys msg as it's a tempstring!
		p2 = strstr(msg, "\\", p); // NOTE: this destroys msg as it's a tempstring!

		if (p1 < 0)
			p1 = p2;

		if (p2 < 0)
			p2 = p1;

		p = min(p1, p2);

		if (p < 0)
			break;

		replacement = substring(msg, p, 2);
		escape = substring(msg, p + 1, 1);

		if (escape == "%")
			replacement = "%";
		else if (escape == "\\")
			replacement = "\\";
		else if (escape == "n")
			replacement = "\n";
		else if (escape == "a")
			replacement = ftos(floor(self.armorvalue));
		else if (escape == "h")
			replacement = ftos(floor(self.health));
		else if (escape == "l")
			replacement = NearestLocation(self.origin);
		else if (escape == "y")
			replacement = NearestLocation(cursor);
		else if (escape == "d")
			replacement = NearestLocation(self.death_origin);
		else if (escape == "w") {
			float wep;
			wep = self.weapon;
			if (!wep)
				wep = self.switchweapon;
			if (!wep)
				wep = self.cnt;
			replacement = W_Name(wep);
		} else if (escape == "W") {
			if (self.items & IT_SHELLS) replacement = "shells";
			else if (self.items & IT_NAILS) replacement = "bullets";
			else if (self.items & IT_ROCKETS) replacement = "rockets";
			else if (self.items & IT_CELLS) replacement = "cells";
			else replacement = "batteries"; // ;)
		} else if (escape == "x") {
			replacement = cursor_ent.netname;
			if (!replacement || !cursor_ent)
				replacement = "nothing";
		} else if (escape == "p") {
			if (self.last_selected_player)
				replacement = self.last_selected_player.netname;
			else
				replacement = "(nobody)";
		} else if (escape == "s")
			replacement = ftos(vlen(self.velocity - self.velocity_z * '0 0 1'));
		else if (escape == "S")
			replacement = ftos(vlen(self.velocity));
		else if (escape == "v") {
			float weapon_number;
			local entity stats;

			if(self.classname == "spectator")
				stats = self.enemy;
			else
				stats = self;

			weapon_number = stats.weapon;

			if (!weapon_number)
				weapon_number = stats.switchweapon;

			if (!weapon_number)
				weapon_number = stats.cnt;

			if(stats.cvar_cl_accuracy_data_share && stats.stats_fired[weapon_number - 1])
				replacement = ftos(bound(0, floor(100 * stats.stats_hit[weapon_number - 1] / stats.stats_fired[weapon_number - 1]), 100));
			else
				replacement = "~"; // or something to indicate NULL, not available
		}

		msg = strcat(substring(msg, 0, p), replacement, substring(msg, p+2, strlen(msg) - (p+2)));
		p = p + strlen(replacement);
	}
	return msg;
}

float boolean(float value) { // if value is 0 return FALSE (0), otherwise return TRUE (1)
	return (value == 0) ? FALSE : TRUE;
}

/*
=============
GetCvars
=============
Called with:
  0:  sends the request
  >0: receives a cvar from name=argv(f) value=argv(f+1)
*/
void GetCvars_handleString(string thisname, float f, .string field, string name)
{
	if (f < 0)
	{
		if (self.field)
			strunzone(self.field);
		self.field = string_null;
	}
	else if (f > 0)
	{
		if (thisname == name)
		{
			if (self.field)
				strunzone(self.field);
			self.field = strzone(argv(f + 1));
		}
	}
	else
		stuffcmd(self, strcat("sendcvar ", name, "\n"));
}
void GetCvars_handleString_Fixup(string thisname, float f, .string field, string name, string(string) func)
{
	GetCvars_handleString(thisname, f, field, name);
	if (f >= 0) // also initialize to the fitting value for "" when sending cvars out
		if (thisname == name)
		{
			string s;
			s = func(strcat1(self.field));
			if (s != self.field)
			{
				strunzone(self.field);
				self.field = strzone(s);
			}
		}
}
void GetCvars_handleFloat(string thisname, float f, .float field, string name)
{
	if (f < 0)
	{
	}
	else if (f > 0)
	{
		if (thisname == name)
			self.field = stof(argv(f + 1));
	}
	else
		stuffcmd(self, strcat("sendcvar ", name, "\n"));
}
void GetCvars_handleFloatOnce(string thisname, float f, .float field, string name)
{
	if (f < 0)
	{
	}
	else if (f > 0)
	{
		if (thisname == name)
		{
			if(!self.field)
			{
				self.field = stof(argv(f + 1));
				if(!self.field)
					self.field = -1;
			}
		}
	}
	else
	{
		if(!self.field)
			stuffcmd(self, strcat("sendcvar ", name, "\n"));
	}
}
string W_FixWeaponOrder_ForceComplete(string s);
string W_FixWeaponOrder_AllowIncomplete(string s);
float w_getbestweapon(entity e);
void GetCvars(float f)
{
	string s;
	if (f > 0)
		s = strcat1(argv(f));
	GetCvars_handleFloat(s, f, autoswitch, "cl_autoswitch");
	GetCvars_handleFloat(s, f, cvar_cl_playerdetailreduction, "cl_playerdetailreduction");
	GetCvars_handleFloat(s, f, cvar_scr_centertime, "scr_centertime");
	GetCvars_handleFloat(s, f, cvar_cl_shownames, "cl_shownames");
	GetCvars_handleString(s, f, cvar_g_nexuizversion, "g_nexuizversion");
	GetCvars_handleFloat(s, f, cvar_cl_handicap, "cl_handicap");
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriority, "cl_weaponpriority", W_FixWeaponOrder_ForceComplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[0], "cl_weaponpriority0", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[1], "cl_weaponpriority1", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[2], "cl_weaponpriority2", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[3], "cl_weaponpriority3", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[4], "cl_weaponpriority4", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[5], "cl_weaponpriority5", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[6], "cl_weaponpriority6", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[7], "cl_weaponpriority7", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[8], "cl_weaponpriority8", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[9], "cl_weaponpriority9", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleFloat(s, f, cvar_cl_autotaunt, "cl_autotaunt");
	GetCvars_handleFloat(s, f, cvar_cl_noantilag, "cl_noantilag");
	GetCvars_handleFloat(s, f, cvar_cl_voice_directional, "cl_voice_directional");
	GetCvars_handleFloat(s, f, cvar_cl_voice_directional_taunt_attenuation, "cl_voice_directional_taunt_attenuation");
	GetCvars_handleFloat(s, f, cvar_cl_hitsound, "cl_hitsound");
	GetCvars_handleFloat(s, f, cvar_cl_accuracy_data_share, "cl_accuracy_data_share");
	GetCvars_handleFloat(s, f, cvar_cl_accuracy_data_receive, "cl_accuracy_data_receive");

	self.cvar_cl_accuracy_data_share = boolean(self.cvar_cl_accuracy_data_share);
	self.cvar_cl_accuracy_data_receive = boolean(self.cvar_cl_accuracy_data_receive);

#ifdef ALLOW_FORCEMODELS
	GetCvars_handleFloat(s, f, cvar_cl_forceplayermodels, "cl_forceplayermodels");
	GetCvars_handleFloat(s, f, cvar_cl_forceplayermodelsfromnexuiz, "cl_forceplayermodelsfromnexuiz");
#endif
	GetCvars_handleFloatOnce(s, f, cvar_cl_gunalign, "cl_gunalign");

	// fixup of switchweapon (needed for LMS or when spectating is disabled, as PutClientInServer comes too early)
	if (f > 0)
	{
		if (s == "cl_weaponpriority")
			self.switchweapon = w_getbestweapon(self);
	}
}

float fexists(string f)
{
    float fh;
    fh = fopen(f, FILE_READ);
    if (fh < 0)
        return FALSE;
    fclose(fh);
    return TRUE;
}

void backtrace(string msg)
{
    float dev, war;
    dev = cvar("developer");
    war = cvar("prvm_backtraceforwarnings");
    cvar_set("developer", "1");
    cvar_set("prvm_backtraceforwarnings", "1");
    print("\n");
    print("--- CUT HERE ---\nWARNING: ");
    print(msg);
    print("\n");
    remove(world); // isn't there any better way to cause a backtrace?
    print("\n--- CUT UNTIL HERE ---\n");
    cvar_set("developer", ftos(dev));
    cvar_set("prvm_backtraceforwarnings", ftos(war));
}

string Team_ColorCode(float teamid)
{
    if (teamid == COLOR_TEAM1)
        return "^1";
    else if (teamid == COLOR_TEAM2)
        return "^4";
    else if (teamid == COLOR_TEAM3)
        return "^3";
    else if (teamid == COLOR_TEAM4)
        return "^6";
    else
        return "^7";
}

string Team_ColorName(float t)
{
    // fixme: Search for team entities and get their .netname's!
    if (t == COLOR_TEAM1)
        return "Red";
    if (t == COLOR_TEAM2)
        return "Blue";
    if (t == COLOR_TEAM3)
        return "Yellow";
    if (t == COLOR_TEAM4)
        return "Pink";
    return "Neutral";
}

string Team_ColorNameLowerCase(float t)
{
    // fixme: Search for team entities and get their .netname's!
    if (t == COLOR_TEAM1)
        return "red";
    if (t == COLOR_TEAM2)
        return "blue";
    if (t == COLOR_TEAM3)
        return "yellow";
    if (t == COLOR_TEAM4)
        return "pink";
    return "neutral";
}

float ColourToNumber(string team_colour)
{
	if (team_colour == "red")
		return COLOR_TEAM1;

	if (team_colour == "blue")
		return COLOR_TEAM2;

	if (team_colour == "yellow")
		return COLOR_TEAM3;

	if (team_colour == "pink")
		return COLOR_TEAM4;

	if (team_colour == "auto")
		return 0;

	return -1;
}

float NumberToTeamNumber(float number)
{
	if (number == 1)
		return COLOR_TEAM1;

	if (number == 2)
		return COLOR_TEAM2;

	if (number == 3)
		return COLOR_TEAM3;

	if (number == 4)
		return COLOR_TEAM4;

	return -1;
}

#define CENTERPRIO_POINT 1
#define CENTERPRIO_SPAM 2
#define CENTERPRIO_VOTE 4
#define CENTERPRIO_NORMAL 5
#define CENTERPRIO_SHIELDING 7
#define CENTERPRIO_MAPVOTE 9
#define CENTERPRIO_IDLEKICK 50
#define CENTERPRIO_ADMIN 99
.float centerprint_priority;
.float centerprint_expires;
void centerprint_atprio(entity e, float prio, string s)
{
    if (intermission_running)
        if (prio < CENTERPRIO_MAPVOTE)
            return;
    if (time > e.centerprint_expires)
        e.centerprint_priority = 0;
    if (prio >= e.centerprint_priority)
    {
        e.centerprint_priority = prio;
        if (timeoutStatus == 2)
            e.centerprint_expires = time + (e.cvar_scr_centertime * TIMEOUT_SLOWMO_VALUE);
        else
            e.centerprint_expires = time + e.cvar_scr_centertime;
        centerprint_builtin(e, s);
    }
}
void centerprint_expire(entity e, float prio)
{
    if (prio == e.centerprint_priority)
    {
        e.centerprint_priority = 0;
        centerprint_builtin(e, "");
    }
}
void centerprint(entity e, string s)
{
    centerprint_atprio(e, CENTERPRIO_NORMAL, s);
}

// decolorizes and team colors the player name when needed
string playername(entity p)
{
    string t;
    if (teams_matter && !intermission_running && p.classname == "player")
    {
        t = Team_ColorCode(p.team);
        return strcat(t, strdecolorize(p.netname));
    }
    else
        return p.netname;
}

vector randompos(vector m1, vector m2)
{
    local vector v;
    m2 = m2 - m1;
    v_x = m2_x * random() + m1_x;
    v_y = m2_y * random() + m1_y;
    v_z = m2_z * random() + m1_z;
    return  v;
};

float g_pickup_shells;
float g_pickup_shells_max;
float g_pickup_nails;
float g_pickup_nails_max;
float g_pickup_rockets;
float g_pickup_rockets_max;
float g_pickup_cells;
float g_pickup_cells_max;
float g_pickup_fuel;
float g_pickup_fuel_jetpack;
float g_pickup_fuel_max;
float g_pickup_armorsmall;
float g_pickup_armorsmall_max;
float g_pickup_armormedium;
float g_pickup_armormedium_max;
float g_pickup_armorbig;
float g_pickup_armorbig_max;
float g_pickup_armorlarge;
float g_pickup_armorlarge_max;
float g_pickup_healthsmall;
float g_pickup_healthsmall_max;
float g_pickup_healthmedium;
float g_pickup_healthmedium_max;
float g_pickup_healthlarge;
float g_pickup_healthlarge_max;
float g_pickup_healthmega;
float g_pickup_healthmega_max;
float g_weaponarena;
float g_weaponarena_random;
string g_weaponarena_list;
float g_weaponspeedfactor;
float g_weaponratefactor;
float g_weapondamagefactor;
float g_weaponforcefactor;
float g_weaponspreadfactor;

float start_weapons;
float start_items;
float start_ammo_shells;
float start_ammo_nails;
float start_ammo_rockets;
float start_ammo_cells;
float start_ammo_fuel;
float start_health;
float start_armorvalue;
float warmup_start_weapons;
float warmup_start_ammo_shells;
float warmup_start_ammo_nails;
float warmup_start_ammo_rockets;
float warmup_start_ammo_cells;
float warmup_start_ammo_fuel;
float warmup_start_health;
float warmup_start_armorvalue;
float g_weapon_stay;
float g_ghost_items;

entity get_weaponinfo(float w);

float want_weapon(string cvarprefix, entity weaponinfo, float allguns)
{
	var float i = weaponinfo.weapon;

	if (!i)
		return 0;

	var float t = cvar(strcat(cvarprefix, weaponinfo.netname));

	if (t < 0) // "default" weapon selection
	{
		if (g_lms || g_ca || allguns)
			t = (weaponinfo.spawnflags & WEP_FLAG_NORMAL);
		else if(t < -1)
			t = 0;
		else if (g_race || g_cts)
			t = (i == WEP_LASER);
		else if (g_nexball)
			t = 0; // weapon is set a few lines later
		else
			t = (i == WEP_LASER || i == WEP_SHOTGUN);
		if(g_grappling_hook) // if possible, redirect off-hand hook to on-hand hook
			t |= (i == WEP_HOOK);
	}

	// we cannot disable porto in Nexball, we must force it
	if(g_nexball && i == WEP_PORTO)
		t = 1;

	return t;
}

float NixNex_CanChooseWeapon(float wpn);
void readplayerstartcvars()
{
	entity e;
	float i, j, t;
	string s;

	// initialize starting values for players
	start_weapons = 0;
	start_items = 0;
	start_ammo_shells = 0;
	start_ammo_nails = 0;
	start_ammo_rockets = 0;
	start_ammo_cells = 0;
	start_health = cvar("g_balance_health_start");
	start_armorvalue = cvar("g_balance_armor_start");

	g_weaponarena = 0;
	s = cvar_string("g_weaponarena");
	if (s == "0")
	{
	}
	else if (s == "all")
	{
		g_weaponarena_list = "All Weapons";
		for (j = WEP_FIRST; j <= WEP_LAST; ++j)
		{
			e = get_weaponinfo(j);
			g_weaponarena |= e.weapons;
			weapon_action(e.weapon, WR_PRECACHE);
		}
	}
	else if (s == "most")
	{
		g_weaponarena_list = "Most Weapons";
		for (j = WEP_FIRST; j <= WEP_LAST; ++j)
		{
			e = get_weaponinfo(j);
			if (e.spawnflags & WEP_FLAG_NORMAL)
			{
				g_weaponarena |= e.weapons;
				weapon_action(e.weapon, WR_PRECACHE);
			}
		}
	}
	else if (s == "none")
	{
		g_weaponarena_list = "No Weapons";
		g_weaponarena = WEPBIT_ALL + 1; // this supports no single weapon bit!
	}
	else
	{
		t = tokenize_console(s);
		g_weaponarena_list = "";
		for (i = 0; i < t; ++i)
		{
			s = argv(i);
			for (j = WEP_FIRST; j <= WEP_LAST; ++j)
			{
				e = get_weaponinfo(j);
				if (e.netname == s)
				{
					g_weaponarena |= e.weapons;
					weapon_action(e.weapon, WR_PRECACHE);
					g_weaponarena_list = strcat(g_weaponarena_list, e.message, " & ");
					break;
				}
			}
			if (j > WEP_LAST)
			{
				print("The weapon mutator list contains an unknown weapon ", s, ". Skipped.\n");
			}
		}
		g_weaponarena_list = strzone(substring(g_weaponarena_list, 0, strlen(g_weaponarena_list) - 3));
	}

	if(g_weaponarena)
		g_weaponarena_random = cvar("g_weaponarena_random");
	else
		g_weaponarena_random = 0;

	if (g_nixnex)
	{
		start_weapons = 0;
		// will be done later
		for (i = WEP_FIRST; i <= WEP_LAST; ++i)
			if (NixNex_CanChooseWeapon(i))
				weapon_action(i, WR_PRECACHE);
		if(!cvar("g_use_ammunition"))
			start_items |= IT_UNLIMITED_AMMO;
	}
	else if (g_weaponarena)
	{
		start_weapons = g_weaponarena;
		if (g_weaponarena & (WEPBIT_GRENADE_LAUNCHER | WEPBIT_HAGAR | WEPBIT_ROCKET_LAUNCHER))
			start_ammo_rockets = 999;
		if (g_weaponarena & WEPBIT_SHOTGUN)
			start_ammo_shells = 999;
		if (g_weaponarena & (WEPBIT_ELECTRO | WEPBIT_CRYLINK | WEPBIT_NEX | WEPBIT_MINSTANEX | WEPBIT_HLAC | WEPBIT_HOOK))
			start_ammo_cells = 999;
		if (g_weaponarena & (WEPBIT_UZI | WEPBIT_CAMPINGRIFLE))
			start_ammo_nails = 999;
		if (g_weaponarena & WEPBIT_HOOK)
			start_ammo_fuel = 999;
		start_items |= IT_UNLIMITED_AMMO;
	}
	else if (g_minstagib)
	{
		start_health = 100;
		start_armorvalue = 0;
		start_weapons = WEPBIT_MINSTANEX;
		weapon_action(WEP_MINSTANEX, WR_PRECACHE);
		start_ammo_cells = cvar("g_minstagib_ammo_start");
		g_minstagib_invis_alpha = cvar("g_minstagib_invis_alpha");
		start_ammo_fuel = cvar("g_start_ammo_fuel");

		if (g_minstagib_invis_alpha <= 0)
			g_minstagib_invis_alpha = -1;
	}
	else
	{
		if (g_lms || g_ca)
		{
			start_ammo_shells = cvar("g_lms_start_ammo_shells");
			start_ammo_nails = cvar("g_lms_start_ammo_nails");
			start_ammo_rockets = cvar("g_lms_start_ammo_rockets");
			start_ammo_cells = cvar("g_lms_start_ammo_cells");
			start_ammo_fuel = cvar("g_lms_start_ammo_fuel");
			start_health = cvar("g_lms_start_health");
			start_armorvalue = cvar("g_lms_start_armor");
		}
		else if (cvar("g_use_ammunition"))
		{
			start_ammo_shells = cvar("g_start_ammo_shells");
			start_ammo_nails = cvar("g_start_ammo_nails");
			start_ammo_rockets = cvar("g_start_ammo_rockets");
			start_ammo_cells = cvar("g_start_ammo_cells");
			start_ammo_fuel = cvar("g_start_ammo_fuel");
		}
		else
		{
			start_ammo_shells = cvar("g_pickup_shells_max");
			start_ammo_nails = cvar("g_pickup_nails_max");
			start_ammo_rockets = cvar("g_pickup_rockets_max");
			start_ammo_cells = cvar("g_pickup_cells_max");
			start_ammo_fuel = cvar("g_pickup_fuel_max");
			start_items |= IT_UNLIMITED_AMMO;
		}

		for (i = WEP_FIRST; i <= WEP_LAST; ++i)
		{
			e = get_weaponinfo(i);
			if(want_weapon("g_start_weapon_", e, FALSE))
			{
				start_weapons |= e.weapons;
				weapon_action(e.weapon, WR_PRECACHE);
			}
		}
	}

	if (inWarmupStage)
	{
		warmup_start_ammo_shells = start_ammo_shells;
		warmup_start_ammo_nails = start_ammo_nails;
		warmup_start_ammo_rockets = start_ammo_rockets;
		warmup_start_ammo_cells = start_ammo_cells;
		warmup_start_ammo_fuel = start_ammo_fuel;
		warmup_start_health = start_health;
		warmup_start_armorvalue = start_armorvalue;
		warmup_start_weapons = start_weapons;

		if (!g_weaponarena && !g_nixnex && !g_minstagib && !g_ca)
		{
			if (cvar("g_use_ammunition"))
			{
				warmup_start_ammo_shells = cvar("g_warmup_start_ammo_shells");
				warmup_start_ammo_cells = cvar("g_warmup_start_ammo_cells");
				warmup_start_ammo_nails = cvar("g_warmup_start_ammo_nails");
				warmup_start_ammo_rockets = cvar("g_warmup_start_ammo_rockets");
				warmup_start_ammo_fuel = cvar("g_warmup_start_ammo_fuel");
			}
			warmup_start_health = cvar("g_warmup_start_health");
			warmup_start_armorvalue = cvar("g_warmup_start_armor");
			warmup_start_weapons = 0;
			for (i = WEP_FIRST; i <= WEP_LAST; ++i)
			{
				e = get_weaponinfo(i);
				if(want_weapon("g_start_weapon_", e, cvar("g_warmup_allguns")))
				{
					warmup_start_weapons |= e.weapons;
					weapon_action(e.weapon, WR_PRECACHE);
				}
			}
		}
	}

	if (g_jetpack || (g_grappling_hook && (start_weapons & WEPBIT_HOOK)))
	{
		g_grappling_hook = 0; // these two can't coexist, as they use the same button
		start_items |= IT_FUEL_REGEN;
		start_ammo_fuel = max(start_ammo_fuel, cvar("g_balance_fuel_rotstable"));
		warmup_start_ammo_fuel = max(warmup_start_ammo_fuel, cvar("g_balance_fuel_rotstable"));
	}

	if (g_jetpack)
		start_items |= IT_JETPACK;

	if (g_weapon_stay == 2)
	{
		if (!start_ammo_shells) start_ammo_shells = g_pickup_shells;
		if (!start_ammo_nails) start_ammo_nails = g_pickup_nails;
		if (!start_ammo_cells) start_ammo_cells = g_pickup_cells;
		if (!start_ammo_rockets) start_ammo_rockets = g_pickup_rockets;
		if (!start_ammo_fuel) start_ammo_fuel = g_pickup_fuel;
		if (!warmup_start_ammo_shells) warmup_start_ammo_shells = g_pickup_shells;
		if (!warmup_start_ammo_nails) warmup_start_ammo_nails = g_pickup_nails;
		if (!warmup_start_ammo_cells) warmup_start_ammo_cells = g_pickup_cells;
		if (!warmup_start_ammo_rockets) warmup_start_ammo_rockets = g_pickup_rockets;
		if (!warmup_start_ammo_fuel) warmup_start_ammo_fuel = g_pickup_fuel;
	}

	start_ammo_shells = max(0, start_ammo_shells);
	start_ammo_nails = max(0, start_ammo_nails);
	start_ammo_cells = max(0, start_ammo_cells);
	start_ammo_rockets = max(0, start_ammo_rockets);
	start_ammo_fuel = max(0, start_ammo_fuel);

	warmup_start_ammo_shells = max(0, warmup_start_ammo_shells);
	warmup_start_ammo_nails = max(0, warmup_start_ammo_nails);
	warmup_start_ammo_cells = max(0, warmup_start_ammo_cells);
	warmup_start_ammo_rockets = max(0, warmup_start_ammo_rockets);
	warmup_start_ammo_fuel = max(0, warmup_start_ammo_fuel);
}

float g_bugrigs;
float g_bugrigs_planar_movement;
float g_bugrigs_planar_movement_car_jumping;
float g_bugrigs_reverse_spinning;
float g_bugrigs_reverse_speeding;
float g_bugrigs_reverse_stopping;
float g_bugrigs_air_steering;
float g_bugrigs_angle_smoothing;
float g_bugrigs_friction_floor;
float g_bugrigs_friction_brake;
float g_bugrigs_friction_air;
float g_bugrigs_accel;
float g_bugrigs_speed_ref;
float g_bugrigs_speed_pow;
float g_bugrigs_steer;

float g_touchexplode;
float g_touchexplode_radius;
float g_touchexplode_damage;
float g_touchexplode_edgedamage;
float g_touchexplode_force;

float sv_autotaunt;
float sv_taunt;

float sv_pitch_min;
float sv_pitch_max;
float sv_pitch_fixyaw;

float sv_accuracy_data_share;

void readlevelcvars(void)
{
    g_bugrigs = cvar("g_bugrigs");
    g_bugrigs_planar_movement = cvar("g_bugrigs_planar_movement");
    g_bugrigs_planar_movement_car_jumping = cvar("g_bugrigs_planar_movement_car_jumping");
    g_bugrigs_reverse_spinning = cvar("g_bugrigs_reverse_spinning");
    g_bugrigs_reverse_speeding = cvar("g_bugrigs_reverse_speeding");
    g_bugrigs_reverse_stopping = cvar("g_bugrigs_reverse_stopping");
    g_bugrigs_air_steering = cvar("g_bugrigs_air_steering");
    g_bugrigs_angle_smoothing = cvar("g_bugrigs_angle_smoothing");
    g_bugrigs_friction_floor = cvar("g_bugrigs_friction_floor");
    g_bugrigs_friction_brake = cvar("g_bugrigs_friction_brake");
    g_bugrigs_friction_air = cvar("g_bugrigs_friction_air");
    g_bugrigs_accel = cvar("g_bugrigs_accel");
    g_bugrigs_speed_ref = cvar("g_bugrigs_speed_ref");
    g_bugrigs_speed_pow = cvar("g_bugrigs_speed_pow");
    g_bugrigs_steer = cvar("g_bugrigs_steer");

    g_touchexplode = cvar("g_touchexplode");
    g_touchexplode_radius = cvar("g_touchexplode_radius");
    g_touchexplode_damage = cvar("g_touchexplode_damage");
    g_touchexplode_edgedamage = cvar("g_touchexplode_edgedamage");
    g_touchexplode_force = cvar("g_touchexplode_force");

#ifdef ALLOW_FORCEMODELS
	sv_clforceplayermodels = cvar("sv_clforceplayermodels");
#endif
	sv_loddistance1 = cvar("sv_loddistance1");
	sv_loddistance2 = cvar("sv_loddistance2");

	if(sv_loddistance2 <= sv_loddistance1)
		sv_loddistance2 = 1073741824; // enough to turn off LOD 2 reliably

	sv_clones = cvar("sv_clones");
	sv_gentle = cvar("sv_gentle");
	sv_foginterval = cvar("sv_foginterval");
	g_cloaked = cvar("g_cloaked");
	g_jump_grunt = cvar("g_jump_grunt");
	g_footsteps = cvar("g_footsteps");
	g_grappling_hook = cvar("g_grappling_hook");
	g_jetpack = cvar("g_jetpack");
	g_laserguided_missile = cvar("g_laserguided_missile");
	g_midair = cvar("g_midair");
	g_minstagib = cvar("g_minstagib");
	g_nixnex = cvar("g_nixnex");
	g_nixnex_with_laser = cvar("g_nixnex_with_laser");
	g_norecoil = cvar("g_norecoil");
	g_vampire = cvar("g_vampire");
	g_bloodloss = cvar("g_bloodloss");
	sv_maxidle = cvar("sv_maxidle");
	sv_maxidle_spectatorsareidle = cvar("sv_maxidle_spectatorsareidle");
	sv_pogostick = cvar("sv_pogostick");
	sv_doublejump = cvar("sv_doublejump");
	g_ctf_reverse = cvar("g_ctf_reverse");
	sv_autotaunt = cvar("sv_autotaunt");
	sv_taunt = cvar("sv_taunt");

	inWarmupStage = cvar("g_warmup");
	g_warmup_limit = cvar("g_warmup_limit");
	g_warmup_allguns = cvar("g_warmup_allguns");
	g_warmup_allow_timeout = cvar("g_warmup_allow_timeout");

	if ((g_race && g_race_qualifying == 2) || g_runematch || g_arena || g_assault || cvar("g_campaign"))
		inWarmupStage = 0; // these modes cannot work together, sorry

	g_pickup_respawntime_weapon = cvar("g_pickup_respawntime_weapon");
	g_pickup_respawntime_ammo = cvar("g_pickup_respawntime_ammo");
	g_pickup_respawntime_short = cvar("g_pickup_respawntime_short");
	g_pickup_respawntime_medium = cvar("g_pickup_respawntime_medium");
	g_pickup_respawntime_long = cvar("g_pickup_respawntime_long");
	g_pickup_respawntime_powerup = cvar("g_pickup_respawntime_powerup");
	g_pickup_respawntimejitter_weapon = cvar("g_pickup_respawntimejitter_weapon");
	g_pickup_respawntimejitter_ammo = cvar("g_pickup_respawntimejitter_ammo");
	g_pickup_respawntimejitter_short = cvar("g_pickup_respawntimejitter_short");
	g_pickup_respawntimejitter_medium = cvar("g_pickup_respawntimejitter_medium");
	g_pickup_respawntimejitter_long = cvar("g_pickup_respawntimejitter_long");
	g_pickup_respawntimejitter_powerup = cvar("g_pickup_respawntimejitter_powerup");

	if (g_minstagib) g_nixnex = g_weaponarena = 0;
	if (g_nixnex) g_weaponarena = 0;
		g_weaponarena = 0;

	g_weaponspeedfactor = cvar("g_weaponspeedfactor");
	g_weaponratefactor = cvar("g_weaponratefactor");
	g_weapondamagefactor = cvar("g_weapondamagefactor");
	g_weaponforcefactor = cvar("g_weaponforcefactor");
	g_weaponspreadfactor = cvar("g_weaponspreadfactor");

	g_pickup_shells = cvar("g_pickup_shells");
	g_pickup_shells_max = cvar("g_pickup_shells_max");
	g_pickup_nails = cvar("g_pickup_nails");
	g_pickup_nails_max = cvar("g_pickup_nails_max");
	g_pickup_rockets = cvar("g_pickup_rockets");
	g_pickup_rockets_max = cvar("g_pickup_rockets_max");
	g_pickup_cells = cvar("g_pickup_cells");
	g_pickup_cells_max = cvar("g_pickup_cells_max");
	g_pickup_fuel = cvar("g_pickup_fuel");
	g_pickup_fuel_jetpack = cvar("g_pickup_fuel_jetpack");
	g_pickup_fuel_max = cvar("g_pickup_fuel_max");
	g_pickup_armorsmall = cvar("g_pickup_armorsmall");
	g_pickup_armorsmall_max = cvar("g_pickup_armorsmall_max");
	g_pickup_armormedium = cvar("g_pickup_armormedium");
	g_pickup_armormedium_max = cvar("g_pickup_armormedium_max");
	g_pickup_armorbig = cvar("g_pickup_armorbig");
	g_pickup_armorbig_max = cvar("g_pickup_armorbig_max");
	g_pickup_armorlarge = cvar("g_pickup_armorlarge");
	g_pickup_armorlarge_max = cvar("g_pickup_armorlarge_max");
	g_pickup_healthsmall = cvar("g_pickup_healthsmall");
	g_pickup_healthsmall_max = cvar("g_pickup_healthsmall_max");
	g_pickup_healthmedium = cvar("g_pickup_healthmedium");
	g_pickup_healthmedium_max = cvar("g_pickup_healthmedium_max");
	g_pickup_healthlarge = cvar("g_pickup_healthlarge");
	g_pickup_healthlarge_max = cvar("g_pickup_healthlarge_max");
	g_pickup_healthmega = cvar("g_pickup_healthmega");
	g_pickup_healthmega_max = cvar("g_pickup_healthmega_max");

	g_pinata = cvar("g_pinata");

	g_weapon_stay = cvar("g_weapon_stay");

	if (!g_weapon_stay && (cvar("deathmatch") == 2))
		g_weapon_stay = 1;

	g_ghost_items = cvar("g_ghost_items");

	if(g_ghost_items >= 1)
		g_ghost_items = 0.25; // default alpha value

	if not(inWarmupStage && !g_ca)
		game_starttime = cvar("g_start_delay");

	sv_pitch_min = cvar("sv_pitch_min");
	sv_pitch_max = cvar("sv_pitch_max");
	sv_pitch_fixyaw = cvar("sv_pitch_fixyaw");

	sv_accuracy_data_share = boolean(cvar("sv_accuracy_data_share"));

	readplayerstartcvars();
}

/*
// TODO sound pack system
string soundpack;

string precache_sound_builtin (string s) = #19;
void(entity e, float chan, string samp, float vol, float atten) sound_builtin = #8;
string precache_sound(string s)
{
	return precache_sound_builtin(strcat(soundpack, s));
}
void play2(entity e, string filename)
{
	stuffcmd(e, strcat("play2 ", soundpack, filename, "\n"));
}
void sound(entity e, float chan, string samp, float vol, float atten)
{
	sound_builtin(e, chan, strcat(soundpack, samp), vol, atten);
}
*/

// Sound functions
string precache_sound (string s) = #19;
void(entity e, float chan, string samp, float vol, float atten) sound_builtin = #8;
float precache_sound_index (string s) = #19;

#define SND_VOLUME      1
#define SND_ATTENUATION 2
#define SND_LARGEENTITY 8
#define SND_LARGESOUND  16

float sound_allowed(float dest, entity e)
{
    // sounds from world may always pass
    for (;;)
    {
        if (e.classname == "body")
            e = e.enemy;
        if (e.owner && e.owner != e)
            e = e.owner;
        else
            break;
    }
    // sounds to self may always pass
    if (dest == MSG_ONE)
        if (e == msg_entity)
            return TRUE;
    // sounds by players can be removed
    if (cvar("bot_sound_monopoly"))
        if (clienttype(e) == CLIENTTYPE_REAL)
            return FALSE;
    // anything else may pass
    return TRUE;
}

void sound(entity e, float chan, string samp, float vol, float atten)
{
    if (!sound_allowed(MSG_BROADCAST, e))
        return;
    sound_builtin(e, chan, samp, vol, atten);
}
void soundtoat(float dest, entity e, vector o, float chan, string samp, float vol, float atten)
{
    float entno, idx;

    if (!sound_allowed(dest, e))
        return;

    entno = num_for_edict(e);
    idx = precache_sound_index(samp);

    float sflags;
    sflags = 0;

    atten = floor(atten * 64);
    vol = floor(vol * 255);

    if (vol != 255)
        sflags |= SND_VOLUME;
    if (atten != 64)
        sflags |= SND_ATTENUATION;
    if (entno >= 8192)
        sflags |= SND_LARGEENTITY;
    if (idx >= 256)
        sflags |= SND_LARGESOUND;

    WriteByte(dest, SVC_SOUND);
    WriteByte(dest, sflags);
    if (sflags & SND_VOLUME)
        WriteByte(dest, vol);
    if (sflags & SND_ATTENUATION)
        WriteByte(dest, atten);
    if (sflags & SND_LARGEENTITY)
    {
        WriteShort(dest, entno);
        WriteByte(dest, chan);
    }
    else
    {
        WriteShort(dest, entno * 8 + chan);
    }
    if (sflags & SND_LARGESOUND)
        WriteShort(dest, idx);
    else
        WriteByte(dest, idx);

    WriteCoord(dest, o_x);
    WriteCoord(dest, o_y);
    WriteCoord(dest, o_z);
}
void soundto(float dest, entity e, float chan, string samp, float vol, float atten)
{
    vector o;

    if (!sound_allowed(dest, e))
        return;

    o = e.origin + 0.5 * (e.mins + e.maxs);
    soundtoat(dest, e, o, chan, samp, vol, atten);
}
void soundat(entity e, vector o, float chan, string samp, float vol, float atten)
{
    soundtoat(MSG_BROADCAST, e, o, chan, samp, vol, atten);
}
void stopsoundto(float dest, entity e, float chan)
{
    float entno;

    if (!sound_allowed(dest, e))
        return;

    entno = num_for_edict(e);

    if (entno >= 8192)
    {
        float idx, sflags;
        idx = precache_sound_index("misc/null.wav");
        sflags = SND_LARGEENTITY;
        if (idx >= 256)
            sflags |= SND_LARGESOUND;
        WriteByte(dest, SVC_SOUND);
        WriteByte(dest, sflags);
        WriteShort(dest, entno);
        WriteByte(dest, chan);
        if (sflags & SND_LARGESOUND)
            WriteShort(dest, idx);
        else
            WriteByte(dest, idx);
        WriteCoord(dest, e.origin_x);
        WriteCoord(dest, e.origin_y);
        WriteCoord(dest, e.origin_z);
    }
    else
    {
        WriteByte(dest, SVC_STOPSOUND);
        WriteShort(dest, entno * 8 + chan);
    }
}
void stopsound(entity e, float chan)
{
    if (!sound_allowed(MSG_BROADCAST, e))
        return;

    stopsoundto(MSG_BROADCAST, e, chan); // unreliable, gets there fast
    stopsoundto(MSG_ALL, e, chan); // in case of packet loss
}

void play2(entity e, string filename)
{
    //stuffcmd(e, strcat("play2 ", filename, "\n"));
    msg_entity = e;
    soundtoat(MSG_ONE, world, '0 0 0', CHAN_AUTO, filename, VOL_BASE, ATTN_NONE);
}

// use this one if you might be causing spam (e.g. from touch functions that might get called more than once per frame)
.float spamtime;
float spamsound(entity e, float chan, string samp, float vol, float atten)
{
    if (!sound_allowed(MSG_BROADCAST, e))
        return FALSE;

    if (time > e.spamtime)
    {
        e.spamtime = time;
        sound(e, chan, samp, vol, atten);
        return TRUE;
    }
    return FALSE;
}

void play2team(float t, string filename)
{
    local entity head;

    if (cvar("bot_sound_monopoly"))
        return;

    FOR_EACH_REALPLAYER(head)
    {
        if (head.team == t)
            play2(head, filename);
    }
}

void play2all(string samp)
{
    if (cvar("bot_sound_monopoly"))
        return;

    sound(world, CHAN_AUTO, samp, VOL_BASE, ATTN_NONE);
}

void PrecachePlayerSounds(string f);
void precache_all_models(string pattern)
{
    float globhandle, i, n;
    string f;

    globhandle = search_begin(pattern, TRUE, FALSE);
    if (globhandle < 0)
        return;
    n = search_getsize(globhandle);
    for (i = 0; i < n; ++i)
    {
		//print(search_getfilename(globhandle, i), "\n");
		f = search_getfilename(globhandle, i);
		if(sv_loddistance1)
			precache_model(f);
		if(substring(f, -9,5) == "_lod1")
			continue;
		if(substring(f, -9,5) == "_lod2")
			continue;
		if(!sv_loddistance1)
			precache_model(f);
		PrecachePlayerSounds(strcat(f, ".sounds"));
    }
    search_end(globhandle);
}

void precache()
{
    // gamemode related things
    precache_model ("models/misc/chatbubble.spr");
    precache_model ("models/misc/teambubble.spr");
    if (g_runematch)
    {
        precache_model ("models/runematch/curse.mdl");
        precache_model ("models/runematch/rune.mdl");
    }

#ifdef TTURRETS_ENABLED
    if (cvar("g_turrets"))
        turrets_precash();
#endif

    // Precache all player models if desired
    if (cvar("sv_precacheplayermodels"))
    {
        PrecachePlayerSounds("sound/player/default.sounds");
        precache_all_models("models/player/*.zym");
        precache_all_models("models/player/*.dpm");
        precache_all_models("models/player/*.md3");
        precache_all_models("models/player/*.psk");
        //precache_model("models/player/carni.zym");
        //precache_model("models/player/crash.zym");
        //precache_model("models/player/grunt.zym");
        //precache_model("models/player/headhunter.zym");
        //precache_model("models/player/insurrectionist.zym");
        //precache_model("models/player/jeandarc.zym");
        //precache_model("models/player/lurk.zym");
        //precache_model("models/player/lycanthrope.zym");
        //precache_model("models/player/marine.zym");
        //precache_model("models/player/nexus.zym");
        //precache_model("models/player/pyria.zym");
        //precache_model("models/player/shock.zym");
        //precache_model("models/player/skadi.zym");
        //precache_model("models/player/specop.zym");
        //precache_model("models/player/visitant.zym");
    }

    if (cvar("sv_defaultcharacter"))
    {
        string s;
        s = cvar_string("sv_defaultplayermodel_red");
        if (s != "")
        {
            precache_model(s);
            PrecachePlayerSounds(strcat(s, ".sounds"));
        }
        s = cvar_string("sv_defaultplayermodel_blue");
        if (s != "")
        {
            precache_model(s);
            PrecachePlayerSounds(strcat(s, ".sounds"));
        }
        s = cvar_string("sv_defaultplayermodel_yellow");
        if (s != "")
        {
            precache_model(s);
            PrecachePlayerSounds(strcat(s, ".sounds"));
        }
        s = cvar_string("sv_defaultplayermodel_pink");
        if (s != "")
        {
            precache_model(s);
            PrecachePlayerSounds(strcat(s, ".sounds"));
        }
        s = cvar_string("sv_defaultplayermodel");
        if (s != "")
        {
            precache_model(s);
            PrecachePlayerSounds(strcat(s, ".sounds"));
        }
    }

    if (g_footsteps)
    {
        PrecacheGlobalSound((globalsound_step = "misc/footstep0 6"));
        PrecacheGlobalSound((globalsound_metalstep = "misc/metalfootstep0 6"));
    }

    // gore and miscellaneous sounds
    //precache_sound ("misc/h2ohit.wav");
    precache_model ("models/hook.md3");
    precache_sound ("misc/armorimpact.wav");
    precache_sound ("misc/bodyimpact1.wav");
    precache_sound ("misc/bodyimpact2.wav");
    precache_sound ("misc/gib.wav");
    precache_sound ("misc/gib_splat01.wav");
    precache_sound ("misc/gib_splat02.wav");
    precache_sound ("misc/gib_splat03.wav");
    precache_sound ("misc/gib_splat04.wav");
    precache_sound ("misc/hit.wav");
	precache_sound ("misc/typehit.wav");
    PrecacheGlobalSound((globalsound_fall = "misc/hitground 4"));
    PrecacheGlobalSound((globalsound_metalfall = "misc/metalhitground 4"));
    precache_sound ("misc/null.wav");
    precache_sound ("misc/spawn.wav");
    precache_sound ("misc/talk.wav");
    precache_sound ("misc/teleport.wav");
    precache_sound ("misc/poweroff.wav");
    precache_sound ("player/lava.wav");
    precache_sound ("player/slime.wav");

    if (g_jetpack)
        precache_sound ("misc/jetpack_fly.wav");

    precache_model ("models/sprites/0.spr32");
    precache_model ("models/sprites/1.spr32");
    precache_model ("models/sprites/2.spr32");
    precache_model ("models/sprites/3.spr32");
    precache_model ("models/sprites/4.spr32");
    precache_model ("models/sprites/5.spr32");
    precache_model ("models/sprites/6.spr32");
    precache_model ("models/sprites/7.spr32");
    precache_model ("models/sprites/8.spr32");
    precache_model ("models/sprites/9.spr32");
    precache_model ("models/sprites/10.spr32");

    // common weapon precaches
    precache_sound ("weapons/weapon_switch.wav");
    precache_sound ("weapons/weaponpickup.wav");
    precache_sound ("weapons/unavailable.wav");
    if (g_grappling_hook)
    {
        precache_sound ("weapons/hook_fire.wav"); // hook
        precache_sound ("weapons/hook_impact.wav"); // hook
    }

    if (cvar("sv_precacheweapons") || g_nixnex)
    {
        //precache weapon models/sounds
        local float wep;
        wep = WEP_FIRST;
        while (wep <= WEP_LAST)
        {
            weapon_action(wep, WR_PRECACHE);
            wep = wep + 1;
        }
    }

    precache_model("models/elaser.mdl");
    precache_model("models/laser.mdl");
    precache_model("models/ebomb.mdl");

#if 0
    // Disabled this code because it simply does not work (e.g. ignores bgmvolume, overlaps with "cd loop" controlled tracks).

    if (!self.noise && self.music) // quake 3 uses the music field
        self.noise = self.music;

    // plays music for the level if there is any
    if (self.noise)
    {
        precache_sound (self.noise);
        ambientsound ('0 0 0', self.noise, VOL_BASE, ATTN_NONE);
    }
#endif
}

// sorry, but using \ in macros breaks line numbers
#define WRITESPECTATABLE_MSG_ONE_VARNAME(varname,statement) entity varname; varname = msg_entity; FOR_EACH_REALCLIENT(msg_entity) if(msg_entity == varname || (msg_entity.classname == STR_SPECTATOR && msg_entity.enemy == varname)) statement msg_entity = varname
#define WRITESPECTATABLE_MSG_ONE(statement) WRITESPECTATABLE_MSG_ONE_VARNAME(oldmsg_entity, statement)
#define WRITESPECTATABLE(msg,statement) if(msg == MSG_ONE) { WRITESPECTATABLE_MSG_ONE(statement); } else statement float WRITESPECTATABLE_workaround = 0

// WARNING: this kills the trace globals
#define EXACTTRIGGER_TOUCH if(WarpZoneLib_ExactTrigger_Touch()) return
#define EXACTTRIGGER_INIT  WarpZoneLib_ExactTrigger_Init()

#define INITPRIO_FIRST              0
#define INITPRIO_GAMETYPE           0
#define INITPRIO_GAMETYPE_FALLBACK  1
#define INITPRIO_CVARS              5
#define INITPRIO_FINDTARGET        10
#define INITPRIO_DROPTOFLOOR       20
#define INITPRIO_SETLOCATION       90
#define INITPRIO_LINKDOORS         91
#define INITPRIO_LAST              99

.void(void) initialize_entity;
.float initialize_entity_order;
.entity initialize_entity_next;
entity initialize_entity_first;

void make_safe_for_remove(entity e)
{
    if (e.initialize_entity)
    {
        entity ent, prev;
        for (ent = initialize_entity_first; ent; )
        {
            if ((ent == e) || ((ent.classname == "initialize_entity") && (ent.enemy == e)))
            {
                //print("make_safe_for_remove: getting rid of initializer ", etos(ent), "\n");
                // skip it in linked list
                if (prev)
                {
                    prev.initialize_entity_next = ent.initialize_entity_next;
                    ent = prev.initialize_entity_next;
                }
                else
                {
                    initialize_entity_first = ent.initialize_entity_next;
                    ent = initialize_entity_first;
                }
            }
            else
            {
                prev = ent;
                ent = ent.initialize_entity_next;
            }
        }
    }
}

void objerror(string s)
{
    make_safe_for_remove(self);
    objerror_builtin(s);
}

void remove_unsafely(entity e)
{
    remove_builtin(e);
}

void remove_safely(entity e)
{
    make_safe_for_remove(e);
    remove_builtin(e);
}

void InitializeEntity(entity e, void(void) func, float order)
{
    entity prev, cur;

    if (!e || e.initialize_entity)
    {
        // make a proxy initializer entity
        entity e_old;
        e_old = e;
        e = spawn();
        e.classname = "initialize_entity";
        e.enemy = e_old;
    }

    e.initialize_entity = func;
    e.initialize_entity_order = order;

    cur = initialize_entity_first;
    for (;;)
    {
        if (!cur || cur.initialize_entity_order > order)
        {
            // insert between prev and cur
            if (prev)
                prev.initialize_entity_next = e;
            else
                initialize_entity_first = e;
            e.initialize_entity_next = cur;
            return;
        }
        prev = cur;
        cur = cur.initialize_entity_next;
    }
}
void InitializeEntitiesRun()
{
    entity startoflist;
    startoflist = initialize_entity_first;
    initialize_entity_first = world;
    for (self = startoflist; self; )
    {
        entity e;
        var void(void) func;
        e = self.initialize_entity_next;
        func = self.initialize_entity;
        self.initialize_entity_order = 0;
        self.initialize_entity = func_null;
        self.initialize_entity_next = world;
        if (self.classname == "initialize_entity")
        {
            entity e_old;
            e_old = self.enemy;
            remove_builtin(self);
            self = e_old;
        }
        //dprint("Delayed initialization: ", self.classname, "\n");
        func();
        self = e;
    }
}

.float uncustomizeentityforclient_set;
.void(void) uncustomizeentityforclient;
void(void) SUB_Nullpointer = #0;
void UncustomizeEntitiesRun()
{
    entity oldself;
    oldself = self;
    for (self = world; (self = findfloat(self, uncustomizeentityforclient_set, 1)); )
        self.uncustomizeentityforclient();
    self = oldself;
}
void SetCustomizer(entity e, float(void) customizer, void(void) uncustomizer)
{
    e.customizeentityforclient = customizer;
    e.uncustomizeentityforclient = uncustomizer;
    e.uncustomizeentityforclient_set = (uncustomizer != SUB_Nullpointer);
}

.float nottargeted;
#define IFTARGETED if(!self.nottargeted && self.targetname != "")

void() SUB_Remove;
void Net_LinkEntity(entity e, float docull, float dt, float(entity, float) sendfunc)
{
    vector mi, ma;

    if (e.classname == "")
        e.classname = "net_linked";

    if (e.model == "" || self.modelindex == 0)
    {
        mi = e.mins;
        ma = e.maxs;
        setmodel(e, "null");
        setsize(e, mi, ma);
    }

    e.SendEntity = sendfunc;
    e.SendFlags = 0xFFFFFF;

    if (!docull)
        e.effects |= EF_NODEPTHTEST;

    if (dt)
    {
        e.nextthink = time + dt;
        e.think = SUB_Remove;
    }
}

void adaptor_think2touch()
{
    entity o;
    o = other;
    other = world;
    self.touch();
    other = o;
}

void adaptor_think2use()
{
    entity o, a;
    o = other;
    a = activator;
    activator = world;
    other = world;
    self.use();
    other = o;
    activator = a;
}

// deferred dropping
void DropToFloor_Handler()
{
    droptofloor_builtin();
    self.dropped_origin = self.origin;
}

void droptofloor()
{
    InitializeEntity(self, DropToFloor_Handler, INITPRIO_DROPTOFLOOR);
}



float trace_hits_box_a0, trace_hits_box_a1;

float trace_hits_box_1d(float end, float thmi, float thma)
{
    if (end == 0)
    {
        // just check if x is in range
        if (0 < thmi)
            return FALSE;
        if (0 > thma)
            return FALSE;
    }
    else
    {
        // do the trace with respect to x
        // 0 -> end has to stay in thmi -> thma
        trace_hits_box_a0 = max(trace_hits_box_a0, min(thmi / end, thma / end));
        trace_hits_box_a1 = min(trace_hits_box_a1, max(thmi / end, thma / end));
        if (trace_hits_box_a0 > trace_hits_box_a1)
            return FALSE;
    }
    return TRUE;
}

float trace_hits_box(vector start, vector end, vector thmi, vector thma)
{
    end -= start;
    thmi -= start;
    thma -= start;
    // now it is a trace from 0 to end

    trace_hits_box_a0 = 0;
    trace_hits_box_a1 = 1;

    if (!trace_hits_box_1d(end_x, thmi_x, thma_x))
        return FALSE;
    if (!trace_hits_box_1d(end_y, thmi_y, thma_y))
        return FALSE;
    if (!trace_hits_box_1d(end_z, thmi_z, thma_z))
        return FALSE;

    return TRUE;
}

float tracebox_hits_box(vector start, vector mi, vector ma, vector end, vector thmi, vector thma)
{
    return trace_hits_box(start, end, thmi - ma, thma - mi);
}

float SUB_NoImpactCheck()
{
	// zero hitcontents = this is not the real impact, but either the
	// mirror-impact of something hitting the projectile instead of the
	// projectile hitting the something, or a touchareagrid one. Neither of
	// these stop the projectile from moving, so...
	if(trace_dphitcontents == 0)
	{
		dprint("A hit happened with zero hit contents... DEBUG THIS, this should never happen for projectiles! Projectile will self-destruct.\n");
		checkclient();
	}
    if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
        return 1;
    if (other == world && self.size != '0 0 0')
    {
        vector tic;
        tic = self.velocity * sys_frametime;
        tic = tic + normalize(tic) * vlen(self.maxs - self.mins);
        traceline(self.origin - tic, self.origin + tic, MOVE_NORMAL, self);
        if (trace_fraction >= 1)
        {
            dprint("Odd... did not hit...?\n");
        }
        else if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
        {
            dprint("Detected and prevented the sky-grapple bug.\n");
            return 1;
        }
    }

    return 0;
}

#define SUB_OwnerCheck() (other && (other == self.owner))

float WarpZone_Projectile_Touch_ImpactFilter_Callback()
{
	if(SUB_OwnerCheck())
		return TRUE;
	if(SUB_NoImpactCheck())
	{
		remove(self);
		return TRUE;
	}
	if(trace_ent && trace_ent.solid > SOLID_TRIGGER)
		UpdateCSQCProjectileNextFrame(self);
	return FALSE;
}
#define PROJECTILE_TOUCH if(WarpZone_Projectile_Touch()) return

float MAX_IPBAN_URIS = 16;

float URI_GET_DISCARD   = 0;
float URI_GET_IPBAN     = 1;
float URI_GET_IPBAN_END = 16;

void URI_Get_Callback(float id, float status, string data)
{
    dprint("Received HTTP request data for id ", ftos(id), "; status is ", ftos(status), "\nData is:\n");
    dprint(data);
    dprint("\nEnd of data.\n");

    if (id == URI_GET_DISCARD)
    {
        // discard
    }
    else if (id >= URI_GET_IPBAN && id <= URI_GET_IPBAN_END)
    {
        // online ban list
        OnlineBanList_URI_Get_Callback(id, status, data);
    }
    else
    {
        print("Received HTTP request data for an invalid id ", ftos(id), ".\n");
    }
}

void print_to(entity e, string s)
{
    if (e)
        sprint(e, strcat(s, "\n"));
    else
        print(s, "\n");
}

string getrecords(float page) // 50 records per page
{
    float rec;
    string h;
    float r;
    float i;
    string s;

    rec = 0;

    s = "";

    if (g_ctf)
    {
        for (i = page * 200; i < MapInfo_count && i < page * 200 + 200; ++i)
        {
            if (MapInfo_Get_ByID(i))
            {
                r = stof(db_get(ServerProgsDB, strcat(MapInfo_Map_bspname, "/captimerecord/time")));
                if (r == 0)
                    continue;
                h = db_get(ServerProgsDB, strcat(MapInfo_Map_bspname, "/captimerecord/netname"));
                s = strcat(s, strpad(32, MapInfo_Map_bspname), " ", strpad(-6, ftos_decimals(r, 2)), " ", h, "\n");
                ++rec;
            }
        }
    }

    if (g_race)
    {
        for (i = page * 200; i < MapInfo_count && i < page * 200 + 200; ++i)
        {
            if (MapInfo_Get_ByID(i))
            {
                r = stof(db_get(ServerProgsDB, strcat(MapInfo_Map_bspname, RACE_RECORD, "time")));
                if (r == 0)
                    continue;
                h = db_get(ServerProgsDB, strcat(MapInfo_Map_bspname, RACE_RECORD, "netname"));
                s = strcat(s, strpad(32, MapInfo_Map_bspname), " ", strpad(-8, TIME_ENCODED_TOSTRING(r)), " ", h, "\n");
                ++rec;
            }
        }
    }

    if (g_cts)
    {
        for (i = page * 200; i < MapInfo_count && i < page * 200 + 200; ++i)
        {
            if (MapInfo_Get_ByID(i))
            {
                r = stof(db_get(ServerProgsDB, strcat(MapInfo_Map_bspname, CTS_RECORD, "time")));
                if (r == 0)
                    continue;
                h = db_get(ServerProgsDB, strcat(MapInfo_Map_bspname, CTS_RECORD, "netname"));
                s = strcat(s, strpad(32, MapInfo_Map_bspname), " ", strpad(-8, TIME_ENCODED_TOSTRING(r)), " ", h, "\n");
                ++rec;
            }
        }
    }

    MapInfo_ClearTemps();

    if (s == "" && page == 0)
        return "No records are available on this server.\n";
    else
        return s;
}

string getrankings()
{
    string n;
    float t;
    float i;
    string s;
    string p;
    string map;

    s = "";

    map = GetMapname();

    for (i = 1; i <= RANKINGS_CNT; ++i)
    {
        t = race_GetTime(i);
	if (t == 0)
	    continue;
	n = race_GetName(i);
	p = race_PlaceName(i);
        s = strcat(s, strpad(8, p), " ", strpad(-8, TIME_ENCODED_TOSTRING(t)), " ", n, "\n");
    }

    MapInfo_ClearTemps();

    if (s == "")
        return strcat("No records are available for the map: ", map, "\n");
    else
        return strcat("Records for ", map, ":\n", s);
}

float MoveToRandomMapLocation(entity e, float goodcontents, float badcontents, float badsurfaceflags, float attempts, float maxaboveground, float minviewdistance)
{
    float m, i;
    vector start, org, delta, end, enddown, mstart;

    m = e.dphitcontentsmask;
    e.dphitcontentsmask = goodcontents | badcontents;

    org = world.mins;
    delta = world.maxs - world.mins;

    for (i = 0; i < attempts; ++i)
    {
        start_x = org_x + random() * delta_x;
        start_y = org_y + random() * delta_y;
        start_z = org_z + random() * delta_z;

        // rule 1: start inside world bounds, and outside
        // solid, and don't start from somewhere where you can
        // fall down to evil
        tracebox(start, e.mins, e.maxs, start - '0 0 1' * delta_z, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        if (trace_startsolid)
            continue;
        if (trace_dphitcontents & badcontents)
            continue;
        if (trace_dphitq3surfaceflags & badsurfaceflags)
            continue;

        // rule 2: if we are too high, lower the point
        if (trace_fraction * delta_z > maxaboveground)
            start = trace_endpos + '0 0 1' * maxaboveground;
        enddown = trace_endpos;

        // rule 3: make sure we aren't outside the map. This only works
        // for somewhat well formed maps. A good rule of thumb is that
        // the map should have a convex outside hull.
        // these can be traceLINES as we already verified the starting box
        mstart = start + 0.5 * (e.mins + e.maxs);
        traceline(mstart, mstart + '1 0 0' * delta_x, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        traceline(mstart, mstart - '1 0 0' * delta_x, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        traceline(mstart, mstart + '0 1 0' * delta_y, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        traceline(mstart, mstart - '0 1 0' * delta_y, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        traceline(mstart, mstart + '0 0 1' * delta_z, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;

        // find a random vector to "look at"
        end_x = org_x + random() * delta_x;
        end_y = org_y + random() * delta_y;
        end_z = org_z + random() * delta_z;
        end = start + normalize(end - start) * vlen(delta);

        // rule 4: start TO end must not be too short
        tracebox(start, e.mins, e.maxs, end, MOVE_NORMAL, e);
        if (trace_startsolid)
            continue;
        if (trace_fraction < minviewdistance / vlen(delta))
            continue;

        // rule 5: don't want to look at sky
        if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_SKY)
            continue;

        // rule 6: we must not end up in trigger_hurt
        if (tracebox_hits_trigger_hurt(start, e.mins, e.maxs, enddown))
        {
            dprint("trigger_hurt! ouch! and nothing else could find it!\n");
            continue;
        }

        break;
    }

    e.dphitcontentsmask = m;

    if (i < attempts)
    {
        setorigin(e, start);
        e.angles = vectoangles(end - start);
        dprint("Needed ", ftos(i + 1), " attempts\n");
        return TRUE;
    }
    else
        return FALSE;
}

float zcurveparticles_effectno;
vector zcurveparticles_start;
float zcurveparticles_spd;

void endzcurveparticles()
{
	if(zcurveparticles_effectno)
	{
		// terminator
		WriteShort(MSG_BROADCAST, zcurveparticles_spd | 0x8000);
	}
	zcurveparticles_effectno = 0;
}

void zcurveparticles(float effectno, vector start, vector end, float end_dz, float spd)
{
	spd = bound(0, floor(spd / 16), 32767);
	if(effectno != zcurveparticles_effectno || start != zcurveparticles_start)
	{
		endzcurveparticles();
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_CSQC_ZCURVEPARTICLES);
		WriteShort(MSG_BROADCAST, effectno);
		WriteCoord(MSG_BROADCAST, start_x);
		WriteCoord(MSG_BROADCAST, start_y);
		WriteCoord(MSG_BROADCAST, start_z);
		zcurveparticles_effectno = effectno;
		zcurveparticles_start = start;
	}
	else
		WriteShort(MSG_BROADCAST, zcurveparticles_spd);
	WriteCoord(MSG_BROADCAST, end_x);
	WriteCoord(MSG_BROADCAST, end_y);
	WriteCoord(MSG_BROADCAST, end_z);
	WriteCoord(MSG_BROADCAST, end_dz);
	zcurveparticles_spd = spd;
}

void zcurveparticles_from_tracetoss(float effectno, vector start, vector end, vector vel)
{
	float end_dz;
	vector vecxy, velxy;

	vecxy = end - start;
	vecxy_z = 0;
	velxy = vel;
	velxy_z = 0;

	if (vlen(velxy) < 0.000001 * fabs(vel_z))
	{
		endzcurveparticles();
		trailparticles(world, effectno, start, end);
		return;
	}

	end_dz = vlen(vecxy) / vlen(velxy) * vel_z - (end_z - start_z);
	zcurveparticles(effectno, start, end, end_dz, vlen(vel));
}

string GetGametype(); // g_world.qc
void write_recordmarker(entity pl, float tstart, float dt)
{
    GameLogEcho(strcat(":recordset:", ftos(pl.playerid), ":", ftos(dt)));

    // also write a marker into demo files for demotc-race-record-extractor to find
    stuffcmd(pl,
             strcat(
                 strcat("//", strconv(2, 0, 0, GetGametype()), " RECORD SET ", TIME_ENCODED_TOSTRING(TIME_ENCODE(dt))),
                 " ", ftos(tstart), " ", ftos(dt), "\n"));
}

vector shotorg_adjustfromclient(vector vecs, float y_is_right, float allowcenter)
{
	switch(self.owner.cvar_cl_gunalign)
	{
		case 1: // right
			break;

		case 2: // left
			vecs_y = -vecs_y;
			break;

		default:
		case 3:
			if(allowcenter) // 2: allow center handedness
			{
				// center
				vecs_y = 0;
				vecs_z -= 4;
			}
			else
			{
				// right
			}
			break;

		case 4:
			if(allowcenter) // 2: allow center handedness
			{
				// center
				vecs_y = 0;
				vecs_z -= 4;
			}
			else
			{
				// left
				vecs_y = -vecs_y;
			}
			break;
	}
	return vecs;
}

vector shotorg_adjust(vector vecs, float y_is_right, float visual)
{
	string s;
	vector v;

	if (cvar("g_shootfromeye"))
	{
		if (visual)
		{
			vecs = shotorg_adjustfromclient(vecs, y_is_right, TRUE);
		}
		else
		{
			vecs_y = 0;
			vecs_z = 0;
		}
	}
	else if (cvar("g_shootfromcenter"))
	{
		if (visual)
		{
			vecs = shotorg_adjustfromclient(vecs, y_is_right, TRUE);
		}
		else
		{
			vecs_y = 0;
			vecs_z -= 4;
		}
	}
	else if ((s = cvar_string("g_shootfromfixedorigin")) != "")
	{
		v = stov(s);
		if (y_is_right)
			v_y = -v_y;
		if (v_x != 0)
			vecs_x = v_x;
		vecs_y = v_y;
		vecs_z = v_z;
	}
	else if (cvar("g_shootfromclient"))
	{
		vecs = shotorg_adjustfromclient(vecs, y_is_right, (cvar("g_shootfromclient") >= 2));
	}
	return vecs;
}



void attach_sameorigin(entity e, entity to, string tag)
{
    vector org, t_forward, t_left, t_up, e_forward, e_up;
    vector org0, ang0;
    float tagscale;

    ang0 = e.angles;
    org0 = e.origin;

    org = e.origin - gettaginfo(to, gettagindex(to, tag));
    tagscale = pow(vlen(v_forward), -2); // undo a scale on the tag
    t_forward = v_forward * tagscale;
    t_left = v_right * -tagscale;
    t_up = v_up * tagscale;

    e.origin_x = org * t_forward;
    e.origin_y = org * t_left;
    e.origin_z = org * t_up;

    // current forward and up directions
    if (substring(e.model, 0, 1) == "*") // bmodels have their own rules
		e.angles = AnglesTransform_FromVAngles(e.angles);
	else
		e.angles = AnglesTransform_FromAngles(e.angles);
    fixedmakevectors(e.angles);

    // untransform forward, up!
    e_forward_x = v_forward * t_forward;
    e_forward_y = v_forward * t_left;
    e_forward_z = v_forward * t_up;
    e_up_x = v_up * t_forward;
    e_up_y = v_up * t_left;
    e_up_z = v_up * t_up;

    e.angles = fixedvectoangles2(e_forward, e_up);
    if (substring(e.model, 0, 1) == "*") // bmodels have their own rules
		e.angles = AnglesTransform_ToVAngles(e.angles);
	else
		e.angles = AnglesTransform_ToAngles(e.angles);

    setattachment(e, to, tag);
    setorigin(e, e.origin);
}

void detach_sameorigin(entity e)
{
    vector org;
    org = gettaginfo(e, 0);
    e.angles = fixedvectoangles2(v_forward, v_up);
    if (substring(e.model, 0, 1) == "*") // bmodels have their own rules
		e.angles = AnglesTransform_ToVAngles(e.angles);
	else
		e.angles = AnglesTransform_ToAngles(e.angles);
    setorigin(e, org);
    setattachment(e, world, "");
    setorigin(e, e.origin);
}

void follow_sameorigin(entity e, entity to)
{
    e.movetype = MOVETYPE_FOLLOW; // make the hole follow
    e.aiment = to; // make the hole follow bmodel
    e.punchangle = to.angles; // the original angles of bmodel
    e.view_ofs = e.origin - to.origin; // relative origin
    e.v_angle = e.angles - to.angles; // relative angles
}

void unfollow_sameorigin(entity e)
{
    e.movetype = MOVETYPE_NONE;
}

entity gettaginfo_relative_ent;
vector gettaginfo_relative(entity e, float tag)
{
    if (!gettaginfo_relative_ent)
    {
        gettaginfo_relative_ent = spawn();
        gettaginfo_relative_ent.effects = EF_NODRAW;
    }
    gettaginfo_relative_ent.model = e.model;
    gettaginfo_relative_ent.modelindex = e.modelindex;
    gettaginfo_relative_ent.frame = e.frame;
    return gettaginfo(gettaginfo_relative_ent, tag);
}

void SoundEntity_StartSound(entity pl, float chan, string samp, float vol, float attn)
{
    float p;
    p = pow(2, chan);
    if (pl.soundentity.cnt & p)
        return;
    soundtoat(MSG_ALL, pl.soundentity, gettaginfo(pl.soundentity, 0), chan, samp, vol, attn);
    pl.soundentity.cnt |= p;
}

void SoundEntity_StopSound(entity pl, float chan)
{
    float p;
    p = pow(2, chan);
    if (pl.soundentity.cnt & p)
    {
        stopsoundto(MSG_ALL, pl.soundentity, chan);
        pl.soundentity.cnt &~= p;
    }
}

void SoundEntity_Attach(entity pl)
{
    pl.soundentity = spawn();
    pl.soundentity.classname = "soundentity";
    pl.soundentity.owner = pl;
    setattachment(pl.soundentity, pl, "");
    setmodel(pl.soundentity, "null");
}

void SoundEntity_Detach(entity pl)
{
    float i;
    for (i = 0; i <= 7; ++i)
        SoundEntity_StopSound(pl, i);
}


float ParseCommandPlayerSlotTarget_firsttoken;
entity GetCommandPlayerSlotTargetFromTokenizedCommand(float tokens, float idx) // idx = start index
{
    string s;
    entity e, head;
    float n;

    s = string_null;

    ParseCommandPlayerSlotTarget_firsttoken = -1;

    if (tokens > idx)
    {
        if (substring(argv(idx), 0, 1) == "#")
        {
            s = substring(argv(idx), 1, -1);
            ++idx;
            if (s == "")
                if (tokens > idx)
                {
                    s = argv(idx);
                    ++idx;
                }
			ParseCommandPlayerSlotTarget_firsttoken = idx;
            if (s == ftos(stof(s)))
            {
                e = edict_num(stof(s));
                if (e.flags & FL_CLIENT)
                    return e;
            }
        }
        else
        {
            // it must be a nick name
            s = argv(idx);
            ++idx;
			ParseCommandPlayerSlotTarget_firsttoken = idx;

            n = 0;
            FOR_EACH_CLIENT(head)
            if (head.netname == s)
            {
                e = head;
                ++n;
            }
            if (n == 1)
                return e;

            s = strdecolorize(s);
            n = 0;
            FOR_EACH_CLIENT(head)
            if (strdecolorize(head.netname) == s)
            {
                e = head;
                ++n;
            }
            if (n == 1)
                return e;
        }
    }

    return world;
}

.float scale2;

float modeleffect_SendEntity(entity to, float sf)
{
	float f;
	WriteByte(MSG_ENTITY, ENT_CLIENT_MODELEFFECT);

	f = 0;
	if(self.velocity != '0 0 0')
		f |= 1;
	if(self.angles != '0 0 0')
		f |= 2;
	if(self.avelocity != '0 0 0')
		f |= 4;

	WriteByte(MSG_ENTITY, f);
	WriteShort(MSG_ENTITY, self.modelindex);
	WriteByte(MSG_ENTITY, self.skin);
	WriteByte(MSG_ENTITY, self.frame);
	WriteCoord(MSG_ENTITY, self.origin_x);
	WriteCoord(MSG_ENTITY, self.origin_y);
	WriteCoord(MSG_ENTITY, self.origin_z);
	if(f & 1)
	{
		WriteCoord(MSG_ENTITY, self.velocity_x);
		WriteCoord(MSG_ENTITY, self.velocity_y);
		WriteCoord(MSG_ENTITY, self.velocity_z);
	}
	if(f & 2)
	{
		WriteCoord(MSG_ENTITY, self.angles_x);
		WriteCoord(MSG_ENTITY, self.angles_y);
		WriteCoord(MSG_ENTITY, self.angles_z);
	}
	if(f & 4)
	{
		WriteCoord(MSG_ENTITY, self.avelocity_x);
		WriteCoord(MSG_ENTITY, self.avelocity_y);
		WriteCoord(MSG_ENTITY, self.avelocity_z);
	}
	WriteShort(MSG_ENTITY, self.scale * 256.0);
	WriteShort(MSG_ENTITY, self.scale2 * 256.0);
	WriteByte(MSG_ENTITY, self.teleport_time * 100.0);
	WriteByte(MSG_ENTITY, self.fade_time * 100.0);
	WriteByte(MSG_ENTITY, self.alpha * 255.0);

	return TRUE;
}

void modeleffect_spawn(string m, float s, float f, vector o, vector v, vector ang, vector angv, float s0, float s2, float a, float t1, float t2)
{
	entity e;
	float sz;
	e = spawn();
	e.classname = "modeleffect";
	setmodel(e, m);
	e.frame = f;
	setorigin(e, o);
	e.velocity = v;
	e.angles = ang;
	e.avelocity = angv;
	e.alpha = a;
	e.teleport_time = t1;
	e.fade_time = t2;
	e.skin = s;
	if(s0 >= 0)
		e.scale = s0 / max6(-e.mins_x, -e.mins_y, -e.mins_z, e.maxs_x, e.maxs_y, e.maxs_z);
	else
		e.scale = -s0;
	if(s2 >= 0)
		e.scale2 = s2 / max6(-e.mins_x, -e.mins_y, -e.mins_z, e.maxs_x, e.maxs_y, e.maxs_z);
	else
		e.scale2 = -s2;
	sz = max(e.scale, e.scale2);
	setsize(e, e.mins * sz, e.maxs * sz);
	Net_LinkEntity(e, FALSE, 0.1, modeleffect_SendEntity);
}

void shockwave_spawn(string m, vector org, float sz, float t1, float t2)
{
	return modeleffect_spawn(m, 0, 0, org, '0 0 0', '0 0 0', '0 0 0', 0, sz, 1, t1, t2);
}

float randombit(float bits)
{
	if not(bits & (bits-1)) // this ONLY holds for powers of two!
		return bits;

	float n, f, b, r;

	r = random();
	b = 0;
	n = 0;

	for(f = 1; f <= bits; f *= 2)
	{
		if(bits & f)
		{
			++n;
			r *= n;
			if(r <= 1)
				b = f;
			else
				r = (r - 1) / (n - 1);
		}
	}

	return b;
}

float randombits(float bits, float k, float error_return)
{
	float r;
	r = 0;
	while(k > 0 && bits != r)
	{
		r += randombit(bits - r);
		--k;
	}
	if(error_return)
		if(k > 0)
			return -1; // all
	return r;
}

void randombit_test(float bits, float iter)
{
	while(iter > 0)
	{
		print(ftos(randombit(bits)), "\n");
		--iter;
	}
}

float ExponentialFalloff(float mindist, float maxdist, float halflifedist, float d)
{
	if(halflifedist > 0)
		return pow(0.5, (bound(mindist, d, maxdist) - mindist) / halflifedist);
	else if(halflifedist < 0)
		return pow(0.5, (bound(mindist, d, maxdist) - maxdist) / halflifedist);
	else
		return 1;
}




#ifdef RELEASE
#define cvar_string_normal cvar_string_builtin
#define cvar_normal cvar_builtin
#else
string cvar_string_normal(string n)
{
	if not(cvar_type(n) & 1)
		backtrace(strcat("Attempt to access undefined cvar: ", n));
	return cvar_string_builtin(n);
}

float cvar_normal(string n)
{
	return stof(cvar_string_normal(n));
}
#endif
#define cvar_set_normal cvar_set_builtin

void defer_think()
{
    entity oself;

    oself           = self;
    self            = self.owner;
    oself.think     = SUB_Remove;
    oself.nextthink = time;

    oself.use();
}

/*
    Execute func() after time + fdelay.
    self when func is executed = self when defer is called
*/
void defer(float fdelay, void() func)
{
    entity e;

    e           = spawn();
    e.owner     = self;
    e.use       = func;
    e.think     = defer_think;
    e.nextthink = time + fdelay;
}
