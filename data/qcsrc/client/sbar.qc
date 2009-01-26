
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
		"+noteams/kills +noteams/deaths +noteams/suicides -noteams,tdm/frags ", // tdm already has this in "score"
		"+kh/caps +kh/pushes +kh/destroyed ",
		"+ctf/caps +ctf/pickups +ctf/fckills +ctf/returns ",
		"-lms/score");
}

void Cmd_Sbar_SetFields(float argc)
{
	float i, j, slash;
	string str, pattern, subpattern, subpattern2;
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

	subpattern = strcat(",", GametypeNameFromType(gametype), ",");
	if(teamplay)
		subpattern2 = ",teams,";
	else
		subpattern2 = ",noteams,";

	for(i = 0; i < argc - 1; ++i)
	{
		str = argv(i+1);

		slash = strstrofs(str, "/", 0);
		if(slash >= 0)
		{
			pattern = substring(str, 0, slash);
			str = substring(str, slash + 1, strlen(str) - (slash + 1));

			if(substring(pattern, 0, 1) == "-")
			{
				pattern = substring(pattern, 1, strlen(pattern) - 1);
				if(strstrofs(strcat(",", pattern, ","), subpattern, 0) >= 0)
					continue;
				if(strstrofs(strcat(",", pattern, ","), subpattern2, 0) >= 0)
					continue;
			}
			else
			{
				if(substring(pattern, 0, 1) == "+")
					pattern = substring(pattern, 1, strlen(pattern) - 1);
				if(strstrofs(strcat(",", pattern, ","), subpattern, 0) < 0)
				if(strstrofs(strcat(",", pattern, ","), subpattern2, 0) < 0)
					continue;
			}
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
			if(!teamplay)
			{
				f = stof(getplayerkey(pl.sv_entnum, "colors"));
				sbar_field_icon0 = "gfx/sb_playercolor_base";
				sbar_field_icon1 = "gfx/sb_playercolor_shirt";
				sbar_field_icon1_rgb = colormapPaletteColor(floor(f / 16), 0);
				sbar_field_icon2 = "gfx/sb_playercolor_pants";
				sbar_field_icon2_rgb = colormapPaletteColor(mod(f, 16), 1);
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

// shamelessly stolen from menu QC :P <- as if I would steal YOUR code pfft ;)
float textLengthUpToWidth(string theText, float maxWidth, float handleColors)
{
	// STOP.
	// The following function is SLOW.
	// For your safety and for the protection of those around you...
	// DO NOT CALL THIS AT HOME.
	// No really, don't.
	if(stringwidth(theText, handleColors) <= maxWidth)
		return strlen(theText); // yeah!

	// binary search for right place to cut string
	float left, right, middle; // this always works
	left = 0;
	right = strlen(theText); // this always fails
	do
	{
		middle = floor((left + right) / 2);
		if(stringwidth(substring(theText, 0, middle), handleColors) <= maxWidth)
			left = middle;
		else
			right = middle;
	}
	while(left < right - 1);

	// NOTE: when color codes are involved, this binary search is,
	// mathematically, BROKEN. However, it is obviously guaranteed to
	// terminate, as the range still halves each time - but nevertheless, it is
	// guaranteed that it finds ONE valid cutoff place (where "left" is in
	// range, and "right" is outside).

	return left;
}
string textShortenToWidth(string theText, float maxWidth, float handleColors)
{
	if(stringwidth(theText, handleColors) <= maxWidth)
		return theText;
	else
		return strcat(substring(theText, 0, textLengthUpToWidth(theText, maxWidth - stringwidth("...", handleColors), handleColors)), "...");
}

float xmin, xmax, ymin, ymax, sbwidth;
float sbar_fixscoreboardcolumnwidth_len;
float sbar_fixscoreboardcolumnwidth_iconlen;
float sbar_fixscoreboardcolumnwidth_marginlen;

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
		str = textShortenToWidth(str, maxsize, TRUE);
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
	ymin = 20;

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
	

	pos_y += 1.5 * sbar_fontsize_y;
	drawcolorcodedstring(pos + '0.5 0 0' * (sbwidth - sbar_fontsize_x * stringwidth(str, TRUE)), str, sbar_fontsize, 0.8, 0);
	
	sbar = sbar_save;
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

void dummyfunction(float a1, float a2, float a3, float a4, float a5, float a6, float a7, float a8)
{
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
		pl = players;
		if(pl == me)
			pl = pl.sort_next;
		
		if(pl) {
			distribution = me.(scores[ps_primary]) - pl.(scores[ps_primary]);
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
				float sz;
				a = bound(0, 1 - 2 * (time - race_checkpointtime), 1);
				sz = 1.2 / (a + 0.2);
				drawstring(m - '0 0 0' - '0 16 0' * (sz - 1) - '16 0 0' * sz * stringwidth(forcetime, FALSE), forcetime, '32 32 0' * sz, '1 1 1', sbar_alpha_fg * a, 0);
				a = 1 - a;
			}
			else
				a = 1;

			if(race_laptime)
			{
				s = mmsss(10*(time - race_laptime));
				drawstring(m - '0 0 0' - '16 0 0' * stringwidth(s, FALSE), s, '32 32 0', '1 1 1', sbar_alpha_fg * a, 0);
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

void Sbar_Draw (void)
{
	float i;
	float x, fade;
	float stat_items, stat_weapons;
	vector o; o = '1 0 0' * vid_conwidth;
	string s;

	sbar_fontsize = Sbar_GetFontsize();
	
	if(spectatee_status)
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
	}
	if(warmup_stage)
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

	if(ready_waiting)
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
	else if(warmup_stage) 
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
	if(teamplay)
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
		Sbar_DrawScoreboard();
	else if (intermission == 1)
	{
		Sbar_DrawScoreboard();
		return;
	}
	else if (intermission == 2)
		Sbar_FinaleOverlay();
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
				x = getstati(STAT_AMMO);
				if ((stat_items & IT_AMMO) || x != 0)
				{
					if (stat_items & IT_SHELLS)
						drawpic(sbar + '296 0 0', "gfx/sb_shells", '24 24 0', '1 1 1', sbar_alpha_fg, 0);
					else if (stat_items & IT_NAILS)
						drawpic(sbar + '296 0 0', "gfx/sb_bullets", '24 24 0', '1 1 1', sbar_alpha_fg, 0);
					else if (stat_items & IT_ROCKETS)
						drawpic(sbar + '296 0 0', "gfx/sb_rocket", '24 24 0', '1 1 1', sbar_alpha_fg, 0);
					else if (stat_items & IT_CELLS)
						drawpic(sbar + '296 0 0', "gfx/sb_cells", '24 24 0', '1 1 1', sbar_alpha_fg, 0);
					if(x > 10)
						Sbar_DrawXNum('224 0 0', x, 3, 24, '0.6 0.7 0.8', 1, 0);
					else
						Sbar_DrawXNum('224 0 0', x, 3, 24, '0.7 0 0', 1, 0);
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

				x = getstati(STAT_AMMO);
				if ((stat_items & IT_AMMO) || x != 0)
				{
					// (519-3*24) = 447
					if (stat_items & IT_SHELLS)
						drawpic(sbar + '519 0 0', "gfx/sb_shells", '0 0 0', '1 1 1', sbar_alpha_fg, 0);
					else if (stat_items & IT_NAILS)
						drawpic(sbar + '519 0 0', "gfx/sb_bullets", '0 0 0', '1 1 1', sbar_alpha_fg, 0);
					else if (stat_items & IT_ROCKETS)
						drawpic(sbar + '519 0 0', "gfx/sb_rocket", '0 0 0', '1 1 1', sbar_alpha_fg, 0);
					else if (stat_items & IT_CELLS)
						drawpic(sbar + '519 0 0', "gfx/sb_cells", '0 0 0', '1 1 1', sbar_alpha_fg, 0);
					if(x > 10)
						Sbar_DrawXNum('447 12 0', x, 3, 24, '0.6 0.7 0.8', 1, 0);
					else
						Sbar_DrawXNum('447 12 0', x, 3, 24, '0.7 0 0', 1, 0);
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
		

			if(gametype == GAME_KEYHUNT)
			{
				CSQC_kh_hud();
			} else if(gametype == GAME_CTF)
			{
				CSQC_ctf_hud();
			}
		}
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
	case 1: drawpic(pos, "gfx/sb_flag_red_taken", '128 64 0', '1 1 1', 1, DRAWFLAG_NORMAL); break;
	case 2: drawpic(pos, "gfx/sb_flag_red_lost", '128 64 0', '1 1 1', 1, DRAWFLAG_NORMAL); break;
	case 3: drawpic(pos, "gfx/sb_flag_red_carrying", '128 64 0', '1 1 1', 1, DRAWFLAG_NORMAL); break;
	default:
		if(stat_items & IT_CTF_SHIELDED)
			if(myteam == COLOR_TEAM2)
				drawpic(pos, "gfx/sb_flag_red_shielded", '128 64 0', '1 1 1', 1, DRAWFLAG_NORMAL); break;
	}

	pos_y -= 64;
	
	switch(blueflag)
	{
	case 1: drawpic(pos, "gfx/sb_flag_blue_taken", '128 64 0', '1 1 1', 1, 0); break;
	case 2: drawpic(pos, "gfx/sb_flag_blue_lost", '128 64 0', '1 1 1', 1, 0); break;
	case 3: drawpic(pos, "gfx/sb_flag_blue_carrying", '128 64 0', '1 1 1', 1, 0); break;
	default:
		if(stat_items & IT_CTF_SHIELDED)
			if(myteam == COLOR_TEAM1)
				drawpic(pos, "gfx/sb_flag_blue_shielded", '128 64 0', '1 1 1', 1, DRAWFLAG_NORMAL); break;
	}
}
