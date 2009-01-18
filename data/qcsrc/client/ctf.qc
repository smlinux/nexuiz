//include "main.qh"
// NOTE: This file contains lots of debugging stuff
// it is not really used... can be seen as another sample...

string STR_PLAYER = "player";
#define FOR_EACH_PLAYER(v) for(v = world; (v = find(v, classname, STR_PLAYER)) != world; )

string ctf_temp_1;
float order_page;

void() menu_close =
{
	menu_visible = false;
	menu_show = menu_show_error;
	menu_action = menu_sub_null;
	
	/*if(ctf_temp_1)
	  strunzone(ctf_temp_1);*/
	
	localcmd("\nin_bindmap 0 0;");
};

void() order_menu_render =
{
	local vector ps, po;
	local float i, p, n;
	local string frags, color;
	ps = '0 200 0';
	po = '0 8 0';

	color = getplayerkey(player_localentnum-1, "topcolor");
	
	if(getstati(STAT_CTF_STATE) == CTF_STATE_COMMANDER) {
		drawstring(ps, "\x1D\x1E\x1E\x1E\x1E Order Menu \x1E\x1E\x1E\x1E\x1F", '8 8 0', '1 1 0', 1, 0); ps += po;
		drawstring(ps, strcat("Order: ", ctf_temp_1), '8 8 0', '1 1 0', 1, 0); ps += po;
		drawcolorcodedstring(ps, "1) ^3previous page", '8 8 0', 1, 0); ps += po;
		drawcolorcodedstring(ps, "2) ^3next page", '8 8 0', 1, 0); ps += po;
		for((n = 2), (p = i = 0); i < maxclients && n > 0; ++i) {
			frags = getplayerkey(i, "frags");
			if(!frags || (i+1) == player_localentnum)
				continue;
			if(frags == "-666" || getplayerkey(i, "topcolor") != color) // FIXME use GetPlayerTeam
				continue;
			++p;
			if(p > (8*order_page))
			{
				// only render current page
				++n;
				if(n == 10)
					n = 0;
				drawcolorcodedstring(ps, strcat(ftos(n), ") ", GetPlayerName(i), " : ", ftos(getstatf(STAT_CTF_STATE))), '8 8 0', 1, 0); ps += po;
			}
		}
		drawstring(ps, "ESC) Exit Menu", '8 8 0', '1 1 0', 1, 0); ps += po;
	} else {
		menu_close();
	}
};

float(float bInputType, float nPrimary, float nSecondary) order_menu_action =
{
	local string arg;
	local float p, i, n, chose;
	local string frags, color;
	if(bInputType != 0) // key down wanted
		return FALSE;
	
	arg = chr2str(nSecondary);
	chose = stof(chr2str(nPrimary));
	//str2chr
	if(arg == "1") {
		color = getplayerkey(player_localentnum-1, "topcolor");
		++order_page;
		for(p = i = 0; i < maxclients; ++i) {
			frags = getplayerkey(i, "frags");
			if(!frags || (i+1) == player_localentnum)
				continue;
			if(frags == "-666" || getplayerkey(i, "topcolor") != color) // FIXME use GetPlayerTeam
				continue;
			++p;
		}
		if(p <= (8*order_page)) // no ppl on page
			order_page = 0;
	} else if(arg == "2") {
		color = getplayerkey(player_localentnum-1, "topcolor");
		--order_page;
		if(order_page < 0) {
			for(p = i = 0; i < maxclients; ++i) {
				frags = getplayerkey(i, "frags");
				if(!frags || (i+1) == player_localentnum)
					continue;
				if(frags == "-666" || getplayerkey(i, "topcolor") != color) // FIXME use GetPlayerTeam
					continue;
				++p;
			}
			order_page = floor(p/8);
		}
	} else if(chose >= 3 && chose <= 9 || arg == "0") { // the 10 needs extra checking, assuming that stof(astring) returns 0
		if(chose == 0)
			chose = 10;
		n = 2;
		color = getplayerkey(player_localentnum-1, "topcolor");
		for(p = i = 0; i < maxclients && n > 0; ++i) {
			frags = getplayerkey(i, "frags");
			if(!frags || (i+1) == player_localentnum)
				continue;
			if(frags == "-666" || getplayerkey(i, "topcolor") != color) // FIXME use GetPlayerTeam
				continue;
			++p;
			if(p > (8*order_page))
			{
				// only render current page
				++n;
				if(n == chose) {
					n = 0;
					break;
				}
			}
		}
		if(n == 0) {
			//print(strcat("Issuing order to: ", ftos(i+1), "\n"));
			//print(strcat("cmd order #", ftos(i+1), " ", ctf_temp_1, ";\n"));
			localcmd(strcat("\ncmd order #", ftos(i+1), " ", ctf_temp_1, ";"));
		} else {
			print(strcat("Couldn't find player ", ftos(chose), "\n"));
		}
		return TRUE;
	} else if(nSecondary == K_ESCAPE) {
		strunzone(ctf_temp_1);
		menu_close();
	} else {
		//print(strcat("Menu action ", arg, " does not exist.\n"));
		return FALSE;
	}
	return TRUE;
};

void() order_menu_show =
{
	order_page = 0;
	menu_show = order_menu_render;
	menu_action = order_menu_action;
};


void() ctf_menu_render =
{
	local vector ps, po;
	ps = '0 200 0';
	po = '0 8 0';
	
	if(getstati(STAT_CTF_STATE) == CTF_STATE_COMMANDER) {
		drawstring(ps, "\x1D\x1E\x1E\x1E\x1E Command Menu \x1E\x1E\x1E\x1E\x1F", '8 8 0', '1 1 0', 1, 0); ps += po;
		drawstring(ps, "Issue orders:", '8 8 0', '1 1 0', 1, 0); ps += po;
		drawstring(ps, " 1) Attack ", '8 8 0', '1 1 0', 1, 0);
		drawstring(ps + '80 0 0', " \x0F", '8 8 0', '1 1 1', 1, 0); ps += po;
		drawstring(ps, " 2) Defend \x0E", '8 8 0', '1 1 0', 1, 0); ps += po;
		ps += po;
		drawstring(ps, "3) Resign from command.", '8 8 0', '1 1 0', 1, 0); ps += po;
		drawstring(ps, "ESC) Exit Menu", '8 8 0', '1 1 0', 1, 0); ps += po;
	} else {
		menu_close();
	}
};

float(float bInputType, float nPrimary, float nSecondary) ctf_menu_action =
{
	local string arg;
	if(bInputType != 0) // key down wanted
		return FALSE;
	
	arg = chr2str(nSecondary);

	if(arg == "1") {
		ctf_temp_1 = strzone("attack");
		order_menu_show();
	} else if(arg == "2") {
		ctf_temp_1 = strzone("defend");
		order_menu_show();
	} else if(arg == "3") {
		localcmd("\ncmd order resign;");
		menu_close();
	} else if(nSecondary == K_ESCAPE) {
		menu_close();
	} else {
		//print(strcat("Menu action ", arg, " does not exist.\n"));
		return FALSE;
	}
	return TRUE;
};

void() ctf_menu_show =
{
	if(getstati(STAT_CTF_STATE) < 0)
		return;
	menu_show = ctf_menu_render;
	menu_action = ctf_menu_action;
	menu_visible = TRUE;
	//menu_default_binds();
};

void() ctf_view =
{
	local float stat;
	stat = getstati(STAT_CTF_STATE);
	if(stat == CTF_STATE_ATTACK) {
		drawpic('0 0 0', "gfx/ctf_ic_atk.tga", '64 64 0', '1 1 1', 1, 0);
	} else if(stat == CTF_STATE_DEFEND) {
		drawpic('0 0 0', "gfx/ctf_ic_def.tga", '64 64 0', '1 1 1', 1, 0);
	} else if(stat == CTF_STATE_COMMANDER) {
		drawstring('0 0 0', "You're commander!", '8 8 0', '1 1 1', 1, 0);
	} else if(stat < 0) {
	} else {
		drawstring('0 0 0', "Awaiting orders...", '8 8 0', '1 1 1', 0.5, 0);
	}
};
