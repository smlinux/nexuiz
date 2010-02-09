var float(string text, float handleColors, vector fontSize) stringwidth;

entity players;
entity teams;

void serverAnnouncer()
{
	// check for pending announcement, play it and remove it
	if(announce_snd != "")
	{
		sound(self, CHAN_VOICE, strcat("announcer/", cvar_string("cl_announcer"), "/", announce_snd, ".wav"), VOL_BASEVOICE, ATTN_NONE);
		strunzone(announce_snd);
		announce_snd = "";
	}
}

void restartAnnouncer_Think() {
	float countdown_rounded, countdown;
	countdown = getstatf(STAT_GAMESTARTTIME) - time;
	countdown_rounded = floor(0.5 + countdown);
	if(countdown <= 0) {
		if (!spectatee_status) //do cprint only for players
			centerprint("^1Begin!");

		sound(self, CHAN_VOICE, strcat("announcer/", cvar_string("cl_announcer"), "/begin.wav"), VOL_BASEVOICE, ATTN_NONE);
		//reset maptime announcers now as well
		announcer_5min = announcer_1min = FALSE;

		remove(self);
		return;
	}
	else {
		if (!spectatee_status) //do cprint only for players
			centerprint(strcat("^1Game starts in ", ftos(countdown_rounded), " seconds"));

		if(countdown_rounded <= 3 && countdown_rounded >= 1) {
			sound(self, CHAN_VOICE, strcat("announcer/", cvar_string("cl_announcer"), "/", ftos(countdown_rounded), ".wav"), VOL_BASEVOICE, ATTN_NONE);
		}

		self.nextthink = getstatf(STAT_GAMESTARTTIME) - (countdown - 1);
	}
}

/**
 * Plays the 1minute or 5 minutes (of maptime) remaining sound, if client wants it
 */
void maptimeAnnouncer() {
    float timelimit;
    timelimit = getstatf(STAT_TIMELIMIT);
    float timeleft;
    timeleft = max(0, timelimit * 60 + getstatf(STAT_GAMESTARTTIME) - time);

    float warmuplimit;
    float warmuptimeleft;
    if(warmup_stage) {
        warmuplimit = cvar("g_warmup_limit");
        if(warmuplimit > 0) {
           warmuptimeleft = max(0, warmuplimit + getstatf(STAT_GAMESTARTTIME) - time); 
        }
    }

    //5 minute check
    if (cvar("cl_sound_maptime_warning") >= 2) {
        //make sure that after connect (and e.g. 4 minutes left) we will not get a wrong sound
        if(announcer_5min)
        {
			if(((!warmup_stage || warmuplimit == 0) && timeleft > 300) || (warmup_stage && warmuplimit > 0 && warmuptimeleft > 300))
				announcer_5min = FALSE;
        }
        else if (((!warmup_stage || warmuplimit == 0) && timelimit > 0 && timeleft < 300 && timeleft > 299) || (warmup_stage && warmuplimit > 0 && warmuptimeleft < 300 && warmuptimeleft > 299))
	//if we're in warmup mode, check whether there's a warmup timelimit
        if not (warmuplimit == -1 && warmup_stage) {
			announcer_5min = TRUE;
			//dprint("i will play the sound, I promise!\n");
			sound(self, CHAN_VOICE, strcat("announcer/", cvar_string("cl_announcer"), "/5minutesremain.wav"), VOL_BASEVOICE, ATTN_NONE);
		}
    }

    //1 minute check
    if (cvar("cl_sound_maptime_warning") == 1 || cvar("cl_sound_maptime_warning") == 3) {
    	if (announcer_1min)
    	{
			if(((!warmup_stage || warmuplimit == 0) && timeleft > 60) || (warmup_stage && warmuplimit > 0 && warmuptimeleft > 60))
				announcer_1min = FALSE;
    	}
    	else if (((!warmup_stage || warmuplimit == 0) && timelimit > 0 && timeleft < 60) || (warmup_stage && warmuplimit > 0 && warmuptimeleft < 60))
	//if we're in warmup mode, check whether there's a warmup timelimit
    	if not (warmuplimit == -1 && warmup_stage) {
			announcer_1min = TRUE;
			sound(self, CHAN_VOICE, strcat("announcer/", cvar_string("cl_announcer"), "/1minuteremains.wav"), VOL_BASEVOICE, ATTN_NONE);
    	}
	}
}

 /**
 * Announce carried items (e.g. flags in CTF).
 */
float redflag_prev;
float blueflag_prev;
void carrierAnnouncer() {
	float stat_items, redflag, blueflag;
	float pickup;
	string item;

	if not(cvar("cl_notify_carried_items"))
		return;

	stat_items = getstati(STAT_ITEMS);

	redflag = (stat_items/IT_RED_FLAG_TAKEN) & 3;
	blueflag = (stat_items/IT_BLUE_FLAG_TAKEN) & 3;

	if (redflag == 3 && redflag != redflag_prev) {
		item = "^1RED^7 flag";
		pickup = (redflag_prev == 2);
	}

	if (blueflag == 3 && blueflag != blueflag_prev) {
		item = "^4BLUE^7 flag";
		pickup = (blueflag_prev == 2);
	}

	if (item)
	{
		if (pickup) {
			if (cvar("cl_notify_carried_items") & 2)
				centerprint(strcat("You picked up the ", item, "!"));
		}
		else {
			if (cvar("cl_notify_carried_items") & 1)
				centerprint(strcat("You got the ", item, "!"));
		}
	}

	blueflag_prev = blueflag;
	redflag_prev = redflag;
}

/**
 * Add all future announcer sounds precaches here.
 * TODO: announcer queues
 */
void Announcer_Precache () {
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/1minuteremains.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/5minutesremain.wav"));

	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/electrobitch.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/airshot.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/03kills.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/05kills.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/10kills.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/15kills.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/20kills.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/25kills.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/30kills.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/botlike.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/yoda.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/amazing.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/awesome.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/headshot.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/impressive.wav"));

	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/prepareforbattle.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/begin.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/timeoutcalled.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/1fragleft.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/2fragsleft.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/3fragsleft.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/terminated.wav"));

	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/1.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/2.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/3.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/4.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/5.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/6.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/7.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/8.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/9.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/10.wav"));

	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/lastsecond.wav"));
	precache_sound (strcat("announcer/", cvar_string("cl_announcer"), "/narrowly.wav"));
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

void CSQC_CheckEngine()
{
	sbar_font = FONT_USER+1;
	sbar_bigfont = FONT_USER+2;
}

vector Sbar_GetFontsize(string cvarname)
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

float Sbar_GetWidth(float teamcolumnwidth)
{
	float f;
	f = cvar("sbar_width");
	if(f == 0)
		f = 640;
	if(f < 320)
		f = 320;
	if(f > vid_conwidth - 2 * teamcolumnwidth)
		f = vid_conwidth - 2 * teamcolumnwidth;
	return f;
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
	if(ColorTranslateMode & 1)
		return strdecolorize(s);
	else
		return s;
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
	if(cs_project_is_b0rked > 0)
	{
		vec_x *= vid_conwidth / vid_width;
		vec_y *= vid_conheight / vid_height;
	}
	return vec;
}

void dummyfunction(float a1, float a2, float a3, float a4, float a5, float a6, float a7, float a8)
{
}

float expandingbox_sizefactor_from_fadelerp(float fadelerp)
{
	return 1.2 / (1.2 - fadelerp);
}

vector expandingbox_resize_centered_box_offset(float sz, vector boxsize, float boxxsizefactor)
{
	boxsize_x *= boxxsizefactor; // easier interface for text
	return boxsize * (0.5 * (1 - sz));
}

void drawborderlines(float thickness, vector pos, vector dim, vector color, float alpha, float drawflag)
{
	vector line_dim;

	// left and right lines
	pos_x -= thickness;
	line_dim_x = thickness;
	line_dim_y = dim_y;
	drawfill(pos, line_dim, color, alpha, drawflag);
	drawfill(pos + (dim_x + thickness) * '1 0 0', line_dim, color, alpha, drawflag);

	// upper and lower lines
	pos_y -= thickness;
	line_dim_x = dim_x + thickness * 2; // make upper and lower lines longer
	line_dim_y = thickness;
	drawfill(pos, line_dim, color, alpha, drawflag);
	drawfill(pos + (dim_y + thickness) * '0 1 0', line_dim, color, alpha, drawflag);
}

void drawpic_tiled(vector pos, string pic, vector sz, vector area, vector color, float alpha, float drawflag)
{
	vector current_pos, end_pos, new_size, ratio;
	end_pos = pos + area;

	current_pos_y = pos_y;
	while (current_pos_y < end_pos_y)
	{
		current_pos_x = pos_x;
		while (current_pos_x < end_pos_x)
		{
			new_size_x = min(sz_x, end_pos_x - current_pos_x);
			new_size_y = min(sz_y, end_pos_y - current_pos_y);
			ratio_x = new_size_x / sz_x;
			ratio_y = new_size_y / sz_y;
			drawsubpic(current_pos, new_size, pic, '0 0 0', ratio, color, alpha, drawflag);
			current_pos_x += sz_x;
		}
		current_pos_y += sz_y;
	}
}

void drawpic_expanding(vector position, string pic, vector scale, vector rgb, float alpha, float flag, float fadelerp)
{
	float sz;
	sz = expandingbox_sizefactor_from_fadelerp(fadelerp);

	drawpic(position + expandingbox_resize_centered_box_offset(sz, scale, 1), pic, scale * sz, rgb, alpha * (1 - fadelerp), flag);
}

void drawpic_expanding_two(vector position, string pic, vector scale, vector rgb, float alpha, float flag, float fadelerp)
{
	drawpic_expanding(position, pic, scale, rgb, alpha, flag, fadelerp);
	drawpic(position, pic, scale, rgb, alpha * fadelerp, flag);
}

vector drawfontscale;
void drawstring_expanding(vector position, string text, vector scale, vector rgb, float alpha, float flag, float fadelerp)
{
	float sz;
	sz = expandingbox_sizefactor_from_fadelerp(fadelerp);

	if(cvar("menu_font_size_snapping_fix"))
		drawfontscale = sz * '1 1 0';
	else
		drawfontscale = '1 1 0';
	dummyfunction(0, 0, 0, 0, 0, 0, 0, 0);
        drawstring(position + expandingbox_resize_centered_box_offset(sz, scale, stringwidth(text, FALSE, scale * (sz / drawfontscale_x)) / (scale_x * sz)), text, scale * (sz / drawfontscale_x), rgb, alpha * (1 - fadelerp), flag);
	// width parameter:
	//    (scale_x * sz / drawfontscale_x) * drawfontscale_x * SIZE1 / (scale_x * sz)
	//    SIZE1

	if(cvar("menu_font_size_snapping_fix"))
		drawfontscale = '1 1 0';
}

void drawcolorcodedstring_expanding(vector position, string text, vector scale, float alpha, float flag, float fadelerp)
{
	float sz;
	sz = expandingbox_sizefactor_from_fadelerp(fadelerp);

	if(cvar("menu_font_size_snapping_fix"))
		drawfontscale = sz * '1 1 0';
	else
		drawfontscale = '1 1 0';
	dummyfunction(0, 0, 0, 0, 0, 0, 0, 0);
	drawcolorcodedstring(position + expandingbox_resize_centered_box_offset(sz, scale, stringwidth(text, TRUE, scale * (sz / drawfontscale_x)) / (scale_x * sz)), text, scale * (sz / drawfontscale_x), alpha * (1 - fadelerp), flag);

	if(cvar("menu_font_size_snapping_fix"))
		drawfontscale = '1 1 0';
}

// this draws the triangles of a model DIRECTLY. Don't expect high performance, really...
void PolyDrawModel(entity e)
{
	float i_s, i_t;
	float n_t;
	vector tri;
	string tex;
	for(i_s = 0; ; ++i_s)
	{
		tex = getsurfacetexture(e, i_s);
		if not(tex)
			break; // this is beyond the last one
		n_t = getsurfacenumtriangles(e, i_s);
		for(i_t = 0; i_t < n_t; ++i_t)
		{
			tri = getsurfacetriangle(e, i_s, i_t);
			R_BeginPolygon(tex, 0);
			R_PolygonVertex(getsurfacepoint(e, i_s, tri_x), getsurfacepointattribute(e, i_s, tri_x, SPA_TEXCOORDS0), '1 1 1', 1);
			R_PolygonVertex(getsurfacepoint(e, i_s, tri_y), getsurfacepointattribute(e, i_s, tri_y, SPA_TEXCOORDS0), '1 1 1', 1);
			R_PolygonVertex(getsurfacepoint(e, i_s, tri_z), getsurfacepointattribute(e, i_s, tri_z, SPA_TEXCOORDS0), '1 1 1', 1);
			R_EndPolygon();
		}
	}
}
