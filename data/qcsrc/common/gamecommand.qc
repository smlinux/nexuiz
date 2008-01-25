#define MAX_RPN_STACK 8
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

float GameCommand_Generic(string command)
{
	float argc;
	float i, j, f, n;
	string s, s2;
	argc = tokenize(command);
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
		print("    f neg|abs|sgn|rand ----------------> f   : negates/... a number\n");
		print("    f f f bound -----------------------> f   : bounds the middle number\n");
		print("    f1 f2 b when ----------------------> f   : f1 if b, f2 otherwise\n");
		print("    s s union|intersection|difference -> s   : set operations\n");
		print("    s shuffle -------------------------> s   : randomly arrange elements\n");
		print("    Set operations operate on 'such''strings' like g_maplist.\n");
		print("    Unknown tokens insert their cvar value.\n");
		print("  maplist add map\n");
		print("  maplist remove map\n");
		print("  maplist shuffle\n");
		return TRUE;
	}
	
	if(argv(0) == "maplist")
	{
		if(argv(1) == "add" && argc == 3)
		{
#ifdef MAPINFO
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
#else
			f = fopen(strcat("maps/", argv(2), ".mapcfg"), FILE_READ);
			if(f != -1)
				fclose(f);
			else {
				print("maplist: ERROR: ", argv(2), " does not exist!\n");
				return TRUE;
			}
			cvar_set("g_maplist", strcat("'", argv(2), "'", cvar_string("g_maplist")));
#endif
			return TRUE;
		}
		else if(argv(1) == "remove" && argc == 3)
		{
			s = argv(2);
#ifdef MAPINFO
			n = tokenizebyseparator(cvar_string("g_maplist"), " ");
#else
			n = tokenize(cvar_string("g_maplist"));
#endif
			s2 = "";
			for(i = 0; i < n; ++i)
				if(argv(i) != s)
				{
#ifdef MAPINFO
					s2 = strcat(s2, " ", argv(i));
#else
					s2 = strcat(s2, "'", argv(i), "'");
#endif
				}
#ifdef MAPINFO
			s2 = substring(s2, 1, strlen(s2) - 1);
#endif
			cvar_set("g_maplist", s2);
			return TRUE;
		}
		else if(argv(1) == "shuffle" && argc == 2)
		{
			s = cvar_string("g_maplist");
#ifdef MAPINFO
			for(i = 1; i < (n = tokenizebyseparator(s, " ")); ++i)
#else
			for(i = 1; i < (n = tokenize(s)); ++i)
#endif
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
				f = ceil(random() * (i + 1)) - 1; // 0 to i
				if(f == i)
					continue; // no change

				s2 = "";
				for(j = 0; j < n; ++j)
#ifdef MAPINFO
					s2 = strcat(s2, " ", argv((j == i) ? f : (j == f) ? i : j));
				s = substring(s2, 1, strlen(s2) - 1);
#else
					s2 = strcat(s2, "'", argv((j == i) ? f : (j == f) ? i : j), "'");
				s = s2;
#endif
			}
			cvar_set("g_maplist", s);
			return TRUE;
		}
	}
	else if(argv(0) == "rpn")
	{
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
				} else if(rpncmd == "union") {
					// s s2 union
					s2 = rpn_pop();
					s = rpn_get();
					f = tokenize(s);
					f2 = tokenize(strcat(s, s2));
					// tokens 0..(f-1) represent s
					// tokens f..f2 represent s2
					// UNION: add all tokens to s that are in s2 but not in s
					s = "";
					for(i = 0; i < f; ++i)
						s = strcat(s, "'", argv(i), "'");
					for(i = f; i < f2; ++i) {
						for(j = 0; j < f; ++j)
							if(argv(i) == argv(j))
								goto skip_union;
						s = strcat(s, "'", argv(i), "'");
:skip_union
					}
					rpn_set(s);
					tokenize(command);
				} else if(rpncmd == "intersection") {
					// s s2 intersection
					s2 = rpn_pop();
					s = rpn_get();
					f = tokenize(s);
					f2 = tokenize(strcat(s, s2));
					// tokens 0..(f-1) represent s
					// tokens f..f2 represent s2
					// INTERSECTION: keep only the tokens from s that are also in s2
					s = "";
					for(i = 0; i < f; ++i) {
						for(j = f; j < f2; ++j)
							if(argv(i) == argv(j))
							{
								s = strcat(s, "'", argv(i), "'");
								break;
							}
					}
					rpn_set(s);
					tokenize(command);
				} else if(rpncmd == "difference") {
					// s s2 difference
					s2 = rpn_pop();
					s = rpn_get();
					f = tokenize(s);
					f2 = tokenize(strcat(s, s2));
					// tokens 0..(f-1) represent s
					// tokens f..f2 represent s2
					// DIFFERENCE: keep only the tokens from s that are not in s2
					s = "";
					for(i = 0; i < f; ++i) {
						for(j = f; j < f2; ++j)
							if(argv(i) == argv(j))
								goto skip_difference;
						s = strcat(s, "'", argv(i), "'");
:skip_difference
					}
					rpn_set(s);
					tokenize(command);
				} else if(rpncmd == "shuffle") {
					// s shuffle
					s = rpn_get();
					f = tokenize(s);

					for(i = 0; i < f - 1; ++i) {
						// move a random item from i..f-1 to position i
						s = "";
						f2 = ceil(random() * (f - i) + i) - 1;
						for(j = 0; j < i; ++j)
							s = strcat(s, "'", argv(j), "'");
						s = strcat(s, "'", argv(f2), "'");
						for(j = i; j < f; ++j)
							if(j != f2)
								s = strcat(s, "'", argv(j), "'");
						f = tokenize(s);
					}

					rpn_set(s);
					tokenize(command);
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
	}

	return FALSE;
}
