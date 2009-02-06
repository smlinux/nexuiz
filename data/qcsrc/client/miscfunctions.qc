var float(string text, float handleColors) stringwidth;

entity players;
entity teams;

void restartAnnouncer_Think() {
	float countdown_rounded, countdown;
	countdown = getstatf(STAT_GAMESTARTTIME) - time;
	countdown_rounded = floor(0.5 + countdown);
	if(countdown <= 0) {
		if (!spectatee_status) //do cprint only for players
			centerprint("^1Begin!");

		sound(self, CHAN_VOICE, "announcer/robotic/begin.wav", VOL_BASEVOICE, ATTN_NONE);
		remove(self);
		return;
	}
	else {
		if (!spectatee_status) //do cprint only for players
			centerprint(strcat("^1Game starts in ", ftos(countdown_rounded), " seconds"));

		if(countdown_rounded <= 3 && countdown_rounded >= 1) {
			sound(self, CHAN_VOICE, strcat("announcer/robotic/", ftos(countdown_rounded), ".wav"), VOL_BASEVOICE, ATTN_NONE);
		}

		self.nextthink = getstatf(STAT_GAMESTARTTIME) - (countdown - 1);
	}
}

void AuditLists()
{
	entity e;
	entity prev;

	prev = players;
	for(e = prev.sort_next; e; prev = e, e = e.sort_next)
	{
		if(prev != e.sort_prev)
			error(strcat("sort list chain error\nplease submit the output of 'prvm_edicts client' to the developers"));
	}

	prev = teams;
	for(e = prev.sort_next; e; prev = e, e = e.sort_next)
	{
		if(prev != e.sort_prev)
			error(strcat("sort list chain error\nplease submit the output of 'prvm_edicts client' to the developers"));
	}
}


float RegisterPlayer(entity player)
{
	entity pl;
	AuditLists();
	for(pl = players.sort_next; pl; pl = pl.sort_next)
		if(pl == player)
			error("Player already registered!");
	player.sort_next = players.sort_next;
	player.sort_prev = players;
	if(players.sort_next)
		players.sort_next.sort_prev = player;
	players.sort_next = player;
	AuditLists();
	return true;
}

void RemovePlayer(entity player)
{
	entity pl, parent;
	AuditLists();
	parent = players;
	for(pl = players.sort_next; pl && pl != player; pl = pl.sort_next)
		parent = pl;

	if(!pl)
	{
		error("Trying to remove a player which is not in the playerlist!");
		return;
	}
	parent.sort_next = player.sort_next;
	if(player.sort_next)
		player.sort_next.sort_prev = parent;
	AuditLists();
}

void MoveToLast(entity e)
{
	AuditLists();
	other = e.sort_next;
	while(other)
	{
		SORT_SWAP(other, e);
		other = e.sort_next;
	}
	AuditLists();
}

float RegisterTeam(entity Team)
{
	entity tm;
	AuditLists();
	for(tm = teams.sort_next; tm; tm = tm.sort_next)
		if(tm == Team)
			error("Team already registered!");
	Team.sort_next = teams.sort_next;
	Team.sort_prev = teams;
	if(teams.sort_next)
		teams.sort_next.sort_prev = Team;
	teams.sort_next = Team;
	AuditLists();
	return true;
}

void RemoveTeam(entity Team)
{
	entity tm, parent;
	AuditLists();
	parent = teams;
	for(tm = teams.sort_next; tm && tm != Team; tm = tm.sort_next)
		parent = tm;

	if(!tm)
	{
		print("Trying to remove a team which is not in the teamlist!");
		return;
	}
	parent.sort_next = Team.sort_next;
	if(Team.sort_next)
		Team.sort_next.sort_prev = parent;
	AuditLists();
}

entity GetTeam(float Team, float add)
{
	float num;
	entity tm;
	num = (Team == COLOR_SPECTATOR) ? 16 : Team;
	if(teamslots[num])
		return teamslots[num];
	if not(add)
		return NULL;
	tm = spawn();
	tm.team = Team;
	teamslots[num] = tm;
	RegisterTeam(tm);
	return tm;
}

float stringwidth_oldfont(string text, float handleColors)
{
	float i, len, ch, width;
	len = strlen(text);
	if(!handleColors)
		return len;
	width = 0;
	for(i = 0; i < len; ++i)
	{
		if(substring(text, i, 1) == "^")
		{
			ch = str2chr(text, i+1);
			if(ch >= '0' && ch <= '9')
				++i;
			else if(i+4 < len && ch == 'x')
			{
				ch = str2chr(text, i+2);
				if ( (ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'f') || (ch >= 'A' && ch <= 'F') )
				{
					ch = str2chr(text, i+3);
					if ( (ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'f') || (ch >= 'A' && ch <= 'F') )
					{
						ch = str2chr(text, i+4);
						if ( (ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'f') || (ch >= 'A' && ch <= 'F') )
							i+=4;
						else ++width;
					} else ++width;
				} else ++width;
			} else ++width;
		} else ++width;
	}
	return width;
}

void CSQC_CheckEngine()
{
	/*
	registercvar("csqc_flags", "0");
	csqc_flags = cvar("csqc_flags");
	*/

	csqc_flags = 0;
	
	if(checkextension("DP_SV_WRITEPICTURE"))
	{
		stringwidth = stringwidth_engine;
		sbar_font = FONT_USER+1;
		sbar_bigfont = FONT_USER+2;
		csqc_flags |= CSQC_FLAG_READPICTURE;
	} else {
		stringwidth = stringwidth_oldfont;
		sbar_font = FONT_DEFAULT;
		sbar_bigfont = FONT_DEFAULT;
	}

	if(strlennocol("^xFFF") == 0)
		csqc_flags |= CSQC_FLAG_COLORCODES;
}

vector Sbar_GetFontsize(string cvarname)
{
	if(csqc_flags & CSQC_FLAG_READPICTURE)
	{
		vector v;
		v = stov(cvar_string(cvarname));
		if(v_x == 0)
			v = '8 8 0';
		if(v_y == 0)
			v_y = v_x;
		v_z = 0;
		return v;
	}
	return '8 8 0' ;
}

float Sbar_GetWidth(float teamcolumnwidth)
{
	if(csqc_flags & CSQC_FLAG_READPICTURE)
	{
		float f;
		f = stof(cvar_string("sbar_width"));
		if(f == 0)
			f = 640;
		if(f < 320)
			f = 320;
		if(f > vid_conwidth - 2 * teamcolumnwidth)
			f = vid_conwidth - 2 * teamcolumnwidth;
		return f;
	}
	return 640;
}

float PreviewExists(string name)
{
	float f;
	string file;

	if(cvar("cl_readpicture_force"))
		return false;

	file = strcat(name, ".tga");
	f = fopen(file, FILE_READ);
	if(f >= 0)
	{
		fclose(f);
		return true;
	}
	file = strcat(name, ".png");
	f = fopen(file, FILE_READ);
	if(f >= 0)
	{
		fclose(f);
		return true;
	}
	file = strcat(name, ".jpg");
	f = fopen(file, FILE_READ);
	if(f >= 0)
	{
		fclose(f);
		return true;
	}
	file = strcat(name, ".pcx");
	f = fopen(file, FILE_READ);
	if(f >= 0)
	{
		fclose(f);
		return true;
	}
	return false;
}

float PI      = 3.14159265359;
float DEG2RAD = 0.01745329252;
vector rotate(vector v, float a)
{
	vector w;
	// FTEQCC SUCKS AGAIN
	w_x =      v_x * cos(a) + v_y * sin(a);
	w_y = -1 * v_x * sin(a) + v_y * cos(a);
	return w;
}

float ColorTranslateMode;

string ColorTranslateRGB(string s)
{
	if not(ColorTranslateMode & 2)
	if(csqc_flags & CSQC_FLAG_COLORCODES)
	{
		if(ColorTranslateMode & 1)
			return strdecolorize(s);
		else
			return s;
	}
	
	// running on an OLD engine!
	// must translate ^xRGB codes to regular color codes
	float i, n;
	string s2, ch, ch2;
	vector theTempColor, hsv;
	float component;

	s2 = "";

	n = strlen(s);
	for(i = 0; i < n; ++i)
	{
		ch = substring(s, i, 1);
		if(ch == "^")
		{
			ch2 = substring(s, i+1, 1);
			if(ch2 == "^")
			{
				s2 = strcat(s2, ch, ch2);
			}
			else if(ch2 == "0" || stof(ch2)) // digit?
			{
				if not(ColorTranslateMode & 1)
					s2 = strcat(s2, ch, ch2);
			}
			else if(ch2 == "x") // ^x found
			{
				theTempColor = '0 0 0';
				
				component = HEXDIGIT_TO_DEC(substring(s, i+2, 1));
				if (component >= 0) // ^xr found
				{
					theTempColor_x = component/15;
					
					component = HEXDIGIT_TO_DEC(substring(s, i+3, 1));
					if (component >= 0) // ^xrg found
					{
						theTempColor_y = component/15;
						
						component = HEXDIGIT_TO_DEC(substring(s, i+4, 1));
						if (component >= 0) // ^xrgb found
						{
							theTempColor_z = component/15;

							if not(ColorTranslateMode & 1)
							{
								hsv = rgb_to_hsv(theTempColor);

								if(hsv_y < 0.2)
								{
									if(hsv_z < 0.5)
										s2 = strcat(s2, "^0");
									else
										s2 = strcat(s2, "^7");
								}
								else
								{
									if(hsv_x < 0.6)
										s2 = strcat(s2, "^1");
									else if(hsv_x < 1.33333333333333333333)
										s2 = strcat(s2, "^3");
									else if(hsv_x < 2.5)
										s2 = strcat(s2, "^2");
									else if(hsv_x < 3.33333333333333333333)
										s2 = strcat(s2, "^5");
									else if(hsv_x < 4.5)
										s2 = strcat(s2, "^4");
									else if(hsv_x < 5.5)
										s2 = strcat(s2, "^6");
									else
										s2 = strcat(s2, "^1");
								}
							}

							i += 3;
						}
						else
						{
							// blue missing
							s2 = strcat(s2, substring(s, i, 4));
							i += 2;
						}
					}
					else
					{
						// green missing
						s2 = strcat(s, substring(s2, i, 3));
						i += 1;
					}
				}
				else
				{
					// red missing
					s2 = strcat(s, substring(s2, i, 2));
				}
			}
			else
			{
				s2 = strcat(s2, ch, ch2);
			}
			++i;
			continue;
		}
		s2 = strcat(s2, ch);
	}

	return s2;
}

float cvar_or(string cv, float v)
{
	string s;
	s = cvar_string(cv);
	if(s == "")
		return v;
	else
		return stof(s);
}

vector project_3d_to_2d(vector vec)
{ 
	vec = cs_project(vec);
	if(cs_project_is_b0rked)
	{
		vec_x += vid_width / 2;
		vec_y += vid_height / 2;
	}
	vec_x *= vid_conwidth / vid_width;
	vec_y *= vid_conheight / vid_height;
	return vec;
}
