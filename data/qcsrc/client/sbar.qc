void drawstringright(vector, string, vector, vector, float, float);
void drawstringcenter(vector, string, vector, vector, float, float);
void Sbar_DrawAccuracyStats();
void Sbar_DrawAccuracyStats_Description_Splash(vector);
void Sbar_DrawAccuracyStats_Description_Hitscan(vector);
float weapon_hits[WEP_COUNT];
float weapon_fired[WEP_COUNT];
float weapon_number;

float last_weapon;
float weapontime;

float sbar_alpha_fg;
float sbar_alpha_bg;
float sbar_color_bg_team;
float sbar_border_tickness;
float sbar_scoreboard_alpha_bg;
float sbar_hudselector;
float sbar_hud_accuracy;

float ps_primary, ps_secondary;
float ts_primary, ts_secondary;

vector sbar, color;
vector element_offset = '0 6 0'; // global item offset from the bottom edge

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
void Sbar_DrawWeapon(float nr, float fade, float active, float wc)
{
	vector pos, vsize, fill_colour;
	float value, idx, imp, sp, weapon_hit, weapon_damage, weapon_stats;

	imp = weaponimpulse[nr];
	weapon_hit = weapon_hits[wc];
 	weapon_damage = weapon_fired[wc];
	if(imp == 0)
		idx = 9;
	else
		idx = imp - 1;

	value = (active) ? 1 : 0.6;
	color_x = color_y = color_z = value;

	// width = 300, height = 100
	const float w_width = 25, w_height = 12, w_space = 2, font_size = 8;

	sp = weaponspace[idx] + 1;
	weaponspace[idx] = sp;

	pos_x = (vid_conwidth + 10 - w_width * 9) * 0.5 + w_width * idx;
	pos_y = (vid_conheight - w_height * sp) - 38; // move 38 pixels up
	pos_z = 0;
	vsize_x = w_width;
	vsize_y = w_height;
	vsize_z = 0;
	if (active)
		drawpic(pos, "gfx/hud/sb_ammobg", vsize, color, value * fade * sbar_alpha_fg, DRAWFLAG_NORMAL);
	drawpic(pos, strcat("gfx/hud/inv_weapon", ftos(nr)), vsize, color, value * fade * sbar_alpha_fg, DRAWFLAG_NORMAL);
	pos_x += w_space;
	pos_y += w_space;
	vsize_x = font_size;
	vsize_y = font_size;
	vsize_z = 0;
	drawstring(pos, ftos(imp), vsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);

	// draw the weapon accuracy on the HUD
	if(sbar_hud_accuracy)
 	{
 		weapon_stats = rint(100*weapon_hit/weapon_damage);
 		fill_colour_x = 1 - 0.015 * weapon_stats;
 		fill_colour_y = 1 - 0.015 * (100 - weapon_stats);
 		drawstringright(pos + '22 0 0', strcat(ftos(weapon_stats),"%"), '6 6 0', fill_colour, sbar_alpha_fg, 0);
 	}
}

void Sbar_DrawXNum (vector pos, float num, float digits, float lettersize, vector rgb, float highlighted, float stroke, float a, float dflags)
{
	float l, i;
	string str, tmp, l_length;
	float minus;
	vector vsize, num_color;
	num_color = rgb;
	
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
	l_length = ftos(l);

	if(l > digits)
	{
		str = substring(str, l-digits, 999);
		l = strlen(str);
	} else if(l < digits)
		pos_x += (digits-l) * lettersize;

	if (highlighted == 1) {
		vector hl_size;
		hl_size_x = vsize_x * l + vsize_x * 0.2;
		hl_size_y = vsize_y * 1.1;
		hl_size_z = 0;
		if(minus)
			hl_size_x = hl_size_x + vsize_x;

		vector hl_pos;
		hl_pos_x = pos_x - lettersize/10;
		hl_pos_y = pos_y - lettersize/20;
		hl_pos_z = 0;

		drawpic(hl_pos, strcat("gfx/hud/sb_highlight_", l_length), hl_size, '1 1 1', sbar_alpha_fg, dflags);
	}
	
	if (stroke == 1)
		num_color = '1 1 1';
	
	if(minus)
	{
		drawpic(pos, "gfx/hud/num_minus", vsize, num_color, a * sbar_alpha_fg, dflags);
		if (stroke == 1)
			drawpic(pos, "gfx/hud/num_minus_stroke", vsize, rgb, a * sbar_alpha_fg, dflags);
		pos_x += lettersize;
	}

	for(i = 0; i < l; ++i)
	{
		drawpic(pos, strcat("gfx/hud/num_", substring(str, i, 1)), vsize, num_color, a * sbar_alpha_fg, dflags);
		if (stroke == 1)
			drawpic(pos, strcat("gfx/hud/num_", substring(str, i, 1), "_stroke"), vsize, rgb, a * sbar_alpha_fg, dflags);
		pos_x += lettersize;
	}
}

void Sbar_DrawXNum_Colored (vector pos, float x, float lettersize, float alpha)
{
	if(x > 200) {
		color_x = 0;
		color_y = 1;
		color_z = 0;
	}
	else if(x > 150) {
		color_x = 0.4 - (x-150)*0.02 * 0.4; //red value between 0.4 -> 0
		color_y = 0.9 + (x-150)*0.02 * 0.1; // green value between 0.9 -> 1
		color_z = 0;
	}
	else if(x > 100) {
		color_x = 1 - (x-100)*0.02 * 0.6; //red value between 1 -> 0.4
		color_y = 1 - (x-100)*0.02 * 0.1; // green value between 1 -> 0.9
		color_z = 1 - (x-100)*0.02; // blue value between 1 -> 0
	}
	else if(x > 50) {
		color_x = 1;
		color_y = 1;
		color_z = 0.2 + (x-50)*0.02 * 0.8; // blue value between 0.2 -> 1
	}
	else if(x > 20) {
		color_x = 1;
		color_y = (x-20)*90/27/100; // green value between 0 -> 1
		color_z = (x-20)*90/27/100 * 0.2; // blue value between 0 -> 0.2
	}
	else {
		color_x = 1;
		color_y = 0;
		color_z = 0;
	}
	Sbar_DrawXNum(pos, x, 3, lettersize, color, 0, 0, alpha, DRAWFLAG_NORMAL);
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
		"+/caps +kh/pushes +kh/destroyed ",
		"?+race/laps ?+race/time ?+race/fastest ",
		"+as/objectives +nexball/faults +nexball/goals ",
		"-lms,race,nexball/score");
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

void Sbar_PrintScoreboardItem(vector pos, entity pl, float is_self, float pl_number)
{
	vector tmp;
	string str;
	float i, field;
	float is_spec;
	is_spec = (GetPlayerColor(pl.sv_entnum) == COLOR_SPECTATOR);

	// Layout:
	tmp_x = sbwidth;
	tmp_y = sbar_fontsize_y * 1.25;
	tmp_z = 0;
	
	// alternated rows highlighting
	if (is_self)
		drawfill(pos - '1 1 0', tmp + '2 0 0', '1 1 1', 0.25, DRAWFLAG_NORMAL);
	else if(!mod(pl_number,2))
		drawfill(pos - '1 1 0', tmp + '2 0 0', '1 1 1', 0.09, DRAWFLAG_NORMAL);

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
			drawpic(pos - tmp, sbar_field_icon0, '0 1 0' * sbar_fontsize_y + '1 0 0' * sbar_fontsize_x * sbar_fixscoreboardcolumnwidth_iconlen, sbar_field_icon1_rgb, sbar_field_icon0_alpha, DRAWFLAG_NORMAL);
		if(sbar_field_icon1 != "")
			drawpic(pos - tmp, sbar_field_icon1, '0 1 0' * sbar_fontsize_y + '1 0 0' * sbar_fontsize_x * sbar_fixscoreboardcolumnwidth_iconlen, sbar_field_icon1_rgb, sbar_field_icon1_alpha, DRAWFLAG_NORMAL);
		if(sbar_field_icon2 != "")
			drawpic(pos - tmp, sbar_field_icon2, '0 1 0' * sbar_fontsize_y + '1 0 0' * sbar_fontsize_x * sbar_fixscoreboardcolumnwidth_iconlen, sbar_field_icon2_rgb, sbar_field_icon2_alpha, DRAWFLAG_NORMAL);
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
				drawpic(pos - tmp, sbar_field_icon0, '0 1 0' * sbar_fontsize_y + '1 0 0' * sbar_fontsize_x * sbar_fixscoreboardcolumnwidth_iconlen, sbar_field_icon1_rgb, sbar_field_icon0_alpha, DRAWFLAG_NORMAL);
			if(sbar_field_icon1 != "")
				drawpic(pos - tmp, sbar_field_icon1, '0 1 0' * sbar_fontsize_y + '1 0 0' * sbar_fontsize_x * sbar_fixscoreboardcolumnwidth_iconlen, sbar_field_icon1_rgb, sbar_field_icon1_alpha, DRAWFLAG_NORMAL);
			if(sbar_field_icon2 != "")
				drawpic(pos - tmp, sbar_field_icon2, '0 1 0' * sbar_fontsize_y + '1 0 0' * sbar_fontsize_x * sbar_fixscoreboardcolumnwidth_iconlen, sbar_field_icon2_rgb, sbar_field_icon2_alpha, DRAWFLAG_NORMAL);

			pos_x -= sbar_fontsize_x*sbar_size[i] + sbar_fontsize_x;
		}
	}
}

/*
 * Sbar_Scoreboard_MakeTable
 * 
 * Makes the table for the team:
 *   rows and columns alternatively highlighted
 *   header darker
 *   player brighter
 */

vector Sbar_Scoreboard_MakeTable(vector pos, entity tm, vector rgb, vector bg_size)
{
	float specs, i, pos_x_save;
	vector tmp;
	
	specs = tm.team_size;
	
	pos -= '1 1 0';

	tmp_x = sbwidth + 2;
	
	// columns headers background
	tmp_y = 1.25 * sbar_fontsize_y;
	
	// flat header
	//drawfill(pos, tmp, '0.5 0.5 0.5', sbar_scoreboard_alpha_bg, DRAWFLAG_NORMAL);
	
	// rounded header
	drawpic(pos, "gfx/hud/sb_scoreboard_tableheader", tmp, '0.5 0.5 0.5', sbar_scoreboard_alpha_bg, DRAWFLAG_NORMAL);
	
	tmp_y += 1.25 * sbar_fontsize_y * specs;
	tmp_y += sbar_border_tickness;
	drawborderlines(sbar_border_tickness, pos, tmp, '0 0 0', sbar_scoreboard_alpha_bg, DRAWFLAG_NORMAL); // more transparency for the scoreboard
	
	// separator
	pos_y += 1.25 * sbar_fontsize_y;
	tmp_y = sbar_border_tickness;
	drawfill(pos, tmp, '0 0 0', sbar_scoreboard_alpha_bg, DRAWFLAG_NORMAL);
	
	pos_y += sbar_border_tickness;
	
	// team board (borders, background, some color)
	tmp_x -= 2;
	tmp_y = 1.25 * sbar_fontsize_y * specs;
	drawpic_tiled(pos, "gfx/hud/sb_scoreboard_bg", bg_size, tmp + '3 1 0', rgb * sbar_color_bg_team, sbar_scoreboard_alpha_bg, DRAWFLAG_NORMAL);
		
	// anyway, apply some color
	drawfill(pos, tmp + '2 0 0', rgb, 0.1, DRAWFLAG_NORMAL);
	
	// go back to the top to make alternated columns highlighting and to print the strings
	pos_y -= 1.25 * sbar_fontsize_y;
	pos_y -= sbar_border_tickness;
	
	pos += '1 1 0';
	
	pos_x_save = pos_x; // will be restored after the column headers are printed

	vector column_dim;
	column_dim_y = specs * 1.25 * sbar_fontsize_y;
	column_dim_y += sbar_border_tickness;
	column_dim_y += 1.25 * sbar_fontsize_y; // header
	
	// print the strings of the columns headers
	for(i = 0; i < sbar_num_fields; ++i)
	{
		column_dim_x = sbar_fontsize_x*sbar_size[i] + sbar_fontsize_x;
		if(sbar_field[i] == SP_SEPARATOR)
			break;
		if (mod(i,2)) // alternated columns highlighting
			drawfill(pos - '1 1 0', column_dim, '0 0 0', sbar_scoreboard_alpha_bg * 0.6, DRAWFLAG_NORMAL);
		drawstring(pos, sbar_title[i], sbar_fontsize, '1 1 1', 1, DRAWFLAG_NORMAL);
		pos_x += column_dim_x;
	}
	if(sbar_field[i] == SP_SEPARATOR)
	{
		pos_x = xmax; // NO + sbar_fontsize_x
		tmp_y = tmp_z = 0;
		for(i = sbar_num_fields-1; i > 0; --i)
		{
			if(sbar_field[i] == SP_SEPARATOR)
				break;

			if (i == sbar_num_fields-1)
				column_dim_x = sbar_fontsize_x*sbar_size[i];
			else
				column_dim_x = sbar_fontsize_x*sbar_size[i] + sbar_fontsize_x;
			
			/**
			 * FTEQCC BUG!
			 * Using the following line will mess it all up:
			 **
			 * tmp_x = sbar_size[i] - strlen(sbar_title[i])*8;
			 */
			pos_x -= stringwidth(sbar_title[i], FALSE)*sbar_fontsize_x;
			if (!mod(i,2)) // alternated columns highlighting
				drawfill(pos - '1 1 0', column_dim, '0 0 0', sbar_scoreboard_alpha_bg * 0.6, DRAWFLAG_NORMAL);
			drawstring(pos, sbar_title[i], sbar_fontsize, '1 1 1', 1, DRAWFLAG_NORMAL);
			pos_x -= sbar_fontsize_x;
		}
	}
	
	pos_x = pos_x_save;
	pos_y += 1.25 * sbar_fontsize_y; // skip the header
	pos_y += sbar_border_tickness;
	return pos;
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
	ymin = 75;

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
	pos_y += sbar_fontsize_y;

	drawfont = sbar_font;

	sbar_save = sbar;
	sbar = '0 0 0';
	
	vector bg_size;
	bg_size = drawgetimagesize("gfx/hud/sb_scoreboard_bg");

	if(teamplay)
	{
		//for(tm = sortedTeams.sort_next; tm; tm = tm.sort_next)
		for(tm = teams.sort_next; tm; tm = tm.sort_next)
		{
			if(!tm.team_size || tm.team == COLOR_SPECTATOR)
				continue;

			rgb = GetTeamRGB(tm.team);

			Sbar_DrawXNum(sbar + pos - '6.5 0 0' * sbar_fontsize_y + '0 1 0' * sbar_fontsize_y, tm.(teamscores[ts_primary]), 4, sbar_fontsize_y * 1.5, rgb, 0, 1, 1, DRAWFLAG_NORMAL);

			if(ts_primary != ts_secondary)
				Sbar_DrawXNum(sbar + pos - '4.5 0 0' * sbar_fontsize_y + '0 2.5 0' * sbar_fontsize_y, tm.(teamscores[ts_secondary]), 4, sbar_fontsize_y * 1, rgb, 0, 1, 1, DRAWFLAG_NORMAL);

			pos = Sbar_Scoreboard_MakeTable(pos, tm, rgb, bg_size);
			
			// fill cells (could be integrated in Sbar_Scoreboard_MakeTable however...)
			specs = 0;
			for(pl = players.sort_next; pl; pl = pl.sort_next)
			{
				if(pl.team != tm.team)
					continue;
				Sbar_PrintScoreboardItem(pos, pl, (pl.sv_entnum == player_localentnum - 1), specs);
				pos_y += 1.25 * sbar_fontsize_y;
				++specs;
			}
			pos_y += 1.25 * sbar_fontsize_y;
			pos_y += 1.25 * sbar_fontsize_y; // add an empty row
		}
	}
	else
	{
		rgb_x = cvar("sbar_color_bg_r");
		rgb_y = cvar("sbar_color_bg_g");
		rgb_z = cvar("sbar_color_bg_b");

		tm = teams.sort_next;
		
		pos = Sbar_Scoreboard_MakeTable(pos, tm, rgb, bg_size);
		
		// fill cells (could be integrated in Sbar_Scoreboard_MakeTable however...)
		specs = 0;
		for(pl = players.sort_next; pl; pl = pl.sort_next)
		{
			if(pl.team == COLOR_SPECTATOR)
				continue;
			Sbar_PrintScoreboardItem(pos, pl, (pl.sv_entnum == player_localentnum - 1), specs);
			pos_y += 1.25 * sbar_fontsize_y;
			++specs;
		}
		pos_y += 1.25 * sbar_fontsize_y;
		pos_y += 1.25 * sbar_fontsize_y; // add an empty row
	}

	tmp = pos + '0 1.5 0' * sbar_fontsize_y;
	pos_y += 3 * sbar_fontsize_y;
	specs = 0;
	for(pl = players.sort_next; pl; pl = pl.sort_next)
	{
		if(pl.team != COLOR_SPECTATOR)
			continue;
		Sbar_PrintScoreboardItem(pos, pl, (pl.sv_entnum == player_localentnum - 1), specs);
		pos_y += 1.25 * sbar_fontsize_y;
		++specs;
	}

	if(specs)
		drawstring(tmp, "Spectators", sbar_fontsize, '1 1 1', 1, DRAWFLAG_NORMAL);

	string str;
	float tl, fl, ll;
	str = strcat("playing on ^2", shortmapname, "^7");
	tl = getstatf(STAT_TIMELIMIT);
	fl = getstatf(STAT_FRAGLIMIT);
	ll = getstatf(STAT_LEADLIMIT);
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
		if(ll > 0)
		{
			if(tl > 0 || fl > 0)
				str = strcat(str, " or");
			if(teamplay)
			{
				str = strcat(str, " until a lead of ^3", ScoreString(teamscores_flags[ts_primary], ll));
				if(teamscores_label[ts_primary] == "score")
					str = strcat(str, " points^7");
				else if(teamscores_label[ts_primary] == "fastest")
					str = strcat(str, " is beaten^7");
				else
					str = strcat(str, " ", teamscores_label[ts_primary]);
			}
			else
			{
				str = strcat(str, " until a lead of ^3", ScoreString(scores_flags[ps_primary], ll));
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
	drawcolorcodedstring(pos + '0.5 0 0' * (sbwidth - sbar_fontsize_x * stringwidth(str, TRUE)), str, sbar_fontsize, 0.8, DRAWFLAG_NORMAL);

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
	float timelimit, minutes, seconds, timeleft, minutesLeft, secondsLeft, distribution, myplace, score, desiredPlayerId;
	vector sbar_save, place, timer_color, offset;
	entity tm, pl, me;
	sbar_save = sbar;

 	vector bottomright;
 	bottomright_x = vid_conwidth;
 	bottomright_y = vid_conheight;
 	bottomright_z = 0;

 	vector topright;
 	topright_x = vid_conwidth;
 	topright_y = 0;
 	topright_z = 0;

	//get the ID (could be "me", or the player I'm spectating)
	desiredPlayerId = player_localentnum - 1;
	if (spectatee_status) {
		if (spectatee_status != -1) {
			desiredPlayerId = spectatee_status - 1;
		}
	}

	sbar_y = vid_conheight - (32+12);
	sbar_x -= margin;

	offset = '0 0 0';
	place_z = 0;
	if(teamplay)
	{
		// Layout:
		//
		//   team1 team3 team4
		//
		//         TEAM2
		//for(i = 0; i < 4; ++i)
		if (vid_conwidth >= 800) {
			place_x = 196;
			place_y = 36;
		}
		else {
			place_x = 196;
			place_y = 84;
		}

		float max_fragcount;
		max_fragcount = -999;

		for(tm = teams.sort_next; tm; tm = tm.sort_next)
		{
			if(tm.team == COLOR_SPECTATOR || !tm.team_size) // no players? don't display
				continue;
			// -32*4 = -128
			score = tm.(teamscores[ts_primary]);

			if (score > max_fragcount)
				max_fragcount = score;

			if(tm.team == myteam) {
				if (max_fragcount == score)
					Sbar_DrawXNum(bottomright - element_offset - place, score, 4, 34, GetTeamRGB(tm.team) * 0.8, 1, 1, sbar_alpha_fg, DRAWFLAG_NORMAL);
				else
					Sbar_DrawXNum(bottomright - element_offset - place, score, 4, 34, GetTeamRGB(tm.team) * 0.8, 0, 1, sbar_alpha_fg, DRAWFLAG_NORMAL);
			}
			else
			{
				if (max_fragcount == score)
					Sbar_DrawXNum(bottomright - element_offset - place + '132 -6 0' - offset, score, 4, 16, GetTeamRGB(tm.team) * 0.8, 1, 1, sbar_alpha_fg, DRAWFLAG_NORMAL);
				else
					Sbar_DrawXNum(bottomright - element_offset - place + '132 -6 0' - offset, score, 4, 16, GetTeamRGB(tm.team) * 0.8, 0, 1, sbar_alpha_fg, DRAWFLAG_NORMAL);
				offset_y -= 16;
			}
		}
	} else {
		// me vector := [team/connected frags id]

		myplace = 0;
		for(me = players.sort_next; me; me = me.sort_next)
		{
			if(me.team != COLOR_SPECTATOR)
				++myplace;
			if(me.sv_entnum == desiredPlayerId)
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

		if (vid_conwidth >= 800) {
			place_x = 196;
			place_y = 36;
		}
		else { // move the scores if vid_conwidth < 800
			place_x = 196;
			place_y = 84;
		}
		score = me.(scores[ps_primary]);

		if(distribution >= 0)
		{
			if (distribution != 0) {
				// draw a + sign in front of the score
				if (distribution < 10) { drawpic(bottomright - element_offset - place + '132 -6 0' + '32 0 0', "gfx/hud/num_plus", '16 16 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_ADDITIVE); }
				else if (distribution < 100) { drawpic(bottomright - element_offset - place + '132 -6 0' + '16 0 0', "gfx/hud/num_plus", '16 16 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_ADDITIVE); }
				else if (distribution < 1000) { drawpic(bottomright - element_offset - place + '132 -6 0', "gfx/hud/num_plus", '16 16 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_ADDITIVE); }
			}

			Sbar_DrawXNum(bottomright - element_offset - place + '132 -6 0', distribution, 4, 16, ' 1 1 1', 0, 0, sbar_alpha_fg, DRAWFLAG_NORMAL);
			Sbar_DrawXNum(bottomright - element_offset - place, score, 4, 34, '1 1 1', 1, 0, sbar_alpha_fg, DRAWFLAG_NORMAL);
		}
		else if(distribution >= -5)
		{
			Sbar_DrawXNum(bottomright - element_offset - place + '132 -6 0', distribution, 4, 16, ' 1 1 0', 0, 0, sbar_alpha_fg, DRAWFLAG_NORMAL);
			Sbar_DrawXNum(bottomright - element_offset - place, score, 4, 34, '1 1 0', 0, 0, sbar_alpha_fg, DRAWFLAG_NORMAL);
		}
		else {
			Sbar_DrawXNum(bottomright - element_offset - place + '132 -6 0', distribution, 4, 16, ' 1 0 0', 0, 0, sbar_alpha_fg, DRAWFLAG_NORMAL);
			Sbar_DrawXNum(bottomright - element_offset - place, score, 4, 34, '1 0 0', 0, 0, sbar_alpha_fg, DRAWFLAG_NORMAL);
		}
	}

	//draw the remaining or elapsed time
	timelimit = getstatf(STAT_TIMELIMIT);

	vector bgpos;
	if(timelimit > 0)
	{
		timeleft = max(0, timelimit * 60 + getstatf(STAT_GAMESTARTTIME) - time);
		timeleft = ceil(timeleft);
		minutesLeft = floor(timeleft / 60);
		secondsLeft = timeleft - minutesLeft*60;

		if(minutesLeft >= 5 || warmup_stage) //don't use red or yellow for timer during warmup
			timer_color = '1 1 1'; //white
		else if(minutesLeft >= 1)
			timer_color = '1 1 0'; //yellow
		else
			timer_color = '1 0 0'; //red

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

		if (minutes == 0) {
			if (cvar("sbar_increment_maptime") == 1)
				bgpos_x = topright_x - 54 - 17 - 12;
			else
				bgpos_x = topright_x - 36 - 7 - 12;
		}
		else if (minutes < 10) // nudge the timer background left if more digits are drawn
			bgpos_x = topright_x - 54 - 17 - 12;
		else if (minutes < 100)
			bgpos_x = topright_x - 72 - 17 - 12;
		else
			bgpos_x = topright_x - 90 - 17 - 12;
		bgpos_y = 0;
		bgpos_z = 0;

		if (cvar("viewsize") <= 100) { // draw timer background when viewsize <= 100
			if (teamplay)
				drawpic(bgpos, "gfx/hud/sb_timerbg", '120 30 0', GetTeamRGB(myteam) * sbar_color_bg_team, sbar_alpha_bg, DRAWFLAG_NORMAL); // timer bg color = myteam color
			else {
				color_x = cvar("sbar_color_bg_r");
				color_y = cvar("sbar_color_bg_g");
				color_z = cvar("sbar_color_bg_b");

				drawpic(bgpos, "gfx/hud/sb_timerbg", '120 30 0', color, sbar_alpha_bg, DRAWFLAG_NORMAL);
			}
		}

		if(minutesLeft >= 1) {
			Sbar_DrawXNum(topright - '103 0 0' + '0 2 0', minutes, 3, 18, timer_color, 0, 0, sbar_alpha_fg, DRAWFLAG_NORMAL);
			drawpic(topright - '53 0 0' + '0 1 0', "gfx/hud/num_colon", '18 18 0', timer_color, sbar_alpha_fg, DRAWFLAG_NORMAL);
		}
		Sbar_DrawXNum(topright - '36 0 0' - '3 0 0' + '0 2 0', seconds, -2, 18, timer_color, 0, 0, sbar_alpha_fg, DRAWFLAG_NORMAL);

	} else {
		timer_color = '1 1 1'; //white
		minutes = floor(time / 60);
		seconds = floor(time - minutes*60);

		if (minutes < 10)
			bgpos_x = topright_x - 54 - 17 - 12;
		else if (minutes < 100)	// nudge the timer background left if more digits are drawn
			bgpos_x = topright_x - 72 - 17 - 12;
		else
			bgpos_x = topright_x - 90 - 17 - 12;
		bgpos_y = 0;
		bgpos_z = 0;

		if (cvar("viewsize") <= 100) { // draw timer background when viewsize <= 100
			if (teamplay)
				drawpic(bgpos, "gfx/hud/sb_timerbg", '120 30 0', GetTeamRGB(myteam) * sbar_color_bg_team, sbar_alpha_bg, DRAWFLAG_NORMAL); // timer bg color = myteam color
			else {
				color_x = cvar("sbar_color_bg_r");
				color_y = cvar("sbar_color_bg_g");
				color_z = cvar("sbar_color_bg_b");

				drawpic(bgpos, "gfx/hud/sb_timerbg", '120 30 0', color, sbar_alpha_bg, DRAWFLAG_NORMAL);
			}
		}

		Sbar_DrawXNum(topright - '103 0 0' + '0 2 0', minutes, 3, 18, timer_color, 0, 0, sbar_alpha_fg, DRAWFLAG_NORMAL);
		drawpic(topright - '53 0 0' + '0 1 0', "gfx/hud/num_colon", '18 18 0', timer_color, sbar_alpha_fg, DRAWFLAG_NORMAL);
		Sbar_DrawXNum(topright - '36 0 0' - '3 0 0' + '0 2 0', seconds, -2, 18, timer_color, 0, 0, sbar_alpha_fg, DRAWFLAG_NORMAL);
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
				drawcolorcodedstring(m - '0 16 0' - '8 0 0' * stringwidth(s, TRUE), s, '16 16 0', sbar_alpha_fg * a, DRAWFLAG_NORMAL);
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
				drawstring(m - '16 0 0' * stringwidth(s, FALSE), s, '32 32 0', '1 1 1', sbar_alpha_fg * a, DRAWFLAG_NORMAL);
			}
		}
		else
		{
			if(race_mycheckpointtime)
			{
				a = bound(0, 2 - (time - race_mycheckpointtime), 1);
				s = MakeRaceString(race_mycheckpoint, race_mycheckpointdelta / 10, -!race_mycheckpointenemy, race_mycheckpointlapsdelta, race_mycheckpointenemy);
				dummyfunction(0, 0, 0, 0, 0, 0, 0, 0); // work around DP bug (set OFS_PARAM5 to 0)
				drawcolorcodedstring(m - '0 16 0' - '8 0 0' * stringwidth(s, TRUE), s, '16 16 0', sbar_alpha_fg * a, DRAWFLAG_NORMAL);
			}
			if(race_othercheckpointtime && race_othercheckpointenemy != "")
			{
				a = bound(0, 2 - (time - race_othercheckpointtime), 1);
				s = MakeRaceString(race_othercheckpoint, -race_othercheckpointdelta / 10, -!race_othercheckpointenemy, race_othercheckpointlapsdelta, race_othercheckpointenemy);
				dummyfunction(0, 0, 0, 0, 0, 0, 0, 0); // work around DP bug (set OFS_PARAM5 to 0)
				drawcolorcodedstring(m - '0 0 0' - '8 0 0' * stringwidth(s, TRUE), s, '16 16 0', sbar_alpha_fg * a, DRAWFLAG_NORMAL);
			}
		}

		drawfont = sbar_font;
	}

	sbar = sbar_save;
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
	vector bottom;

	bottom_x = vid_conwidth/2;
	bottom_y = vid_conheight;
	bottom_z = 0;

	float stat_items, dt;
	stat_items = getstati(STAT_ITEMS);
	/*
	if not(stat_items & IT_STRENGTH)
		if not(stat_items & IT_INVINCIBLE)
			return;
	*/

	if (getstati(STAT_HEALTH) <= 0)
		return;

	vector picsize;
	float strength_time, invincibility_time, countdown_fontsize;

	picsize = '22 22 0';
	countdown_fontsize = 18;

	//strength
	strength_time = getstatf(STAT_STRENGTH_FINISHED);
	invincibility_time = getstatf(STAT_INVINCIBLE_FINISHED);

	if (strength_time) {
		dt = strength_time - time;
		if(dt > 0)
		{
			if(dt < 5)
			{
				drawpic_expanding_two(bottom + '192 -46 0', "gfx/hud/sb_str", picsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_ADDITIVE,
					bound(0, (ceil(dt) - dt) / 0.5, 1));
			}
			else
			{
				drawpic(bottom + '192 -46 0', "gfx/hud/sb_str", picsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_ADDITIVE);
			}
			Sbar_DrawXNum(bottom + '152 -44 0', ceil(dt), 2, countdown_fontsize, '1 1 1', 0, 0, sbar_alpha_fg, DRAWFLAG_NORMAL);
		}
		else if(dt > -1)
		{
			drawpic_expanding(bottom + '192 -46 0', "gfx/hud/sb_str", picsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_ADDITIVE,
				bound(0, -dt / 0.5, 1));
		}
	}

	//invincibility
	if (invincibility_time) {
		dt = invincibility_time - time;
		if(dt > 0)
		{
			if(dt < 5)
			{
				drawpic_expanding_two(bottom + '192 -24 0', "gfx/hud/sb_invinc", picsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_ADDITIVE,
					bound(0, (ceil(dt) - dt) / 0.5, 1));
			}
			else
			{
				drawpic(bottom + '192 -24 0', "gfx/hud/sb_invinc", picsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_ADDITIVE);
			}
			Sbar_DrawXNum(bottom + '152 -22 0', ceil(dt), 2, countdown_fontsize, '1 1 1', 0, 0, 1, DRAWFLAG_NORMAL);
		}
		else if(dt > -1)
		{
			drawpic_expanding(bottom + '192 -24 0', "gfx/hud/sb_invinc", picsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_ADDITIVE,
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
	drawpic(pos + '-15   -6   0', "gfx/hud/keys/key_bg.tga",           bgsize, '1 1 1', .1, DRAWFLAG_NORMAL);
	drawpic(pos + ' 83.5  9   0', ((pressedkeys & KEY_CROUCH) ? "gfx/hud/keys/key_crouch_inv.tga" : "gfx/hud/keys/key_crouch.tga"), ' 24 24 0', '1 1 1', 1, DRAWFLAG_NORMAL);
	drawpic(pos + ' 32   -1.5 0', ((pressedkeys & KEY_FORWARD) ? "gfx/hud/keys/key_forward_inv.tga" : "gfx/hud/keys/key_forward.tga"),  ' 32 32 0', '1 1 1', 1, DRAWFLAG_NORMAL);
	drawpic(pos + '-11.5  9   0', ((pressedkeys & KEY_JUMP) ? "gfx/hud/keys/key_jump_inv.tga" : "gfx/hud/keys/key_jump.tga"),     ' 24 24 0', '1 1 1', 1, DRAWFLAG_NORMAL);
	drawpic(pos + ' -1   32   0', ((pressedkeys & KEY_LEFT) ? "gfx/hud/keys/key_left_inv.tga" : "gfx/hud/keys/key_left.tga"),     ' 32 32 0', '1 1 1', 1, DRAWFLAG_NORMAL);
	drawpic(pos + ' 32   32   0', ((pressedkeys & KEY_BACKWARD) ? "gfx/hud/keys/key_backward_inv.tga" : "gfx/hud/keys/key_backward.tga"), ' 32 32 0', '1 1 1', 1, DRAWFLAG_NORMAL);
	drawpic(pos + ' 65   32   0', ((pressedkeys & KEY_RIGHT) ? "gfx/hud/keys/key_right_inv.tga" : "gfx/hud/keys/key_right.tga"),    ' 32 32 0', '1 1 1', 1, DRAWFLAG_NORMAL);
}

void Sbar_ShowSpeed(void)
{
	vector numsize;
	float pos;
	string speed;
	
	if (cvar("cl_showspeed_z") == 1)
		speed = ftos(floor(vlen(pmove_vel) + 0.5));
	else
		speed = ftos(floor(vlen(pmove_vel - pmove_vel_z * '0 0 1') + 0.5));
		
	pos = cvar("cl_showspeed_position");
	numsize_x = numsize_y = cvar("cl_showspeed_size");
	pos = (vid_conheight - numsize_y) * pos;
	
	drawstringcenter('1 0 0' + pos * '0 1 0', speed, numsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);
}

void Sbar_DrawAccuracyStats()
{
	float i, count_hitscan, count_splash, row;  // count is the number of 'colums'
	float weapon_hit, weapon_damage, weapon_stats;
	float left_border;  // position where the weapons start, the description is in the border
	vector fill_colour, fill_size;
	vector pos;

	float col_margin = 20;  // pixels between the columns
	float row_margin = 20;  // pixels between the rows
	float top_border;  // position where the first row starts: pixels down the screen

	fill_size_x = 5 * sbar_fontsize_x;  // width of the background
	fill_size_y = 10 * sbar_fontsize_y;  // height of the background

	// 45 pixels is the same as the 'Scoreboard' heading
	drawfont = sbar_bigfont;
	drawstringcenter('0 45 0', "Weapon Accuracy", 2 * sbar_fontsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);
	left_border = col_margin + 11 * sbar_fontsize_x;

	top_border = 80;
	Sbar_DrawAccuracyStats_Description_Hitscan('1 0 0' * col_margin + '0 1 0' * top_border);

	top_border = 220;
	Sbar_DrawAccuracyStats_Description_Splash('1 0 0' * col_margin + '0 1 0' * top_border);


	for(i = WEP_FIRST; i <= WEP_LAST; ++i)
	{
		weapon_hit = weapon_hits[i];
		weapon_damage = weapon_fired[i];
		self = get_weaponinfo(i);

		//if ((weapon_number != 42))  // print them all :)
 		if ((self.weapon_type == WEP_TYPE_SPLASH) && (weapon_damage))
		{
			top_border = 220;
			weapon_stats = rint(100 * weapon_hit / weapon_damage);

			fill_colour_x = 1 - 0.015 * weapon_stats;
			fill_colour_y = 1 - 0.015 * (100 - weapon_stats);

// 			how the background colour is calculated
// 			%	red	green	red_2		green_2
// 			0	1	0	1 - % * 0.015	1 - (100 - %) * 0.015
// 			10	0.85	0	1 - % * 0.015	1 - (100 - %) * 0.015
// 			20	0.70	0	1 - % * 0.015	1 - (100 - %) * 0.015
// 			30	0.55	0	1 - % * 0.015	1 - (100 - %) * 0.015
// 			40	0.40	0.10	1 - % * 0.015	1 - (100 - %) * 0.015
// 			50	0.25	0.25	1 - % * 0.015	1 - (100 - %) * 0.015
// 			60	0.10	0.40	1 - % * 0.015	1 - (100 - %) * 0.015
// 			70	0	0.55	1 - % * 0.015	1 - (100 - %) * 0.015
// 			80	0	0.70	1 - % * 0.015	1 - (100 - %) * 0.015
// 			90	0	0.85	1 - % * 0.015	1 - (100 - %) * 0.015
// 			100	0	1	1 - % * 0.015	1 - (100 - %) * 0.015

			if ((left_border + count_splash * (fill_size_x + col_margin) + fill_size_x) >= vid_conwidth)
			{
				count_splash = 0;
				++row;
				Sbar_DrawAccuracyStats_Description_Splash('1 0 0' * col_margin + '0 1 0' * (top_border + row * (fill_size_y + row_margin)));
			}

			pos_x = left_border + count_splash * (fill_size_x + col_margin);
			pos_y = top_border + row * (fill_size_y + row_margin);

			// background
			drawpic(pos, "gfx/hud/sb_accuracy", fill_size , fill_colour, sbar_alpha_bg, DRAWFLAG_NORMAL);
			drawborderlines(sbar_border_tickness, pos, fill_size, '0 0 0', sbar_alpha_bg, DRAWFLAG_NORMAL);

			// the weapon
			drawpic(pos, strcat("gfx/hud/inv_weapon", ftos(i-1)), '1 0.5 0' * fill_size_x , '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);

			// the amount of shots fired or max damage
			drawstringright(pos + '4.5 0 0' * sbar_fontsize_x + '0 3 0' * sbar_fontsize_y, ftos(weapon_damage), sbar_fontsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);

			// the amount of hits or actual damage
			drawstringright(pos + '4.5 0 0' * sbar_fontsize_x + '0 5 0' * sbar_fontsize_y, ftos(weapon_hit), sbar_fontsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);

			// the accuracy
			drawstringright(pos + '4.5 0 0' * sbar_fontsize_x + '0 7 0' * sbar_fontsize_y, strcat(ftos(weapon_stats),"%"), sbar_fontsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);

			// the amount of shots missed or damage wasted
			drawstringright(pos + '4.5 0 0' * sbar_fontsize_x + '0 9 0' * sbar_fontsize_y, ftos(weapon_damage - weapon_hit), sbar_fontsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);

			++count_splash;
		}
		else if ((self.weapon_type == WEP_TYPE_HITSCAN) && (weapon_damage))
		{
			top_border = 80;
			weapon_stats = rint(100 * weapon_hit / weapon_damage);

			fill_colour_x = 1 - 0.015 * weapon_stats;
			fill_colour_y = 1 - 0.015 * (100 - weapon_stats);

// 			how the background colour is calculated
// 			%	red	green	red_2		green_2
// 			0	1	0	1 - % * 0.015	1 - (100 - %) * 0.015
// 			10	0.85	0	1 - % * 0.015	1 - (100 - %) * 0.015
// 			20	0.70	0	1 - % * 0.015	1 - (100 - %) * 0.015
// 			30	0.55	0	1 - % * 0.015	1 - (100 - %) * 0.015
// 			40	0.40	0.10	1 - % * 0.015	1 - (100 - %) * 0.015
// 			50	0.25	0.25	1 - % * 0.015	1 - (100 - %) * 0.015
// 			60	0.10	0.40	1 - % * 0.015	1 - (100 - %) * 0.015
// 			70	0	0.55	1 - % * 0.015	1 - (100 - %) * 0.015
// 			80	0	0.70	1 - % * 0.015	1 - (100 - %) * 0.015
// 			90	0	0.85	1 - % * 0.015	1 - (100 - %) * 0.015
// 			100	0	1	1 - % * 0.015	1 - (100 - %) * 0.015

			if ((left_border + count_hitscan * (fill_size_x + col_margin) + fill_size_x + cvar("stats_right_margin")) >= vid_conwidth)
			{
				count_hitscan = 0;
				++row;
				Sbar_DrawAccuracyStats_Description_Hitscan('1 0 0' * col_margin + '0 1 0' * (top_border + row * (fill_size_y + row_margin)));
			}

			pos_x = left_border + count_hitscan * (fill_size_x + col_margin);
			pos_y = top_border + row * (fill_size_y + row_margin);

			// background
			drawpic(pos, "gfx/hud/sb_accuracy", fill_size , fill_colour, sbar_alpha_bg, DRAWFLAG_NORMAL);
			drawborderlines(sbar_border_tickness, pos, fill_size, '0 0 0', sbar_alpha_bg, DRAWFLAG_NORMAL);

			// the weapon
			drawpic(pos, strcat("gfx/hud/inv_weapon", ftos(i-1)), '1 0.5 0' * fill_size_x , '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);

			// the amount of shots fired or max damage
			drawstringright(pos + '4.5 0 0' * sbar_fontsize_x + '0 3 0' * sbar_fontsize_y, ftos(weapon_damage), sbar_fontsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);

			// the amount of hits or actual damage
			drawstringright(pos + '4.5 0 0' * sbar_fontsize_x + '0 5 0' * sbar_fontsize_y, ftos(weapon_hit), sbar_fontsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);

			// the accuracy
			drawstringright(pos + '4.5 0 0' * sbar_fontsize_x + '0 7 0' * sbar_fontsize_y, strcat(ftos(weapon_stats),"%"), sbar_fontsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);

			// the amount of shots missed or damage wasted
			drawstringright(pos + '4.5 0 0' * sbar_fontsize_x + '0 9 0' * sbar_fontsize_y, ftos(weapon_damage - weapon_hit), sbar_fontsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);

			++count_hitscan;
		}
	}
}

void Sbar_DrawAccuracyStats_Description_Hitscan(vector position)
{
	drawfont = sbar_font;
	 // hitscan stats
	drawstring(position + '0 3 0' * sbar_fontsize_y, "Shots fired:", sbar_fontsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);
	drawstring(position + '0 5 0' * sbar_fontsize_y, "Shots hit:", sbar_fontsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);
	drawstring(position + '0 7 0' * sbar_fontsize_y, "Accuracy:", sbar_fontsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);
	drawstring(position + '0 9 0' * sbar_fontsize_y, "Shots missed:", sbar_fontsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);
}

void Sbar_DrawAccuracyStats_Description_Splash(vector position)
{
	//splash stats
	drawfont = sbar_font;
	drawstring(position + '0 3 0' * sbar_fontsize_y, "Maximum damage:", sbar_fontsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);
	drawstring(position + '0 5 0' * sbar_fontsize_y, "Actual damage:", sbar_fontsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);
	drawstring(position + '0 7 0' * sbar_fontsize_y, "Accuracy:", sbar_fontsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);
	drawstring(position + '0 9 0' * sbar_fontsize_y, "Damage wasted:", sbar_fontsize, '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);
}

void drawstringright(vector position, string text, vector scale, vector rgb, float alpha, float flag)
{
	position_x -= 2 / 3 * strlen(text) * scale_x;
	drawstring(position, text, scale, rgb, alpha, flag);
}

void drawstringcenter(vector position, string text, vector scale, vector rgb, float alpha, float flag)
{
	position_x = 0.5 * (vid_conwidth - 0.6025 * strlen(text) * scale_x);
	drawstring(position, text, scale, rgb, alpha, flag);
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
		case 0: return "gfx/hud/sb_shells";
		case 1: return "gfx/hud/sb_bullets";
		case 2: return "gfx/hud/sb_rocket";
		case 3: return "gfx/hud/sb_cells";
		case 4: return "gfx/hud/sb_fuel";
		default: return "";
	}
}

void Sbar_Draw (void)
{
	// vectors for top right, bottom right, bottom and bottom left corners

	vector topright;
	vector bottom;
	vector bottomright;
	vector bottomleft;

	topright_x = vid_conwidth;
	topright_y = 0;
	topright_z = 0;

	bottom_x = vid_conwidth/2;
	bottom_y = vid_conheight;
	bottom_z = 0;

	bottomright_x = vid_conwidth;
	bottomright_y = vid_conheight;
	bottomright_z = 0;

	bottomleft_x = 0;
	bottomleft_y = vid_conheight;
	bottomleft_z = 0;

	sbar_alpha_bg = cvar("sbar_alpha_bg");
	sbar_scoreboard_alpha_bg = cvar("sbar_scoreboard_alpha_bg");
	sbar_color_bg_team = cvar("sbar_color_bg_team");
	sbar_border_tickness = 2;

	float i;
	float weapon_stats;
	float x, fade;
	float stat_items, stat_weapons;

	weapon_stats = getstati(STAT_DAMAGE_HITS);
 	weapon_number = weapon_stats & 63;
 	weapon_hits[weapon_number] = rint(weapon_stats / 64);

 	weapon_stats = getstati(STAT_DAMAGE_FIRED);
 	weapon_number = weapon_stats & 63;
 	weapon_fired[weapon_number] = rint(weapon_stats / 64);

	vector o; o = '1 0 0' * vid_conwidth;
	o_y = 28; // move spectator text slightly down to prevent overlapping the timer

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

	Sbar_UpdatePlayerTeams();

	if (intermission == 2) // map voting screen
	{
		if(sb_showscores) {
			Sbar_DrawScoreboard();
			Sbar_Score(16);
		}
		else if(sb_showaccuracy) {
			Sbar_DrawAccuracyStats();
			Sbar_Score(16);
		}
  		else
			Sbar_FinaleOverlay();
	}
	else if (sb_showscores_force || getstati(STAT_HEALTH) <= 0 || intermission == 1)
	{
  		if(sb_showaccuracy)
  			Sbar_DrawAccuracyStats();
  		else
			Sbar_DrawScoreboard();
		Sbar_Score(16);
  	}
	else
	{
		if (sb_showscores)
			Sbar_DrawScoreboard();
		else if(sb_showaccuracy)
			Sbar_DrawAccuracyStats();

		float armor, health;
		armor = getstati(STAT_ARMOR);
		health = getstati(STAT_HEALTH);

		stat_items = getstati(STAT_ITEMS);
		stat_weapons = getstati(STAT_WEAPONS);

		fade = 3.2 - 2 * (time - weapontime);
		fade = bound(0.7, fade, 1);

		vector bg_size; // hud background size
		bg_size_x = 800;
		if (vid_conwidth > 800) // if conwidth > 800, resize the background image
			bg_size_x = vid_conwidth;
		bg_size_y = 58;
		bg_size_z = 0;

		vector bgoffset; // hud background offset
		bgoffset_x = 0;
		bgoffset_y = 0;
		bgoffset_z = 0;
		if (vid_conwidth < 800) // if conwidth < 800 we need to offset the background image to keep it centered, as it will be scaled up
			bgoffset_x = (vid_conwidth - 800) / 2;

		if (cvar("viewsize") <= 100) {
			if (teamplay)
				drawpic(bottomleft - '0 58 0' + bgoffset, "gfx/hud/sbar", bg_size, GetTeamRGB(myteam) * sbar_color_bg_team, sbar_alpha_bg, DRAWFLAG_NORMAL); // hud color = myteam color
			else {
				// allow for custom HUD colors in non-teamgames
				color_x = cvar("sbar_color_bg_r");
				color_y = cvar("sbar_color_bg_g");
				color_z = cvar("sbar_color_bg_b");

				drawpic(bottomleft - '0 58 0' + bgoffset, "gfx/hud/sbar", bg_size, color, sbar_alpha_bg, DRAWFLAG_NORMAL);
			}
		}

		if(sbar_hudselector == 2) // combined health and armor display
		{
			vector v;
			v = healtharmor_maxdamage(health, armor, armorblockpercent);

			vector num_pos;
			num_pos = bottom - element_offset - '0 22 0' + '-96 0 0';

			x = floor(v_x + 1);

			if(v_z) // fully armored
			{
				// here, armorideal > armor
				drawpic(num_pos + '78 -4.5 0', "gfx/hud/sb_health", '32 32 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);
				drawpic(num_pos + '108 -4.5 0', "gfx/hud/sb_armor", '20 20 0', '1 1 1', sbar_alpha_fg * armor / v_y, DRAWFLAG_NORMAL);
			}
			else
			{
				drawpic(num_pos + '108 -4.5 0', "gfx/hud/sb_health", '20 20 0', '1 1 1', sbar_alpha_fg * v_y / armor, DRAWFLAG_NORMAL);
				drawpic(num_pos + '78 -4.5 0', "gfx/hud/sb_armor", '32 32 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);
			}
			Sbar_DrawXNum_Colored(num_pos, x, 24, sbar_alpha_fg); // draw the combined health and armor
		}

		else
		{
			vector health_pos, armor_pos;

			if (sbar_hudselector == 0) { // old style layout with armor left of health
				health_pos = bottom - element_offset - '0 22 0' + '14 0 0';
				armor_pos = bottom - element_offset - '0 22 0' + '-96 0 0';
			}
			else {
				health_pos = bottom - element_offset - '0 22 0' + '-96 0 0';
				armor_pos = bottom - element_offset - '0 22 0' + '14 0 0';
			}

			// armor
			x = armor;
			if (x > 0)
			{
				drawpic(armor_pos + '78 -4.5 0', "gfx/hud/sb_armor", '32 32 0', '1 1 1', (x+10)/55 * sbar_alpha_fg, DRAWFLAG_NORMAL);
				if (x > 45)
					Sbar_DrawXNum_Colored(armor_pos, x, 24, sbar_alpha_fg);
				else
					Sbar_DrawXNum_Colored(armor_pos, x, 24, (x+10)/55 * sbar_alpha_fg);
			}

			// health
			x = health;
			drawpic(health_pos + '78 -4.5 0', "gfx/hud/sb_health", '32 32 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);
			Sbar_DrawXNum_Colored(health_pos, x, 24, sbar_alpha_fg);
		}

		// weapon icons
		x = 1.0;
		Sbar_DrawWeapon_Clear();
		for(i = 1; i <= 24; ++i)
		{
			if(weaponimpulse[i-1] >= 0)
			if(stat_weapons & x)
			{
				Sbar_DrawWeapon(i-1, fade, (i == activeweapon), i);
			}
			x *= 2;
		}

		// ammo
		float a; // i will be the ammo type (already declared), a will contain how much ammo there is of type i
		vector pos;
		pos_z = 0;

		for (i = 0; i < 4; ++i) {
			a = getstati(GetAmmoStat(i)); // how much ammo do we have of type i?

			if(sbar_currentammo)
			{
				pos = '0 0 0';
				if (stat_items & GetAmmoItemCode(i))
				{
					if(vid_conwidth >= 800) {
						pos_x = 170;
						pos_y = -40;
					}
					else {
						pos_x = vid_conwidth - 110;
						pos_y = -128;
					}
					
					drawpic(bottomleft + pos + '0 1.5 0', "gfx/hud/sb_ammobg", '107 29 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);
					drawpic(bottomleft + pos + '76 3 0', GetAmmoPicture(i), '24 24 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);
					if(a < 10)
						Sbar_DrawXNum(bottomleft + pos + '5 5 0', a, 3, 24, '0.7 0 0', 0, 0, sbar_alpha_fg, DRAWFLAG_NORMAL);
					else
						Sbar_DrawXNum(bottomleft + pos + '5 5 0', a, 3, 24, '1 1 1', 0, 0, sbar_alpha_fg, DRAWFLAG_NORMAL);
				}
			}
			else
			{
				if (a > 0) {
					pos = '0 0 0';
					if (vid_conwidth >= 800)
						switch (i) {
							case 0: pos_x = 114; pos_y = -48; break; // shells
							case 1: pos_x = 114; pos_y = -26; break; // bullets
							case 2: pos_x = 200; pos_y = -48; break; // rockets
							case 3: pos_x = 200; pos_y = -26; break; // cells
						}
					else // if vid_conwidth is lower than 800, ammo will overlap with weapon icons and health so we'll move it to the right
						switch (i) {
							case 0: pos_x = vid_conwidth - 158; pos_y = -150; break; // shells
							case 1: pos_x = vid_conwidth - 158; pos_y = -128; break; // bullets
							case 2: pos_x = vid_conwidth - 84; pos_y = -150; break; // rockets
							case 3: pos_x = vid_conwidth - 84; pos_y = -128; break; // cells
						}

					if (stat_items & GetAmmoItemCode(i))
						drawpic(bottomleft + pos + '0 1.5 0', "gfx/hud/sb_ammobg", '80 22 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);
					drawpic(bottomleft + pos + '56 3 0', GetAmmoPicture(i), '18 18 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);
					if (a < 10) {
						if(stat_items & GetAmmoItemCode(i))
							Sbar_DrawXNum(bottomleft + pos + '6 4.5 0', a, 3, 16, '0.7 0 0', 0, 0, sbar_alpha_fg, DRAWFLAG_NORMAL);
						else
							Sbar_DrawXNum(bottomleft + pos + '6 4.5 0', a, 3, 16, '0.7 0 0', 0, 0, sbar_alpha_fg * 0.7, DRAWFLAG_NORMAL);
					} else {
						if(stat_items & GetAmmoItemCode(i))
							Sbar_DrawXNum(bottomleft + pos + '6 4.5 0', a, 3, 16, '1 1 1', 0, 0, sbar_alpha_fg, DRAWFLAG_NORMAL);
						else
							Sbar_DrawXNum(bottomleft + pos + '6 4.5 0', a, 3, 16, '0.7 0.7 0.7', 0, 0, sbar_alpha_fg * 0.7, DRAWFLAG_NORMAL);
					}
				}
			}
		}

		// fuel ammo
		a = getstati(GetAmmoStat(4)); // how much fuel do we have?

		if (a > 0) { // if we have fuel, draw the amount
			float invincibility_time, dt;
			invincibility_time = getstatf(STAT_INVINCIBLE_FINISHED);
			dt = invincibility_time - time;
			if (dt > 0) { // if the invincibility timer is active, draw fuel ammo elsewhere
				pos_x = bottom_x + 140;
				pos_y = bottom_y - 72;
			}
			else { // if the invincibility timer is inactive, draw the fuel ammo there (it's rare to have invincibility + fuel anyway)
				pos_x = bottom_x + 140;
				pos_y = bottom_y - 22;
			}
			drawpic(pos - '0 2 0' + '52 0 0', GetAmmoPicture(4), '20 20 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);
			if (a > 10)
				Sbar_DrawXNum(pos, a, 3, 16, '1 1 1', 0, 0, 1, DRAWFLAG_NORMAL);
			else
				Sbar_DrawXNum(pos, a, 3, 16, '0.7 0 0', 0, 0, 1, DRAWFLAG_NORMAL);
		}

		// draw scores and timer
		Sbar_Score(16);

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
}

// CTF HUD
void CSQC_ctf_hud(void)
{
	vector bottomleft, redflag_pos, blueflag_pos;
	bottomleft_x = 0;
	bottomleft_y = vid_conheight;
	bottomleft_z = 0;

	float redflag, blueflag;
	float stat_items;

	stat_items = getstati(STAT_ITEMS);
	redflag = (stat_items/IT_RED_FLAG_TAKEN) & 3;
	blueflag = (stat_items/IT_BLUE_FLAG_TAKEN) & 3;

	if (myteam == COLOR_TEAM1) { // always draw own flag on left
		redflag_pos = bottomleft - element_offset - '-4 36 0';
		blueflag_pos = bottomleft - element_offset - '-68 36 0';
	}
	
	else {
		blueflag_pos = bottomleft - element_offset - '-4 36 0';
		redflag_pos = bottomleft - element_offset - '-68 36 0';
	}
	
	switch(redflag)
	{
	case 1: drawpic(redflag_pos, "gfx/hud/sb_flag_red_taken", '48 48 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL); break;
	case 2: drawpic(redflag_pos, "gfx/hud/sb_flag_red_lost", '48 48 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL); break;
	case 3: drawpic(redflag_pos, "gfx/hud/sb_flag_red_carrying", '48 48 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL); break;
	default:
		if(stat_items & IT_CTF_SHIELDED)
			if(myteam == COLOR_TEAM2)
				drawpic(redflag_pos, "gfx/hud/sb_flag_red_shielded", '48 48 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL); break;
	}

	switch(blueflag)
	{
	case 1: drawpic(blueflag_pos, "gfx/hud/sb_flag_blue_taken", '48 48 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL); break;
	case 2: drawpic(blueflag_pos, "gfx/hud/sb_flag_blue_lost", '48 48 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL); break;
	case 3: drawpic(blueflag_pos, "gfx/hud/sb_flag_blue_carrying", '48 48 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL); break;
	default:
		if(stat_items & IT_CTF_SHIELDED)
			if(myteam == COLOR_TEAM1)
				drawpic(blueflag_pos, "gfx/hud/sb_flag_blue_shielded", '48 48 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL); break;
	}
}

// Keyhunt HUD
void CSQC_kh_hud(void)
{
	float kh_keys, kh_keys_status, kh_teams_set;
	vector red_pos, blue_pos, yellow_pos, pink_pos, kh_size;

	vector bottomleft;
	bottomleft_x = 0;
	bottomleft_y = vid_conheight;
	bottomleft_z = 0;

	red_pos_x = 6;
	red_pos_y = vid_conheight - 35 - 6;
	red_pos_z = 0;

	blue_pos_x = 6 + (24 * 1);
	blue_pos_y = vid_conheight - 35 - 6;
	blue_pos_z = 0;

	yellow_pos_x = 6 + (24 * 2);
	yellow_pos_y = vid_conheight - 35 - 6;
	yellow_pos_z = 0;

	pink_pos_x = 6 + (24 * 3);
	pink_pos_y = vid_conheight - 35 - 6;
	pink_pos_z = 0;

	kh_keys = getstati(STAT_KH_KEYS);
	kh_keys_status = kh_keys / 256;
	kh_teams_set = cvar("_teams_available");  // set in keyhunt.qc

	kh_size = '22 35 0';

	if (kh_keys_status & 1)  // red
		drawpic (red_pos, "gfx/hud/sb_kh_red", kh_size, '1 1 1', 0.3, DRAWFLAG_NORMAL);  // show 30% alpha key
	if (kh_keys & 1)
		drawpic (red_pos, "gfx/hud/sb_kh_red", kh_size, '1 1 1', 1.0, DRAWFLAG_NORMAL);  // show solid key 100% alpha

	if (kh_keys_status & 2)  // blue
		drawpic (blue_pos, "gfx/hud/sb_kh_blue", kh_size, '1 1 1', 0.3, DRAWFLAG_NORMAL);
	if (kh_keys & 2)
		drawpic (blue_pos, "gfx/hud/sb_kh_blue", kh_size, '1 1 1', 1.0, DRAWFLAG_NORMAL);

	if (kh_teams_set & 4)  // yellow
	{
		if (kh_keys_status & 4)
			drawpic (yellow_pos, "gfx/hud/sb_kh_yellow", kh_size, '1 1 1', 0.3, DRAWFLAG_NORMAL);
		if (kh_keys & 4)
			drawpic (yellow_pos, "gfx/hud/sb_kh_yellow", kh_size, '1 1 1', 1.0, DRAWFLAG_NORMAL);
	}

	if (kh_teams_set & 8)  // pink
	{
		if (kh_keys_status & 8)
			drawpic (pink_pos, "gfx/hud/sb_kh_pink", kh_size, '1 1 1', 0.3, DRAWFLAG_NORMAL);
		if (kh_keys & 8)
			drawpic (pink_pos, "gfx/hud/sb_kh_pink", kh_size, '1 1 1', 1.0, DRAWFLAG_NORMAL);
	}
}

//Nexball HUD
#define NBPB_SIZE '96 38 0'
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

	pos_x = 4;
	pos_y = vid_conheight - 42;
	pos_z = 0;

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

	pos_x += 12; //horizontal margin to the picture
	pos_y += 2; //vertical margin to the picture

	if (stat_items & IT_KEY1)
		drawpic(pos, "gfx/hud/sb_nexball_carrying", '80 34 0', '1 1 1', 1, DRAWFLAG_NORMAL);
}
