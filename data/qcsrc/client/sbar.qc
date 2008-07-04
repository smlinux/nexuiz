
float sb_lines; // still don't know what to do with that NOTE: check dp's sbar.c to see what that should be

vector sbar;

entity sortedPlayers;
entity sortedTeams;

.float sb_frags;
.float sb_team;
.float sb_player;

void Sbar_FinaleOverlay()
{
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

float Sbar_PlayerCmp(entity l, entity r)
{
	if(teamplay)
	{
		if(l.sb_team < r.sb_team)
			return true;
		else if(l.sb_team > r.sb_team)
			return false;
	}
	if(l.sb_frags > r.sb_frags)
		return true;
	else if(l.sb_frags < r.sb_frags)
		return false;
	return (l.sb_player > r.sb_player);
}
float Sbar_TeamCmp(entity l, entity r)
{
	if(l.sb_frags > r.sb_frags)
		return true;
	else if(l.sb_frags < r.sb_frags)
		return false;
	return (l.sb_player > r.sb_player);
}

void Sbar_SortFrags()
{
	float i;
	entity tmp;
	entity t1, t2, t3, t4, ts;
	
	Sort_Remove(sortedPlayers);
	sortedPlayers = Sort_New(Sbar_PlayerCmp);

	numteams = 0;
	if(teamplay)
	{
		Sort_Remove(sortedTeams);
	
		t1 = spawn();
		t2 = spawn();
		t3 = spawn();
		t4 = spawn();
		ts = spawn();
	
		t1.sb_team = COLOR_TEAM1;
		t2.sb_team = COLOR_TEAM2;
		t3.sb_team = COLOR_TEAM3;
		t4.sb_team = COLOR_TEAM4;
		ts.sb_team = COLOR_SPECTATOR;

		t1.sb_player = t2.sb_player = t3.sb_player = t4.sb_player = ts.sb_player = 0;
		t1.sb_frags = t2.sb_frags = t3.sb_frags = t4.sb_frags = 0;
		sortedTeams = Sort_New(Sbar_TeamCmp);
		
		for(i = 0; i < maxclients; ++i)
		{
			if(strlen(getplayerkey(i, "name")) <= 0)
				continue;
		
			tmp = spawn();
			tmp.sb_player = i;
			tmp.sb_frags = stof(getplayerkey(i, "frags"));
			if(tmp.sb_frags == -666)
				tmp.sb_team = COLOR_SPECTATOR;
			else
				tmp.sb_team = GetPlayerColor(i);

			switch(tmp.sb_team)
			{
			case COLOR_TEAM1: t1.sb_frags += tmp.sb_frags; t1.sb_player++; break;
			case COLOR_TEAM2: t2.sb_frags += tmp.sb_frags; t2.sb_player++; break;
			case COLOR_TEAM3: t3.sb_frags += tmp.sb_frags; t3.sb_player++; break;
			case COLOR_TEAM4: t4.sb_frags += tmp.sb_frags; t4.sb_player++; break;
			case COLOR_SPECTATOR: ts.sb_frags += tmp.sb_frags; ts.sb_player++; break;
			}

			if(i == player_localentnum-1)
				myteam = tmp.sb_team;

			Sort_Add(sortedPlayers, tmp);
		}
		if(t1.sb_player) ++numteams;
		if(t2.sb_player) ++numteams;
		if(t3.sb_player) ++numteams;
		if(t4.sb_player) ++numteams;

		Sort_Add(sortedTeams, t1);
		Sort_Add(sortedTeams, t2);
		Sort_Add(sortedTeams, t3);
		Sort_Add(sortedTeams, t4);
		Sort_Add(sortedTeams, ts);

	} else {
		for(i = 0; i < maxclients; ++i)
		{
			if(strlen(getplayerkey(i, "name")) <= 0)
				continue;
		
			tmp = spawn();
			tmp.sb_player = i;
			tmp.sb_frags = stof(getplayerkey(i, "frags"));
			if(tmp.sb_frags == -666)
				tmp.sb_team = COLOR_SPECTATOR;
			else
				tmp.sb_team = COLOR_TEAM1;
			Sort_Add(sortedPlayers, tmp);
		}
	}
}

void Sbar_PrintScoreboardItem(vector pos, entity pl, float is_self, float mask)
{
	vector tmp;
	string str;
	
	tmp_y = tmp_z = 0;
	pos_x += 56;

	str = bufstr_get(databuf, DATABUF_PING + pl.sb_player);
	tmp_x = 4*8 - strlen(str) * 8 - 56;
	drawstring(pos + tmp, str, '8 8 0', '0.8 0.8 0.8', 0.8, 0);

	if(!(mask & 1))
	{
		str = ftos(pl.sb_frags);
		tmp_x = 4*8 - strlen(str) * 8;
		drawstring(pos + tmp, str, '8 8 0', '1 1 1', 1, 0);
	}

	if(is_self)
		drawstring(pos + '40 0 0', "\x0D", '8 8 0', '1 1 1', 1, 0);
	str = getplayerkey(pl.sb_player, "name");
	tmp_x = 5*8 - strlen(str) * 8 + 56;
	drawcolorcodedstring(pos + '48 0 0', str, '8 8 0', 1, 0);
}
void Sbar_PrintScoreboardTeamItem(vector pos, entity tm, vector rgb, string name)
{
	vector tmp;
	string str;
	
	tmp_y = tmp_z = 0;
	pos_x += 56;

	str = ftos(tm.sb_frags);
	tmp_x = 4*8 - strlen(str) * 8;
	drawstring(pos + tmp, str, '8 8 0', rgb, 1, 0);

	drawstring(pos + '48 0 0', name, '8 8 0', rgb, 1, 0);
}

void Sbar_DrawScoreboard()
{
	// Assume: frags are already sorted
	float xmin, xmax, ymin, ymax;
	vector pos, teammin, teammax, rgb;
	entity pl, tm;
	float specs;
	specs = false;

	xmin = vid_conwidth / 4;
	xmax = vid_conwidth - xmin;
	ymin = 64;
	ymax = vid_conheight - 50;

	pos_x = xmin;
	pos_y = ymin;
	pos_z = 0;

	teammin = teammax = '0 0 0';
	teammin_x = xmin - 2;
	teammax_x = xmax - 2;
	
	drawstring(pos, "ping", '8 8 0', '1 1 1', 1, 0);
	drawstring(pos + '48 0 0', "frags", '8 8 0', '1 1 1', 1, 0);
	drawstring(pos + '104 0 0', "name", '8 8 0', '1 1 1', 1, 0);
	pos += '0 16 0';
	
	if(teamplay)
	{
		//for(t = 0; t < 4; ++t)
		for(tm = sortedTeams.sort_next; tm; tm = tm.sort_next)
		{
			if(!tm.sb_player || tm.sb_team == COLOR_SPECTATOR) // no players in it?
				continue;

			teammin_y = pos_y - 2;
			teammax_y = pos_y + 2 + 10 * (tm.sb_player+1);
			rgb = GetTeamRGB(tm.sb_team);
			drawfill(teammin, teammax - teammin, rgb, 0.2, DRAWFLAG_NORMAL);
			Sbar_PrintScoreboardTeamItem(pos, tm, rgb, GetTeamName(tm.sb_team));
			pos += '0 12 0';
			//for(i = 0; i < maxclients; ++i)
			for(pl = sortedPlayers.sort_next; pl; pl = pl.sort_next)
			{
				if(pl.sb_team != tm.sb_team)
					continue;
				Sbar_PrintScoreboardItem(pos, pl, (pl.sb_player == player_localentnum - 1), 0);
				pos += '0 10 0';
			}
			
			pos += '0 12 0';
		}

		// rgb := tempvector :)
		rgb = pos + '0 12 0';
		//pos += '64 24 0';
		pos_y += 24;
		//for(i = 0; i < maxclients; ++i)
		for(pl = sortedPlayers.sort_next; pl; pl = pl.sort_next)
		{
			if(pl.sb_team != COLOR_SPECTATOR)
				continue;
			//drawcolorcodedstring(pos, getplayerkey(pl.sb_player, "name"), '8 8 0', 1, 0);
			Sbar_PrintScoreboardItem(pos, pl, (pl.sb_player == player_localentnum - 1), 1);
			pos += '0 10 0';
			specs = true;
		}
			
		if(specs)
			drawstring(rgb, "Spectators", '8 8 0', '1 1 1', 1, 0);
	} else {
		//for(i = 0; i < maxclients; ++i)
		for(pl = sortedPlayers.sort_next; pl; pl = pl.sort_next)
		{
			if(pl.sb_team != COLOR_TEAM1)
				continue;
			//drawstring(pos, ftos(pl.sb_frags), '8 8 0', '1 1 1', 1, 0);
			//drawcolorcodedstring(pos + '64 0 0', getplayerkey(pl.sb_player, "name"), '8 8 0', 1, 0);
			Sbar_PrintScoreboardItem(pos, pl, (pl.sb_player == player_localentnum - 1), 0);
			pos += '0 12 0';
		}
		rgb = pos + '0 12 0';
		//pos += '64 24 0';
		pos_y += 24;
		for(pl = sortedPlayers.sort_next; pl; pl = pl.sort_next)
		{
			if(pl.sb_team != COLOR_SPECTATOR)
				continue;
			specs = true;
			//drawcolorcodedstring(pos, getplayerkey(pl.sb_player, "name"), '8 8 0', 1, 0);
			Sbar_PrintScoreboardItem(pos, pl, (pl.sb_player == player_localentnum - 1), 1);
			pos += '0 12 0';
		}
		if(specs)
			drawstring(rgb, "Spectators", '8 8 0', '1 1 1', 1, 0);
	}
}


void Sbar_Score(float margin)
{
	float timelimit, timeleft, minutes, seconds, distribution, myplace;
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
		for(tm = sortedTeams.sort_next; tm; tm = tm.sort_next)
		{
			if(tm.sb_team == COLOR_SPECTATOR || !tm.sb_player) // no players? don't display
				continue;
			// -32*4 = -128
			if(tm.sb_team == myteam)
				Sbar_DrawXNum('-128 0', tm.sb_frags, 4, 32, GetTeamRGB(tm.sb_team), 1, DRAWFLAG_NORMAL);
			else
			{
				Sbar_DrawXNum(place, tm.sb_frags, 4, 12, GetTeamRGB(tm.sb_team), 1, DRAWFLAG_NORMAL);
				place_x -= 4*12;
			}
		}
	} else {
		// me vector := [team/connected frags id]
		myplace = 0;
		for(me = sortedPlayers.sort_next; me; me = me.sort_next)
		{
			if(me.sb_team != COLOR_SPECTATOR)
				++myplace;
			if(me.sb_player == player_localentnum - 1)
				break;
		}
		pl = sortedPlayers.sort_next;
		if(pl == me)
			pl = pl.sort_next;
		
		if(pl && myplace != 1)
		{
			distribution = me.sb_frags - pl.sb_frags;
		} else if(pl) {
			distribution = me.sb_frags - pl.sb_frags;
		} else
			distribution = 0;
		
		if(myplace == 1)
			Sbar_DrawXNum('-36 -12', myplace, 3, 12, '1 1 1', 1, DRAWFLAG_NORMAL);
		else if(myplace == 2)
			Sbar_DrawXNum('-36 -12', myplace, 3, 12, '1 1 0', 1, DRAWFLAG_NORMAL);
		else
			Sbar_DrawXNum('-36 -12', myplace, 3, 12, '1 0 0', 1, DRAWFLAG_NORMAL);

		if(distribution >= 0)
		{
			Sbar_DrawXNum('-84 -12', distribution, 4, 12, ' 1 1 1', 1, DRAWFLAG_NORMAL);
			Sbar_DrawXNum('-128 0', me.sb_frags, 4, 32, '1 1 1', 1, DRAWFLAG_NORMAL);
		} else if(distribution >= -5)
		{
			Sbar_DrawXNum('-84 -12', distribution, 4, 12, ' 1 1 0', 1, DRAWFLAG_NORMAL);
			Sbar_DrawXNum('-128 0', me.sb_frags, 4, 32, '1 1 0', 1, DRAWFLAG_NORMAL);
		} else {
			Sbar_DrawXNum('-84 -12', distribution, 4, 12, ' 1 0 0', 1, DRAWFLAG_NORMAL);
			Sbar_DrawXNum('-128 0', me.sb_frags, 4, 32, '1 0 0', 1, DRAWFLAG_NORMAL);
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
	float x;
	pos_x += 72;
	
	if(teamplay)
		drawfill(pos + '0 1 0', '40 6 0', GetTeamRGB(pl.sb_team)*0.5, 1, DRAWFLAG_NORMAL);
	else
		drawfill(pos + '0 1 0', '40 6 0', '0.5 0.5 0.5', 0.5, DRAWFLAG_NORMAL);
	x = pos_x;
	pos_x += 5*8;
	pos_x -= strlen(ftos(pl.sb_frags))*8;
	drawstring(pos, ftos(pl.sb_frags), '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);
	pos_x = x;
	if(is_self)
	{
		pos_x += 48;
		drawstring(pos, "\x0D", '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);
		pos_x += 8;
	} else
		pos_x += 56;
	drawcolorcodedstring(pos, getplayerkey(pl.sb_player, "name"), '8 8 0', 1, 0);
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
	pos_x -= strlen(ftos(frags))*8;
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
	float i, numlines, up, down;
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
	for(me = sortedPlayers.sort_next; me; me = me.sort_next)
	{
		if(me.sb_player == player_localentnum - 1)
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
		if(pl.sb_team == COLOR_SPECTATOR)
			continue;
		Sbar_MiniscoreItem(pos, pl, false);
		pos_y -= 9;
		--down;
	}
	Sbar_MiniscoreItem(pos, me, true);
	pos_y -= 9;
	up += down; // if there weren't enough lines below... add them
	for(pl = me.sort_prev; pl != sortedPlayers && up > 0; pl = pl.sort_prev)
	{
		if(pl.sb_team == COLOR_SPECTATOR)
			continue;
		Sbar_MiniscoreItem(pos, pl, false);
		pos_y -= 9;
		--up;
	}

	if(teamplay)
	{
		for(tm = sortedTeams.sort_next; tm.sort_next; tm = tm.sort_next);
		for(; tm != sortedTeams; tm = tm.sort_prev)
		{
			if(!tm.sb_player || tm.sb_team == COLOR_SPECTATOR) // no players?
				continue;
			Sbar_MiniscoreTeamItem(pos, tm.sb_team, tm.sb_frags, (tm.sb_team == me.sb_team));
			pos_y -= 9;
		}
	}
}

void Sbar_Draw (void)
{
	float i;
	float x, fade;
	float stat_items;

	Sbar_SortFrags();

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

	pos_x = (cvar("sbar_flagstatus_right")) ? vid_conwidth - 10 - sbar_x - 64 : 10 - sbar_x;
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
