
float last_weapon;
float weapontime;

float sb_lines; // still don't know what to do with that NOTE: check dp's sbar.c to see what that should be

vector sbar;
float sbar_alpha_fg;
float sbar_hudselector;

float ps_primary, ps_secondary;
float ts_primary, ts_secondary;

void CSQC_kh_hud();
void CSQC_ctf_hud();
void CSQC_nb_hud();
void MapVote_Draw();
void Sbar_FinaleOverlay()
{
	/*vector pos;
	pos_x = (vid_conwidth - 1)/2;
	pos_y = 16;
	pos_z = 0;*/
	
	//drawpic(pos, "gfx/finale", '0 0 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);
	
	//drawstring(pos, "END", sbar_fontsize, '1 1 1', 1, DRAWFLAG_NORMAL);
	MapVote_Draw();
}

float weaponspace[10];
float weapon_first, weapon_last;
void Sbar_DrawWeapon_Clear()
{
	float idx;
	weapon_first = -2;
	weapon_last = -1;
	for(idx = 0; idx < 10; ++idx)
		weaponspace[idx] = 0;
	for(idx = 0; idx <= 23; ++idx)
	{
		if(weaponimpulse[idx] >= 0)
		{
			if(weapon_first < 0)
				weapon_first = idx;
			weapon_last = idx;
		}
	}
}
void Sbar_DrawWeapon(float nr, float fade, float active)
{
	vector pos, vsize, color;
	float value, idx, imp, sp;

	imp = weaponimpulse[nr];
	if(imp == 0)
		idx = 9;
	else
		idx = imp - 1;
	
	value = (active) ? 1 : 0.6;
	color_x = color_y = color_z = value;
	
	if(sbar_hudselector == 1)
	{
		// width = 300, height = 100
		const float w_width = 32, w_height = 12, w_space = 2, font_size = 8;

		sp = weaponspace[idx] + 1;
		weaponspace[idx] = sp;
		
		pos_x = (vid_conwidth - w_width * 9) * 0.5 + w_width * idx;
		pos_y = (vid_conheight - w_height * sp);
		pos_z = 0;
		vsize_x = w_width;
		vsize_y = w_height;
		vsize_z = 0;
		drawpic(pos, strcat("gfx/inv_weapon", ftos(nr)), vsize, color, value * fade * sbar_alpha_fg, 0);
		pos_x += w_space;
		pos_y += w_space;
		vsize_x = font_size;
		vsize_y = font_size;
		vsize_z = 0;
		drawstring(pos, ftos(imp), vsize, '1 1 0', sbar_alpha_fg, 0);
	}
	else
	{
		// width = 300, height = 100
		const float w2_width = 300, w2_height = 100, w2_space = 10;
		const float w2_scale = 0.4;

		float f;
		f = 9 / (weapon_last + 1 - weapon_first);

		pos_x = vid_conwidth - (w2_width + w2_space) * w2_scale * f;
		pos_y = (w2_height + w2_space) * w2_scale * nr * f + w2_space;
		pos_z = 0;
		vsize_x = w2_width * w2_scale * f;
		vsize_y = w2_height * w2_scale * f;
		vsize_z = 0;
		
		drawpic(pos, strcat("gfx/inv_weapon", ftos(nr)), vsize, color, value * fade * sbar_alpha_fg, 0);
	}
}
void Sbar_DrawXNum (vector pos, float num, float digits, float lettersize, vector rgb, float a, float dflags)
{
	float l, i;
	string str, tmp;
	float minus;
	vector vsize;

	vsize_x = vsize_y = lettersize;
	vsize_z = 0;

	if(num < 0)
	{
		minus = true;
		num = -num;
		pos_x -= lettersize;
	} else
		minus = false;
	
	if(digits < 0)
	{
		tmp = ftos(num);
		digits = -digits;
		str = strcat(substring("0000000000", 0, digits - strlen(tmp)), tmp);
	} else
		str = ftos(num);
	
	l = strlen(str);

	if(l > digits)
	{
		str = substring(str, l-digits, 999);
		l = strlen(str);
	} else if(l < digits)
		pos_x += (digits-l) * lettersize;

	if(minus)
	{
		drawpic(sbar + pos, "gfx/num_minus", vsize, rgb, a * sbar_alpha_fg, dflags);
		pos_x += lettersize;
	}

	for(i = 0; i < l; ++i)
	{
		drawpic(sbar + pos, strcat("gfx/num_", substring(str, i, 1)), vsize, rgb, a * sbar_alpha_fg, dflags);
		pos_x += lettersize;
	}
}

void Cmd_Sbar_SetFields(float argc);
void Sbar_InitScores()
{
	float i, f;

	ps_primary = ps_secondary = ts_primary = ts_secondary = -1;
	for(i = 0; i < MAX_SCORE; ++i)
	{
		f = (scores_flags[i] & SFL_SORT_PRIO_MASK);
		if(f == SFL_SORT_PRIO_PRIMARY)
			ps_primary = i;
		if(f == SFL_SORT_PRIO_SECONDARY)
			ps_secondary = i;
	}
	if(ps_secondary == -1)
		ps_secondary = ps_primary;
	
	for(i = 0; i < MAX_TEAMSCORE; ++i)
	{
		f = (teamscores_flags[i] & SFL_SORT_PRIO_MASK);
		if(f == SFL_SORT_PRIO_PRIMARY)
			ts_primary = i;
		if(f == SFL_SORT_PRIO_SECONDARY)
			ts_secondary = i;
	}
	if(ts_secondary == -1)
		ts_secondary = ts_primary;

	Cmd_Sbar_SetFields(0);
}

void Sbar_UpdatePlayerPos(entity pl);
float SetTeam(entity pl, float Team);
//float lastpnum;
void Sbar_UpdatePlayerTeams()
{
	float Team;
	entity pl, tmp;
	float num;

	num = 0;
	for(pl = players.sort_next; pl; pl = pl.sort_next)
	{
		num += 1;
		Team = GetPlayerColor(pl.sv_entnum);
		if(SetTeam(pl, Team))
		{
			tmp = pl.sort_prev;
			Sbar_UpdatePlayerPos(pl);
			if(tmp)
				pl = tmp;
			else
				pl = players.sort_next;
		}
	}
	/*
	if(num != lastpnum)
		print(strcat("PNUM: ", ftos(num), "\n"));
	lastpnum = num;
	*/
}

float Sbar_ComparePlayerScores(entity left, entity right)
{
	float vl, vr;
	vl = GetPlayerColor(left.sv_entnum);
	vr = GetPlayerColor(right.sv_entnum);

	if(!left.gotscores)
		vl = COLOR_SPECTATOR;
	if(!right.gotscores)
		vr = COLOR_SPECTATOR;
	
	if(vl > vr)
		return true;
	if(vl < vr)
		return false;

	if(vl == COLOR_SPECTATOR)
	{
		// FIRST the one with scores (spectators), THEN the ones without (downloaders)
		// no other sorting
		if(!left.gotscores && right.gotscores)
			return true;
		return false;
	}

	vl = left.scores[ps_primary];
	vr = right.scores[ps_primary];
	if(scores_flags[ps_primary] & SFL_ZERO_IS_WORST)
	{
		if(vl == 0 && vr != 0)
			return 1;
		if(vl != 0 && vr == 0)
			return 0;
	}
	if(vl > vr)
		return IS_INCREASING(scores_flags[ps_primary]);
	if(vl < vr)
		return IS_DECREASING(scores_flags[ps_primary]);
	
	vl = left.scores[ps_secondary];
	vr = right.scores[ps_secondary];
	if(scores_flags[ps_secondary] & SFL_ZERO_IS_WORST)
	{
		if(vl == 0 && vr != 0)
			return 1;
		if(vl != 0 && vr == 0)
			return 0;
	}
	if(vl > vr)
		return IS_INCREASING(scores_flags[ps_secondary]);
	if(vl < vr)
		return IS_DECREASING(scores_flags[ps_secondary]);
	
	return false;
}

void Sbar_UpdatePlayerPos(entity player)
{
	for(other = player.sort_next; other && Sbar_ComparePlayerScores(player, other); other = player.sort_next)
	{
		SORT_SWAP(player, other);
	}
	for(other = player.sort_prev; other != players && Sbar_ComparePlayerScores(other, player); other = player.sort_prev)
	{
		SORT_SWAP(other, player);
	}
}

float Sbar_CompareTeamScores(entity left, entity right)
{
	float vl, vr;

	if(left.team == COLOR_SPECTATOR)
		return 1;
	if(right.team == COLOR_SPECTATOR)
		return 0;
	
	vl = left.teamscores[ts_primary];
	vr = right.teamscores[ts_primary];
	if(vl > vr)
		return IS_INCREASING(teamscores_flags[ts_primary]);
	if(vl < vr)
		return IS_DECREASING(teamscores_flags[ts_primary]);
	
	vl = left.teamscores[ts_secondary];
	vr = right.teamscores[ts_secondary];
	if(vl > vr)
		return IS_INCREASING(teamscores_flags[ts_secondary]);
	if(vl < vr)
		return IS_DECREASING(teamscores_flags[ts_secondary]);

	return false;
}

void Sbar_UpdateTeamPos(entity Team)
{
	for(other = Team.sort_next; other && Sbar_CompareTeamScores(Team, other); other = Team.sort_next)
	{
		SORT_SWAP(Team, other);
	}
	for(other = Team.sort_prev; other != teams && Sbar_CompareTeamScores(other, Team); other = Team.sort_prev)
	{
		SORT_SWAP(other, Team);
	}
}

void Cmd_Sbar_Help(float argc)
{
	print("You can modify the scoreboard using the\n");
	print("^3|---------------------------------------------------------------|\n");
	print("^1 TO BE DONE\n");
	print("Usage:\n");
	print("^2sbar_columns_set default\n");
	print("^2sbar_columns_set ^7filed1 field2 ...\n");
	print("The following field names are recognized (case INsensitive):\n");
	print("You can use a ^3|^7 to start the right-aligned fields.\n");
	
	print("^3name^7 or ^3nick^7             Name of a player\n");
	print("^3ping^7                     Ping time\n\n");
	print("^3kd^7 or ^3kdr^7 or ^3kdratio^7 or ^3k/d\n");
	print("                         The kill-death ratio\n");

	print("Before a field you can put a + or - sign, then a comma separated list\n");
	print("of game types, then a slash, to make the field show up only in these\n");
	print("or in all but these game types.\n");

	print("The special game type names 'teams' and 'noteams' can be used to\n");
	print("include/exclude ALL teams/noteams game modes.\n");

	local float i;
	print("Additional columns:\n");
	for(i = 0; i < MAX_SCORE; ++i)
	{
		if(scores_label[i] != "")
			print(strcat(scores_label[i], "\n"));
	}
}

#define MIN_NAMELEN 24
#define MAX_NAMELEN 24

string Sbar_DefaultColumnLayout()
{
	return strcat( // fteqcc sucks
		"ping pl name | ",
		"-teams,race,lms/kills -teams,lms/deaths -teams,lms,race/suicides -race,dm,tdm/frags ", // tdm already has this in "score"
		"+ctf/caps +ctf/pickups +ctf/fckills +ctf/returns ",
		"+lms/lives +lms/rank ",
		"+kh/caps +kh/pushes +kh/destroyed ",
		"?+race/laps ?+race/time ?+race/fastest ",
		"+as/objectives ",
		"-lms,race/score");
}

void Cmd_Sbar_SetFields(float argc)
{
	float i, j, slash;
	string str, pattern;
	float digit;
	float have_name, have_primary, have_secondary, have_separator;
	float missing;

	// TODO: re enable with gametype dependant cvars?
	if(argc < 2) // no arguments provided
		argc = tokenizebyseparator(strcat("x ", cvar_string("sbar_columns")), " ");

	if(argc < 2)
		argc = tokenizebyseparator(strcat("x ", Sbar_DefaultColumnLayout()), " ");

	if(argc == 2)
	{
		if(argv(1) == "default")
			argc = tokenizebyseparator(strcat("x ", Sbar_DefaultColumnLayout()), " ");
		else if(argv(1) == "all")
		{
			string s;
			s = "ping pl color name |";
			for(i = 0; i < MAX_SCORE; ++i)
			{
				if(i != ps_primary)
				if(i != ps_secondary)
				if(scores_label[i] != "")
					s = strcat(s, " ", scores_label[i]);
			}
			if(ps_secondary != ps_primary)
				s = strcat(s, " ", scores_label[ps_secondary]);
			s = strcat(s, " ", scores_label[ps_primary]);
			argc = tokenizebyseparator(strcat("x ", s), " ");
		}
	}
		
	
	sbar_num_fields = 0;

	drawfont = sbar_font;
	digit = stringwidth("0123456789", FALSE) / 10;

	for(i = 0; i < argc - 1; ++i)
	{
		float nocomplain;
		str = argv(i+1);

		nocomplain = FALSE;
		if(substring(str, 0, 1) == "?")
		{
			nocomplain = TRUE;
			str = substring(str, 1, strlen(str) - 1);
		}

		slash = strstrofs(str, "/", 0);
		if(slash >= 0)
		{
			pattern = substring(str, 0, slash);
			str = substring(str, slash + 1, strlen(str) - (slash + 1));

			if not(isGametypeInFilter(gametype, teamplay, pattern))
				continue;
		}

		strunzone(sbar_title[sbar_num_fields]);
		sbar_title[sbar_num_fields] = strzone(str);
		sbar_size[sbar_num_fields] = stringwidth(str, FALSE);
		str = strtolower(str);

		if(str == "ping") {
			sbar_field[sbar_num_fields] = SP_PING;
		} else if(str == "pl") {
			sbar_field[sbar_num_fields] = SP_PL;
		} else if(str == "kd" || str == "kdr" || str == "kdratio" || str == "k/d") {
			sbar_field[sbar_num_fields] = SP_KDRATIO;
		} else if(str == "name" || str == "nick") {
			sbar_field[sbar_num_fields] = SP_NAME;
			sbar_size[sbar_num_fields] = MIN_NAMELEN; // minimum size? any use?
			have_name = 1;
		} else if(str == "|") {
			sbar_field[sbar_num_fields] = SP_SEPARATOR;
			have_separator = 1;
		} else {
			for(j = 0; j < MAX_SCORE; ++j)
				if(str == strtolower(scores_label[j]))
					goto found; // sorry, but otherwise fteqcc -O3 miscompiles this and warns about "unreachable code"
:notfound
			if(str == "frags")
			{
				j = SP_FRAGS;
			}
			else
			{
				if not(nocomplain)
					print(strcat("^1Error:^7 Unknown score field: '", str, "'\n"));
				continue;
			}
:found
			sbar_field[sbar_num_fields] = j;
			if(j == ps_primary)
				have_primary = 1;
			if(j == ps_secondary)
				have_secondary = 1;
		}
		++sbar_num_fields;
		if(sbar_num_fields >= MAX_SBAR_FIELDS)
			break;
	}

	if(scores_flags[ps_primary] & SFL_ALLOW_HIDE)
		have_primary = 1;
	if(scores_flags[ps_secondary] & SFL_ALLOW_HIDE)
		have_secondary = 1;
	if(ps_primary == ps_secondary)
		have_secondary = 1;
	missing = !have_primary + !have_secondary + !have_separator + !have_name;

	if(sbar_num_fields+missing < MAX_SBAR_FIELDS)
	{
		if(!have_name)
		{
			strunzone(sbar_title[sbar_num_fields]);
			for(i = sbar_num_fields; i > 0; --i)
			{
				sbar_title[i] = sbar_title[i-1];
				sbar_size[i] = sbar_size[i-1];
				sbar_field[i] = sbar_field[i-1];
			}
			sbar_title[0] = strzone("name");
			sbar_field[0] = SP_NAME;
			sbar_size[0] = MIN_NAMELEN; // minimum size? any use?
			++sbar_num_fields;
			print("fixed missing field 'name'\n");

			if(!have_separator)
			{
				strunzone(sbar_title[sbar_num_fields]);
				for(i = sbar_num_fields; i > 1; --i)
				{
					sbar_title[i] = sbar_title[i-1];
					sbar_size[i] = sbar_size[i-1];
					sbar_field[i] = sbar_field[i-1];
				}
				sbar_title[1] = strzone("|");
				sbar_field[1] = SP_SEPARATOR;
				sbar_size[1] = stringwidth("|", FALSE);
				++sbar_num_fields;
				print("fixed missing field '|'\n");
			}
		}
		else if(!have_separator)
		{
			strunzone(sbar_title[sbar_num_fields]);
			sbar_title[sbar_num_fields] = strzone("|");
			sbar_size[sbar_num_fields] = stringwidth("|", FALSE);
			sbar_field[sbar_num_fields] = SP_SEPARATOR;
			++sbar_num_fields;
			print("fixed missing field '|'\n");
		}

		if(!have_secondary)
		{
			strunzone(sbar_title[sbar_num_fields]);
			sbar_title[sbar_num_fields] = strzone(scores_label[ps_secondary]);
			sbar_size[sbar_num_fields] = stringwidth(sbar_title[sbar_num_fields], FALSE);
			sbar_field[sbar_num_fields] = ps_secondary;
			++sbar_num_fields;
			print("fixed missing field '", scores_label[ps_secondary], "'\n");
		}

		if(!have_primary)
		{
			strunzone(sbar_title[sbar_num_fields]);
			sbar_title[sbar_num_fields] = strzone(scores_label[ps_primary]);
			sbar_size[sbar_num_fields] = stringwidth(sbar_title[sbar_num_fields], FALSE);
			sbar_field[sbar_num_fields] = ps_primary;
			++sbar_num_fields;
			print("fixed missing field '", scores_label[ps_primary], "'\n");
		}
	}

	sbar_field[sbar_num_fields] = SP_END;
}

// MOVEUP::
vector sbar_field_rgb;
string sbar_field_icon0;
string sbar_field_icon1;
string sbar_field_icon2;
vector sbar_field_icon0_rgb;
vector sbar_field_icon1_rgb;
vector sbar_field_icon2_rgb;
float sbar_field_icon0_alpha;
float sbar_field_icon1_alpha;
float sbar_field_icon2_alpha;
string Sbar_GetField(entity pl, float field)
{
	float tmp, num, denom, f;
	string str;
	sbar_field_rgb = '1 1 1';
	sbar_field_icon0 = "";
	sbar_field_icon1 = "";
	sbar_field_icon2 = "";
	sbar_field_icon0_rgb = '1 1 1';
	sbar_field_icon1_rgb = '1 1 1';
	sbar_field_icon2_rgb = '1 1 1';
	sbar_field_icon0_alpha = 1;
	sbar_field_icon1_alpha = 1;
	sbar_field_icon2_alpha = 1;
	switch(field)
	{
		case SP_PING:
			if not(pl.gotscores)
				return "\x8D\x8D\x8D"; // >>> sign
			str = getplayerkey(pl.sv_entnum, "ping");
			if(str == "0")
				return "N/A";
			tmp = max(0, min(220, stof(str)-80)) / 220;
			sbar_field_rgb = '1 1 1' - '0 1 1'*tmp;
			return str;
		
		case SP_PL:
			if not(pl.gotscores)
				return "N/A";
			str = getplayerkey(pl.sv_entnum, "pl");
			if(str == "0")
				return "";
			tmp = bound(0, stof(str), 20) / 20; // 20% is REALLY BAD pl
			sbar_field_rgb = '1 0.5 0.5' - '0 0.5 0.5'*tmp;
			return str;
		
		case SP_NAME:
			if(ready_waiting && pl.ready)
			{
				sbar_field_icon0 = "gfx/sb_player_ready";
			}
			else if(!teamplay)
			{
				f = stof(getplayerkey(pl.sv_entnum, "colors"));
				{
					sbar_field_icon0 = "gfx/sb_playercolor_base";
					sbar_field_icon1 = "gfx/sb_playercolor_shirt";
					sbar_field_icon1_rgb = colormapPaletteColor(floor(f / 16), 0);
					sbar_field_icon2 = "gfx/sb_playercolor_pants";
					sbar_field_icon2_rgb = colormapPaletteColor(mod(f, 16), 1);
				}
			}
			return GetPlayerName(pl.sv_entnum);

		case SP_FRAGS:
			f = pl.(scores[SP_KILLS]);
			f -= pl.(scores[SP_SUICIDES]);
			return ftos(f);

		case SP_KDRATIO:
			num = pl.(scores[SP_KILLS]);
			denom = pl.(scores[SP_DEATHS]);

			if(denom == 0) {
				sbar_field_rgb = '0 1 0';
				str = ftos(num);
			} else if(num <= 0) {
				sbar_field_rgb = '1 0 0';
				str = ftos(num/denom);
			} else
				str = ftos(num/denom);
		
			tmp = strstrofs(str, ".", 0);
			if(tmp > 0)
				str = substring(str, 0, tmp+2);
			return str;
			
		default:
			tmp = pl.(scores[field]);
			f = scores_flags[field];
			if(field == ps_primary)
				sbar_field_rgb = '1 1 0';
			else if(field == ps_secondary)
				sbar_field_rgb = '0 1 1';
			else
				sbar_field_rgb = '1 1 1';
			return ScoreString(f, tmp);
	}
	//return "error";
}

float xmin, xmax, ymin, ymax, sbwidth;
float sbar_fixscoreboardcolumnwidth_len;
float sbar_fixscoreboardcolumnwidth_iconlen;
float sbar_fixscoreboardcolumnwidth_marginlen;

float stringwidth_colors(string s)
{
	return stringwidth(s, TRUE);
}

float stringwidth_nocolors(string s)
{
	return stringwidth(s, FALSE);
}

string Sbar_FixScoreboardColumnWidth(float i, string str)
{
	float field, maxsize, j, f;
	vector sz;
	field = sbar_field[i];

	if(field == SP_NAME) // name gets all remaining space
	{
		maxsize = (xmax - xmin) / sbar_fontsize_x;
		for(j = 0; j < sbar_num_fields; ++j) if(j != i) if(sbar_field[j] != SP_SEPARATOR)
			maxsize -= sbar_size[j] + 1;
		maxsize += 1;
		str = textShortenToWidth(str, maxsize, stringwidth_colors);
		sbar_fixscoreboardcolumnwidth_len = stringwidth(str, TRUE);
	}
	else
		sbar_fixscoreboardcolumnwidth_len = stringwidth(str, FALSE);
	
	sbar_fixscoreboardcolumnwidth_iconlen = 0;

	if(sbar_field_icon0 != "")
	{
		sz = drawgetimagesize(sbar_field_icon0);
		f = sz_x / sz_y;
		if(sbar_fixscoreboardcolumnwidth_iconlen < f)
			sbar_fixscoreboardcolumnwidth_iconlen = f;
	}

	if(sbar_field_icon1 != "")
	{
		sz = drawgetimagesize(sbar_field_icon1);
		f = sz_x / sz_y;
		if(sbar_fixscoreboardcolumnwidth_iconlen < f)
			sbar_fixscoreboardcolumnwidth_iconlen = f;
	}

	if(sbar_field_icon2 != "")
	{
		sz = drawgetimagesize(sbar_field_icon2);
		f = sz_x / sz_y;
		if(sbar_fixscoreboardcolumnwidth_iconlen < f)
			sbar_fixscoreboardcolumnwidth_iconlen = f;
	}

	sbar_fixscoreboardcolumnwidth_iconlen *= sbar_fontsize_y / sbar_fontsize_x; // fix icon aspect

	if(sbar_fixscoreboardcolumnwidth_iconlen != 0 && sbar_fixscoreboardcolumnwidth_len != 0)
		sbar_fixscoreboardcolumnwidth_marginlen = stringwidth(" ", FALSE);
	else
		sbar_fixscoreboardcolumnwidth_marginlen = 0;

	f = sbar_fixscoreboardcolumnwidth_len + sbar_fixscoreboardcolumnwidth_marginlen + sbar_fixscoreboardcolumnwidth_iconlen;
	if(sbar_size[i] < f)
		sbar_size[i] = f;

	return str;
}

void Sbar_PrintScoreboardItem(vector pos, entity pl, float is_self)
{
	vector tmp;
	string str;
	float i, field;
	float is_spec;
	is_spec = (GetPlayerColor(pl.sv_entnum) == COLOR_SPECTATOR);

	// Layout:
	tmp_z = 0;
	if(is_self)
	{
		tmp_x = sbwidth;
		tmp_y = sbar_fontsize_y;
		drawfill(pos - '1 1 0', tmp + '2 2 0', '1 1 1', 0.3, DRAWFLAG_NORMAL);
	}	
	tmp_y = 0;
	
	for(i = 0; i < sbar_num_fields; ++i)
	{
		field = sbar_field[i];
		if(field == SP_SEPARATOR)
			break;

		if(is_spec && field != SP_NAME && field != SP_PING) {
			pos_x += sbar_fontsize_x*sbar_size[i] + sbar_fontsize_x;
			continue;
		}
		str = Sbar_GetField(pl, field);
		str = Sbar_FixScoreboardColumnWidth(i, str);

		pos_x += sbar_fontsize_x*sbar_size[i] + sbar_fontsize_x;

		if(field == SP_NAME) {
			tmp_x = sbar_fontsize_x*(sbar_size[i] - sbar_fixscoreboardcolumnwidth_iconlen - sbar_fixscoreboardcolumnwidth_marginlen) + sbar_fontsize_x;
			drawcolorcodedstring(pos - tmp, str, sbar_fontsize, 1, DRAWFLAG_NORMAL);
		} else {
			tmp_x = sbar_fixscoreboardcolumnwidth_len*sbar_fontsize_x + sbar_fontsize_x;
			drawstring(pos - tmp, str, sbar_fontsize, sbar_field_rgb, 1, DRAWFLAG_NORMAL);
		}

		tmp_x = sbar_fontsize_x*sbar_size[i] + sbar_fontsize_x;
		if(sbar_field_icon0 != "")
			drawpic(pos - tmp, sbar_field_icon0, '0 1 0' * sbar_fontsize_y + '1 0 0' * sbar_fontsize_x * sbar_fixscoreboardcolumnwidth_iconlen, sbar_field_icon1_rgb, sbar_field_icon0_alpha, 0);
		if(sbar_field_icon1 != "")
			drawpic(pos - tmp, sbar_field_icon1, '0 1 0' * sbar_fontsize_y + '1 0 0' * sbar_fontsize_x * sbar_fixscoreboardcolumnwidth_iconlen, sbar_field_icon1_rgb, sbar_field_icon1_alpha, 0);
		if(sbar_field_icon2 != "")
			drawpic(pos - tmp, sbar_field_icon2, '0 1 0' * sbar_fontsize_y + '1 0 0' * sbar_fontsize_x * sbar_fixscoreboardcolumnwidth_iconlen, sbar_field_icon2_rgb, sbar_field_icon2_alpha, 0);
	}
	
	if(sbar_field[i] == SP_SEPARATOR)
	{
		pos_x = xmax;
		for(i = sbar_num_fields-1; i > 0; --i)
		{
			field = sbar_field[i];
			if(field == SP_SEPARATOR)
				break;
			
			if(is_spec && field != SP_NAME && field != SP_PING) {
				pos_x -= sbar_fontsize_x*sbar_size[i] + sbar_fontsize_x;
				continue;
			}
			
			str = Sbar_GetField(pl, field);
			str = Sbar_FixScoreboardColumnWidth(i, str);

			if(field == SP_NAME) {
				tmp_x = sbar_fontsize_x*sbar_fixscoreboardcolumnwidth_len; // left or right aligned? let's put it right...
				drawcolorcodedstring(pos - tmp, str, sbar_fontsize, 1, DRAWFLAG_NORMAL);
			} else {
				tmp_x = sbar_fontsize_x*sbar_fixscoreboardcolumnwidth_len; //strlen(str);
				drawstring(pos - tmp, str, sbar_fontsize, sbar_field_rgb, 1, DRAWFLAG_NORMAL);
			}

			tmp_x = sbar_fontsize_x*sbar_size[i];
			if(sbar_field_icon0 != "")
				drawpic(pos - tmp, sbar_field_icon0, '0 1 0' * sbar_fontsize_y + '1 0 0' * sbar_fontsize_x * sbar_fixscoreboardcolumnwidth_iconlen, sbar_field_icon1_rgb, sbar_field_icon0_alpha, 0);
			if(sbar_field_icon1 != "")
				drawpic(pos - tmp, sbar_field_icon1, '0 1 0' * sbar_fontsize_y + '1 0 0' * sbar_fontsize_x * sbar_fixscoreboardcolumnwidth_iconlen, sbar_field_icon1_rgb, sbar_field_icon1_alpha, 0);
			if(sbar_field_icon2 != "")
				drawpic(pos - tmp, sbar_field_icon2, '0 1 0' * sbar_fontsize_y + '1 0 0' * sbar_fontsize_x * sbar_fixscoreboardcolumnwidth_iconlen, sbar_field_icon2_rgb, sbar_field_icon2_alpha, 0);

			pos_x -= sbar_fontsize_x*sbar_size[i] + sbar_fontsize_x;
		}
	}
}

float lastpingstime;
float scoreboard_bottom;
void Sbar_DrawScoreboard()
{
	//float xmin, ymin, xmax, ymax;
	vector rgb, pos, tmp, sbar_save;
	entity pl, tm;
	float specs, i;
	float center_x;

	if(time > lastpingstime + 10)
	{
		localcmd("pings\n");
		lastpingstime = time;
	}

	sbwidth = Sbar_GetWidth(6.5 * sbar_fontsize_y);

	xmin = 0.5 * (vid_conwidth - sbwidth);
	ymin = 45;

	xmax = vid_conwidth - xmin;
    ymax = vid_conheight - 0.2*vid_conheight;

	center_x = xmin + 0.5*sbwidth;

	//Sbar_UpdateFields();

	// Initializes position
	//pos_x = xmin;
	pos_y = ymin;
	pos_z = 0;

	// Heading
	drawfont = sbar_bigfont;
	pos_x = center_x - stringwidth("Scoreboard", TRUE)*0.5*24;
	drawstring(pos, "Scoreboard", '24 24 0', '1 1 1', 1, DRAWFLAG_NORMAL);
	pos_x = xmin;
	pos_y += 24 + 4;

	// Titlebar background:
	tmp_x = sbwidth;
	tmp_y = sbar_fontsize_y;
	drawfill(pos - '1 1 0', tmp + '2 2 0', '0.5 0.5 0.5', 0.5, DRAWFLAG_NORMAL);
	
	drawfont = sbar_font;

	for(i = 0; i < sbar_num_fields; ++i)
	{
		if(sbar_field[i] == SP_SEPARATOR)
			break;
		drawstring(pos, sbar_title[i], sbar_fontsize, '1 1 1', 1, DRAWFLAG_NORMAL);
		pos_x += sbar_fontsize_x*sbar_size[i] + sbar_fontsize_x;
	}
	
	if(sbar_field[i] == SP_SEPARATOR)
	{
		pos_x = xmax + sbar_fontsize_x;
		tmp_y = tmp_z = 0;
		for(i = sbar_num_fields-1; i > 0; --i)
		{
			if(sbar_field[i] == SP_SEPARATOR)
				break;

			pos_x -= sbar_fontsize_x*sbar_size[i] + sbar_fontsize_x;
			/**
			 * FTEQCC BUG!
			 * Using the following line will mess it all up:
			 **
			 * tmp_x = sbar_size[i] - strlen(sbar_title[i])*8;
			 */
			tmp_x = sbar_fontsize_x*sbar_size[i];
			tmp_x -= stringwidth(sbar_title[i], FALSE)*sbar_fontsize_x;
			drawstring(pos + tmp, sbar_title[i], sbar_fontsize, '1 1 1', 1, DRAWFLAG_NORMAL);
		}
	}
		
	pos_x = xmin;
	pos_y += 1.5 * sbar_fontsize_y;

	sbar_save = sbar;
	sbar = '0 0 0';
	
	if(teamplay)
	{
		//for(tm = sortedTeams.sort_next; tm; tm = tm.sort_next)
		for(tm = teams.sort_next; tm; tm = tm.sort_next)
		{
			if(!tm.team_size || tm.team == COLOR_SPECTATOR)
				continue;

			rgb = GetTeamRGB(tm.team);

			pos_x = xmin;

			Sbar_DrawXNum(
				pos - '6.5 0 0' * sbar_fontsize_y,
				tm.(teamscores[ts_primary]),
				4, sbar_fontsize_y * 1.5, rgb, 1, DRAWFLAG_NORMAL);

			if(ts_primary != ts_secondary)
			Sbar_DrawXNum(
				pos - '4.5 0 0' * sbar_fontsize_y + '0 1.5 0' * sbar_fontsize_y,
				tm.(teamscores[ts_secondary]),
				4, sbar_fontsize_y * 1, rgb, 1, DRAWFLAG_NORMAL);
			
			specs = tm.team_size;

			if(specs < 2)
				specs = 2;
			
			tmp_x = sbwidth;
			tmp_y = 1.25 * sbar_fontsize_y * specs;
			drawfill(pos - '1 1 0', tmp + '2 0 0', rgb, 0.2, DRAWFLAG_NORMAL);
			
			for(pl = players.sort_next; pl; pl = pl.sort_next)
			{
				if(pl.team != tm.team)
					continue;
				Sbar_PrintScoreboardItem(pos, pl, (pl.sv_entnum == player_localentnum - 1));
				pos_y += 1.25 * sbar_fontsize_y;
				tmp_y -= 1.25 * sbar_fontsize_y;
			}
			pos_y += tmp_y + 1.5 * sbar_fontsize_y;
		}
		// rgb := tempvector :)
		rgb = pos + '0 1.5 0' * sbar_fontsize_y;
		pos_y += 3 * sbar_fontsize_y;
		specs = 0;
		for(pl = players.sort_next; pl; pl = pl.sort_next)
		{
			if(pl.team != COLOR_SPECTATOR)
				continue;
			Sbar_PrintScoreboardItem(pos, pl, (pl.sv_entnum == player_localentnum - 1));
			pos += '0 1.25 0' * sbar_fontsize_y;
			++specs;
		}
			
		if(specs)
			drawstring(rgb, "Spectators", sbar_fontsize, '1 1 1', 1, 0);
	} else {
		pos_x = xmin;
		for(pl = players.sort_next; pl; pl = pl.sort_next)
		{
			if(pl.team == COLOR_SPECTATOR)
				continue;
			Sbar_PrintScoreboardItem(pos, pl, (pl.sv_entnum == player_localentnum - 1));
			pos_y += 1.25 * sbar_fontsize_y;
			tmp_y -= 1.25 * sbar_fontsize_y;
		}

		// rgb := tempvector :)
		rgb = pos + '0 1.5 0' * sbar_fontsize_y;
		pos_y += 3 * sbar_fontsize_y;
		specs = 0;
		for(pl = players.sort_next; pl; pl = pl.sort_next)
		{
			if(pl.team != COLOR_SPECTATOR)
				continue;
			Sbar_PrintScoreboardItem(pos, pl, (pl.sv_entnum == player_localentnum - 1));
			pos += '0 1.25 0' * sbar_fontsize_y;
			++specs;
		}
			
		if(specs)
			drawstring(rgb, "Spectators", sbar_fontsize, '1 1 1', 1, 0);
	}

	string str;
	float tl, fl;
	str = strcat("playing on ^2", shortmapname, "^7");
	tl = getstatf(STAT_TIMELIMIT);
	fl = getstatf(STAT_FRAGLIMIT);
	if(gametype == GAME_LMS)
	{
		if(tl > 0)
			str = strcat(str, " for up to ^1", ftos(tl), " minutes^7");
	}
	else
	{
		if(tl > 0)
			str = strcat(str, " for ^1", ftos(tl), " minutes^7");
		if(fl > 0)
		{
			if(tl > 0)
				str = strcat(str, " or");
			if(teamplay)
			{
				str = strcat(str, " until ^3", ScoreString(teamscores_flags[ts_primary], fl));
				if(teamscores_label[ts_primary] == "score")
					str = strcat(str, " points^7");
				else if(teamscores_label[ts_primary] == "fastest")
					str = strcat(str, " is beaten^7");
				else
					str = strcat(str, " ", teamscores_label[ts_primary]);
			}
			else
			{
				str = strcat(str, " until ^3", ScoreString(scores_flags[ps_primary], fl));
				if(scores_label[ps_primary] == "score")
					str = strcat(str, " points^7");
				else if(scores_label[ps_primary] == "fastest")
					str = strcat(str, " is beaten^7");
				else
					str = strcat(str, " ", scores_label[ps_primary]);
			}
		}
	}
	

	pos_y += 1.2 * sbar_fontsize_y;
	drawcolorcodedstring(pos + '0.5 0 0' * (sbwidth - sbar_fontsize_x * stringwidth(str, TRUE)), str, sbar_fontsize, 0.8, 0);
	
	sbar = sbar_save;
	scoreboard_bottom = pos_y + 2 * sbar_fontsize_y;
}

string MakeRaceString(float cp, float mytime, float histime, float lapdelta, string hisname)
{
	string col;
	string timestr;
	string cpname;
	string lapstr;
	lapstr = "";

	if(histime == 0) // goal hit
	{
		if(mytime > 0)
		{
			timestr = strcat("+", ftos_decimals(+mytime, 1));
			col = "^1";
		}
		else if(mytime == 0)
		{
			timestr = "+0.0";
			col = "^3";
		}
		else
		{
			timestr = strcat("-", ftos_decimals(-mytime, 1));
			col = "^2";
		}

		if(lapdelta > 0)
		{
			lapstr = strcat(" (-", ftos(lapdelta), "L)");
			col = "^2";
		}
		else if(lapdelta < 0)
		{
			lapstr = strcat(" (+", ftos(-lapdelta), "L)");
			col = "^1";
		}
	}
	else if(histime > 0) // anticipation
	{
		if(mytime >= histime)
			timestr = strcat("+", ftos_decimals(mytime - histime, 1));
		else
			timestr = mmsss(histime * 10);
		col = "^3";
	}
	else
		col = "^7";

	if(cp)
		cpname = strcat("Intermediate ", ftos(cp));
	else
		cpname = "Finish line";
	
	if(histime < 0)
		return strcat(col, cpname);
	else if(hisname == "")
		return strcat(col, cpname, " (", timestr, ")");
	else
		return strcat(col, cpname, " (", timestr, " ", strcat(hisname, col, lapstr), ")");
}

void Sbar_Score(float margin)
{
	float timelimit, minutes, seconds, timeleft, minutesLeft, secondsLeft, distribution, myplace, score;
	vector sbar_save, place, timer_color;
	entity tm, pl, me;
	sbar_save = sbar;
	
	myteam = GetPlayerColor(player_localentnum - 1);

	sbar_y = vid_conheight - (32+12);
	sbar_x -= margin;
	
	place = '-48 -12 0';
	if(teamplay)
	{
		// Layout:
		//
		//   team1 team3 team4
		//
		//         TEAM2
		//for(i = 0; i < 4; ++i)
		for(tm = teams.sort_next; tm; tm = tm.sort_next)
		{
			if(tm.team == COLOR_SPECTATOR || !tm.team_size) // no players? don't display
				continue;
			// -32*4 = -128
			score = tm.(teamscores[ts_primary]);
			if(tm.team == myteam)
				Sbar_DrawXNum('-128 0 0', score, 4, 32, GetTeamRGB(tm.team), 1, DRAWFLAG_NORMAL);
			else
			{
				Sbar_DrawXNum(place, score, 4, 12, GetTeamRGB(tm.team), 1, DRAWFLAG_NORMAL);
				place_x -= 4*12;
			}
		}
	} else {
		// me vector := [team/connected frags id]
		myplace = 0;
		for(me = players.sort_next; me; me = me.sort_next)
		{
			if(me.team != COLOR_SPECTATOR)
				++myplace;
			if(me.sv_entnum == player_localentnum - 1)
				break;
		}
		pl = players.sort_next;
		if(pl == me)
			pl = pl.sort_next;
		
		if(pl) {
			distribution = me.(scores[ps_primary]);
			distribution -= pl.(scores[ps_primary]);
		} else
			distribution = 0;
		
		if(myplace == 1)
			Sbar_DrawXNum('-36 -12 0', myplace, 3, 12, '1 1 1', 1, DRAWFLAG_NORMAL);
		else if(myplace == 2)
			Sbar_DrawXNum('-36 -12 0', myplace, 3, 12, '1 1 0', 1, DRAWFLAG_NORMAL);
		else
			Sbar_DrawXNum('-36 -12 0', myplace, 3, 12, '1 0 0', 1, DRAWFLAG_NORMAL);

		score = me.(scores[ps_primary]);
		if(distribution >= 0)
		{
			Sbar_DrawXNum('-84 -12 0', distribution, 4, 12, ' 1 1 1', 1, DRAWFLAG_NORMAL);
			Sbar_DrawXNum('-128 0 0', score, 4, 32, '1 1 1', 1, DRAWFLAG_NORMAL);
		} else if(distribution >= -5)
		{
			Sbar_DrawXNum('-84 -12 0', distribution, 4, 12, ' 1 1 0', 1, DRAWFLAG_NORMAL);
			Sbar_DrawXNum('-128 0 0', score, 4, 32, '1 1 0', 1, DRAWFLAG_NORMAL);
		} else {
			Sbar_DrawXNum('-84 -12 0', distribution, 4, 12, ' 1 0 0', 1, DRAWFLAG_NORMAL);
			Sbar_DrawXNum('-128 0 0', score, 4, 32, '1 0 0', 1, DRAWFLAG_NORMAL);
		}
	}
	
	//draw the remaining or elapsed time
	timelimit = getstatf(STAT_TIMELIMIT);
	if(timelimit > 0)
	{
		timeleft = max(0, timelimit * 60 + getstatf(STAT_GAMESTARTTIME) - time);
		timeleft = ceil(timeleft);
		minutesLeft = floor(timeleft / 60);
		secondsLeft = timeleft - minutesLeft*60;
		
		if(minutesLeft >= 5) {
			timer_color = '1 1 1'; //white
		} else if(minutesLeft >= 1) {
			timer_color = '1 1 0'; //yellow
		} else {
			timer_color = '1 0 0'; //red
		}
		
		if (warmup_stage) {
			timer_color = '1 1 1'; //don't use red or yellow for timer during warmup
		}
		
		if (cvar("sbar_increment_maptime")) {
			if (time < getstatf(STAT_GAMESTARTTIME)) {
				//while restart is still active, show negative counter
				minutes = 0;
				seconds = ceil(getstatf(STAT_GAMESTARTTIME) - time);
			} else {
				float elapsedTime;
				elapsedTime = floor(time - getstatf(STAT_GAMESTARTTIME)); //127
				minutes = floor(elapsedTime / 60);
				seconds = elapsedTime - minutes*60;
			}
		} else {
			minutes = minutesLeft;
			seconds = secondsLeft;
		}
		
		if(minutesLeft >= 1 || (cvar("sbar_increment_maptime") && minutes >= 1) ) {
			Sbar_DrawXNum('-72 32 0', minutes, 3, 12, timer_color, 1, DRAWFLAG_NORMAL);
			drawpic(sbar + '-36 32 0', "gfx/num_colon", '12 12 0', timer_color, sbar_alpha_fg, 0);
		}
		Sbar_DrawXNum('-24 32 0', seconds, -2, 12, timer_color, 1, DRAWFLAG_NORMAL);
	} else {
		timer_color = '1 1 1'; //white
		minutes = floor(time / 60);
		seconds = floor(time - minutes*60);
		Sbar_DrawXNum('-72 32 0', minutes, 3, 12, timer_color, 1, DRAWFLAG_NORMAL);
		drawpic(sbar + '-36 32 0', "gfx/num_colon", '12 12 0', timer_color, sbar_alpha_fg, 0);
		Sbar_DrawXNum('-24 32 0', seconds, -2, 12, timer_color, 1, DRAWFLAG_NORMAL);
	}

	if(gametype == GAME_RACE)
	{
		drawfont = sbar_bigfont;
		float a;
		vector m;
		string s, forcetime;

		m = '0.5 0 0' * vid_conwidth + '0 0.25 0' * vid_conheight;

		if(race_checkpointtime)
		{
			a = bound(0, 2 - (time - race_checkpointtime), 1);
			s = "";
			forcetime = "";
			if(a > 0) // just hit a checkpoint?
			{
				if(race_time && race_previousbesttime)
					s = MakeRaceString(race_checkpoint, race_time / 10 - race_previousbesttime / 10, 0, 0, race_previousbestname);
				else
					s = MakeRaceString(race_checkpoint, 0, -1, 0, race_previousbestname);
				if(race_time)
					forcetime = mmsss(race_time);
			}
			else
			{
				if(race_laptime && race_nextbesttime)
				{
					a = bound(0, 2 - ((race_laptime + race_nextbesttime/10) - time), 1);
					if(a > 0) // next one?
					{
						s = MakeRaceString(race_nextcheckpoint, time - race_laptime, race_nextbesttime / 10, 0, race_nextbestname);
					}
				}
			}

			if(s != "" && a > 0)
			{
				dummyfunction(0, 0, 0, 0, 0, 0, 0, 0); // work around DP bug (set OFS_PARAM5 to 0)
				drawcolorcodedstring(m - '0 16 0' - '8 0 0' * stringwidth(s, TRUE), s, '16 16 0', sbar_alpha_fg * a, 0);
			}

			if(forcetime != "")
			{
				a = bound(0, (time - race_checkpointtime) / 0.5, 1);
				drawstring_expanding(m - '16 0 0' * stringwidth(forcetime, FALSE), forcetime, '32 32 0', '1 1 1', sbar_alpha_fg, 0, a);
			}
			else
				a = 1;

			if(race_laptime)
			{
				s = mmsss(10*(time - race_laptime));
				drawstring(m - '16 0 0' * stringwidth(s, FALSE), s, '32 32 0', '1 1 1', sbar_alpha_fg * a, 0);
			}
		}
		else
		{
			if(race_mycheckpointtime)
			{
				a = bound(0, 2 - (time - race_mycheckpointtime), 1);
				s = MakeRaceString(race_mycheckpoint, race_mycheckpointdelta / 10, -!race_mycheckpointenemy, race_mycheckpointlapsdelta, race_mycheckpointenemy);
				dummyfunction(0, 0, 0, 0, 0, 0, 0, 0); // work around DP bug (set OFS_PARAM5 to 0)
				drawcolorcodedstring(m - '0 16 0' - '8 0 0' * stringwidth(s, TRUE), s, '16 16 0', sbar_alpha_fg * a, 0);
			}
			if(race_othercheckpointtime && race_othercheckpointenemy != "")
			{
				a = bound(0, 2 - (time - race_othercheckpointtime), 1);
				s = MakeRaceString(race_othercheckpoint, -race_othercheckpointdelta / 10, -!race_othercheckpointenemy, race_othercheckpointlapsdelta, race_othercheckpointenemy);
				dummyfunction(0, 0, 0, 0, 0, 0, 0, 0); // work around DP bug (set OFS_PARAM5 to 0)
				drawcolorcodedstring(m - '0 0 0' - '8 0 0' * stringwidth(s, TRUE), s, '16 16 0', sbar_alpha_fg * a, 0);
			}
		}

		drawfont = sbar_font;
	}

	sbar = sbar_save;
}

void Sbar_MiniscoreItem(vector pos, entity pl, float is_self)
{
	float x, score;
	pos_x += 72;
	
	if(teamplay)
		drawfill(pos + '0 1 0', '40 6 0', GetTeamRGB(pl.team)*0.5, 1, DRAWFLAG_NORMAL);
	else
		drawfill(pos + '0 1 0', '40 6 0', '0.5 0.5 0.5', 0.5, DRAWFLAG_NORMAL);
	x = pos_x;
	pos_x += 5*8;
	score = pl.(scores[ps_primary]);
	pos_x -= stringwidth(ftos(score), FALSE)*8;
	drawstring(pos, ftos(score), '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);
	pos_x = x;
	if(is_self)
	{
		pos_x += 48;
		drawstring(pos, "\x0D", '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);
		pos_x += 8;
	} else
		pos_x += 56;
	drawcolorcodedstring(pos, GetPlayerName(pl.sv_entnum), '8 8 0', 1, 0);
}

void Sbar_MiniscoreTeamItem(vector pos, float color, float frags, float is_self)
{
	float x;
	pos_x += 72;
	
	if(teamplay)
		drawfill(pos + '0 1 0', '40 6 0', GetTeamRGB(color)*0.5, 1, DRAWFLAG_NORMAL);
	else
		drawfill(pos + '0 1 0', '40 6 0', '0.5 0.5 0.5', 0.5, DRAWFLAG_NORMAL);
	x = pos_x;
	pos_x += 5*8;
	pos_x -= stringwidth(ftos(frags), FALSE)*8;
	drawstring(pos, ftos(frags), '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);
	pos_x = x;
	if(is_self)
	{
		pos_x += 48;
		drawstring(pos, "\x0D", '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);
		pos_x += 8;
	} else
		pos_x += 56;
	drawstring(pos, GetTeamName(color), '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);
}

void Sbar_MiniDeathmatchOverlay(vector pos)
{
	float numlines, up, down, score;
	entity me, tm, pl;
	float miniscoreboard_size;
	miniscoreboard_size = cvar("sbar_miniscoreboard_size");
	
	if(miniscoreboard_size == 0)
		return;
	pos_y = vid_conheight - 8;
	
	if(miniscoreboard_size < 0)
		numlines = (vid_conheight - sbar_y + 7) / 8;
	else
		numlines = miniscoreboard_size;

	// give up if there isn't enough room
	if(pos_x >= vid_conwidth || pos_y >= vid_conheight || numlines < 1)
		return;

	// me vector := [team/connected frags id]
	for(me = players.sort_next; me; me = me.sort_next)
	{
		if(me.sv_entnum == player_localentnum - 1)
			break;
	}

	if(teamplay)
		numlines -= numteams;

	// figure out how many players above and below we can show
	up = floor(numlines/2);
	down = up;
	if((up + down) > numlines)
		down = numlines - up;

	// render bottom-up
	for(pl = me.sort_next; pl && down > 0; pl = pl.sort_next)
	{
		if(pl.team == COLOR_SPECTATOR)
			continue;
		Sbar_MiniscoreItem(pos, pl, false);
		pos_y -= 9;
		--down;
	}
	Sbar_MiniscoreItem(pos, me, true);
	pos_y -= 9;
	up += down; // if there weren't enough lines below... add them
	for(pl = me.sort_prev; pl && up > 0; pl = pl.sort_prev)
	{
		if(pl.team == COLOR_SPECTATOR)
			continue;
		Sbar_MiniscoreItem(pos, pl, false);
		pos_y -= 9;
		--up;
	}

	if(teamplay)
	{
		for(tm = teams.sort_next; tm.sort_next; tm = tm.sort_next);
		for(; tm; tm = tm.sort_prev)
		{
			if(!tm.team_size || tm.team == COLOR_SPECTATOR)
				continue;
			score = tm.(teamscores[ts_primary]);
			Sbar_MiniscoreTeamItem(pos, tm.team, score, (tm.team == me.team));
			pos_y -= 9;
		}
	}
}

float Sbar_WouldDrawScoreboard ()
{
	if (sb_showscores)
		return 1;
	else if (intermission == 1)
		return 1;
	else if (intermission == 2)
		return 1;
	else if (getstati(STAT_HEALTH) <= 0 && cvar("cl_deathscoreboard"))
		return 1;
	else if(sb_showscores_force)
		return 1;
	return 0;
}

void CSQC_Strength_Timer() {
	float stat_items, dt;
	stat_items = getstati(STAT_ITEMS);
	/*
	if not(stat_items & IT_STRENGTH)
		if not(stat_items & IT_INVINCIBLE)
			return;
	*/
	
	if (getstati(STAT_HEALTH) <= 0)
		return;
	
	vector pos, picsize, number_position;
	float strength_time, invincibility_time, countdown_fontsize;

	picsize = '40 40 0';
	countdown_fontsize = 22;
	
	//element will be positioned on the right side of the screen:
	pos_x = vid_conwidth - picsize_x - 10; //margin 10 from right border
	number_position_x = pos_x - 5/*margin to the left from image*/ - countdown_fontsize*2/*width of text*/;
	
	pos_y = 180;
	number_position_y = pos_y;
	
	//now calculate the values Sbar_DrawXNum() will be called with:
	number_position_x = number_position_x - sbar_x; //relative to sbar coordinates
	number_position_y = number_position_y - sbar_y; //relative to sbar coordinates
	number_position_y += 10; //center number vertically to the icon
	
	pos_z = number_position_z = 0;
	
	//strength
	strength_time = getstatf(STAT_STRENGTH_FINISHED);
	invincibility_time = getstatf(STAT_INVINCIBLE_FINISHED);

	if (strength_time) {
		dt = strength_time - time;
		if(dt > 0)
		{
			if(dt < 5)
			{
				drawpic_expanding_two(pos, "gfx/sb_str", picsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_ADDITIVE,
					bound(0, (ceil(dt) - dt) / 0.5, 1));
			}
			else
			{
				drawpic(pos, "gfx/sb_str", picsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_ADDITIVE);
			}
			Sbar_DrawXNum(number_position, ceil(dt), 2, countdown_fontsize, '1 1 1', 1, DRAWFLAG_NORMAL);
		}
		else if(dt > -1)
		{
			drawpic_expanding(pos, "gfx/sb_str", picsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_ADDITIVE,
				bound(0, -dt / 0.5, 1));
		}
	}
	
	//add some margin to the invincibility icon
	pos_y             += picsize_y + 10;
	number_position_y += picsize_y + 10;

	//invincibility
	if (invincibility_time) {
		dt = invincibility_time - time;
		if(dt > 0)
		{
			if(dt < 5)
			{
				drawpic_expanding_two(pos, "gfx/sb_invinc", picsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_ADDITIVE,
					bound(0, (ceil(dt) - dt) / 0.5, 1));
			}
			else
			{
				drawpic(pos, "gfx/sb_invinc", picsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_ADDITIVE);
			}
			Sbar_DrawXNum(number_position, ceil(dt), 2, countdown_fontsize, '1 1 1', 1, DRAWFLAG_NORMAL);
		}
		else if(dt > -1)
		{
			drawpic_expanding(pos, "gfx/sb_invinc", picsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_ADDITIVE,
				bound(0, -dt / 0.5, 1));
		}
	}
}

#define CENTERPRINT_MAX_LINES 30
string centerprint_messages[CENTERPRINT_MAX_LINES]; 
float centerprint_width[CENTERPRINT_MAX_LINES]; 
vector centerprint_start;
float centerprint_expire;
float centerprint_num;
float centerprint_offset_hint;
vector centerprint_fontsize;

void centerprint(string strMessage)
{
	float i, j, n, hcount;
	string s;

	centerprint_fontsize = Sbar_GetFontsize("scr_centersize");

	centerprint_expire = min(centerprint_expire, time); // if any of the returns happens, this message will fade out

	if(cvar("scr_centertime") <= 0)
		return;
	
	if(strMessage == "")
		return;

	// strip trailing newlines
	j = strlen(strMessage) - 1;
	while(substring(strMessage, j, 1) == "\n" && j >= 0)
		j = j - 1;
	strMessage = substring(strMessage, 0, j + 1);
	
	if(strMessage == "")
		return;

	// strip leading newlines and remember them, they are a hint that the message should be lower on the screen
	j = 0;
	while(substring(strMessage, j, 1) == "\n" && j < strlen(strMessage))
		j = j + 1;
	strMessage = substring(strMessage, j, strlen(strMessage) - j);
	centerprint_offset_hint = j;

	if(strMessage == "")
		return;

	// if we get here, we have a message. Initialize its height.
	centerprint_num = 0;
	
	n = tokenizebyseparator(strMessage, "\n");
	i = hcount = 0;
	for(j = 0; j < n; ++j)
	{
		getWrappedLine_remaining = argv(j);
		while(getWrappedLine_remaining)
		{
			s = getWrappedLine(vid_conwidth * 0.75 / centerprint_fontsize_x, stringwidth_colors);
			if(centerprint_messages[i])
				strunzone(centerprint_messages[i]);
			centerprint_messages[i] = strzone(s);
			centerprint_width[i] = stringwidth(s, TRUE);
			++i;

			// half height for empty lines looks better
			if(s == "")
				hcount += 0.5;
			else
				hcount += 1;

			if(i >= CENTERPRINT_MAX_LINES)
				break;
		}
	}

	float h, havail;
	h = centerprint_fontsize_y*hcount;

	havail = vid_conheight;
	if(cvar("con_chatpos") < 0)
		havail -= (-cvar("con_chatpos") + cvar("con_chat")) * cvar("con_chatsize"); // avoid overlapping chat

	centerprint_start_x = 0;

#if 0
	float forbiddenmin, forbiddenmax, allowedmin, allowedmax, preferred;

	// here, the centerprint would cover the crosshair. REALLY BAD.
	forbiddenmin = vid_conheight * 0.5 - h - 16;
	forbiddenmax = vid_conheight * 0.5 + 16;

	allowedmin = scoreboard_bottom;
	allowedmax = havail - h;
	preferred = (havail - h)/2;


	// possible orderings (total: 4! / 4 = 6)
	//  allowedmin allowedmax forbiddenmin forbiddenmax
	//  forbiddenmin forbiddenmax allowedmin allowedmax
	if(allowedmax < forbiddenmin || allowedmin > forbiddenmax)
	{
		// forbidden doesn't matter in this case
		centerprint_start_y = bound(allowedmin, preferred, allowedmax);
	}
	//  allowedmin forbiddenmin allowedmax forbiddenmax
	else if(allowedmin < forbiddenmin && allowedmax < forbiddenmax)
	{
		centerprint_start_y = bound(allowedmin, preferred, forbiddenmin);
	}
	//  allowedmin forbiddenmin forbiddenmax allowedmax
	else if(allowedmin < forbiddenmin)
	{
		// make sure the forbidden zone is not covered
		if(preferred > (forbiddenmin + forbiddenmax) * 0.5)
			centerprint_start_y = bound(allowedmin, preferred, forbiddenmin);
		else
			centerprint_start_y = bound(forbiddenmax, preferred, allowedmin);
	}
	//  forbiddenmin allowedmin allowedmax forbiddenmax
	else if(allowedmax < forbiddenmax)
	{
		// it's better to leave the allowed zone (overlap with scoreboard) than
		// to cover the forbidden zone (crosshair)
		if(preferred > (forbiddenmin + forbiddenmax) * 0.5)
			centerprint_start_y = forbiddenmax;
		else
			centerprint_start_y = forbiddenmin;
	}
	//  forbiddenmin allowedmin forbiddenmax allowedmax
	else
	{
		centerprint_start_y = bound(forbiddenmax, preferred, allowedmax);
	}
#else
	centerprint_start_y =
		min(
			max(
				max(scoreboard_bottom, vid_conheight * 0.5 + 16),
				(havail - h)/2
			),
			havail - h
		);
#endif

	centerprint_num = i;
	centerprint_expire = time + cvar("scr_centertime");
}

void Sbar_DrawCenterPrint (void)
{
	float i;
	vector pos;
	string ts;
	float a;

	//if(time > centerprint_expire)
	//	return;
	
	//a = bound(0, 1 - 2 * (time - centerprint_expire), 1);
	a = bound(0, 1 - 4 * (time - centerprint_expire), 1);
	//sz = 1.2 / (a + 0.2);

	if(a <= 0)
		return;
	
	pos = centerprint_start;
	for (i=0; i<centerprint_num; i = i + 1)
	{
		pos_x = (vid_conwidth - centerprint_fontsize_x * centerprint_width[i]) * 0.5;
		ts = centerprint_messages[i];
		if (ts != "")
		{
			dummyfunction(0, 0, 0, 0, 0, 0, 0, 0); // work around DP bug (set OFS_PARAM5 to 0)
			drawcolorcodedstring(pos, ts, centerprint_fontsize, a, DRAWFLAG_NORMAL);
			//  - '0 0.5 0' * (sz - 1) * centerprint_fontsize_x - '0.5 0 0' * (sz - 1) * centerprint_width[i] * centerprint_fontsize_y, centerprint_fontsize * sz
			pos_y = pos_y + centerprint_fontsize_y;
		}
		else
			// half height for empty lines looks better
			pos_y = pos_y + centerprint_fontsize_y * 0.5;
	}
}

vector Sbar_DrawNoteLine(vector offset, string s)
{
	dummyfunction(0, 0, 0, 0, 0, 0, 0, 0); // work around DP bug (set OFS_PARAM5 to 0)
	drawcolorcodedstring(
		offset - sbar_fontsize_x * '1 0 0' * stringwidth(s, TRUE),
		s,
		sbar_fontsize,
		sbar_alpha_fg,
		0
	);
	return offset + sbar_fontsize_y * '0 1 0';
}

void Sbar_DrawPressedKeys(void)
{
	vector pos, bgsize;
	float pressedkeys;
	
	pos = stov(cvar_string("cl_showpressedkeys_position"));

	bgsize = '126 75 0';

	pos = '1 0 0' * (vid_conwidth - bgsize_x) * pos_x
	    + '0 1 0' * (vid_conheight - bgsize_y) * pos_y;
	pos -= '-15 -6 0'; // adjust to the origin of these numbers
	
	pressedkeys = getstatf(STAT_PRESSED_KEYS);
	drawpic(pos + '-15   -6   0', "gfx/keys/key_bg.tga",           bgsize, '1 1 1', .1, DRAWFLAG_NORMAL);
	drawpic(pos + ' 83.5  9   0', "gfx/keys/key_crouch.tga",   ' 24 24 0', '1 1 1', .5 * ((pressedkeys & KEY_CROUCH) + 1), DRAWFLAG_NORMAL);
	drawpic(pos + ' 32   -1.5 0', "gfx/keys/key_forward.tga",  ' 32 32 0', '1 1 1', .5 * ((pressedkeys & KEY_FORWARD) + 1), DRAWFLAG_NORMAL);
	drawpic(pos + '-11.5  9   0', "gfx/keys/key_jump.tga",     ' 24 24 0', '1 1 1', .5 * ((pressedkeys & KEY_JUMP) + 1), DRAWFLAG_NORMAL);
	drawpic(pos + ' -1   32   0', "gfx/keys/key_left.tga",     ' 32 32 0', '1 1 1', .5 * ((pressedkeys & KEY_LEFT) + 1), DRAWFLAG_NORMAL);
	drawpic(pos + ' 32   32   0', "gfx/keys/key_backward.tga", ' 32 32 0', '1 1 1', .5 * ((pressedkeys & KEY_BACKWARD) + 1), DRAWFLAG_NORMAL);
	drawpic(pos + ' 65   32   0', "gfx/keys/key_right.tga",    ' 32 32 0', '1 1 1', .5 * ((pressedkeys & KEY_RIGHT) + 1), DRAWFLAG_NORMAL);
}

float GetAmmoStat(float i)
{
	switch(i)
	{
		case 0: return STAT_SHELLS;
		case 1: return STAT_NAILS;
		case 2: return STAT_ROCKETS;
		case 3: return STAT_CELLS;
		case 4: return STAT_FUEL;
		default: return -1;
	}
}

float GetAmmoItemCode(float i)
{
	switch(i)
	{
		case 0: return IT_SHELLS;
		case 1: return IT_NAILS;
		case 2: return IT_ROCKETS;
		case 3: return IT_CELLS;
		case 4: return IT_FUEL;
		default: return -1;
	}
}

string GetAmmoPicture(float i)
{
	switch(i)
	{
		case 0: return "gfx/sb_shells";
		case 1: return "gfx/sb_bullets";
		case 2: return "gfx/sb_rocket";
		case 3: return "gfx/sb_cells";
		case 4: return "gfx/sb_fuel";
		default: return "";
	}
}

void Sbar_Draw (void)
{
	float i;
	float x, fade;
	float stat_items, stat_weapons;
	vector o; o = '1 0 0' * vid_conwidth;
	vector v;
	string s;

	sbar_fontsize = Sbar_GetFontsize("sbar_fontsize");
	
	if(spectatee_status && !intermission)
	{
		if(spectatee_status == -1)
			s = "^1Observing";
		else
			s = strcat("^1Spectating ^7", GetPlayerName(spectatee_status - 1));
		o = Sbar_DrawNoteLine(o, s);

		if(spectatee_status == -1)
			s = strcat("^1Press ^3", getcommandkey("primary fire", "+attack"), "^1 to spectate");
		else
			s = strcat("^1Press ^3", getcommandkey("primary fire", "+attack"), "^1 for another player");
		o = Sbar_DrawNoteLine(o, s);

		if(spectatee_status == -1)
			s = strcat("^1Use ^3", getcommandkey("next weapon", "weapnext"), "^1 or ^3", getcommandkey("previous weapon", "weapprev"), "^1 to change the speed");
		else
			s = strcat("^1Press ^3", getcommandkey("secondary fire", "+attack2"), "^1 to observe");
		o = Sbar_DrawNoteLine(o, s);

		s = strcat("^1Press ^3", getcommandkey("server info", "+show_info"), "^1 for gamemode info");
		o = Sbar_DrawNoteLine(o, s);

		if(gametype == GAME_ARENA)
			s = "^1Wait for your turn to join";
		else if(gametype == GAME_LMS)
		{
			entity sk;
			sk = playerslots[player_localentnum - 1];
			if(sk.(scores[ps_primary]) >= 666)
				s = "^1Match has already begun";
			else if(sk.(scores[ps_primary]) > 0)
				s = "^1You have no more lives left";
			else
				s = strcat("^1Press ^3", getcommandkey("jump", "+jump"), "^1 to join");
		}
		else
			s = strcat("^1Press ^3", getcommandkey("jump", "+jump"), "^1 to join");
		o = Sbar_DrawNoteLine(o, s);
		
		//show restart countdown:
		if (time < getstatf(STAT_GAMESTARTTIME)) {
			float countdown;
			//we need to ceil, otherwise the countdown would be off by .5 when using round()
			countdown = ceil(getstatf(STAT_GAMESTARTTIME) - time);
			s = strcat("^1Game starts in ^3", ftos(countdown), "^1 seconds");
			o = Sbar_DrawNoteLine(o, s);
		}
	}
	if(warmup_stage && !intermission)
	{
		s = "^2Currently in ^1warmup^2 stage!";
		o = Sbar_DrawNoteLine(o, s);
	}

	// move more important stuff more to the middle so its more visible
	o_y = vid_conheight * 0.66;

	string blinkcolor;
	if(mod(time, 1) >= 0.5)
		blinkcolor = "^1";
	else
		blinkcolor = "^3";

	if(ready_waiting && !intermission)
	{
		if(ready_waiting_for_me)
		{
			if(warmup_stage) 
				s = strcat(blinkcolor, "Press ^3", getcommandkey("ready", "ready"), blinkcolor, " to end warmup");
			else
				s = strcat(blinkcolor, "Press ^3", getcommandkey("ready", "ready"), blinkcolor, " once you are ready");
		}
		else
		{
			if(warmup_stage) 
				s = strcat("^2Waiting for others to ready up to end warmup...");
			else
				s = strcat("^2Waiting for others to ready up...");
		}
		o = Sbar_DrawNoteLine(o, s);
	}
	else if(warmup_stage && !intermission) 
	{
		s = strcat("^2Press ^3", getcommandkey("ready", "ready"), "^2 to end warmup");
		o = Sbar_DrawNoteLine(o, s);
	}
	if(vote_waiting)
	{
		s = strcat("^2A vote has been called for ^1", vote_called_vote);
		o = Sbar_DrawNoteLine(o, s);

		if(vote_waiting_for_me)
		{
			s = strcat(blinkcolor, "Press ^3", getcommandkey("vote yes", "vyes"), blinkcolor, " to accept");
			o = Sbar_DrawNoteLine(o, s);

			s = strcat(blinkcolor, "Press ^3", getcommandkey("vote no", "vno"), blinkcolor, " to reject");
			o = Sbar_DrawNoteLine(o, s);

			s = strcat(blinkcolor, "Press ^3", getcommandkey("vote abstain", "vabstain"), blinkcolor, " to abstain");
			o = Sbar_DrawNoteLine(o, s);
		}
		else
		{
			s = strcat("^2Waiting for others to vote...");
			o = Sbar_DrawNoteLine(o, s);
		}
	}
	if(teamplay && !intermission)
	{
		entity tm;
		float ts_min, ts_max;
		tm = teams.sort_next;
		if (tm)
		{
			for(; tm.sort_next; tm = tm.sort_next)
			{
				if(!tm.team_size || tm.team == COLOR_SPECTATOR)
					continue;
				if(!ts_min) ts_min = tm.team_size;
				else ts_min = min(ts_min, tm.team_size);
				if(!ts_max) ts_max = tm.team_size;
				else ts_max = max(ts_max, tm.team_size);
			}
			if ((ts_max - ts_min) > 1)
			{
				s = strcat(blinkcolor, "Teamnumbers are unbalanced!");
				tm = GetTeam(myteam, false);
				if (tm)
				if (tm.team != COLOR_SPECTATOR)
				if (tm.team_size == ts_max)
					s = strcat(s, " Press ^3", getcommandkey("team menu", "menu_showteamselect"), blinkcolor, " to adjust");

				o = Sbar_DrawNoteLine(o, s);
			}
		}
	}

	//Sbar_SortFrags();
	Sbar_UpdatePlayerTeams();

	sb_lines = 24;

	if (sb_showscores)
	{
		Sbar_DrawScoreboard();
		Sbar_DrawCenterPrint();
	}
	else if (intermission == 1)
	{
		Sbar_DrawScoreboard();
		Sbar_DrawCenterPrint();
		return;
	}
	else if (intermission == 2)
	{
		Sbar_FinaleOverlay();
		Sbar_DrawCenterPrint();
	}
	else
	{
		if (sb_showscores || sb_showscores_force || (getstati(STAT_HEALTH) <= 0 && cvar("cl_deathscoreboard")))
		{
			sbar_x = (vid_conwidth - 640.0)*0.5;
			sbar_y = vid_conheight - 47;
			//Sbar_DrawAlphaPic (sbar_x, sbar_y, sb_scorebar, sbar_alpha_bg.value);
			//drawpic('0 0 0', "gfx/scorebar", '0 0 0', '1 1 1', cvar("sbar_alpha_bg"), 0);
			Sbar_DrawScoreboard ();
		}
		else
		{
			if (sb_lines && sbar_hudselector == 1)
			{
				stat_items = getstati(STAT_ITEMS);
				stat_weapons = getstati(STAT_WEAPONS);

				sbar_x = (vid_conwidth - 320.0)*0.5;
				sbar_y = vid_conheight - 24.0 - 16.0;
				sbar_z = 0;
			
				fade = 3.2 - 2 * (time - weapontime);
				fade = bound(0.7, fade, 1);

				x = 1.0;
				Sbar_DrawWeapon_Clear();
				for(i = 1; i <= 24; ++i)
				{
					if(weaponimpulse[i-1] >= 0)
					if(stat_weapons & x)
					{
						Sbar_DrawWeapon(i-1, fade, (i == activeweapon));
					}
					x *= 2;
				}

				// armor
				x = getstati(STAT_ARMOR);
				if (x > 0)
				{
					// "gfx/sb_armor"
					//Sbar_DrawStretchPic (72, 0, sb_armor[0], sbar_alpha_fg.value, 24, 24);
					drawpic(sbar + '72 0 0', "gfx/sb_armor", '24 24 0', '1 1 1', sbar_alpha_fg, 0);
					if(x > 200)
						Sbar_DrawXNum('0 0 0', x, 3, 24, '0 1 0', 1, 0);
					else if(x > 100)
						Sbar_DrawXNum('0 0 0', x, 3, 24, '0.2 1 0', 1, 0);
					else if(x > 50)
						Sbar_DrawXNum('0 0 0', x, 3, 24, '0.6 0.7 0.8', 1, 0);
					else if(x > 25)
						Sbar_DrawXNum('0 0 0', x, 3, 24, '1 1 0.2', 1, 0);
					else
						Sbar_DrawXNum('0 0 0', x, 3, 24, '0.7 0 0', 1, 0);
				}

				// health
				x = getstati(STAT_HEALTH);
				if (x != 0)
				{
					// "gfx/sb_health"
					//Sbar_DrawStretchPic (184, 0, sb_health, sbar_alpha_fg.value, 24, 24);
					drawpic(sbar + '184 0 0', "gfx/sb_health", '24 24 0', '1 1 1', sbar_alpha_fg, 0);
					if(x > 200)
						Sbar_DrawXNum('112 0 0', x, 3, 24, '0 1 0', 1, 0);
					else if(x > 100)
						Sbar_DrawXNum('112 0 0', x, 3, 24, '0.2 1 0', 1, 0);
					else if(x > 50)
						Sbar_DrawXNum('112 0 0', x, 3, 24, '0.6 0.7 0.8', 1, 0);
					else if(x > 25)
						Sbar_DrawXNum('112 0 0', x, 3, 24, '1 1 0.2', 1, 0);
					else
						Sbar_DrawXNum('112 0 0', x, 3, 24, '0.7 0 0', 1, 0);
				}

				// ammo
				for(i = 0, v = '0 0 0'; (x = GetAmmoStat(i)) >= 0; ++i)
					if(stat_items & GetAmmoItemCode(i))
					{
						x = getstati(x);
						drawpic(sbar + '296 0 0' + v, GetAmmoPicture(i), '24 24 0', '1 1 1', sbar_alpha_fg, 0);
						if(x > 10)
							Sbar_DrawXNum('224 0 0' + v, x, 3, 24, '0.6 0.7 0.8', 1, 0);
						else
							Sbar_DrawXNum('224 0 0' + v, x, 3, 24, '0.7 0 0', 1, 0);
						v_y -= 30;
					}

				if (sbar_x + 320 + 160 <= vid_conwidth)
					Sbar_MiniDeathmatchOverlay(sbar + '320 0 0');
				if (sbar_x > 0)
					Sbar_Score(16);
				// The margin can be at most 8 to support 640x480 console size:
				//   320 + 2 * (144 + 16) = 640
			}
			else if (sb_lines)
			{
			
				stat_items = getstati(STAT_ITEMS);
				stat_weapons = getstati(STAT_WEAPONS);
			
				sbar_x = (vid_conwidth - 640.0)*0.5;
				sbar_y = vid_conheight - 47;
				sbar_z = 0;

				fade = 3 - 2 * (time - weapontime);

				x = 1.0;
				Sbar_DrawWeapon_Clear();
				for(i = 1; i <= 24; ++i)
				{
					if(weaponimpulse[i-1] >= 0)
					if(stat_weapons & x)
					{
						Sbar_DrawWeapon(i-1, fade, (i == activeweapon));
					}
					x *= 2;
				}

				if (sb_lines > 24)
					drawpic(sbar, "gfx/sbar", '0 0 0', '1 1 1', sbar_alpha_fg, 0);
				else
					drawpic(sbar, "gfx/sbar_minimal", '0 0 0', '1 1 1', sbar_alpha_fg, 0);

				// armor
				// (340-3*24) = 268
				Sbar_DrawXNum('268 12 0', getstati(STAT_ARMOR), 3, 24, '0.6 0.7 0.8', 1, 0);

				// health
				// (154-3*24) = 82
				x = getstati(STAT_HEALTH);
				if(x > 100)
					Sbar_DrawXNum('82 12 0', x, 3, 24, '1 1 1', 1, 0);
				else if(x <= 25 && time - floor(time) > 0.5)
					Sbar_DrawXNum('82 12 0', x, 3, 24, '0.7 0 0', 1, 0);
				else
					Sbar_DrawXNum('81 12 0', x, 3, 24, '0.6 0.7 0.8', 1, 0);

				// ammo
				for(i = 0, v = '0 0 0'; (x = GetAmmoStat(i)) >= 0; ++i)
					if(stat_items & GetAmmoItemCode(i))
					{
						x = getstati(x);
						drawpic(sbar + '519 0 0' + v, GetAmmoPicture(i), '0 0 0', '1 1 1', sbar_alpha_fg, 0);
						if(x > 10)
							Sbar_DrawXNum('447 12 0' + v, x, 3, 24, '0.6 0.7 0.8', 1, 0);
						else
							Sbar_DrawXNum('447 12 0' + v, x, 3, 24, '0.7 0 0', 1, 0);
						v_y -= 40;
					}

				if (sb_lines > 24)
					drawpic(sbar, "gfx/sbar_overlay", '0 0 0', '1 1 1', 1, DRAWFLAG_MODULATE);

				if (sbar_x + 600 + 160 <= vid_conwidth)
					Sbar_MiniDeathmatchOverlay (sbar + '600 0 0');

				if (sbar_x > 0)
					Sbar_Score(-16);
				// Because:
				//   Mini scoreboard uses 12*4 per other team, that is, 144
				//   pixels when there are four teams...
				//   Nexuiz by default sets vid_conwidth to 800... makes
				//   sbar_x == 80...
				//   so we need to shift it by 64 pixels to the right to fit
				//   BUT: then it overlaps with the image that gets drawn
				//   for viewsize 100! Therefore, just account for 3 teams,
				//   that is, 96 pixels mini scoreboard size, needing 16 pixels
				//   to the right!
			}
			
			//show strength/invincibility ICON and timer:
			CSQC_Strength_Timer();

			if(gametype == GAME_KEYHUNT)
			{
				CSQC_kh_hud();
			} else if(gametype == GAME_CTF)
			{
				CSQC_ctf_hud();
			} else if(gametype == GAME_NEXBALL)
			{
				CSQC_nb_hud();
			}
		}
		Sbar_DrawCenterPrint();
	}
}

void CSQC_ctf_hud(void)
{
	// cvar("sbar_flagstatus_right") move the flag icons right
	// cvar("sbar_flagstatus_pos") pixel position of the nexuiz flagstatus icons
	float redflag, blueflag;
	float stat_items;
	vector pos;
	
	stat_items = getstati(STAT_ITEMS);
	redflag = (stat_items/IT_RED_FLAG_TAKEN) & 3;
	blueflag = (stat_items/IT_BLUE_FLAG_TAKEN) & 3;

	/**
	 * FTEQCC BUG!
	 * For some reason now not even THAT works there...
	 * Maybe the minus' precedence screws it up? The last one there, maybe I should use brackets
	 **
	 * pos_x = (cvar("sbar_flagstatus_right")) ? vid_conwidth - 10 - sbar_x - 64 : 10 - sbar_x;
	 ** Should try those later:
	 * pos_x = (cvar("sbar_flagstatus_right")) ? (vid_conwidth - 10 - sbar_x - 64) : (10 - sbar_x);
	 * pos_x = ( (cvar("sbar_flagstatus_right")) ? vid_conwidth - 10 - 64 : 10 ) - sbar_x;
	 */
	
	if(cvar("sbar_flagstatus_right"))
		pos_x = vid_conwidth - 10 - sbar_x - 64;
	else
		pos_x = 10 - sbar_x;
	
	pos_z = 0;

	if(sbar_hudselector == 1)
		pos_y = (vid_conheight - sbar_y) - cvar("sbar_flagstatus_pos") - 64;
	else
		pos_y = -117;

	pos += sbar;

	switch(redflag)
	{
	case 1: drawpic(pos, "gfx/sb_flag_red_taken", '128 64 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL); break;
	case 2: drawpic(pos, "gfx/sb_flag_red_lost", '128 64 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL); break;
	case 3: drawpic(pos, "gfx/sb_flag_red_carrying", '128 64 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL); break;
	default:
		if(stat_items & IT_CTF_SHIELDED)
			if(myteam == COLOR_TEAM2)
				drawpic(pos, "gfx/sb_flag_red_shielded", '128 64 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL); break;
	}

	pos_y -= 64;
	
	switch(blueflag)
	{
	case 1: drawpic(pos, "gfx/sb_flag_blue_taken", '128 64 0', '1 1 1', sbar_alpha_fg, 0); break;
	case 2: drawpic(pos, "gfx/sb_flag_blue_lost", '128 64 0', '1 1 1', sbar_alpha_fg, 0); break;
	case 3: drawpic(pos, "gfx/sb_flag_blue_carrying", '128 64 0', '1 1 1', sbar_alpha_fg, 0); break;
	default:
		if(stat_items & IT_CTF_SHIELDED)
			if(myteam == COLOR_TEAM1)
				drawpic(pos, "gfx/sb_flag_blue_shielded", '128 64 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL); break;
	}
}

//box style
#define NBPB_SIZE '128 66 0'
#define NBPB_BT 2                   //thickness
#define NBPB_BRGB '1 1 1'
#define NBPB_BALPH 1                //alpha
#define NBPB_BFLAG DRAWFLAG_NORMAL
#define NBPB_IALPH 0.4
#define NBPB_IFLAG DRAWFLAG_NORMAL
#define NBPB_IRGB '0.7 0.1 0'

void CSQC_nb_hud(void)
{
	float stat_items, nb_pb_starttime, dt, p;
	vector pos;
	
	stat_items = getstati(STAT_ITEMS);
	nb_pb_starttime = getstatf(STAT_NB_METERSTART);
	
	if(cvar("sbar_flagstatus_right"))
		pos_x = vid_conwidth - 10 - sbar_x - 64;
	else
		pos_x = 10 - sbar_x;
	
	pos_z = 0;

	if(sbar_hudselector == 1)
		pos_y = (vid_conheight - sbar_y) - cvar("sbar_flagstatus_pos") - 64;
	else
		pos_y = -117;

	pos += sbar;
	pos_y -= 1; //vertical margin to the picture

	//Manage the progress bar if any
	if (nb_pb_starttime > 0)
	{
		vector s;
		dt = mod(time - nb_pb_starttime, nb_pb_period);
		// one period of positive triangle
		p = 2 * dt / nb_pb_period;
		if (p > 1)
			p = 2 - p;

		s = NBPB_SIZE;
		//Draw the filling
		drawfill(pos, p * s_x * '1 0 0' + s_y * '0 1 0', NBPB_IRGB, NBPB_IALPH, NBPB_IFLAG);

		//Draw the box
		s = NBPB_SIZE;
		drawline(NBPB_BT, pos    , pos + '1 0 0' * s_x, NBPB_BRGB, NBPB_BALPH, NBPB_BFLAG);
		drawline(NBPB_BT, pos    , pos + '0 1 0' * s_y, NBPB_BRGB, NBPB_BALPH, NBPB_BFLAG);
		drawline(NBPB_BT, pos + s, pos + '1 0 0' * s_x, NBPB_BRGB, NBPB_BALPH, NBPB_BFLAG);
		drawline(NBPB_BT, pos + s, pos + '0 1 0' * s_y, NBPB_BRGB, NBPB_BALPH, NBPB_BFLAG);
	}

	pos_y += 1; //vertical margin to the picture
	
	if (stat_items & IT_KEY1)
		drawpic(pos, "gfx/sb_nexball_carrying", '128 64 0', '1 1 1', 1, DRAWFLAG_NORMAL);
}
