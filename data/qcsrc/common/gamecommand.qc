#define MAX_RPN_STACK 16
float rpn_db;
float rpn_error;
float rpn_sp;
string rpn_stack[MAX_RPN_STACK];
string rpn_pop() {
	if(rpn_sp > 0) {
		--rpn_sp;
		return rpn_stack[rpn_sp];
	} else {
		print("rpn: stack underflow\n");
		rpn_error = TRUE;
		return "";
	}
}
void rpn_push(string s) {
	if(rpn_sp < MAX_RPN_STACK) {
		rpn_stack[rpn_sp] = s;
		++rpn_sp;
	} else {
		print("rpn: stack overflow\n");
		rpn_error = TRUE;
	}
}
string rpn_get() {
	if(rpn_sp > 0) {
		return rpn_stack[rpn_sp - 1];
	} else {
		print("rpn: empty stack\n");
		rpn_error = TRUE;
		return "";
	}
}
void rpn_set(string s) {
	if(rpn_sp > 0) {
		rpn_stack[rpn_sp - 1] = s;
	} else {
		print("rpn: empty stack\n");
		rpn_error = TRUE;
	}
}
float rpn_getf() { return stof(rpn_get()); }
float rpn_popf() { return stof(rpn_pop()); }
void rpn_pushf(float f) { return rpn_push(ftos(f)); }
void rpn_setf(float f) { return rpn_set(ftos(f)); }

float mapvote_nextthink;
float mapvote_initialized;
float mapvote_keeptwotime;
float mapvote_timeout;
string mapvote_message;
string mapvote_screenshot_dir;

float mapvote_count;
float mapvote_count_real;
string mapvote_maps[MAPVOTE_COUNT];
float mapvote_maps_suggested[MAPVOTE_COUNT];
string mapvote_suggestions[MAPVOTE_COUNT];
float mapvote_suggestion_ptr;
float mapvote_maxlen;
float mapvote_voters;
float mapvote_votes[MAPVOTE_COUNT];
float mapvote_run;
float mapvote_detail;
float mapvote_abstain;
float mapvote_dirty;
.float mapvote;

void MapVote_ClearAllVotes()
{
	FOR_EACH_CLIENT(other)
		other.mapvote = 0;
}

string MapVote_Suggest(string m)
{
	float i;
	if(m == "")
		return "That's not how to use this command.";
	if(!cvar("g_maplist_votable_suggestions"))
		return "Suggestions are not accepted on this server.";
	if(mapvote_initialized)
		return "Can't suggest - voting is already in progress!";
	m = MapInfo_FixName(m);
	if(!m)
		return "The map you suggested is not available on this server.";
	if(!cvar("g_maplist_votable_override_mostrecent"))
		if(Map_IsRecent(m))
			return "This server does not allow for recent maps to be played again. Please be patient for some rounds.";

	if(!MapInfo_CheckMap(m))
		return "The map you suggested does not support the current game mode.";
	for(i = 0; i < mapvote_suggestion_ptr; ++i)
		if(mapvote_suggestions[i] == m)
			return "This map was already suggested.";
	if(mapvote_suggestion_ptr >= MAPVOTE_COUNT)
	{
		i = floor(random() * mapvote_suggestion_ptr);
	}
	else
	{
		i = mapvote_suggestion_ptr;
		mapvote_suggestion_ptr += 1;
	}
	if(mapvote_suggestions[i] != "")
		strunzone(mapvote_suggestions[i]);
	mapvote_suggestions[i] = strzone(m);
	if(cvar("sv_eventlog"))
		GameLogEcho(strcat(":vote:suggested:", m, ":", ftos(self.playerid)));
	return strcat("Suggestion of ", m, " accepted.");
}

void MapVote_AddVotable(string nextMap, float isSuggestion)
{
	float j;
	if(nextMap == "")
		return;
	for(j = 0; j < mapvote_count; ++j)
		if(mapvote_maps[j] == nextMap)
			return;
	if(strlen(nextMap) > mapvote_maxlen)
		mapvote_maxlen = strlen(nextMap);
	mapvote_maps[mapvote_count] = strzone(nextMap);
	mapvote_maps_suggested[mapvote_count] = isSuggestion;
	mapvote_count += 1;
}

void MapVote_SendData(float target);
void MapVote_Init()
{
	float i;
	float nmax, smax;

	MapVote_ClearAllVotes();

	mapvote_count = 0;
	mapvote_detail = !cvar("g_maplist_votable_nodetail");
	mapvote_abstain = cvar("g_maplist_votable_abstain");

	if(mapvote_abstain)
		nmax = min(MAPVOTE_COUNT - 1, cvar("g_maplist_votable"));
	else
		nmax = min(MAPVOTE_COUNT, cvar("g_maplist_votable"));
	smax = min3(nmax, cvar("g_maplist_votable_suggestions"), mapvote_suggestion_ptr);

	if(mapvote_suggestion_ptr)
		for(i = 0; i < 100 && mapvote_count < smax; ++i)
			MapVote_AddVotable(mapvote_suggestions[floor(random() * mapvote_suggestion_ptr)], TRUE);

	for(i = 0; i < 100 && mapvote_count < nmax; ++i)
		MapVote_AddVotable(GetNextMap(), FALSE);

	if(mapvote_count == 0)
	{
		bprint( "Maplist contains no single playable map!  Resetting it to default map list.\n" );
		cvar_set("g_maplist", MapInfo_ListAllowedMaps(0, MAPINFO_FLAG_HIDDEN));
		localcmd("\nmenu_cmd sync\n");
		for(i = 0; i < 100 && mapvote_count < nmax; ++i)
			MapVote_AddVotable(GetNextMap(), FALSE);
	}

	mapvote_count_real = mapvote_count;
	if(mapvote_abstain)
		MapVote_AddVotable("don't care", 0);

	//dprint("mapvote count is ", ftos(mapvote_count), "\n");

	mapvote_keeptwotime = time + cvar("g_maplist_votable_keeptwotime");
	mapvote_timeout = time + cvar("g_maplist_votable_timeout");
	if(mapvote_count_real < 3 || mapvote_keeptwotime <= time)
		mapvote_keeptwotime = 0;
	mapvote_message = "Choose a map and press its key!";

	mapvote_screenshot_dir = cvar_string("g_maplist_votable_screenshot_dir");
	if(mapvote_screenshot_dir == "")
		mapvote_screenshot_dir = "maps";
	mapvote_screenshot_dir = strzone(mapvote_screenshot_dir);

	if(!cvar("g_maplist_textonly"))
		MapVote_SendData(MSG_ALL);
}

void MapVote_SendPicture(float id)
{
	msg_entity = self;
	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	WriteByte(MSG_ONE, TE_CSQC_MAPVOTE);
	WriteByte(MSG_ONE, MAPVOTE_NET_PIC);
	WriteByte(MSG_ONE, id);
	WritePicture(MSG_ONE, strcat(mapvote_screenshot_dir, "/", mapvote_maps[id]), 3072);
}

float GameCommand_MapVote(string cmd)
{
	if(!intermission_running)
		return FALSE;
	if(!cvar("g_maplist_textonly"))
	{
		if(cmd == "mv_getpic")
		{
			MapVote_SendPicture(stof(argv(1)));
			return TRUE;
		}
	}

	return FALSE;
}

float MapVote_GetMapMask()
{
	float mask, i, power;
	mask = 0;
	for(i = 0, power = 1; i < mapvote_count; ++i, power *= 2)
		if(mapvote_maps[i] != "")
			mask |= power;
	return mask;
}

void MapVote_SendData(float targ)
{
	string mapfile, pakfile;
	float i, o;
	WriteByte(targ, SVC_TEMPENTITY);
	WriteByte(targ, TE_CSQC_CONFIG);
	WriteString(targ, "mv_screenshot_dir");
	WriteString(targ, mapvote_screenshot_dir);

	WriteByte(targ, SVC_TEMPENTITY);
	WriteByte(targ, TE_CSQC_MAPVOTE);
	WriteByte(targ, MAPVOTE_NET_INIT);

  	WriteByte(targ, mapvote_count);
  	WriteByte(targ, mapvote_abstain);
  	WriteByte(targ, mapvote_detail);
	WriteCoord(targ, mapvote_timeout);
 	if(mapvote_count <= 8)
 		WriteByte(targ, MapVote_GetMapMask());
 	else
 		WriteShort(targ, MapVote_GetMapMask());
 	for(i = 0; i < mapvote_count; ++i)
		if(mapvote_maps[i] != "")
		{
			WriteString(targ, mapvote_maps[i]);
			mapfile = strcat(mapvote_screenshot_dir, "/", mapvote_maps[i]);
			pakfile = whichpack(strcat(mapfile, ".tga"));
			if(pakfile == "")
				pakfile = whichpack(strcat(mapfile, ".jpg"));
			if(pakfile == "")
				pakfile = whichpack(strcat(mapfile, ".png"));
			print("pakfile is ", pakfile, "\n");
			for(o = strstr(pakfile, "/", 0)+1; o > 0; o = strstr(pakfile, "/", 0)+1)
				pakfile = substring(pakfile, o, 999);
			WriteString(targ, pakfile);
		}
}

void MapVote_UpdateData(float targ)
{
	float i;
	WriteByte(targ, SVC_TEMPENTITY);
	WriteByte(targ, TE_CSQC_MAPVOTE);
	WriteByte(targ, MAPVOTE_NET_UPDATE);
	if(mapvote_count <= 8)
		WriteByte(targ, MapVote_GetMapMask());
	else
		WriteShort(targ, MapVote_GetMapMask());
	if(mapvote_detail)
		for(i = 0; i < mapvote_count; ++i)
			if(mapvote_maps[i] != "")
				WriteByte(targ, mapvote_votes[i]);
}

void MapVote_TellVote(float targ, float vote)
{
	WriteByte(targ, SVC_TEMPENTITY);
	WriteByte(targ, TE_CSQC_MAPVOTE);
	WriteByte(targ, MAPVOTE_NET_OWNVOTE);
	WriteByte(targ, vote);
}

float MapVote_Finished(float mappos)
{
	string result;
	float i;
	float didntvote;

	if(cvar("sv_eventlog"))
	{
		result = strcat(":vote:finished:", mapvote_maps[mappos]);
		result = strcat(result, ":", ftos(mapvote_votes[mappos]), "::");
		didntvote = mapvote_voters;
		for(i = 0; i < mapvote_count; ++i)
			if(mapvote_maps[i] != "")
			{
				didntvote -= mapvote_votes[i];
				if(i != mappos)
				{
					result = strcat(result, ":", mapvote_maps[i]);
					result = strcat(result, ":", ftos(mapvote_votes[i]));
				}
			}
		result = strcat(result, ":didn't vote:", ftos(didntvote));

		GameLogEcho(result);
		if(mapvote_maps_suggested[mappos])
			GameLogEcho(strcat(":vote:suggestion_accepted:", mapvote_maps[mappos]));
	}

	FOR_EACH_REALCLIENT(other)
		FixClientCvars(other);

	Map_Goto_SetStr(mapvote_maps[mappos]);
	Map_Goto();
	alreadychangedlevel = TRUE;
	return TRUE;
}
void MapVote_CheckRules_1()
{
	float i;

	for(i = 0; i < mapvote_count; ++i) if(mapvote_maps[i] != "")
	{
		//dprint("Map ", ftos(i), ": "); dprint(mapvote_maps[i], "\n");
		mapvote_votes[i] = 0;
	}

	mapvote_voters = 0;
	FOR_EACH_REALCLIENT(other)
	{
		++mapvote_voters;
		if(other.mapvote)
		{
			i = other.mapvote - 1;
			//dprint("Player ", other.netname, " vote = ", ftos(other.mapvote - 1), "\n");
			mapvote_votes[i] = mapvote_votes[i] + 1;
		}
	}
}

float MapVote_CheckRules_2()
{
	float i;
	float firstPlace, secondPlace;
	float firstPlaceVotes, secondPlaceVotes;
	float mapvote_voters_real;
	string result;

	mapvote_voters_real = mapvote_voters;
	if(mapvote_abstain)
		mapvote_voters_real -= mapvote_votes[mapvote_count - 1];

	RandomSelection_Init();
	for(i = 0; i < mapvote_count_real; ++i) if(mapvote_maps[i] != "")
		RandomSelection_Add(world, i, 1, mapvote_votes[i]);
	firstPlace = RandomSelection_chosen_float;
	firstPlaceVotes = RandomSelection_best_priority;
	//dprint("First place: ", ftos(firstPlace), "\n");
	//dprint("First place votes: ", ftos(firstPlaceVotes), "\n");

	RandomSelection_Init();
	for(i = 0; i < mapvote_count_real; ++i) if(mapvote_maps[i] != "")
		if(i != firstPlace)
			RandomSelection_Add(world, i, 1, mapvote_votes[i]);
	secondPlace = RandomSelection_chosen_float;
	secondPlaceVotes = RandomSelection_best_priority;
	//dprint("Second place: ", ftos(secondPlace), "\n");
	//dprint("Second place votes: ", ftos(secondPlaceVotes), "\n");

	if(firstPlace == -1)
		error("No first place in map vote... WTF?");

	if(secondPlace == -1 || time > mapvote_timeout || (mapvote_voters_real - firstPlaceVotes) < firstPlaceVotes)
		return MapVote_Finished(firstPlace);

	if(mapvote_keeptwotime)
		if(time > mapvote_keeptwotime || (mapvote_voters_real - firstPlaceVotes - secondPlaceVotes) < secondPlaceVotes)
		{
			float didntvote;
			mapvote_dirty = TRUE;
			mapvote_message = "Now decide between the TOP TWO!";
			mapvote_keeptwotime = 0;
			result = strcat(":vote:keeptwo:", mapvote_maps[firstPlace]);
			result = strcat(result, ":", ftos(firstPlaceVotes));
			result = strcat(result, ":", mapvote_maps[secondPlace]);
			result = strcat(result, ":", ftos(secondPlaceVotes), "::");
			didntvote = mapvote_voters;
			for(i = 0; i < mapvote_count; ++i)
				if(mapvote_maps[i] != "")
				{
					didntvote -= mapvote_votes[i];
					if(i != firstPlace)
						if(i != secondPlace)
						{
							result = strcat(result, ":", mapvote_maps[i]);
							result = strcat(result, ":", ftos(mapvote_votes[i]));
							if(i < mapvote_count_real)
							{
								strunzone(mapvote_maps[i]);
								mapvote_maps[i] = "";
							}
						}
				}
			result = strcat(result, ":didn't vote:", ftos(didntvote));
			if(cvar("sv_eventlog"))
				GameLogEcho(result);
		}

	return FALSE;
}
void MapVote_Tick()
{
	string msgstr;
	string tmp;
	float i;
	float keeptwo;
	float totalvotes;

	keeptwo = mapvote_keeptwotime;
	MapVote_CheckRules_1(); // count
	if(MapVote_CheckRules_2()) // decide
		return;

	totalvotes = 0;
	FOR_EACH_REALCLIENT(other)
	{
		// hide scoreboard again
		if(other.health != 2342)
		{
			other.health = 2342;
			other.impulse = 0;
			if(clienttype(other) == CLIENTTYPE_REAL)
			{
				if(cvar("g_maplist_textonly"))
					stuffcmd(other, "\nin_bind 7 1 \"impulse 1\"; in_bind 7 2 \"impulse 2\"; in_bind 7 3 \"impulse 3\"; in_bind 7 4 \"impulse 4\"; in_bind 7 5 \"impulse 5\"; in_bind 7 6 \"impulse 6\"; in_bind 7 7 \"impulse 7\"; in_bind 7 8 \"impulse 8\"; in_bind 7 9 \"impulse 9\"; in_bind 7 0 \"impulse 10\"; in_bind 7 KP_1 \"impulse 1\"; in_bind 7 KP_2 \"impulse 2\"; in_bind 7 KP_3 \"impulse 3\"; in_bind 7 KP_4 \"impulse 4\"; in_bind 7 KP_5 \"impulse 5\"; in_bind 7 KP_6 \"impulse 6\"; in_bind 7 KP_7 \"impulse 7\"; in_bind 7 KP_8 \"impulse 8\"; in_bind 7 KP_9 \"impulse 9\"; in_bind 7 KP_0 \"impulse 10\"; in_bindmap 7 0\n");

				msg_entity = other;
				WriteByte(MSG_ONE, SVC_FINALE);
				WriteString(MSG_ONE, "");
			}
		}

		// notify about keep-two
		if(keeptwo != 0 && mapvote_keeptwotime == 0)
			play2(other, "misc/invshot.wav");

		// clear possibly invalid votes
		if(mapvote_maps[other.mapvote - 1] == "")
			other.mapvote = 0;
		// use impulses as new vote
		if(other.impulse >= 1 && other.impulse <= mapvote_count)
			if(mapvote_maps[other.impulse - 1] != "")
			{
				other.mapvote = other.impulse;
				if(mapvote_detail)
					mapvote_dirty = TRUE;

				msg_entity = other;
				MapVote_TellVote(MSG_ONE, other.mapvote);
			}
		other.impulse = 0;

		if(other.mapvote)
			++totalvotes;
	}

	MapVote_CheckRules_1(); // just count

	if(!cvar("g_maplist_textonly"))
	if(mapvote_dirty) // 1 if "keeptwo" or "impulse" happened before
	{
		MapVote_UpdateData(MSG_BROADCAST);
		mapvote_dirty = FALSE;
	}

	if(cvar("g_maplist_textonly"))
	{
		FOR_EACH_REALCLIENT(other)
		{
			// display voting screen
			msgstr = "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
			msgstr = substring(msgstr, 0, strlen(msgstr) - mapvote_count);
			if(mapvote_abstain)
				msgstr = substring(msgstr, 1, strlen(msgstr) - 1);
			msgstr = strcat(msgstr, mapvote_message);
			msgstr = strcat(msgstr, "\n\n");
			for(i = 0; i < mapvote_count; ++i)
				if(mapvote_maps[i] == "")
					msgstr = strcat(msgstr, "\n");
				else
				{
					tmp = mapvote_maps[i];
					tmp = strpad(mapvote_maxlen, tmp);
					tmp = strcat(ftos(mod(i + 1, 10)), ": ", tmp);
					if(mapvote_detail)
					{
						tmp = strcat(tmp, " ^2(", ftos(mapvote_votes[i]), " vote");
						if(mapvote_votes[i] != 1)
							tmp = strcat(tmp, "s");
						tmp = strcat(tmp, ")");
						tmp = strpad(mapvote_maxlen + 15, tmp);
					}
					if(mapvote_abstain)
						if(i == mapvote_count - 1)
							msgstr = strcat(msgstr, "\n");
					if(other.mapvote == i + 1)
						msgstr = strcat(msgstr, "^3> ", tmp, "\n");
					else
						msgstr = strcat(msgstr, "^7  ", tmp, "\n");
				}

			msgstr = strcat(msgstr, "\n\n^2", ftos(totalvotes), " vote");
			if(totalvotes != 1)
				msgstr = strcat(msgstr, "s");
			msgstr = strcat(msgstr, " cast");
			i = ceil(mapvote_timeout - time);
			msgstr = strcat(msgstr, "\n", ftos(i), " second");
			if(i != 1)
				msgstr = strcat(msgstr, "s");
			msgstr = strcat(msgstr, " left");

			centerprint_atprio(other, CENTERPRIO_MAPVOTE, msgstr);
		}
	}
}
void MapVote_Start()
{
	if(mapvote_run)
		return;

	MapInfo_Enumerate();
	if(MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), 0, (g_maplist_allow_hidden ? MAPINFO_FLAG_HIDDEN : 0), 1))
		mapvote_run = TRUE;
}
void MapVote_Think()
{
	if(!mapvote_run)
		return;

	if(alreadychangedlevel)
		return;

	if(time < mapvote_nextthink)
		return;
	//dprint("tick\n");

	mapvote_nextthink = time + 0.5;

	if(!mapvote_initialized)
	{
		mapvote_initialized = TRUE;
		if(DoNextMapOverride())
			return;
		if(!cvar("g_maplist_votable") || player_count <= 0)
		{
			GotoNextMap();
			return;
		}
		MapVote_Init();
	}

	MapVote_Tick();
};

string GotoMap(string m)
{
	if(!MapInfo_CheckMap(m))
		return "The map you chose is not available on this server.";
	cvar_set("nextmap", m);
	cvar_set("timelimit", "-1");
	if(mapvote_initialized || alreadychangedlevel)
	{
		if(DoNextMapOverride())
			return "Map switch initiated.";
		else
			return "Hm... no. For some reason I like THIS map more.";
	}
	else
		return "Map switch will happen after scoreboard.";
}

float GameCommand_Generic(string command)
{
	float argc;
	float i, j, f, n;
	string s, s2;
	argc = tokenize_sane(command);
	if(argv(0) == "help")
	{
		print("  rpn EXPRESSION... - a RPN calculator.\n");
		print("    Operator description (x: string, s: set, f: float):\n");
		print("    x pop ----------------------------->     : removes the top\n");
		print("    x dup -----------------------------> x x : duplicates the top\n");
		print("    x x exch --------------------------> x x : swap the top two\n");
		print("    /cvarname load --------------------> x   : loads a cvar\n");
		print("    /cvarname x def ------------------->     : writes to a cvar\n");
		print("    f f add|sub|mul|div|mod|max|min ---> f   : adds/... two numbers\n");
		print("    f f eq|ne|gt|ge|lt|le -------------> f   : compares two numbers\n");
		print("    f neg|abs|sgn|rand|floor|ceil------> f   : negates/... a number\n");
		print("    f f f bound -----------------------> f   : bounds the middle number\n");
		print("    f1 f2 b when ----------------------> f   : f1 if b, f2 otherwise\n");
		print("    s s union|intersection|difference -> s   : set operations\n");
		print("    s shuffle -------------------------> s   : randomly arrange elements\n");
		print("    x dbpush -------------------------->     : pushes the top onto the database\n");
		print("    dbpop|dbget -----------------------> x   : removes/reads DB's top\n");
		print("    dblen|dbat ------------------------> f   : gets the DB's size/cursor pos\n");
		print("    dbclr ----------------------------->     : clear the DB\n");
		print("    s dbsave|dbload-------------------->     : save/load the DB to/from a file\n");
		print("    x dbins --------------------------->     : moves the top into the DB\n");
		print("    dbext|dbread ----------------------> x   : extract/get from the DB's cursor\n");
		print("    f dbmov|dbgoto -------------------->     : move or set the DB's cursor\n");
		print("    Set operations operate on 'such''strings'.\n");
		print("    Unknown tokens insert their cvar value.\n");
		print("  maplist add map\n");
		print("  maplist remove map\n");
		print("  maplist shuffle\n");
		print("  suggestmap map\n");
		return TRUE;
	}
	
	if(argv(0) == "maplist")
	{
		if(argv(1) == "add" && argc == 3)
		{
			f = fopen(strcat("maps/", argv(2), ".bsp"), FILE_READ);
			if(f != -1)
				fclose(f);
			else {
				print("maplist: ERROR: ", argv(2), " does not exist!\n");
				return TRUE;
			}
			if(cvar_string("g_maplist") == "")
				cvar_set("g_maplist", argv(2));
			else
				cvar_set("g_maplist", strcat(argv(2), " ", cvar_string("g_maplist")));
			return TRUE;
		}
		else if(argv(1) == "remove" && argc == 3)
		{
			s = argv(2);
			n = tokenizebyseparator(cvar_string("g_maplist"), " ");
			s2 = "";
			for(i = 0; i < n; ++i)
				if(argv(i) != s)
				{
					s2 = strcat(s2, " ", argv(i));
				}
			s2 = substring(s2, 1, strlen(s2) - 1);
			cvar_set("g_maplist", s2);
			return TRUE;
		}
		else if(argv(1) == "shuffle" && argc == 2)
		{
			s = cvar_string("g_maplist");
			for(i = 1; i < (n = tokenizebyseparator(s, " ")); ++i)
			{
				// swap i-th item at a random position from 0 to i
				// proof for even distribution:
				//   n = 1: obvious
				//   n -> n+1:
				//     item n+1 gets at any position with chance 1/(n+1)
				//     all others will get their 1/n chance reduced by factor n/(n+1)
				//     to be on place n+1, their chance will be 1/(n+1)
				//     1/n * n/(n+1) = 1/(n+1)
				//     q.e.d.
				f = floor(random() * (i + 1)); // 0 to i
				if(f == i)
					continue; // no change

				s2 = "";
				for(j = 0; j < n; ++j)
					s2 = strcat(s2, " ", argv((j == i) ? f : (j == f) ? i : j));
				s = substring(s2, 1, strlen(s2) - 1);
			}
			cvar_set("g_maplist", s);
			return TRUE;
		}
	}
	else if(argv(0) == "rpn")
	{
		if(!rpn_db)
		{
			rpn_db = db_create();
			db_put(rpn_db, "stack.pointer", "0");
			db_put(rpn_db, "stack.pos", "-1");
		}
		if(argc >= 2)
		{
			float rpnpos;
			string rpncmd;
			float f2, f3;
			rpn_sp = 0;
			rpn_error = FALSE;
			for(rpnpos = 1; rpnpos < argc; ++rpnpos)
			{
				rpncmd = argv(rpnpos);
				f = strlen(rpncmd);
				if(rpncmd == "") {
				} else if(stof(substring(rpncmd, 0, 1)) > 0) {
					rpn_push(rpncmd);
				} else if(substring(rpncmd, 0, 1) == "0") {
					rpn_push(rpncmd);
				} else if(f >= 2 && substring(rpncmd, 0, 1) == "+") {
					rpn_push(rpncmd);
				} else if(f >= 2 && substring(rpncmd, 0, 1) == "-") {
					rpn_push(rpncmd);
				} else if(f >= 2 && substring(rpncmd, 0, 1) == "/") {
					rpn_push(substring(rpncmd, 1, strlen(rpncmd) - 1));
				} else if(rpncmd == "clear") {
					rpn_sp = 0;
				} else if(rpncmd == "def" || rpncmd == "=") {
					s = rpn_pop();
					s2 = rpn_pop();
#ifdef MENUQC
					registercvar(s2, "", 0);
#else
					registercvar(s2, "");
#endif
					if(!rpn_error) // don't change cvars if a stack error had happened!
						cvar_set(s2, s);
				} else if(rpncmd == "defs" || rpncmd == "@") {
					s = "";
					i = rpn_popf();
					j = (i == 0);
					while(rpn_sp > 1 && (j || i > 0))
					{
						s = strcat("/", rpn_pop(), " ", s);
						--i;
					}
					s2 = rpn_pop();
#ifdef MENUQC
					registercvar(s2, "", 0);
#else
					registercvar(s2, "");
#endif
					if(!rpn_error) // don't change cvars if a stack error had happened!
						cvar_set(s2, s);
				} else if(rpncmd == "load") {
					rpn_set(cvar_string(rpn_get()));
				} else if(rpncmd == "exch") {
					s = rpn_pop();
					s2 = rpn_get();
					rpn_set(s);
					rpn_push(s2);
				} else if(rpncmd == "dup") {
					rpn_push(rpn_get());
				} else if(rpncmd == "pop") {
					rpn_pop();
				} else if(rpncmd == "add" || rpncmd == "+") {
					f = rpn_popf();
					rpn_setf(rpn_getf() + f);
				} else if(rpncmd == "sub" || rpncmd == "-") {
					f = rpn_popf();
					rpn_setf(rpn_getf() - f);
				} else if(rpncmd == "mul" || rpncmd == "*") {
					f = rpn_popf();
					rpn_setf(rpn_getf() * f);
				} else if(rpncmd == "div" || rpncmd == "/") {
					f = rpn_popf();
					rpn_setf(rpn_getf() / f);
				} else if(rpncmd == "mod" || rpncmd == "%") {
					f = rpn_popf();
					f2 = rpn_getf();
					rpn_setf(f2 - f * floor(f2 / f));
				} else if(rpncmd == "abs") {
					rpn_setf(fabs(rpn_getf()));
				} else if(rpncmd == "sgn") {
					f = rpn_getf();
					if(f < 0)
						rpn_set("-1");
					else if(f > 0)
						rpn_set("1");
					else
						rpn_set("0");
				} else if(rpncmd == "neg" || rpncmd == "~") {
					rpn_setf(-rpn_getf());
				} else if(rpncmd == "floor" || rpncmd == "f") {
					rpn_setf(floor(rpn_getf()));
				} else if(rpncmd == "ceil" || rpncmd == "c") {
					rpn_setf(ceil(rpn_getf()));
				} else if(rpncmd == "max") {
					f = rpn_popf();
					f2 = rpn_getf();
					rpn_setf(max(f2, f));
				} else if(rpncmd == "min") {
					f = rpn_popf();
					f2 = rpn_getf();
					rpn_setf(min(f2, f));
				} else if(rpncmd == "bound") {
					f = rpn_popf();
					f2 = rpn_popf();
					f3 = rpn_getf();
					rpn_setf(bound(f3, f2, f));
				} else if(rpncmd == "when") {
					f = rpn_popf();
					f2 = rpn_popf();
					f3 = rpn_getf();
					if(f)
						rpn_setf(f3);
					else
						rpn_setf(f2);
				} else if(rpncmd == ">" || rpncmd == "gt") {
					f = rpn_popf();
					rpn_setf(rpn_getf() > f);
				} else if(rpncmd == "<" || rpncmd == "lt") {
					f = rpn_popf();
					rpn_setf(rpn_getf() < f);
				} else if(rpncmd == "==" || rpncmd == "eq") {
					f = rpn_popf();
					rpn_setf(rpn_getf() == f);
				} else if(rpncmd == ">=" || rpncmd == "ge") {
					f = rpn_popf();
					rpn_setf(rpn_getf() >= f);
				} else if(rpncmd == "<=" || rpncmd == "le") {
					f = rpn_popf();
					rpn_setf(rpn_getf() <= f);
				} else if(rpncmd == "!=" || rpncmd == "ne") {
					f = rpn_popf();
					rpn_setf(rpn_getf() != f);
				} else if(rpncmd == "rand") {
					rpn_setf(ceil(random() * rpn_getf()) - 1);
				} else if(rpncmd == "dbpush") {
					s = rpn_pop();
					if(!rpn_error)
					{
						i = stof(db_get(rpn_db, "stack.pointer"));
						db_put(rpn_db, "stack.pointer", ftos(i+1));
						db_put(rpn_db, strcat("stack.", ftos(i)), s);
					}
					if(!i)
						db_put(rpn_db, "stack.pos", "0");
				} else if(rpncmd == "dbpop") {
					i = stof(db_get(rpn_db, "stack.pointer"));
					if(i)
					{
						s = ftos(i-1);
						db_put(rpn_db, "stack.pointer", s);
						rpn_push(db_get(rpn_db, strcat("stack.", s)));
						j = stof(db_get(rpn_db, "stack.pos"));
						if(j >= i)
							db_put(rpn_db, "stack.pos", ftos(i-2));
					} else {
						rpn_error = 1;
						print("rpn: database underflow\n");
					}
				} else if(rpncmd == "dbget") {
					
					i = stof(db_get(rpn_db, "stack.pointer"));
					if(i)
					{
						rpn_push(db_get(rpn_db, strcat("stack.", ftos(i-1))));
					} else {
						rpn_error = 1;
						print("rpn: database empty\n");
					}
				} else if(rpncmd == "dblen") {
					rpn_push(db_get(rpn_db, "stack.pointer"));
				} else if(rpncmd == "dbclr") {
					db_close(rpn_db);
					rpn_db = db_create();
					db_put(rpn_db, "stack.pointer", "0");
					db_put(rpn_db, "stack.pos", "-1");
				} else if(rpncmd == "dbsave") {
					s = rpn_pop();
					if(!rpn_error)
						db_save(rpn_db, s);
				} else if(rpncmd == "dbload") {
					s = rpn_pop();
					if(!rpn_error)
					{
						db_close(rpn_db);
						rpn_db = db_load(s);
					}
				} else if(rpncmd == "dbins") {
					s = rpn_pop();
					if(!rpn_error)
						//if(rpn_sp > 0)
					{
						j = stof(db_get(rpn_db, "stack.pointer"));
						i = stof(db_get(rpn_db, "stack.pos"));
						
						if(i < 0)
						{
							i = 0;
							db_put(rpn_db, "stack.pos", "0");
						}
						
						db_put(rpn_db, "stack.pointer", ftos(j+1));
						for(--j; j >= i; --j)
						{
							db_put(rpn_db, strcat("stack.", ftos(j+1)),
							       db_get(rpn_db, (strcat("stack.", ftos(j))))
								);
						}
						db_put(rpn_db, strcat("stack.", ftos(i)), s);
					}
				} else if(rpncmd == "dbext") {
					j = stof(db_get(rpn_db, "stack.pointer"));
					i = stof(db_get(rpn_db, "stack.pos"));
					if(!j)
					{
						rpn_error = TRUE;
						print("rpn: empty database\n");
					} else {
						--j;
						rpn_push(db_get(rpn_db, strcat("stack.", ftos(i))));
						db_put(rpn_db, "stack.pointer", ftos(j));
						if(i == j)
						{
							db_put(rpn_db, "stack.pos", ftos(j-1));
						} else {
							while(i < j)
							{
								db_put(rpn_db, strcat("stack.", ftos(i)),
								       db_get(rpn_db, (strcat("stack.", ftos(i+1))))
									);
								++i;
							}
						}
					}
				} else if(rpncmd == "dbread") {
					s = db_get(rpn_db, "stack.pos");
					if(stof(s) >= 0)
					{
						rpn_push(db_get(rpn_db, strcat("stack.", s)));
					} else {
						rpn_error = 1;
						print("rpn: empty database\n");
					}
				} else if(rpncmd == "dbat") {
					rpn_push(db_get(rpn_db, "stack.pos"));
				} else if(rpncmd == "dbmov") {
					j = stof(db_get(rpn_db, "stack.pointer"));
					i = stof(db_get(rpn_db, "stack.pos"));
					i += rpn_popf();
					if(!rpn_error)
					{
						if(i < 0 || i >= j)
						{
							print("rpn: database cursor out of bounds\n");
							rpn_error = TRUE;
						}
						if(!rpn_error)
						{
							db_put(rpn_db, "stack.pos", ftos(i));
						}
					}
				} else if(rpncmd == "dbgoto") {
					s = rpn_pop();
					j = stof(db_get(rpn_db, "stack.pointer"));
					if(!j)
					{
						rpn_error = TRUE;
						print("rpn: empty database, cannot move cursor\n");
					}
					if(!rpn_error)
					{
						if(s == "end")
							i = stof(db_get(rpn_db, "stack.pointer"))-1;
						else if(s == "beg")
							i = 0;
						else
							i = stof(s);
						
						j = stof(db_get(rpn_db, "stack.pointer"));
						if(i < 0 || i >= j)
						{
							print("rpn: database cursor destination out of bounds\n");
							rpn_error = TRUE;
						}
						if(!rpn_error)
						{
							db_put(rpn_db, "stack.pos", ftos(i));
						}
					}
				} else if(rpncmd == "union") {
					// s s2 union
					s2 = rpn_pop();
					s = rpn_get();
					f = tokenize_sane(s);
					f2 = tokenize_sane(strcat(s, " ", s2));
					// tokens 0..(f-1) represent s
					// tokens f..f2 represent s2
					// UNION: add all tokens to s that are in s2 but not in s
					s = "";
					for(i = 0; i < f; ++i)	
						s = strcat(s, " ", argv(i));
					for(i = f; i < f2; ++i) {
						for(j = 0; j < f; ++j)
							if(argv(i) == argv(j))
								goto skip_union;
						s = strcat(s, " ", argv(i));
:skip_union
					}
					if(substring(s, 0, 1) == " ")
						s = substring(s, 1, 99999);
					rpn_set(s);
					tokenize_sane(command);
				} else if(rpncmd == "intersection") {
					// s s2 intersection
					s2 = rpn_pop();
					s = rpn_get();
					f = tokenize_sane(s);
					f2 = tokenize_sane(strcat(s, " ", s2));
					// tokens 0..(f-1) represent s
					// tokens f..f2 represent s2
					// INTERSECTION: keep only the tokens from s that are also in s2
					s = "";
					for(i = 0; i < f; ++i) {
						for(j = f; j < f2; ++j)
							if(argv(i) == argv(j))
							{
								s = strcat(s, " ", argv(i));
								break;
							}
					}
					if(substring(s, 0, 1) == " ")
						s = substring(s, 1, 99999);
					rpn_set(s);
					tokenize_sane(command);
				} else if(rpncmd == "difference") {
					// s s2 difference
					s2 = rpn_pop();
					s = rpn_get();
					f = tokenize_sane(s);
					f2 = tokenize_sane(strcat(s, " ", s2));
					// tokens 0..(f-1) represent s
					// tokens f..f2 represent s2
					// DIFFERENCE: keep only the tokens from s that are not in s2
					s = "";
					for(i = 0; i < f; ++i) {
						for(j = f; j < f2; ++j)
							if(argv(i) == argv(j))
								goto skip_difference;
						s = strcat(s, " ", argv(i));
:skip_difference
					}
					if(substring(s, 0, 1) == " ")
						s = substring(s, 1, 99999);
					rpn_set(s);
					tokenize_sane(command);
				} else if(rpncmd == "shuffle") {
					// s shuffle
					s = rpn_get();
					f = tokenize_sane(s);

					for(i = 0; i < f - 1; ++i) {
						// move a random item from i..f-1 to position i
						s = "";
						f2 = floor(random() * (f - i) + i);
						for(j = 0; j < i; ++j)
							s = strcat(s, " ", argv(j));
						s = strcat(s, " ", argv(f2));
						for(j = i; j < f; ++j)
							if(j != f2)
								s = strcat(s, " ", argv(j));
						f = tokenize_sane(s);
					}

					if(substring(s, 0, 1) == " ")
						s = substring(s, 1, 99999);
					rpn_set(s);
					tokenize_sane(command);
					} else if(rpncmd == "fexists_assert") {
					s = rpn_pop();
					if(!rpn_error)
					{
						f = fopen(s, FILE_READ);
						if(f != -1)
							fclose(f);
						else {
							print("rpn: ERROR: ", s, " does not exist!\n");
							rpn_error = TRUE;
						}
					}
				} else {
					rpn_push(cvar_string(rpncmd));
				}
				if(rpn_error)
					break;
			}
			while(rpn_sp > 0)
			{
				s = rpn_pop();
				print("rpn: still on stack: ", s, "\n");
			}
			return TRUE;
		}
#ifdef MENUQC
	} else if(argv(0) == "cp") {
		if(argc >= 2)
		{
			s = argv(1);
			for(i = 2; i < argc; ++i)
				s = strcat(s, " ", argv(i));
			centerprint(unescape(s));
		}
		return TRUE;
#endif
	} else if(argv(0) == "suggestmap") {
		print(strcat(MapVote_Suggest(argv(1)), "\n"));
	}

	return FALSE;
}
