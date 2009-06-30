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
		//reset maptime announcers now as well
		announcer_5min = announcer_1min = FALSE;
		
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

/**
 * Plays the 1minute or 5 minutes (of maptime) remaining sound, if client wants it
 */
void maptimeAnnouncer() {
    float timelimit;
    timelimit = getstatf(STAT_TIMELIMIT);
    float timeleft;
    timeleft = max(0, timelimit * 60 + getstatf(STAT_GAMESTARTTIME) - time);
    
    //5 minute check
    if (cvar("cl_sound_maptime_warning") >= 2) {
        //make sure that after connect (and e.g. 4 minutes left) we will not get a wrong sound
        if (!announcer_5min && timelimit > 0 && timeleft < 300 && timeleft > 299) {
            announcer_5min = TRUE;
            //dprint("i will play the sound, I promise!\n");
            sound(self, CHAN_VOICE, "announcer/robotic/5minutesremain.wav", VOL_BASEVOICE, ATTN_NONE);
        }
        
    }
    
    //1 minute check
    if (cvar("cl_sound_maptime_warning") == 1 || cvar("cl_sound_maptime_warning") == 3) {
        if (!announcer_1min && timelimit > 0 && timeleft < 60) {
            announcer_1min = TRUE;
            sound(self, CHAN_VOICE, "announcer/robotic/1minuteremains.wav", VOL_BASEVOICE, ATTN_NONE);
        }
    }
}

/**
 * Add all future announcer sounds precaches here.
 * TODO: make all announcer sound() calls client-side in the end, to allow queues etc.
 */
void Announcer_Precache () {
    precache_sound ("announcer/robotic/1minuteremains.wav");
	precache_sound ("announcer/robotic/5minutesremain.wav");
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
	f = stof(cvar_string("sbar_width"));
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
	if(cs_project_is_b0rked)
	{
		vec_x += vid_width / 2;
		vec_y += vid_height / 2;
	}
	vec_x *= vid_conwidth / vid_width;
	vec_y *= vid_conheight / vid_height;
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

void drawstring_expanding(vector position, string text, vector scale, vector rgb, float alpha, float flag, float fadelerp)
{
	float sz;
	sz = expandingbox_sizefactor_from_fadelerp(fadelerp);

	dummyfunction(0, 0, 0, 0, 0, 0, 0, 0);
	drawstring(position + expandingbox_resize_centered_box_offset(sz, scale, stringwidth(text, FALSE)), text, scale * sz, rgb, alpha * (1 - fadelerp), flag);
}

void drawcolorcodedstring_expanding(vector position, string text, vector scale, float alpha, float flag, float fadelerp)
{
	float sz;
	sz = expandingbox_sizefactor_from_fadelerp(fadelerp);

	dummyfunction(0, 0, 0, 0, 0, 0, 0, 0);
	drawcolorcodedstring(position + expandingbox_resize_centered_box_offset(sz, scale, stringwidth(text, TRUE)), text, scale * sz, alpha * (1 - fadelerp), flag);
}
