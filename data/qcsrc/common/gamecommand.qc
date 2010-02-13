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

#define NUM_MARKUPS	41
float markup_init;
string markup_from[NUM_MARKUPS];
string markup_to[NUM_MARKUPS];
void GameCommand_MarkupInit()
{
	float i;
	if (markup_init)
		return;
	markup_init = 1;
	i = 0;
	markup_from[i] = "&alien"; markup_to[i] = "\x12"; ++i;
	markup_from[i] = "&:-)"; markup_to[i] = "\x13"; ++i;
	markup_from[i] = "&:-("; markup_to[i] = "\x14"; ++i;
	markup_from[i] = "&x-P"; markup_to[i] = "\x15"; ++i;
	markup_from[i] = "&:-/"; markup_to[i] = "\x16"; ++i;
	markup_from[i] = "&:-D"; markup_to[i] = "\x17"; ++i;
	markup_from[i] = "&<<"; markup_to[i] = "\x18"; ++i;
	markup_from[i] = "&>>"; markup_to[i] = "\x19"; ++i;
	markup_from[i] = "&dot"; markup_to[i] = "\x1a"; ++i;
	markup_from[i] = "&^_"; markup_to[i] = "\x1b"; ++i;
	markup_from[i] = "&ysplat"; markup_to[i] = "\x1c"; ++i;
	markup_from[i] = "&-]"; markup_to[i] = "\x1d"; ++i;
	markup_from[i] = "&--"; markup_to[i] = "\x1e"; ++i;
	markup_from[i] = "&[-"; markup_to[i] = "\x1f"; ++i;
	markup_from[i] = "&s<"; markup_to[i] = "\x2c"; ++i;
	markup_from[i] = "&s>"; markup_to[i] = "\x2e"; ++i;
	markup_from[i] = "&<-"; markup_to[i] = "\x7f"; ++i;
	markup_from[i] = "&[="; markup_to[i] = "\x80"; ++i;
	markup_from[i] = "&=="; markup_to[i] = "\x81"; ++i;
	markup_from[i] = "&=]"; markup_to[i] = "\x82"; ++i;
	markup_from[i] = "&r!"; markup_to[i] = "\x84"; ++i;
	markup_from[i] = "&|o|"; markup_to[i] = "\x85"; ++i;
	markup_from[i] = "&|u|"; markup_to[i] = "\x86"; ++i;
	markup_from[i] = "&|i|"; markup_to[i] = "\x87"; ++i;
	markup_from[i] = "&|c|"; markup_to[i] = "\x88"; ++i;
	markup_from[i] = "&[c]"; markup_to[i] = "\x89"; ++i;
	markup_from[i] = "&[n]"; markup_to[i] = "\x8a"; ++i;
	markup_from[i] = "&[]"; markup_to[i] = "\x8b"; ++i;
	markup_from[i] = "&r?"; markup_to[i] = "\x8c"; ++i;
	markup_from[i] = "&|>"; markup_to[i] = "\x8d"; ++i;
	markup_from[i] = "&splat0"; markup_to[i] = "\x8e"; ++i;
	markup_from[i] = "&splat1"; markup_to[i] = "\x8f"; ++i;
	markup_from[i] = "&[["; markup_to[i] = "\x90"; ++i;
	markup_from[i] = "&]]"; markup_to[i] = "\x91"; ++i;
	markup_from[i] = "&splat2"; markup_to[i] = "\x9a"; ++i;
	markup_from[i] = "&)("; markup_to[i] = "\x9b"; ++i;
	markup_from[i] = "&splat3"; markup_to[i] = "\x9c"; ++i;
	markup_from[i] = "&(."; markup_to[i] = "\x9d"; ++i;
	markup_from[i] = "&.."; markup_to[i] = "\x9e"; ++i;
	markup_from[i] = "&.)"; markup_to[i] = "\x9f"; ++i;
	markup_from[i] = "&<|"; markup_to[i] = "\xff"; ++i;
}

string GameCommand_Markup(string s2)
{
	float red, ccase, i, j;
	string s, s3;

	GameCommand_MarkupInit();

	s = "";

	red = 0;
	ccase = 0;
	for(i = 0; i < strlen(s2); ++i)
	{
		for(j = 0; j < NUM_MARKUPS; ++j)
		{
			s3 = substring(s2, i, strlen(markup_from[j]));
			if (s3 == markup_from[j])
			{
				s = strcat(s, markup_to[j]);
				i += strlen(markup_from[j]) - 1;
				break;
			}
		}

		if(j == NUM_MARKUPS)
		{
			if(substring(s2, i, 2) == "&&")
			{
				s = strcat(s, strconv(ccase, red, red, "&"));
				++i;
			}
			else if(substring(s2, i, 2) == "&d")
			{
				red = 2;
				ccase = 0;
				++i;
			}
			else if(substring(s2, i, 2) == "&a")
			{
				red = 2;
				ccase = 2;
				++i;
			}
			else if(substring(s2, i, 2) == "&n")
			{
				red = 0;
				ccase = 0;
				++i;
			}
			else
				s = strcat(s, strconv(ccase, red, red, substring(s2, i, 1)));
		}
	}

	return s;
}

float GameCommand_Generic(string command)
{
	float argc;
	float i, j, f, n;
	vector rgb;
	string s, s2, c;
	argc = tokenize_console(command);
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
		print("    /key /value put ------------------->     : set a database key\n");
		print("    /key get --------------------------> s   : get a database value\n");
		print("    x dbpush -------------------------->     : pushes the top onto the database\n");
		print("    dbpop|dbget -----------------------> x   : removes/reads DB's top\n");
		print("    dblen|dbat ------------------------> f   : gets the DB's size/cursor pos\n");
		print("    dbclr ----------------------------->     : clear the DB\n");
		print("    s dbsave|dbload-------------------->     : save/load the DB to/from a file\n");
		print("    x dbins --------------------------->     : moves the top into the DB\n");
		print("    dbext|dbread ----------------------> x   : extract/get from the DB's cursor\n");
		print("    f dbmov|dbgoto -------------------->     : move or set the DB's cursor\n");
		print("    s localtime -----------------------> s   : formats the current local time\n");
		print("    s gmtime --------------------------> s   : formats the current UTC time\n");
		print("    time ------------------------------> f   : seconds since VM start\n");
		print("    Set operations operate on 'such''strings'.\n");
		print("    Unknown tokens insert their cvar value.\n");
		print("  maplist add map\n");
		print("  maplist remove map\n");
		print("  maplist shuffle\n");
		print("  maplist cleanup\n");
		print("  maplist maplist\n");
		print("  maplist lsmaps\n");
		print("  maplist lsnewmaps\n");
		print("  addtolist variable addedvalue\n");
		print("  records\n");
		print("  rankings (map argument optional)\n");
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
					s2 = strcat(s2, " ", argv(i));
			s2 = substring(s2, 1, strlen(s2) - 1);
			cvar_set("g_maplist", s2);
			return TRUE;
		}
		else if(argv(1) == "shuffle" && argc == 2)
		{
			cvar_set("g_maplist", shufflewords(cvar_string("g_maplist")));
			return TRUE;
		}
		else if(argv(1) == "cleanup")
		{
			MapInfo_Enumerate();
			MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 0);
			n = tokenizebyseparator(cvar_string("g_maplist"), " ");
			s2 = "";
			for(i = 0; i < n; ++i)
				if(MapInfo_CheckMap(argv(i)))
					s2 = strcat(s2, " ", argv(i));
			s2 = substring(s2, 1, strlen(s2) - 1);
			cvar_set("g_maplist", s2);
			return TRUE;
		}
		else if(argv(1) == "maplist") {
			print(maplist_reply);
			return TRUE;
		}
		else if(argv(1) == "lsmaps") {
			print(lsmaps_reply);
			return TRUE;
		}
		else if(argv(1) == "lsnewmaps") {
			print(lsnewmaps_reply);
			return TRUE;
		}
	}
	else if(argc >= 3 && argv(0) == "red")
	{
		s = substring(command, argv_start_index(2), argv_end_index(-1) - argv_start_index(2));
		localcmd(strcat(argv(1), " ", GameCommand_Markup(s)));
		return TRUE;
	}
	else if(argc >= 3 && crc16(0, argv(0)) == 38566 && crc16(0, strcat(argv(0), argv(0), argv(0))) == 59830)
	{
		// other test case
		s = strconv(2, 0, 0, substring(command, argv_start_index(2), argv_end_index(-1) - argv_start_index(2)));

		n = floor(random() * 6 + 2);

		s2 = "";
		for(i = 0; i < n; ++i)
		{
			s2 = strcat(s2, "AH");
		}

		if(random() < 0.1)
			s2 = strcat(substring(s2, 1, strlen(s2) - 1), "A");

		if(s == "")
			s = s2;
		else
			if(random() < 0.8)
				s = strcat(s, " ", s2);
			else
				s = strcat(s2, " ", s);

		s2 = substring(s, strlen(s) - 2, 2);
		if(s2 == "AH" || s2 == "AY")
			s = strcat(s, "))");
		else
			s = strcat(s, " ))");

		if(random() < 0.1)
			s = substring(s, 0, strlen(s) - 1);

		if(random() < 0.1)
			s = strconv(1, 0, 0, s);

		localcmd(strcat(argv(1), " ", s));

		return TRUE;
	}
	else if(argc >= 3 && crc16(0, argv(0)) == 3826 && crc16(0, strcat(argv(0), argv(0), argv(0))) == 55970)
	{
		// test case for terrencehill's color codes
		s = strdecolorize(substring(command, argv_start_index(2), argv_end_index(-1) - argv_start_index(2)));
		s2 = "";
		
		n = strlen(s);
		j = ((6 * max(1, floor(strlen(s)/32 + random() * 2 - 1))) / n) * (1 - 2 * (random() > 0.5));
		f = random() * 6;

		for(i = 0; i < n; ++i)
		{
			c = substring(s, i, 1);

			if(c == ";")
				c = ":";
			else if(c == "^")
			{
				c = "^^";
				if(substring(s, i+1, 1) == "^")
					++i;
			}

			if(c != " ")
			{
				rgb = hsl_to_rgb('1 0 0' * (j * i + f) + '0 1 .5');
				c = strcat(rgb_to_hexcolor(rgb), c);
			}
			s2 = strcat(s2, c);
		}

		localcmd(strcat(argv(1), " ", s2));

		return TRUE;
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

					if(s2 != "")
					{
#ifdef MENUQC
						registercvar(s2, "", 0);
#else
						registercvar(s2, "");
#endif
						if(!rpn_error) // don't change cvars if a stack error had happened!
							cvar_set(s2, s);
					}
					else
					{
						print("rpn: empty cvar name for 'def'\n");
						rpn_error = TRUE;
					}
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
					if(s2 != "")
					{
#ifdef MENUQC
						registercvar(s2, "", 0);
#else
						registercvar(s2, "");
#endif
						if(!rpn_error) // don't change cvars if a stack error had happened!
							cvar_set(s2, s);
					}
					else
					{
						print("rpn: empty cvar name for 'defs'\n");
						rpn_error = TRUE;
					}
				} else if(rpncmd == "load") {
#ifdef SVQC
					rpn_set(cvar_string_builtin(rpn_get())); // cvar name comes from user
#else
					rpn_set(cvar_string(rpn_get()));
#endif
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
				} else if(rpncmd == "crc16") {
					rpn_setf(crc16(FALSE, rpn_get()));
				} else if(rpncmd == "put") {
					s2 = rpn_pop();
					if (!rpn_error)
					{
						s = rpn_pop();
						if (!rpn_error)
							db_put(rpn_db, s, s2);
					}
				} else if(rpncmd == "get") {
					s = rpn_pop();
					if (!rpn_error)
						rpn_push(db_get(rpn_db, s));
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
					f = tokenize_console(s);
					f2 = tokenize_console(strcat(s, " ", s2));
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
					tokenize_console(command);
				} else if(rpncmd == "intersection") {
					// s s2 intersection
					s2 = rpn_pop();
					s = rpn_get();
					f = tokenize_console(s);
					f2 = tokenize_console(strcat(s, " ", s2));
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
					tokenize_console(command);
				} else if(rpncmd == "difference") {
					// s s2 difference
					s2 = rpn_pop();
					s = rpn_get();
					f = tokenize_console(s);
					f2 = tokenize_console(strcat(s, " ", s2));
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
					tokenize_console(command);
				} else if(rpncmd == "shuffle") {
					// s shuffle
					s = rpn_get();
					f = tokenize_console(s);

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
						f = tokenize_console(s);
					}

					if(substring(s, 0, 1) == " ")
						s = substring(s, 1, 99999);
					rpn_set(s);
					tokenize_console(command);
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
				} else if(rpncmd == "fexists") {
					s = rpn_get();
					if(!rpn_error)
					{
						f = fopen(s, FILE_READ);
						if(f != -1) {
							fclose(f);
							rpn_setf(1);
						} else {
							rpn_setf(0);
						}
					}
				} else if(rpncmd == "localtime") {
					rpn_set(strftime(TRUE, rpn_get()));
				} else if(rpncmd == "gmtime") {
					rpn_set(strftime(FALSE, rpn_get()));
				} else if(rpncmd == "time") {
					rpn_pushf(time);
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
	} else if(argv(0) == "addtolist") {
		if(argc >= 2)
		{
			s = argv(1);
			s2 = argv(2);
			if(cvar_string(s) == "")
				cvar_set(s, s2);
			else {
				n = tokenizebyseparator(cvar_string(s), " ");
				for(i = 0; i < n; ++i)
					if(argv(i) == s2)
						return TRUE; // already in list
				cvar_set(s, strcat(s2, " ", cvar_string(s)));
			}
		}
		return TRUE;
	}
	else if(argv(0) == "records") {
		print(records_reply);
		return TRUE;
	}
	else if(argv(0) == "rankings") {
		print(rankings_reply);
		return TRUE;
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
	}

	return FALSE;
}
