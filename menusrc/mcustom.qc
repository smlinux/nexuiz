///////////////////////////////////////////////
// Custom Menu Source File
///////////////////////
// This file belongs to dpmod/darkplaces
// AK contains menu specific stuff that is made especially for dpmod
// AK this file is used e.g. for defining some special event functions
////////////////////////////////////////////////

////////////////
// global stuff
///

void(void) nex_slidertext =
{
	entity ent;
	if(self.link == "")
	{
		print("No link specified\n");
		eprint(self);
		self.init = null_function;
		return;
	}

	ent = menu_getitem(self.link);
	if(ent == null_entity)
	{
		objerror("No link found for ", self.link,"\n");
	}

	self._link = ent;

	self.flag = self.flag | FLAG_DRAWREFRESHONLY;

	self.refresh = _nex_slidertext_refresh;
};

void(void) _nex_slidertext_refresh =
{
	self.text = ftos(self._link.value);
	if(self.maxlen > 0)
		self.text = substring(self.text,0, self.maxlen);
	// reset the size, so its set
	self.size = '0 0 0';
};

float(float keynr, float ascii) nex_redirect_key =
{
	if((ascii>=20 && ascii <= 126) || keynr == K_BACKSPACE || keynr == K_ENTER || keynr == K_LEFTARROW || keynr == K_RIGHTARROW || (keynr >= K_MOUSE1 && keynr <= K_MOUSE10))
	{
		raise_key(self._child, keynr, ascii);
		return true;
	}
	return false;
};

void(void) nex_cvar_slider =
{
	self.value = cvar(self.cvarname);
	self.slidermove = self.switchchange = _nex_cvar_slider;
	self.refresh = _nex_cvar_slider_refresh;
};

void(void) _nex_cvar_slider_refresh =
{
	if(self.cvartype == CVAR_INT || self.cvartype == CVAR_FLOAT || self.cvartype == CVAR_STEP)
		self.value = cvar(self.cvarname);
};

void(void) _nex_cvar_slider =
{
	if(self.cvarname == "")
		return;
	if(self.cvartype == CVAR_INT) // || self.cvartype == CVAR_STRING)
		self.value = rint(self.value);
	if(self.cvartype == CVAR_STEP)
		self.value = rint(self.value / self.step) * self.step;
	if(self.cvartype == CVAR_INT || self.cvartype == CVAR_FLOAT || self.cvartype == CVAR_STEP)
		cvar_set(self.cvarname, ftos(self.value));
	/*if(cvartype == CVAR_STRING)
	{
		string s;
		s = getaltstring(self.value, self.cvarvalues);
		cvar_set(self.cvarname, s);
	}
	*/
};

//////////////
// main.menu
///

// quit menu

void(void) nex_quit_choose =
{
	entity e;
	// because of the missing support for real array, we have to do it the stupid way
	// (we also have to use strzone for the text, cause it the temporary strings wont work
	// for it)
	if(nex_quitrequest == 0)
	{
		e = menu_getitem("quit_msg_0");
		e.text = getaltstring(0,nex_quitmsg_0);
	}
	if(nex_quitrequest == 1)
	{
		e = menu_getitem("quit_msg_0");
		e.text = getaltstring(0,nex_quitmsg_1);
	}
	if(nex_quitrequest == 2)
	{
		e = menu_getitem("quit_msg_0");
		e.text = getaltstring(0,nex_quitmsg_2);
	}
	if(nex_quitrequest == 3)
	{
		e = menu_getitem("quit_msg_0");
		e.text = getaltstring(0,nex_quitmsg_3);
	}
	e.text = strzone(e.text);

	if(nex_quitrequest == 0)
	{
		e = menu_getitem("quit_msg_1");
		e.text = getaltstring(1,nex_quitmsg_0);
	}
	if(nex_quitrequest == 1)
	{
		e = menu_getitem("quit_msg_1");
		e.text = getaltstring(1,nex_quitmsg_1);
	}
	if(nex_quitrequest == 2)
	{
		e = menu_getitem("quit_msg_1");
		e.text = getaltstring(1,nex_quitmsg_2);
	}
	if(nex_quitrequest == 3)
	{
		e = menu_getitem("quit_msg_1");
		e.text = getaltstring(1,nex_quitmsg_3);
	}
	e.text = strzone(e.text);

	nex_quitrequest = nex_quitrequest + 1;
	if(nex_quitrequest == DPMOD_QUIT_MSG_COUNT)
		nex_quitrequest = 0;
};

void(void) nex_quit =
{
/*	entity ent;
	// choose a quit message
	nex_quit_choose();

	// change the flags
	ent = menu_getitem("main");
	ent.flag = ent.flag | FLAG_CHILDDRAWONLY;
	ent = menu_getitem("quit");
	ent.flag = FLAG_NOSELECT;
	menu_jumptowindow(ent, false);*/
	entity ent;

	// change the flags
	ent = menu_getitem("quitbox_ref");
	ent._child = menu_activewindow;
	ent = menu_getitem("quitbox");
	menu_jumptowindow(ent, true);
};

void(void) nex_quit_yes =
{
	cmd("quit\n");
};

void(void) nex_quit_no =
{
/*	entity ent;

	ent = menu_getitem("quit_msg_0");
	strunzone(ent.text);

	ent = menu_getitem("quit_msg_1");
	strunzone(ent.text);

	ent = menu_getitem("quit");
	ent.flag = FLAG_HIDDEN;
	ent = menu_getitem("main");
	ent.flag = ent.flag - FLAG_CHILDDRAWONLY;
	menu_selectup();*/
	menu_selectup();
};

float(float keynr, float ascii) nex_quit_key =
{
	if(keynr == K_LEFTARROW)
		return false;
	if(keynr == K_RIGHTARROW)
		return false;
	if(keynr == K_ENTER)
		return false;
	if(keynr == K_MOUSE1)
		return false;
	if(ascii == 'Y' || ascii == 'y')
		nex_quit_yes();
	if(ascii == 'N' || ascii == 'n' || keynr == K_ESCAPE)
		nex_quit_no();
	return true;
};

// options menu

void(void) nex_display_options =
{
	entity ent;

	if(substring(menu_activewindow.name,0,3) == "opt")
		return;

	ent = menu_getitem("options_settings_ref");
	ent._child = menu_getitem(self.link);

	menu_jumptowindow(menu_getitem("options"), true);
};

/////////////////
// video.menu

void(void) nex_display_video =
{
	if(menu_activewindow.name == "video")
		return;
	menu_jumptowindow(menu_getitem("video"),true);
};

void(void) nex_video_bpp_reinit =
{
	if(cvar("vid_bitsperpixel") == 32)
		self.value = 1;
	else
		self.value = 0;
};

void(void) nex_video_fullscreen_reinit =
{
	self.value = cvar("vid_fullscreen");
};

string nex_video_resolutions;

void(void) nex_video_resolution_switch_reinit =
{
	float c, i;
	float pos86;

	c = getaltstringcount(nex_video_resolutions);
	for(i = 0; i < c; i=i+1)
	{
		string s;
		vector t;
		s = getaltstring(i,nex_video_resolutions);
		s = strcat("'",s,"'");
		t = stov(s);
		if(t_x == cvar("vid_width") && t_y == cvar("vid_height"))
		{
			self.value = i;
			return;
		}
		if(t == '800 600 0')
			pos86 = i;
	}

	self.value = pos86;
};

void(void) nex_video_resolution_switch =
{
	var float pos86 = 0;
	var float counter = 0;
	vector t;

	nex_video_resolutions = "";
	self.text = "";
	self.value = -1;

	while((t = getresolution(counter)) != '0 0 0')
	{
		if(t == '800 600 0')
			pos86 = counter;
		if(t_x == cvar("vid_width") && t_y == cvar("vid_height"))
		{
			self.value = counter;
		}
		counter = counter + 1;
		self.text = strcat(self.text,"'",ftos(t_x),"x");
		self.text = strcat(self.text,ftos(t_y),"'");
		nex_video_resolutions = strcat(nex_video_resolutions,vtos(t));
	}

	if(self.value == -1)
		self.value = pos86;

	self.text = strzone(self.text);
	nex_video_resolutions = strzone(nex_video_resolutions);

	self.reinit = nex_video_resolution_switch;
};

void(void) nex_video_apply =
{
	vector set, res;
	float changed;
	entity tmp;

	changed = false;

	// resolution test
	res_x = cvar("vid_width");
	res_y = cvar("vid_height");
	res_z = 0;

	tmp = menu_getitem("video_wnd_resolution_switch");
	set = stov(getaltstring(tmp.value, nex_video_resolutions));
	if(set != res)
	{
		cvar_set("vid_width",ftos(set_x));
		cvar_set("vid_height",ftos(set_y));
		changed = true;
	}
	// bpp test
	tmp = menu_getitem("video_wnd_bpp_switch");
	if((tmp.value+1)*16 != cvar("vid_bitsperpixel"))
	{
		cvar_set("vid_bitsperpixel",ftos((tmp.value+1)*16));
		changed = true;
	}
	// fullscreen changed
	tmp = menu_getitem("video_wnd_fullscreen_switch");
	if(tmp.value != cvar("vid_fullscreen"))
	{
		cvar_set("vid_fullscreen",ftos(tmp.value));
		changed = true;
	}

	if(changed)
	{
		cmd("vid_restart\n");
	}
};

/////////////////
// xplayer.menu
///

float maxfrags;
float maxtime;
float maxbots;
string mapname = "e1m1";
entity selectmap;
var float selectnum  = 0;
float FRAME_WIDTH = 5;
float MAPNAME_WIDTH = 100;
float mapnum;

// create the mapselection frame stuff
void(void) nex_xp_build_maplist =
{
	entity pic;
	entity mapname;
	entity template_text;
	entity template_pic;
	float searchhandle;
	float counter;

	// search through maps for all bsps and add them to the list
	// if a picture exists for them, add it to
	searchhandle = search_begin("maps/*.bsp",true,true);
	if(searchhandle == -1)
	{
		print("menu: No maps found...\n");
		return;
	}

	template_text = menu_getitem("mapselection_template_text");
	template_pic = menu_getitem("mapselection_template_picture");

	mapnum = search_getsize(searchhandle);

	for(counter = 0; counter < mapnum; counter = counter + 1)
	{
		string extstripped;
		string allstripped;
		float filehandle;

		extstripped = search_getfilename(searchhandle, counter);
		extstripped = substring(extstripped, 0, strlen(extstripped) - 4); // .bsp off
		extstripped = strzone(extstripped);

		allstripped = substring(extstripped, 5, 400); // maps/ off
		allstripped = strzone(allstripped);

		mapname = spawn();
		pic = spawn();

		copyentity(template_text, mapname);
		copyentity(template_pic, pic);

		mapname.name = strzone(allstripped);
		mapname.text = strzone(allstripped);

		mapname.orderpos = counter + mapnum + 1;

		mapname.pos_x = counter * MAPNAME_WIDTH;

		mapname.size_x = MAPNAME_WIDTH;
		mapname.size_y = mapname.font_size_y;
		mapname.font_size = '0 0 0';

		{
			entity old
			old = self;
			self = mapname;
			ITEM_TEXT();
			self = old;
		}

		pic.orderpos = counter + 1;
		pic.pos_x = counter * MAPNAME_WIDTH;
		pic.name = strzone(strcat(allstripped,"_picture"));

		// TODO: add support for other formats, too
		filehandle = search_begin(strcat(extstripped,".jpg"), true, true);
		if(filehandle != -1)
		{
			pic.picture = strcat(extstripped,".jpg");
			pic.picture = strzone(pic.picture);
			search_end(filehandle);
		}

		if(counter == 0)
			selectmap = mapname;

		strunzone(extstripped);
		strunzone(allstripped);
	}

	print(ftos(mapnum),"\n");

	search_end(searchhandle);
};

void(void) nex_xp_prev =
{
	entity s;
	if(selectnum <= 0)
		return;

	selectnum = selectnum - 1;

	s = menu_getitem("mapselection_selsquare");
	s.pos_x = selectnum * 100;

	// scroll left ?
	if((mapnum - 1 - selectnum) > floor(FRAME_WIDTH / 2) && selectnum + 1 >= ceil(FRAME_WIDTH / 2)) // 2,3
	{
		s = menu_getitem("mapselection_frame");
		s.origin_x = s.origin_x + 100;
	}
};

void(void) nex_xp_next =
{
	entity s;
	if(selectnum >= mapnum - 1)
		return;

	selectnum = selectnum + 1;

	s = menu_getitem("mapselection_selsquare");
	s.pos_x = selectnum * 100;

	// scroll right ?
	if((mapnum - 1 - selectnum) >= floor(FRAME_WIDTH / 2) && selectnum + 1 > ceil(FRAME_WIDTH / 2)) // 2,3
	{
		s = menu_getitem("mapselection_frame");
		s.origin_x = s.origin_x - 100;
	}
};

void(void) nex_xp_click = // if one of the maplist entries get 'clicked' :-)
{
	float deltapos;

	// get the position
	// HACKHACK
	if(self.orderpos > mapnum)
	{
		deltapos = self.orderpos - mapnum - selectnum - 1;
	} else
	{
		deltapos = self.orderpos - selectnum - 1;
	}

	print(ftos(deltapos));

	if(deltapos == 0)
		return;

	if(deltapos > 0)
	{
		while(deltapos > 0)
		{
			deltapos = deltapos - 1;
			nex_xp_next();
		}
	}
	else
	{
		while(deltapos < 0)
		{
			deltapos = deltapos + 1;
			nex_xp_prev();
		}
	}
};

void(void) nex_display_singleplayer =
{
	if(menu_activewindow.name == "singleplayer")
		return;
	menu_jumptowindow(menu_getitem("singleplayer"),true);
};

void(void) nex_xp_maxfrags =
{
	float x;
	x = stof(self.text);
	x = rint(x);

	maxfrags = x;
	strunzone(self.text);
	self.text = ftos(x);
	self.text = strzone(self.text);
};

void(void) nex_xp_maxbots =
{
	float x;
	x = stof(self.text);
	x = rint(x);

	maxbots = x;
	strunzone(self.text);
	self.text = ftos(x);
	self.text = strzone(self.text);
};

void(void) nex_xp_maxtime =
{
	float x;
	x = stof(self.text);
	x = rint(x);

	maxtime = x;
	strunzone(self.text);
	self.text = ftos(x);
	self.text = strzone(self.text);
};

void(void) nex_sp_start =
{
	local float i;

	cvar_set("fraglimit", ftos(maxfrags));
	cvar_set("timelimit", ftos(maxtime));
	cvar_set("deathmatch", ftos(1));
	cmd("map ");
	cmd(mapname);
	cmd(";wait\n");

	/*for(i = 0; i < maxbots; i = i + 1)
	{
		cmd("impulse 100;wait;wait;");
	}*/
	cmd("scratch1 ");
	cmd(ftos(maxbots));

	cmd("\n");

	menu_toggle();
};

/////////////////
// options.menu
///

void(void) nex_options_alwaysrun_switchchange =
{
	if(self.value)
	{
		cvar_set("cl_forwardspeed","400");
		cvar_set("cl_backspeed","400");
	}
	else
	{
		cvar_set("cl_forwardspeed","200");
		cvar_set("cl_backspeed","200");
	}
};

void(void) nex_options_alwaysrun_refresh =
{
	if(cvar("cl_forwardspeed") > 200)
		self.value = 1;
	else
		self.value = 0;
};

void(void) nex_options_invmouse_switchchange =
{
	float old;
	old = 0 - cvar("m_pitch");
	cvar_set("m_pitch",ftos(old));
};

void(void) nex_options_invmouse_refresh =
{
	if(cvar("m_pitch") > 0)
		self.value = 0;
	else
		self.value = 1;
};

void(void) nex_snd =
{
	entity ent;
	ent = menu_getitem("options_settings_ref");
	ent._child = menu_getitem("options_sound");
	menu_jumptowindow(ent, false);
}

void(void) nex_snd_cd_init =
{
	if(cvar("cdaudioinitialized"))
	{
		self.flag = FLAG_AUTOSETCLICK;
		self.color = ITEM_TEXT_NORMAL_COLOR;
	}
	else
	{
		self.flag = FLAG_NOSELECT | FLAG_DRAWONLY | FLAG_CHILDDRAWONLY;
		self.color = '0.5 0.5 0.5';
	}
};

void(void) nex_snd_snd_init =
{
	if(cvar("snd_initialized"))
	{
		self.flag = FLAG_AUTOSETCLICK;
		self.color = ITEM_TEXT_NORMAL_COLOR;
	}
	else
	{
		self.flag = FLAG_NOSELECT | FLAG_DRAWONLY | FLAG_CHILDDRAWONLY;
		self.color = '0.5 0.5 0.5';
	}
};

void(void) nex_cc =
{
	entity ent;
	ent = menu_getitem("options_settings_ref");
	ent._child = menu_getitem("options_cc");
	menu_jumptowindow(ent, false);
}

void(void) nex_cc_reset =
{
	cmd(
	"v_hwgamma 1;"
	"v_gamma 1;"
	"v_contrast 1;"
	"v_brightness 0;"
	"v_color_enable 0;"
	"v_color_black_r 0;"
	"v_color_black_g 0;"
	"v_color_black_b 0;"
	"v_color_grey_r 0;"
	"v_color_grey_g 0;"
	"v_color_grey_b 0;"
	"v_color_white_r 1;"
	"v_color_white_g 1;"
	"v_color_white_b 1;"
	"\n");
};

void(void) nex_cc_check_hwgamma =
{
	if(cvar("vid_hardwaregammasupported"))
	{
		self.flag = FLAG_AUTOSETCLICK;
		self.color = ITEM_TEXT_NORMAL_COLOR;
	}
	else
	{
		self.flag = FLAG_NOSELECT;
		self.color = '0.5 0.5 0.5';
	}
};

void(void) nex_cc_check_gamma = // used in key -- BADBAD HACKHACK
{
	if(cvar("v_hwgamma") && cvar("vid_hardwaregammasupported") && !cvar("v_color_enable"))
	{
		self.flag = FLAG_AUTOSETCLICK;
		self.color = ITEM_TEXT_NORMAL_COLOR;
	}
	else
	{
		self.flag = FLAG_NOSELECT;
		self.color = '0.5 0.5 0.5';
	}
};

void(void) nex_cc_check_grey = // used in key -- BADBAD HACKHACK
{
	if(cvar("v_hwgamma") && cvar("vid_hardwaregammasupported") && cvar("v_color_enable"))
	{
		self.flag = FLAG_AUTOSETCLICK;
		self.color = ITEM_TEXT_NORMAL_COLOR;
	}
	else
	{
		self.flag = FLAG_NOSELECT;
		self.color = '0.5 0.5 0.5';
	}
};

void(void) nex_cc_check_ncolor_enable =
{
	if(!cvar("v_color_enable"))
	{
		self.flag = FLAG_AUTOSETCLICK;
		self.color = ITEM_TEXT_NORMAL_COLOR;
	}
	else
	{
		self.flag = FLAG_NOSELECT;
		self.color = '0.5 0.5 0.5';
	}
};

void(void) nex_cc_check_color_enable =
{
	if(cvar("v_color_enable"))
	{
		self.flag = FLAG_AUTOSETCLICK;
		self.color = ITEM_TEXT_NORMAL_COLOR;
	}
	else
	{
		self.flag = FLAG_NOSELECT;
		self.color = '0.5 0.5 0.5';
	}
};

void(void) nex_cc_color_enable =
{
	cvar_set("v_color_enable","1");
};

void(void) nex_cc_ncolor_enable =
{
	cvar_set("v_color_enable","0");
};

void(void) nex_cc_grey_refresh =
{
	self.value = cvar(strcat(self.cvarname,"_r"));
	self.value = self.value + cvar(strcat(self.cvarname,"_g"));
	self.value = self.value + cvar(strcat(self.cvarname,"_b"));
	self.value = self.value / 3;
};


void(void) nex_cc_grey_move =
{
	string tmp;
	tmp = ftos(self.value);
	cvar_set(strcat(self.cvarname,"_r"), tmp);
	cvar_set(strcat(self.cvarname,"_g"), tmp);
	cvar_set(strcat(self.cvarname,"_b"), tmp);
};

void(void) nex_cc_grey =
{
	self.refresh = nex_cc_grey_refresh;
	self.slidermove = nex_cc_grey_move;
};

////////////////////////////////////////////////////
// Test Stuff
///
void(void) initbrightness =
{
	self.value = cvar("scr_conbrightness");
};

void(void) setbrightness =
{
	cvar_set("scr_conbrightness",ftos(self.value));
};

void(void)	nex_main_exit =
{
	entity e;
	e = menu_getitem("MAIN_MENU");
	e.flag = FLAG_NOSELECT + FLAG_CHILDDRAWONLY;
	e = menu_getitem("MAIN_EXIT_MENU");
	e.flag = FLAG_NOSELECT;
	menu_jumptowindow(e, false);
};

void(void) nex_main_exit_no =
{
	entity e;
	e = menu_getitem("MAIN_EXIT_MENU");
	e.flag = FLAG_NOSELECT + FLAG_HIDDEN;
	e = menu_getitem("MAIN_MENU");
	e.flag = FLAG_NOSELECT;
	menu_selectup();
};

void(void) nex_main_exit_yes =
{
	cmd("quit\n");
};

float(float keynr, float ascii) nex_main_exit_key =
{
	if(keynr == K_ESCAPE)
	{
		nex_main_exit_no();
		return true;
	}
	return false;
}

void(void) 	dorestart =
{
	cmd("menu_restart\n");
};

void(void) nex_text_cur_x =
{
	self.text = ftos(rint(cursor_x));
};

void(void) nex_text_cur_y =
{
	self.text = ftos(rint(cursor_y));
};