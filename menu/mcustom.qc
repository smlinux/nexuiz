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

void() nex_setposition =
{
	self.pos_x = 0;
	self.pos_y = (self.font_size_y + 5) * self.orderpos;
	self.pos_z = 0;

	self.origin = self.pos;
};

void(entity item) nex_makeonlyvisible =
{
	local entity node;

	if( item.flag & FLAG_HIDDEN )
		item.flag = item.flag - FLAG_HIDDEN;
	for( node = item._next ; node ; node = node._next )
		node.flag = item.flag | FLAG_HIDDEN;
	for( node = item._prev ; node ; node = node._prev )
		node.flag = item.flag | FLAG_HIDDEN;
};

void(void) nex_linkrelhack =
{
	self._child._parent = self;
};

void(void) nex_maketextzone =
{
	self.text = strzone(self.text);
};

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

void(void) nex_makeselfonlyvisible =
{
	nex_makeonlyvisible( self );
};

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
/*  entity ent;
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
/*  entity ent;

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

	ent = menu_getitem( "options" );

	nex_makeonlyvisible( ent );
	menu_jumptowindow( ent, false );
};

/////////////////
// video.menu

void(void) nex_display_video =
{
	nex_makeonlyvisible( menu_getitem( "video" ) );
	menu_jumptowindow( menu_getitem( "video" ), false );
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

	tmp = menu_getitem("video_resolution_switch");
	set = stov(getaltstring(tmp.value, nex_video_resolutions));
	if(set != res)
	{
		cvar_set("vid_width",ftos(set_x));
		cvar_set("vid_height",ftos(set_y));
		changed = true;
	}
	// bpp test
	tmp = menu_getitem("video_bpp_switch");
	if((tmp.value+1)*16 != cvar("vid_bitsperpixel"))
	{
		cvar_set("vid_bitsperpixel",ftos((tmp.value+1)*16));
		changed = true;
	}
	// fullscreen changed
	tmp = menu_getitem("video_fullscreen_switch");
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
float skilllevel;
string hostname;
float  maxclients;
float  publicserver;
float  gamemode;

entity maps_list;
entity maps_current;

// text = info text
// picture = picture filename
// name = map name
void(entity node) _nex_xp_remove =
{
	strunzone( node.picture );
	strunzone( node.text );
	strunzone( node.name );
	remove( node );
}

void(void) _nex_xp_update =
{
	entity item;

	item = menu_getitem( "creategame_map_name" );
	item.text = maps_current.name;

	item = menu_getitem( "creategame_map_picture" );
	item.picture = maps_current.picture;

	item = menu_getitem( "creategame_map_info" );
	item.text = maps_current.text;
};

void(void) nex_xp_enummaps =
{
	float count;
	float searchhandle;
	float counter;

	// remove the old list
	if( maps_list ) {
		entity node;

		node = maps_list;
		while( node._next ) {
			node = node._next;
			_nex_xp_remove( node._prev );
		}
		_nex_xp_remove( node );
	}
	maps_list = maps_current = null_entity;

	searchhandle = search_begin( "maps/*.bsp", true, true );
	if( searchhandle == -1 ) {
		print( "menu: No maps found!\n" );
		return;
	} else if( searchhandle == -2)
		return;

	maps_list = maps_current = spawn();
	count = search_getsize( searchhandle );
	for( counter = 0 ; counter < count ; counter = counter + 1 ) {
		float file;
		string fname;

		fname = search_getfilename( searchhandle, counter );
		fname = substring( fname, 0, strlen( fname ) -  4 );
		fname = strzone( fname );

		//try to find the information text
		file = fopen( strcat( fname, ".txt" ), FILE_READ );
		if( file == -1 )
			maps_current.text = strzone( "--NO INFORMATION AVAILABLE--" );
		else {
			string temp, old;
			maps_current.text = strzone( "" );
			do {
				old = maps_current.text;
				temp = fgets( file );
				maps_current.text = strzone( strcat( old, temp, "\n" ) );
				strunzone( old );
			} while( temp );
			fclose( file );
		}

		//try to find the picture
		file = search_begin( strcat( fname, ".jpg" ), true, true );
		if( file == -1 )
			maps_current.picture = strzone( "gfx/m_nomap" );
		else {
			maps_current.picture = strzone( strcat( fname, ".jpg" ) );
			search_end( file );
		}

		maps_current.name = strzone( substring( fname, 5, strlen( fname ) - 5 ) ); // remove the 'maps/'
		strunzone( fname );

		// create next item and link it with the list
		maps_current._next = spawn();
		maps_current._next._prev = maps_current;
		maps_current = maps_current._next;
	}
	// remove the last item
	maps_current = maps_current._prev;
	remove( maps_current._next );
	maps_current._next = null_entity;

	search_end( searchhandle );

	maps_current = maps_list;
	_nex_xp_update();
};

void(void) nex_xp_prev =
{
	if( maps_current._prev )
		maps_current = maps_current._prev;
	_nex_xp_update();
};

void(void) nex_xp_next =
{
	if( maps_current._next )
		maps_current = maps_current._next;
	_nex_xp_update();
};


void(void) nex_display_creategame =
{
	nex_makeonlyvisible( menu_getitem( "creategame" ) );
	menu_jumptowindow( menu_getitem( "creategame" ), false );
};

void(void) nex_xp_maxfrags =
{
	float x;
	x = stof(self.text);
	maxfrags = rint(x);

	strunzone(self.text);
	self.text = ftos(x);
	self.text = strzone(self.text);
};

void(void) nex_xp_maxbots =
{
	float x;
	x = stof(self.text);
	maxbots = min( fabs(rint(x)), maxclients - 1, 16 ); // 16 is currently max in frikbot - see below

	strunzone(self.text);
	self.text = ftos(x);
	self.text = strzone(self.text);
};

void(void) nex_xp_maxtime =
{
	float x;
	x = stof(self.text);
	maxtime = rint(x);

	strunzone(self.text);
	self.text = ftos(maxtime);
	self.text = strzone(self.text);
};

void(void) nex_xp_hostname =
{
	hostname = self.text;
};

void(void) nex_xp_maxclients =
{
	local float i;
	i = stof(self.text);
	maxclients = rint(i);

	strunzone(self.text);
	self.text = strzone(ftos(maxclients));
};

void(void) nex_xp_publicserv =
{
	publicserver = self.value;
};

void(void) nex_xp_gamemode =
{
	gamemode = self.value;
};

void(void) nex_xp_skilllevel =
{
	skilllevel = self.value;
}

void(void) nex_xp_start =
{
	cvar_set( "fraglimit", ftos( maxfrags ) );
	cvar_set( "timelimit", ftos( maxtime ) );
	cvar_set( "deathmatch", "1" );

	cmd( "maxplayers " );
	cmd( ftos( maxclients ) );
	cmd( "\n" );

	cvar_set( "sv_public", ftos( publicserver ) );
	cvar_set( "hostname", hostname );

	// see bot/bot.qc: BotInit
	cvar_set( "saved1", "1" );
	cvar_set( "scratch1", ftos( pow( 2, maxbots ) - 1 ) );
	cvar_set( "scratch2", ftos( skilllevel * (pow(4, min(maxbots, 8)) - 1) / 3) );
	cvar_set( "scratch3", ftos( skilllevel * (pow(4, min(maxbots - 8, 8)) - 1) / 3) );

	cmd( "map " );
	cmd( maps_current.name );
	cmd( "\n" );
	cmd( "togglemenu\n" );
};

void(void) nex_goto_createserver =
{
	menu_jumptowindow( menu_getitem( "multiplayer_frame"), false );
}

void(void) nex_draw_text =
{
	local vector drawpos;
	local float cpos, end;

	cpos = 0;
	drawpos = self.pos;
	drawpos_y = drawpos_y + self.font_size_y;
	do {
		local string l;
		local float i;

		end = strlen( self.text );
		i = cpos;
		do {
			l = substring( self.text, i, 1 );

			if( l == "\n" ) {
				end = i;
				break;
			}

			i = i + 1;
		} while( l != "" );

		l = substring( self.text, cpos, end - cpos );
		if( l != "" )
			menu_drawstring( drawpos, l, self.font_size, self.color, self.alpha, self.drawflag );
		drawpos_y = drawpos_y + self.font_size_y;

		cpos = end + 1;
	} while( end != strlen( self.text ) );
}

// server list
var float slist_selected = 0;
var float slist_start   = 0;
float slist_estimatedsize;

void(void) nex_display_serverlist =
{
	if(menu_activewindow.name == "serverlist")
		return;
	menu_jumptowindow(menu_getitem("serverlist"),true);
	cmd("net_slist\n");
};

// use a ITEM_TEXT as base item for this
// we need another item to clip the slist
// (another reason for a new menu qc!)
void(void) slist_draw =
{
	float c;
	vector pos;
	float listsize;

	//print("slist drawing...", ftos(listsize), "\n");

	pos = '0 0 0'; // the upper item sets the origin
	listsize = gethostcachevalue(SLIST_HOSTCACHECOUNT);
	if(!listsize)
	{
		menu_drawstring(pos, "No Servers", self.font_size, self.color, self.alpha, self.drawflag);
		return;
	}

	for(c = 0; c < slist_estimatedsize + 1; c = c + 1)
	{
		string line;

		if(listsize <= slist_start + c)
			break;

		//print("drawing ", ftos(c),"\n");

		if(slist_selected - slist_start == c)
		{
			vector s;
			s = self.size;
			s_y = self.font_size_y * 2;

			menu_fillarea(pos, s, self.color_selected, self.alpha_selected * (sin(time * 9) + 1) / 2, self.drawflag_selected);
		}

		line = gethostcachestring(SLIST_LINE1, slist_start + c);

		if( !line || line == "" )
			line = "Empty";
		menu_drawstring(pos, line, self.font_size, self.color, self.alpha, self.drawflag);

		pos_y = pos_y + self.font_size_y;

		line = gethostcachestring(SLIST_LINE2, slist_start + c);

		if( !line || line == "" )
			line = "Empty";
		menu_drawstring(pos, line, self.font_size, self.color, self.alpha, self.drawflag);

		pos_y = pos_y + self.font_size_y;
	}
};

void(void) slist_init =
{
	self.size = self._parent.size;
	slist_estimatedsize = self.size_y / self.font_size_y / 2;
};

void(void) slist_refresh =
{
	float hostcachesize;

	hostcachesize = gethostcachevalue(SLIST_HOSTCACHECOUNT);
	if(slist_start >= hostcachesize)
		slist_start = ceil(hostcachesize - slist_estimatedsize);
	if(slist_start < 0)
		slist_start = 0;
	if(slist_selected >= hostcachesize)
		slist_selected = hostcachesize;
};

void(void) slist_join =
{
	string cname;
	cname = gethostcachestring(SLIST_CNAME, slist_selected);

	if(cname != "")
	{
		cmd("connect ");
		cmd(cname);
		cmd(" ;togglemenu\n");
	}
};

float(float keynr, float ascii ) slist_key =
{
	float listsize;

	if(keynr == K_UPARROW)
	{
		if(slist_selected > 0)
			slist_selected = slist_selected - 1;
		if(slist_start > slist_selected)
			slist_start = slist_selected;
		return TRUE;
	} else if(keynr == K_DOWNARROW)
	{
		listsize = gethostcachevalue(SLIST_HOSTCACHECOUNT);
		if(slist_selected < listsize - 1)
			slist_selected = slist_selected + 1;
		if(slist_start + slist_estimatedsize - 0.5 < slist_selected)
			slist_start = ceil(slist_selected - slist_estimatedsize + 0.5);
		return TRUE;
	} else if(keynr == K_ENTER)
	{
		slist_join();
		return TRUE;
	} else if(keynr == K_SPACE)
	{
		cmd("net_slist\n");
		return TRUE;
	} else if(keynr == K_MOUSE1)
	{
		float pos;

		listsize = gethostcachevalue(SLIST_HOSTCACHECOUNT);
		pos = floor(menu_cursor_y / self.font_size_y / 2);

		 if(pos + slist_start == slist_selected)
			slist_join();
		else if(pos + slist_start < listsize)
			slist_selected = pos;
		return TRUE;
	}
	return FALSE;
};

void(void) slist_info1 =
{
	float query, reply;
	string temp;

	query = gethostcachevalue(SLIST_MASTERQUERYCOUNT);
	reply = gethostcachevalue(SLIST_MASTERREPLYCOUNT);

	strunzone(self.text);

	temp = strcat(ftos(reply), "/");
	temp = strcat(temp, ftos(query), " Master Servers");

	self.text = strzone(temp);
};

void(void) slist_info2 =
{
	float query, reply;
	string temp;

	query = gethostcachevalue(SLIST_SERVERQUERYCOUNT);
	reply = gethostcachevalue(SLIST_SERVERREPLYCOUNT);

	strunzone(self.text);

	temp = strcat(ftos(reply), "/");
	temp = strcat(temp, ftos(query), " Game Servers");

	self.text = strzone(temp);
};

/////////////////
// options.menu
///

// player options
var entity mlist_list = null_entity;
entity mlist_current;
string mlist_saved;

string player_name;

string player_model_cvar = "player_model";
string player_name_cvar = "_cl_name";
string player_skin_cvar = "player_skin";
string player_fov_cvar = "player_fov";

void(void) nex_player_init =
{
	entity ent;

	if( mlist_saved )
		strunzone( mlist_saved );
	mlist_saved = strzone( str_cvar( player_model_cvar ) );

	ent = menu_getitem( "options_player_opt_playername_switch" );
	strunzone( ent.text );
	ent.text = strzone( str_cvar( player_name_cvar ) );
};

void(void) nex_player_name =
{
	player_name = self.text;
};

void(void) nex_player_apply =
{
	cvar_set( player_model_cvar, mlist_current.picture_selected );
	cvar_set( player_skin_cvar, mlist_current.picture_pressed );

	cmd( strcat( "name ", player_name, "\n" ) );
};

// name = name
// picture_selected = model name
// picture_pressed = skin name
// picture = picture
// text = desc text
void(entity e) _nex_player_remove =
{
	strunzone( e.name );
	strunzone( e.picture_selected );
	strunzone( e.picture_pressed );
	strunzone( e.picture );
	strunzone( e.text );

	remove( e );
};

void() _nex_player_model_update =
{
	entity item;

	if( !mlist_list )
		return;

	item = menu_getitem( "options_player_model_name" );
	item.text = mlist_current.name;

	item = menu_getitem( "options_player_model_picture" );
	item.picture = mlist_current.picture;

	item = menu_getitem( "options_player_model_info" );
	item.text = mlist_current.text;
};

/*
.mdef file format
name
picture\n
skin filename\n
model filename\n
rest text*/
void(void) nex_player_buildlist =
{
	local float shandle;
	local float count;
	local float counter;
	local float loaded;
	local entity hit;

	// remove the old player list
	if( mlist_list ) {
		entity node;

		// save the old selected model
		mlist_saved = strzone( mlist_current.name );

		node = mlist_list;
		while( node._next ) {
			node = node._next;
			_nex_player_remove( node._prev );
		}
		_nex_player_remove( node );

		mlist_list = mlist_current = null_entity;
	}

	shandle = search_begin( "models/player/*.txt", false, true );
	if( shandle < 0 )
		return;

	count = search_getsize( shandle );
	mlist_list = mlist_current = spawn();
	hit = null_entity;
	loaded = 0;
	for ( counter = 0 ; counter < count ; counter = counter + 1 ) {
		local string dname;
		local string dpicture;
		local string dskin;
		local string dmodel;
		local string dtext;

		local float handle;

		handle = fopen( search_getfilename( handle, counter ), FILE_READ );

		if( handle < 0 )
			continue;

		dname = strzone( fgets( handle ) );
		dpicture = strzone( fgets( handle ) );
		dskin = strzone( fgets( handle ) );
		dmodel = strzone( fgets( handle ) );
		{
			local string temp, old;
			dtext = strzone( "" );
			do {
				old = dtext;
				temp = fgets( handle );
				dtext = strzone( strcat( old, temp, "\n" ) );
				strunzone( old );
			} while( temp );
		}

		if( !dname || !dpicture || !dskin || !dmodel || !dtext ) {
			print( "Bad model definition file '", search_getfilename( shandle, counter ), "'\n" );

			strunzone( dname );
			strunzone( dpicture );
			strunzone( dskin );
			strunzone( dmodel );

			fclose( handle );
			continue;
		}

		// is this the previous selected model?
		if( dname == mlist_saved )
			hit = mlist_current;

		mlist_current.name = dname;
		mlist_current.picture = dpicture;
		mlist_current.picture_pressed = dskin;
		mlist_current.picture_selected = dmodel;
		mlist_current.text = dtext;

		loaded = loaded + 1;

		mlist_current._next = spawn();
		mlist_current._next._prev = mlist_current;
		mlist_current = mlist_current._next;

		fclose( handle );
	}
	mlist_current._prev._next = null_entity;
	remove( mlist_current );

	search_end( shandle );

	if( loaded == 0 ) {
		print( "No model description files found in models/player\n" );
		mlist_list = mlist_current = null_entity;
	} else
		print( ftos( loaded ), " model description files loaded from models/player\n" );

	if( hit )
		mlist_current = hit;
	else
		mlist_current = mlist_list;

	_nex_player_model_update();
};

void(void) nex_player_model_next =
{
	if( mlist_current._next )
		mlist_current = mlist_current._next;
	_nex_player_model_update();
};

void(void) nex_player_model_prev =
{
	if( mlist_current._prev )
		mlist_current = mlist_current._prev;
	_nex_player_model_update();
};

void(void) nex_player =
{
	entity ent;
	ent = menu_getitem("options_player");
	nex_makeonlyvisible( ent );
	menu_jumptowindow(ent, false);
};

// old/other options

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
	ent = menu_getitem("options_sound");
	nex_makeonlyvisible( ent );
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
	ent = menu_getitem("options_cc");
	nex_makeonlyvisible( ent );
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

// key control stuff
void(void) nex_cntrl =
{
	entity ent;
	ent = menu_getitem("options_control");
	nex_makeonlyvisible( ent );
	menu_jumptowindow(ent, false);
}

const float NUMKEYS = 2;	// visible key count (first and secondary key)
string bindcommand;

void(float keynr, float ascii) nex_con_keyhook =
{
	entity ent;

	//dprint("nex_con_keyhook called !\n");

	if(keynr != K_ESCAPE)
	{
		string tmp;
		tmp = bind_getkeylist(bindcommand);
		// remove the binds if we need more space
		bind_limitbinds(NUMKEYS - 1, bindcommand);
		// bind the new key
		bind_bindkey(bind_getstringforkey(keynr), bindcommand);
	}

	ent = menu_getitem("options_control_statemsg1");
	ent.value = 0;

	ent = menu_getitem("options_control_statemsg2");
	ent.value = 0;

	menu_keyhook = null_function;
};

void(void) nex_con_action_key =
{
	entity ent;

	bindcommand = self.link;

	//dprint("action called");

	menu_keyhook = nex_con_keyhook;

	ent = menu_getitem("options_control_statemsg1");
	ent.value = 1;

	ent = menu_getitem("options_control_statemsg2");
	ent.value = 1;
};

float(float keynr, float ascii) nex_con_key =
{
	if(keynr == K_DEL)
	{
		// the user wants to unbind this action
		//dprint("Removing binds for '", self.link,"'\n");
		bind_limitbinds(0, self.link);
		return true;
	}

	return false;
};

void(void) nex_con_update_keys =
{
	entity ent;
	string keystr;
	float num;

	if(!self._child)
		return;

	keystr = strzone(bind_getkeylist(self.link));

	num = 0;

	for(ent = self._child; ent != null_entity; ent = ent._next)
	{
		float keynr;

		keynr = stof(getaltstring(num, keystr));

		strunzone(ent.text);

		if(keynr == -1 )
			ent.text = strzone("-");
		else
			ent.text = strzone(bind_getstringforkey(keynr));

		num = num + 1;
	}

	strunzone(keystr);
};

var float numkey = 0;
void(void) CONTROL_KEY =
{
	entity key1, key2, desc;
	entity temp_desc, temp_key;

	temp_desc = menu_getitem("control_desc_template");
	temp_key = menu_getitem("control_key_template");

	desc = spawn();
	copyentity(temp_desc, desc);

	key1 = spawn();
	copyentity(temp_key, key1);

	key2 = spawn();
	copyentity(temp_key, key2);

	desc.name = self.text;
	key1.name = strzone(strcat(self.text, " key1"));
	key2.name = strzone(strcat(self.text, " key2"));

	desc.pos_y = key1.pos_y = key2.pos_y = temp_desc.pos_y * numkey;
	key2.pos_x = 2 * key2.pos_x;

	desc.text = self.text;
	desc.link = self.link;

	key1.text = strzone("-");
	key2.text = strzone("-");

	desc.alignment = 0;

	// set the parents
	desc.parent = "options_control";
	desc._parent = menu_getitem("options_control");

	key1.parent = key2.parent = desc.name;
	key1._parent = key2._parent = desc;

	//eprint(key1);
	//eprint(key2);
	//eprint(desc);

	numkey = numkey + 1;
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

void(void)  nex_main_exit =
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

void(void)  dorestart =
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