///////////////////////////////////////////////
// Graphic Source File
///////////////////////
// This file belongs to dpmod/darkplaces
// AK contains all graphic functions
///////////////////////////////////////////////

void(void) gfx_init =
{
	vid_conwidth = cvar("vid_conwidth");
	vid_conheight = cvar("vid_conheight");
};

void(void) gfx_frame =
{
	vid_conwidth = cvar("vid_conwidth");
	vid_conheight = cvar("vid_conheight");
};

void(void) gfx_toggle =
{
};

void(float keynr, float ascii) gfx_keydown =
{
};

void(void) gfx_draw =
{
};

void(void) gfx_shutdown =
{
};

string(string pic_name, float complain) gfx_loadpic =
{
	string c;
	c = precache_pic(pic_name);

	if(c == "" && complain)
		error("Couldnt precache ", pic_name, " !\n");
	if(c == "")
		dprint("Couldnt precache ", pic_name, " !\n");
	return c;
};

void(string pic_name) gfx_unloadpic =
{
	// FIXME: gfx_unloadpic is a bit buggy in dp at the moment - restart the menu a few times
	// and you get an access violation
	//gfx_unloadpic(pic_name);
};

void(vector position, float character, vector scale, vector rgb, float alpha, float flag)
gfx_drawchar =
{
	float ret;

	position = gfx_converttocon(position);
	scale = gfx_converttocon(scale);

	if(scale == '0 0 0')
		return;

	ret = drawcharacter(position, character, scale, rgb, alpha, flag);

	if(ret == 1)
		return;
	if(ret == ERR_NULLSTRING)
		error("Null character !\n");
	if(ret == ERR_BADDRAWFLAG)
		error("Bad draw flag !\n");
	if(ret == ERR_BADSCALE)
		error("Bad scale !\n");
	error("Unknown error code !\n");
};

void(vector position, string str, vector scale, vector rgb, float alpha, float flag)
gfx_drawstring =
{
	float ret;

	position = gfx_converttocon(position);
	scale = gfx_converttocon(scale);

	if(scale == '0 0 0')
		return;

	ret = drawstring(position, str, scale, rgb, alpha, flag);

	if(ret == 1)
		return;
	if(ret == ERR_NULLSTRING)
		error("Null string !\n");
	if(ret == ERR_BADDRAWFLAG)
		error("Bad draw flag !\n");
	if(ret == ERR_BADSCALE)
		error("Bad scale !\n");
	error("Unknown error code !\n");
};

void(vector position, string pic_name, vector size, vector rgb, float alpha, float flag)
gfx_drawpic =
{
	float ret;

	if(size == '0 0 0')
		size = gfx_getimagesize(pic_name);

	// for FrikQCC
	position = gfx_converttocon(position);
	size = gfx_converttocon(size);

	ret = drawpic(position, pic_name, size, rgb, alpha, flag);

	if(ret == 1)
		return;
	if(ret == ERR_NULLSTRING)
		error("Null string !\n");
	if(ret == ERR_BADDRAWFLAG)
		error("Bad draw flag !\n");
	if(ret == ERR_BADSIZE)
		error("Bad size !\n");
	if(ret == ERR_NOTCACHED)
		error("Picture ", pic_name, " was not precached !\n");
	error("Unknown error code !\n");
};

void(vector position, vector size, vector rgb, float alpha, float flag)
gfx_fillarea =
{
	float ret;

	position = gfx_converttocon(position);
	size = gfx_converttocon(size);

	if(size == '0 0 0')
		return;

	ret = drawfill(position, size, rgb, alpha, flag);

	if(ret == 1)
		return;
	if(ret == ERR_BADDRAWFLAG)
		error("Bad draw flag !\n");
	error("Unknown error code !\n");
};

void(vector position, vector size) gfx_setcliparea =
{
	position = gfx_converttocon(position);
	size = gfx_converttocon(size);
	drawsetcliparea(position_x, position_y, size_x, size_y);
};

void(void) gfx_resetcliparea =
{
	drawresetcliparea();
};

void(vector position, float character, vector scale, vector rgb, float alpha, float flag)
menu_drawchar =
{
	position = gfx_conmentogfx(position);
	gfx_drawchar(position, character, scale, rgb, alpha, flag);
};

void(vector position, string str, vector scale, vector rgb, float alpha, float flag)
menu_drawstring =
{
	position = gfx_conmentogfx(position);
	gfx_drawstring(position, str, scale, rgb, alpha, flag);
}

void(vector position, string pic_name, vector size, vector rgb, float alpha, float flag)
menu_drawpic =
{
	position = gfx_conmentogfx(position);
	gfx_drawpic(position, pic_name, size, rgb, alpha, flag);
};

void(vector position, vector size, vector rgb, float alpha, float flag)
menu_fillarea =
{
	position = gfx_conmentogfx(position);
	gfx_fillarea(position, size, rgb, alpha, flag);
};


void(vector position, vector size) menu_setcliparea =
{
	position = gfx_conmentogfx(position);
	gfx_setcliparea(position, size);
};


void(void) menu_resetcliparea =
{
	gfx_resetcliparea();
};

vector(string pic_name) gfx_getimagesize =
{
	return drawgetimagesize(pic_name);
}

vector(vector vec) gfx_converttogfx =
{
	vector v;
	v_x = vec_x * (GFX_WIDTH / vid_conwidth);
	v_y = vec_y * (GFX_HEIGHT / vid_conheight);
	return v;
};

vector(vector vec) gfx_converttocon =
{
	vector v;
	v_x = vec_x * (vid_conwidth / GFX_WIDTH);
	v_y = vec_y * (vid_conheight / GFX_HEIGHT);
	return v;
};

vector(vector vec) gfx_conmentogfx =
{
	return (vec + menu_localorigin);
};

vector(vector vec) gfx_congfxtomen =
{
	return (vec - menu_localorigin);
};
