
float last_weapon;
float activeweapon;
float weapontime;

float sb_lines; // still don't know what to do with that NOTE: check dp's sbar.c to see what that should be

vector sbar;
vector sbar_fontsize;
float sbar_alpha_fg;
float sbar_hudselector;
/*
entity sortedPlayers;
entity sortedTeams;

.float sb_frags;
.float sb_team;
.float sb_player;
.float sb_caps;
*/
float ps_primary, ps_secondary;
float ts_primary, ts_secondary;

entity team1, team2, team3, team4, teamspec;

void CSQC_kh_hud();
void CSQC_ctf_hud();
void MapVote_Draw();
void Sbar_FinaleOverlay()
{
	/*vector pos;
	pos_x = (vid_conwidth - 1)/2;
	pos_y = 16;
	pos_z = 0;*/
	
	//drawpic(pos, "gfx/finale", '0 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);
	
	//drawstring(pos, "END", sbar_fontsize, '1 1 1', 1, DRAWFLAG_NORMAL);
	MapVote_Draw();
}

void Sbar_DrawWeapon(float nr, float fade, float active)
{
	vector pos, vsize, color;
	float value;
	
	value = (active) ? 1 : 0.6;
	color_x = color_y = color_z = value;
	
	if(sbar_hudselector == 1)
	{
		// width = 300, height = 100
		const float w_width = 32, w_height = 12, w_space = 2, font_size = 8;
		
		pos_x = (vid_conwidth - w_width * 9) * 0.5 + w_width * nr;
		pos_y = (vid_conheight - w_height);
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
		drawstring(pos, ftos(nr+1), vsize, '1 1 0', sbar_alpha_fg, 0);

	}
	else
	{
		// width = 300, height = 100
		const float w2_width = 300, w2_height = 100, w2_space = 10;
		const float w2_scale = 0.4;

		pos_x = vid_conwidth - (w2_width + w2_space) * w2_scale;
		pos_y = (w2_height + w2_space) * w2_scale * nr + w2_space;
		pos_z = 0;
		vsize_x = w2_width * w2_scale;
		vsize_y = w2_height * w2_scale;
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
	float i, f, primary_prio, secondary_prio;

	primary_prio = secondary_prio = -1;
	for(i = 0; i < MAX_SCORE; ++i)
	{
		f = (scores_flags[i] & SFL_SORT_PRIO_MASK);
		if(f > primary_prio) {
			ps_secondary = ps_primary;
			ps_primary = i;
		} else if(f > secondary_prio)
			ps_secondary = i;
	}
	
	primary_prio = secondary_prio = -1;
	for(i = 0; i < MAX_TEAMSCORE; ++i)
	{
		f = (teamscores_flags[i] & SFL_SORT_PRIO_MASK);
		if(f > primary_prio) {
			ts_secondary = ts_primary;
			ts_primary = i;
		} else if(f > secondary_prio)
			ts_secondary = i;
	}

	Cmd_Sbar_SetFields(0);
}

void Sbar_UpdatePlayerPos(entity pl);
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
		if(pl.team != Team)
		{
			tmp = GetTeam(pl.team, false);
			tmp.team_size -= 1;
			tmp = GetTeam(Team, true);
			tmp.team_size += 1;
			
			pl.team = Team;

			tmp = pl.sort_prev;
			Sbar_UpdatePlayerPos(pl);
			if(tmp)
				pl = tmp;
			else
				pl = players.sort_next;
		}
	}
	//print(strcat("PNUM: ", ftos(num), "\n"));
}

float Sbar_ComparePlayerScores(entity left, entity right)
{
	float vl, vr;
	vl = GetPlayerColor(left.sv_entnum);
	vr = GetPlayerColor(right.sv_entnum);
	
	if(vl > vr)
		return true;
	if(vl < vr)
		return false;

	vl = left.scores[ps_primary];
	vr = right.scores[ps_primary];
	if(vl > vr)
		return IS_INCREASING(scores_flags[ps_primary]);
	if(vl < vr)
		return IS_DECREASING(scores_flags[ps_primary]);
	
	vl = left.scores[ps_secondary];
	vr = right.scores[ps_secondary];
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
	for(other = Team.sort_next; other && Sbar_ComparePlayerScores(Team, other); other = Team.sort_next)
	{
		if(other.team == COLOR_SPECTATOR)
			break;
		SORT_SWAP(Team, other);
	}
	for(other = Team.sort_prev; other != teams && Sbar_ComparePlayerScores(other, Team); other = Team.sort_prev)
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

/*
	print("^3caps^7 or ^3captures^7         Number of flags captured\n");
	print("^3rets^7 or ^3returns^7          Number of flags returned\n");
	print("^3frags^7 or ^3kills^7           Frags\n");
	print("^3deaths^7 or ^3dths^7           Number of deaths\n");
	*/
	local float i;
	print("Additional columns:\n");
	for(i = 0; i < MAX_SCORE; ++i)
	{
		if(scores_label[i])
			print(strcat(scores_label[i], "\n"));
	}
}

#define MIN_NAMELEN 24
#define MAX_NAMELEN 24

string Sbar_DefaultColumnLayout()
{
	return "ping name | +kh,ctf/caps -ctf,kh/kills -ctf,kh/deaths score";
	/*
	switch(gametype)
	{
		case GAME_CTF: return "ping name | caps score";
		case GAME_KEYHUNT: return "ping name | caps kills score";
		default: return "ping name | score";
			// TODO: add other gametypes
	}
	*/
}

void Cmd_Sbar_SetFields(float argc)
{
	float i, j, slash;
	string str, pattern, subpattern;
	float digit;

	// TODO: re enable with gametype dependant cvars?
	if(argc < 2) // no arguments provided
		argc = tokenizebyseparator(strcat("x ", cvar_string("sbar_columns")), " ");

	if(argc < 2 || (argc == 2 && argv(1) == "default"))
		argc = tokenizebyseparator(strcat("x ", Sbar_DefaultColumnLayout()), " ");
	
	argc = min(MAX_SBAR_FIELDS, argc);
	sbar_num_fields = 0;

	drawfont = sbar_font;
	digit = stringwidth("0123456789", FALSE) / 10;

	subpattern = strcat(",", GametypeNameFromType(gametype), ",");

	argc = min(argc-1, MAX_SBAR_FIELDS-1);
	for(i = 0; i < argc; ++i)
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
			}
			else
			{
				if(substring(pattern, 0, 1) == "+")
					pattern = substring(pattern, 1, strlen(pattern) - 1);
				if(strstrofs(strcat(",", pattern, ","), subpattern, 0) < 0)
					continue;
			}
		}

		strunzone(sbar_title[sbar_num_fields]);
		sbar_title[sbar_num_fields] = strzone(str);
		sbar_size[sbar_num_fields] = stringwidth(str, FALSE);
		str = strtolower(str);

		if(str == "ping") {
			sbar_field[sbar_num_fields] = SP_PING;
		} else if(str == "name" || str == "nick") {
			sbar_field[sbar_num_fields] = SP_NAME;
			sbar_size[sbar_num_fields] = MIN_NAMELEN; // minimum size? any use?
		} else if(str == "|") {
			sbar_field[sbar_num_fields] = SP_SEPARATOR;
		} else {
			for(j = 0; j < MAX_SCORE; ++j)
			{
				if(str == strtolower(scores_label[j]))
					break;
			}
			if(j == MAX_SCORE) {
				print(strcat("^1Error:^7 Unknown score field: '", str, "'\n"));
				continue;
			} else {
				//print("field ", ftos(sbar_num_fields), " is column ", ftos(j), " (", str, ")\n");
				sbar_field[sbar_num_fields] = j;
			}
		}
		++sbar_num_fields;
	}
	sbar_field[sbar_num_fields] = SP_END;
}

// MOVEUP::
vector sbar_field_rgb;
string Sbar_GetField(entity pl, float field)
{
	float tmp, num, denom;
	string str;
	sbar_field_rgb = '1 1 1';
	switch(field)
	{
		case SP_PING:
			str = bufstr_get(databuf, DATABUF_PING + pl.sv_entnum);
			tmp = max(0, min(220, stof(str)-80)) / 220;
			sbar_field_rgb = '1 1 1' - '0 1 1'*tmp;
			return str;
		
		case SP_NAME:
			return getplayerkey(pl.sv_entnum, "name");

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
			return ftos(pl.(scores[field]));
	}
	return "error";
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

float xmin, xmax, ymin, ymax, sbwidth, sbheight;

void Sbar_PrintScoreboardItem(vector pos, entity pl, float is_self)
{
	vector tmp;
	string str;
	float i, field, len;
	float is_spec;
	is_spec = (GetPlayerColor(pl.sv_entnum) == COLOR_SPECTATOR);

	// Layout:
	tmp_z = 0;
	if(is_self)
	{
		tmp_x = sbwidth;
		tmp_y = sbar_fontsize_y;
		drawfill(pos - '1 1', tmp + '2 2', '1 1 1', 0.3, DRAWFLAG_NORMAL);
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

		if(field == SP_NAME)
		{
			float realsize;
			float j;
			realsize = sbar_size[i];
			if(i+1 < sbar_num_fields)
				if(sbar_field[i+1] == SP_SEPARATOR)
				{
					realsize = (xmax - xmin) / sbar_fontsize_x;
					for(j = 0; j < sbar_num_fields; ++j) if(j != i) if(sbar_field[j] != SP_SEPARATOR)
						realsize -= sbar_size[j] + 1;
					realsize += 1;
				}
			str = textShortenToWidth(str, realsize, TRUE);
		}
		len = stringwidth(str, TRUE);
		
		if(sbar_size[i] < len)
			sbar_size[i] = len;

		pos_x += sbar_fontsize_x*sbar_size[i] + sbar_fontsize_x;

		if(field == SP_NAME) {
			tmp_x = sbar_fontsize_x*sbar_size[i] + sbar_fontsize_x;
			drawcolorcodedstring(pos - tmp, str, sbar_fontsize, 1, DRAWFLAG_NORMAL);
		} else {
			tmp_x = len*sbar_fontsize_x + sbar_fontsize_x;
			drawstring(pos - tmp, str, sbar_fontsize, sbar_field_rgb, 1, DRAWFLAG_NORMAL);
		}
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

			if(field == SP_NAME)
				str = textShortenToWidth(str, sbar_size[i], TRUE);
			len = stringwidth(str, TRUE);

			if(sbar_size[i] < len)
				sbar_size[i] = len;

			if(field == SP_NAME) {
				tmp_x = sbar_fontsize_x*len; // left or right aligned? let's put it right...
				drawcolorcodedstring(pos - tmp, str, sbar_fontsize, 1, DRAWFLAG_NORMAL);
			} else {
				tmp_x = sbar_fontsize_x*len; //strlen(str);
				drawstring(pos - tmp, str, sbar_fontsize, sbar_field_rgb, 1, DRAWFLAG_NORMAL);
			}
			pos_x -= sbar_fontsize_x*sbar_size[i] + sbar_fontsize_x;
		}
	}
}

void Sbar_DrawScoreboard()
{
	//float xmin, ymin, xmax, ymax;
	vector rgb, pos, tmp, sbar_save;
	entity pl, tm;
	float specs, i;
	float center_x;

	sbar_fontsize = Sbar_GetFontsize();
	if(sbar_fontsize_x == 0)
		sbar_fontsize = '8 8 0';
	if(sbar_fontsize_y == 0)
		sbar_fontsize_y = sbar_fontsize_x;
	
	xmin = vid_conwidth / 5;
	ymin = 20;

	xmax = vid_conwidth - xmin;
	ymax = vid_conheight - 0.2*vid_conheight;

	sbwidth = xmax - xmin;
	sbheight = ymax - ymin;

	center_x = xmin + 0.5*sbwidth;

	//Sbar_UpdateFields();

	// Initializes position
	//pos_x = xmin;
	pos_y = ymin;
	pos_z = 0;

	// Heading
	drawfont = sbar_font;
	pos_x = center_x - stringwidth("Scoreboard", TRUE)*0.5*24;
	drawstring(pos, "Scoreboard", '24 24', '1 1 1', 1, DRAWFLAG_NORMAL);
	pos_x = xmin;
	pos_y += 24 + 4;

	// Titlebar background:
	tmp_x = sbwidth;
	tmp_y = sbar_fontsize_y;
	drawfill(pos - '1 1', tmp + '2 2', '0.5 0.5 0.5', 0.5, DRAWFLAG_NORMAL);
	
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
			 * Using the following line will fuck it all up:
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

			pos_x = xmin - 4*24;
			// TODO: Print primary and secondary scores!
			
			pos_x = xmin;

			specs = tm.team_size;

			if(specs < 2)
				specs = 2;
			
			tmp_x = sbwidth;
			tmp_y = 1.25 * sbar_fontsize_y * specs;
			drawfill(pos - '1 1', tmp + '2 0', rgb, 0.2, DRAWFLAG_NORMAL);
			
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
			//drawcolorcodedstring(pos, getplayerkey(pl.sb_player, "name"), '8 8 0', 1, 0);
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
	sbar = sbar_save;
}

void Sbar_Score(float margin)
{
	float timelimit, timeleft, minutes, seconds, distribution, myplace, score;
	vector sbar_save, place;
	entity tm, pl, me;
	sbar_save = sbar;

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
				Sbar_DrawXNum('-128 0', score, 4, 32, GetTeamRGB(tm.team), 1, DRAWFLAG_NORMAL);
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
			Sbar_DrawXNum('-36 -12', myplace, 3, 12, '1 1 1', 1, DRAWFLAG_NORMAL);
		else if(myplace == 2)
			Sbar_DrawXNum('-36 -12', myplace, 3, 12, '1 1 0', 1, DRAWFLAG_NORMAL);
		else
			Sbar_DrawXNum('-36 -12', myplace, 3, 12, '1 0 0', 1, DRAWFLAG_NORMAL);

		score = me.(scores[ps_primary]);
		if(distribution >= 0)
		{
			Sbar_DrawXNum('-84 -12', distribution, 4, 12, ' 1 1 1', 1, DRAWFLAG_NORMAL);
			Sbar_DrawXNum('-128 0', score, 4, 32, '1 1 1', 1, DRAWFLAG_NORMAL);
		} else if(distribution >= -5)
		{
			Sbar_DrawXNum('-84 -12', distribution, 4, 12, ' 1 1 0', 1, DRAWFLAG_NORMAL);
			Sbar_DrawXNum('-128 0', score, 4, 32, '1 1 0', 1, DRAWFLAG_NORMAL);
		} else {
			Sbar_DrawXNum('-84 -12', distribution, 4, 12, ' 1 0 0', 1, DRAWFLAG_NORMAL);
			Sbar_DrawXNum('-128 0', score, 4, 32, '1 0 0', 1, DRAWFLAG_NORMAL);
		}
	}
	timelimit = getstatf(STAT_TIMELIMIT);
	if(timelimit)
	{
		timeleft = max(0, timelimit * 60 - time);
		minutes = floor(timeleft / 60);
		seconds = floor(timeleft - minutes*60);
		if(minutes >= 5)
		{
			Sbar_DrawXNum('-72 32', minutes, 3, 12, '1 1 1', 1, DRAWFLAG_NORMAL);
			drawpic(sbar + '-36 32', "gfx/num_colon", '12 12', '1 1 1', sbar_alpha_fg, 0);
			Sbar_DrawXNum('-24 32', seconds, -2, 12, '1 1 1', 1, DRAWFLAG_NORMAL);
		} else if(minutes >= 1)
		{
			Sbar_DrawXNum('-72 32', minutes, 3, 12, '1 1 0', 1, DRAWFLAG_NORMAL);
			drawpic(sbar + '-36 32', "gfx/num_colon", '12 12', '1 1 0', sbar_alpha_fg, 0);
			Sbar_DrawXNum('-24 32', seconds, -2, 12, '1 1 0', 1, DRAWFLAG_NORMAL);
		} else {
			Sbar_DrawXNum('-24 32', seconds, -2, 12, '1 0 0', 1, DRAWFLAG_NORMAL);
		}
	} else {
		minutes = floor(time / 60);
		seconds = floor(time - minutes*60);
		Sbar_DrawXNum('-72 32', minutes, 3, 12, '1 1 1', 1, DRAWFLAG_NORMAL);
		drawpic(sbar + '-36 32', "gfx/num_colon", '12 12', '1 1 1', sbar_alpha_fg, 0);
		Sbar_DrawXNum('-24 32', seconds, -2, 12, '1 1 1', 1, DRAWFLAG_NORMAL);
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
	drawcolorcodedstring(pos, getplayerkey(pl.sv_entnum, "name"), '8 8 0', 1, 0);
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

void Sbar_Draw (void)
{
	float i;
	float x, fade;
	float stat_items;

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
		if (sb_showscores || (getstati(STAT_HEALTH) <= 0 && cvar("cl_deathscoreboard")))
		{
			sbar_x = (vid_conwidth - 640.0)*0.5;
			sbar_y = vid_conheight - 47;
			//Sbar_DrawAlphaPic (sbar_x, sbar_y, sb_scorebar, sbar_alpha_bg.value);
			//drawpic('0 0', "gfx/scorebar", '0 0 0', '1 1 1', cvar("sbar_alpha_bg"), 0);
			Sbar_DrawScoreboard ();
		}
		else
		{
			if (sb_lines && sbar_hudselector == 1)
			{
				stat_items = getstati(STAT_ITEMS);

				sbar_x = (vid_conwidth - 320.0)*0.5;
				sbar_y = vid_conheight - 24.0 - 16.0;
				sbar_z = 0;
			
				fade = 3.2 - 2 * (time - weapontime);
				fade = bound(0.7, fade, 1);

				x = 1.0;
				for(i = 0; i < 8; ++i)
				{
					if(stat_items & x)
					{
						Sbar_DrawWeapon(i+1, fade, (i + 2 == activeweapon));
					}
					x *= 2;
				}
				x *= 2*2*2*2;
				if(stat_items & x)
				{
					Sbar_DrawWeapon(0, fade, (activeweapon == 1));
				}

				// armor
				x = getstati(STAT_ARMOR);
				if (x > 0)
				{
					// "gfx/sb_armor"
					//Sbar_DrawStretchPic (72, 0, sb_armor[0], sbar_alpha_fg.value, 24, 24);
					drawpic(sbar + '72 0', "gfx/sb_armor", '24 24 0', '1 1 1', sbar_alpha_fg, 0);
					if(x > 200)
						Sbar_DrawXNum('0 0', x, 3, 24, '0 1 0', 1, 0);
					else if(x > 100)
						Sbar_DrawXNum('0 0', x, 3, 24, '0.2 1 0', 1, 0);
					else if(x > 50)
						Sbar_DrawXNum('0 0', x, 3, 24, '0.6 0.7 0.8', 1, 0);
					else if(x > 25)
						Sbar_DrawXNum('0 0', x, 3, 24, '1 1 0.2', 1, 0);
					else
						Sbar_DrawXNum('0 0', x, 3, 24, '0.7 0 0', 1, 0);
				}

				// health
				x = getstati(STAT_HEALTH);
				if (x != 0)
				{
					// "gfx/sb_health"
					//Sbar_DrawStretchPic (184, 0, sb_health, sbar_alpha_fg.value, 24, 24);
					drawpic(sbar + '184 0', "gfx/sb_health", '24 24 0', '1 1 1', sbar_alpha_fg, 0);
					if(x > 200)
						Sbar_DrawXNum('112 0', x, 3, 24, '0 1 0', 1, 0);
					else if(x > 100)
						Sbar_DrawXNum('112 0', x, 3, 24, '0.2 1 0', 1, 0);
					else if(x > 50)
						Sbar_DrawXNum('112 0', x, 3, 24, '0.6 0.7 0.8', 1, 0);
					else if(x > 25)
						Sbar_DrawXNum('112 0', x, 3, 24, '1 1 0.2', 1, 0);
					else
						Sbar_DrawXNum('112 0', x, 3, 24, '0.7 0 0', 1, 0);
				}

				// ammo
				x = getstati(STAT_AMMO);
				if ((stat_items & (NEX_IT_SHELLS | NEX_IT_BULLETS | NEX_IT_ROCKETS | NEX_IT_CELLS)) || x != 0)
				{
					if (stat_items & NEX_IT_SHELLS)
						drawpic(sbar + '296 0', "gfx/sb_shells", '24 24 0', '1 1 1', sbar_alpha_fg, 0);
					else if (stat_items & NEX_IT_BULLETS)
						drawpic(sbar + '296 0', "gfx/sb_bullets", '24 24 0', '1 1 1', sbar_alpha_fg, 0);
					else if (stat_items & NEX_IT_ROCKETS)
						drawpic(sbar + '296 0', "gfx/sb_rocket", '24 24 0', '1 1 1', sbar_alpha_fg, 0);
					else if (stat_items & NEX_IT_CELLS)
						drawpic(sbar + '296 0', "gfx/sb_cells", '24 24 0', '1 1 1', sbar_alpha_fg, 0);
					if(x > 10)
						Sbar_DrawXNum('224 0', x, 3, 24, '0.6 0.7 0.8', 1, 0);
					else
						Sbar_DrawXNum('224 0', x, 3, 24, '0.7 0 0', 1, 0);
				}

				if (sbar_x + 320 + 160 <= vid_conwidth)
					Sbar_MiniDeathmatchOverlay(sbar + '320 0');
				if (sbar_x > 0)
					Sbar_Score(16);
				// The margin can be at most 8 to support 640x480 console size:
				//   320 + 2 * (144 + 16) = 640
			}
			else if (sb_lines)
			{
			
				stat_items = getstati(STAT_ITEMS);
			
				sbar_x = (vid_conwidth - 640.0)*0.5;
				sbar_y = vid_conheight - 47;
				sbar_z = 0;

				fade = 3 - 2 * (time - weapontime);

				x = 1.0;
				for(i = 0; i < 8; ++i)
				{
					if(stat_items & x)
					{
						Sbar_DrawWeapon(i+1, fade, (i + 2 == activeweapon));
					}
					x *= 2;
				}
				x *= 2*2*2*2;
				if(stat_items & x)
				{
					Sbar_DrawWeapon(0, fade, (activeweapon == 1));
				}

				if (sb_lines > 24)
					drawpic(sbar, "gfx/sbar", '0 0 0', '1 1 1', sbar_alpha_fg, 0);
				else
					drawpic(sbar, "gfx/sbar_minimal", '0 0 0', '1 1 1', sbar_alpha_fg, 0);

				// armor
				// (340-3*24) = 268
				Sbar_DrawXNum('268 12', getstati(STAT_ARMOR), 3, 24, '0.6 0.7 0.8', 1, 0);

				// health
				// (154-3*24) = 82
				x = getstati(STAT_HEALTH);
				if(x > 100)
					Sbar_DrawXNum('82 12', x, 3, 24, '1 1 1', 1, 0);
				else if(x <= 25 && time - floor(time) > 0.5)
					Sbar_DrawXNum('82 12', x, 3, 24, '0.7 0 0', 1, 0);
				else
					Sbar_DrawXNum('81 12', x, 3, 24, '0.6 0.7 0.8', 1, 0);

				// AK dont draw ammo for the laser
				x = getstati(STAT_AMMO);
				if(activeweapon != 12)
				{
					// (519-3*24) = 447
					if (stat_items & NEX_IT_SHELLS)
						drawpic(sbar + '519 0', "gfx/sb_shells", '0 0 0', '1 1 1', sbar_alpha_fg, 0);
					else if (stat_items & NEX_IT_BULLETS)
						drawpic(sbar + '519 0', "gfx/sb_bullets", '0 0 0', '1 1 1', sbar_alpha_fg, 0);
					else if (stat_items & NEX_IT_ROCKETS)
						drawpic(sbar + '519 0', "gfx/sb_rocket", '0 0 0', '1 1 1', sbar_alpha_fg, 0);
					else if (stat_items & NEX_IT_CELLS)
						drawpic(sbar + '519 0', "gfx/sb_cells", '0 0 0', '1 1 1', sbar_alpha_fg, 0);
					if(x > 10)
						Sbar_DrawXNum('447 12', x, 3, 24, '0.6 0.7 0.8', 1, 0);
					else
						Sbar_DrawXNum('447 12', x, 3, 24, '0.7 0 0', 1, 0);
				}

				if (sb_lines > 24)
					drawpic(sbar, "gfx/sbar_overlay", '0 0 0', '1 1 1', 1, DRAWFLAG_MODULATE);

				if (sbar_x + 600 + 160 <= vid_conwidth)
					Sbar_MiniDeathmatchOverlay (sbar + '600 0');

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
	redflag = (stat_items/32768) & 3;
	blueflag = (stat_items/131072) & 3;

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
	case 1: drawpic(pos, "gfx/sb_flag_red_taken", '0 0 0', '1 1 1', 1, DRAWFLAG_NORMAL); break;
	case 2: drawpic(pos, "gfx/sb_flag_red_lost", '0 0 0', '1 1 1', 1, DRAWFLAG_NORMAL); break;
	case 3: drawpic(pos, "gfx/sb_flag_red_carrying", '0 0 0', '1 1 1', 1, DRAWFLAG_NORMAL); break;
	}

	pos_y -= 64;
	
	switch(blueflag)
	{
	case 1: drawpic(pos, "gfx/sb_flag_blue_taken", '0 0 0', '1 1 1', 1, 0); break;
	case 2: drawpic(pos, "gfx/sb_flag_blue_lost", '0 0 0', '1 1 1', 1, 0); break;
	case 3: drawpic(pos, "gfx/sb_flag_blue_carrying", '0 0 0', '1 1 1', 1, 0); break;
	}
}
