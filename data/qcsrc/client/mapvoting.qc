float mv_num_maps;

string mv_maps[MAPVOTE_COUNT];
string mv_pics[MAPVOTE_COUNT];
string mv_pk3[MAPVOTE_COUNT];
float mv_preview[MAPVOTE_COUNT];
float mv_votes[MAPVOTE_COUNT];
entity mv_pk3list;
float mv_abstain;
float mv_ownvote;
float mv_detail;
float mv_timeout;

// TODO: First the text, then the image above it, centered
void MapVote_DrawMapItem(vector pos, float isize, string map, string pic, float count, float id)
{
	vector img_size;
	vector rgb;
	string label;
	float text_size;
	
	if(id == mv_ownvote)
		rgb = '1 1 0';
	else
		rgb = '1 1 1';
	
	isize -= sbar_fontsize_y; // respect the text when calculating the image size
	
	img_size_y = isize;
	img_size_x = isize / 0.75; // 4:3 x can be stretched easily, height is defined in isize

	drawfont = sbar_font;
	pos_y = pos_y + img_size_y;
	
	if(mv_detail)
		label = strcat(ftos(id+1), ". ", ftos(count), ": ", map);
	else
		label = strcat(ftos(id+1), ". ", map);

	text_size = stringwidth(label, false) * sbar_fontsize_x;
	
	pos_x -= text_size*0.5;
	drawstring(pos, label, sbar_fontsize, rgb, 1, DRAWFLAG_NORMAL);
	
	pos_x = pos_x + text_size*0.5 - img_size_x*0.5;
	pos_y = pos_y - img_size_y;
	drawpic(pos, pic, img_size, '1 1 1', 1, DRAWFLAG_NORMAL);
}

void MapVote_DrawMapNotAvailable(vector pos, float isize, string map, float count, float id)
{
	vector img_size, a, b;
	vector rgb;
	string label;
	float text_size;
	
	if(id == mv_ownvote)
		rgb = '1 1 0';
	else
		rgb = '1 1 1';
	
	isize -= sbar_fontsize_y; // respect the text when calculating the image size
	
	img_size_y = isize;
	img_size_x = isize / 0.75; // 4:3 x can be stretched easily, height is defined in isize

	drawfont = sbar_font;
	pos_y = pos_y + img_size_y;
	
	if(mv_detail)
		label = strcat(ftos(id+1), ". ", ftos(count), ": ", map);
	else
		label = strcat(ftos(id+1), ". ", map);

	text_size = stringwidth(label, false) * sbar_fontsize_x;
	
	pos_x -= text_size*0.5;
	drawstring(pos, label, sbar_fontsize, rgb, 1, DRAWFLAG_NORMAL);

	a_x = img_size_x; // for the lines
	b_y = img_size_y;
	
	pos_x = pos_x + text_size*0.5 - img_size_x*0.5;
	pos_y = pos_y - img_size_y;
	
	drawfill(pos, img_size, '.5 .5 .5', .7, DRAWFLAG_NORMAL);
	drawline(2, pos, pos + a, '1 1 1', 1, DRAWFLAG_NORMAL);
	drawline(2, pos, pos + b, '1 1 1', 1, DRAWFLAG_NORMAL);
	drawline(2, pos + img_size, pos + a, '1 1 1', 1, DRAWFLAG_NORMAL);
	drawline(2, pos + img_size, pos + b, '1 1 1', 1, DRAWFLAG_NORMAL);
}

void MapVote_DrawAbstain(vector pos, float isize, float count, float id)
{
	vector img_size;
	vector rgb;
	float text_size;
	string label;
	
	if(id == mv_ownvote)
		rgb = '1 1 0';
	else
		rgb = '1 1 1';

	drawfont = sbar_font;
	pos_y = pos_y + sbar_fontsize_y;
	
	if(mv_detail)
		label = strcat(ftos(id+1), ". ", ftos(count), ": Don't care");
	else
		label = strcat(ftos(id+1), ". Don't care");

	text_size = stringwidth(label, false) * sbar_fontsize_x;
	
	pos_x -= text_size*0.5;
	drawstring(pos, label, sbar_fontsize, rgb, 1, DRAWFLAG_NORMAL);
}

void MapVote_Draw()
{
	string map;
	float i, tmp;
	vector pos;
	float isize;
	float center;
	
	center = (vid_conwidth - 1)/2;
	xmin = vid_conwidth*0.05; // 5% border must suffice
	xmax = vid_conwidth - xmin;
	ymin = 24;
	i = cvar("con_chatpos"); //*cvar("con_chatsize");
	if(i < 0)
		ymax = vid_conheight + (i - cvar("con_chat")) * cvar("con_chatsize");
	if(i >= 0 || ymax < (vid_conheight*0.5))
		ymax = vid_conheight - ymin;

	drawfont = sbar_bigfont;
	sbar_fontsize = stov(cvar_string("sbar_fontsize"));
	if(sbar_fontsize_x == 0)
		sbar_fontsize = '8 8 0';
	if(sbar_fontsize_y == 0)
		sbar_fontsize_y = sbar_fontsize_x;

	pos_y = ymin;
	pos_z = 0;
	pos_x = center - stringwidth("Vote for a map", false) * 0.5 * 24;
	drawstring(pos, "Vote for a map", '24 24 0', '1 1 1', 1, DRAWFLAG_NORMAL);
	pos_y += 26;

	i = ceil(mv_timeout - time);
	map = strcat(ftos(i), " seconds left");
	pos_x = center - stringwidth(map, false) * 0.5 * 16;
	drawstring(pos, map, '16 16 0', '0 1 0', 1, DRAWFLAG_NORMAL);
	pos_y += 22;
	pos_x = xmin;

	drawfont = sbar_bigfont; // FIXME change this to sbar_font when it gets a SANE size later
	
	// base for multi-column stuff...
	ymin = pos_y;
	if(mv_num_maps > 5)
	{
		//xmax = 0.5*(xmax - xmin);
		isize = (ymax - pos_y - mv_num_maps*10) / floor(0.5*mv_num_maps); // or ceil?
		pos_x = xmin + 0.25*(xmax-xmin);
	} else {
		isize = (ymax - pos_y - mv_num_maps*10) / mv_num_maps;
		pos_x = xmin + 0.5*(xmax-xmin);
	}

	ymax -= isize;
	for(i = 0; i < (mv_num_maps - mv_abstain); ++i)
	{
		// base for multi-column stuff
		if(pos_y >= ymax)
		{
			pos_y = ymin;
			pos_x = xmin + 0.75*(xmax-xmin);
			//xmax = 2*xmax - xmin;
			//xmin = pos_x;
		}
		
		tmp = mv_votes[i]; // FTEQCC bug: too many array accesses in the function call screw it up
		if(tmp < 0)
		{
			pos_y += isize + 10;
			continue;
		}
		map = mv_maps[i];
		if(mv_preview[i])
			MapVote_DrawMapItem(pos, isize, map, mv_pics[i], tmp, i);
		else
			MapVote_DrawMapNotAvailable(pos, isize, map, tmp, i);
		pos_y += isize + 10;
	}
	if(mv_abstain && i < mv_num_maps) {
		tmp = mv_votes[i];
		MapVote_DrawAbstain(pos, isize, tmp, i);
	}
}

void Cmd_MapVote_MapDownload(float argc)
{
	float id;
	entity pak;

	if(argc != 2 || !mv_pk3list)
	{
		print("mv_mapdownload: ^3You're not supposed to use this command on your own!\n");
		return;
	}
	
	id = stof(argv(1));
	for(pak = mv_pk3list; pak; pak = pak.chain)
		if(pak.sv_entnum == id)
			break;
	
	if(!pak || pak.sv_entnum != id) {
		print("^1Error:^7 Couldn't find pak index.\n");
		return;
	}

	//print(strcat("^3Adding: ", ftos(id), " - ", pak.message, " - "));
	
	if(PreviewExists(pak.message))
	{
		mv_preview[id] = true;
		//print("^2Found...\n");
		return;
	} else if(csqc_flags & CSQC_FLAG_READPICTURE) {
		print("Requesting preview...\n");
		localcmd(strcat("\ncmd mv_getpic ", ftos(id), "\n"));
	} else {
		print("^3Missing map preview - Update to a newer build to be able to see them.\n");
	}
}

void MapVote_CheckPK3(string pic, string pk3, float id)
{
	entity pak;
	pak = spawn();
	pak.netname = pk3;
	pak.message = pic;
	pak.sv_entnum = id;
	
	pak.chain = mv_pk3list;
	mv_pk3list = pak;
	
	localcmd(strcat("\ncurl --pak ", pk3, "; wait; cl_cmd mv_download ", ftos(id), "\n"));
}

void MapVote_CheckPic(string pic, string pk3, float id)
{
	if(PreviewExists(pic))
	{
		mv_preview[id] = true;
		return;
	}
	MapVote_CheckPK3(pic, pk3, id);
}

void MapVote_Init()
{
	float i, power, m;
	string map, pk3;

	registercmd("+showscores");
	registercmd("-showscores");
	
	mv_num_maps = min(MAPVOTE_COUNT, ReadByte());
	mv_abstain = ReadByte();
	if(mv_abstain)
		mv_abstain = 1; // must be 1 for bool-true, makes stuff easier
	mv_detail = ReadByte();

	mv_ownvote = -1;
	mv_timeout = time + ReadByte();

	if(mv_num_maps <= 8)
		m = ReadByte();
	else
		m = ReadShort();
	
	// Assume mv_pk3list is NULL, there should only be 1 mapvote per round
	mv_pk3list = NULL; // I'm still paranoid!
	
	for(i = 0, power = 1; i < mv_num_maps; ++i, power *= 2)
	{
		mv_votes[i] = 0;

		if(m & power)
		{
			map = strzone(ReadString());
			pk3 = strzone(ReadString());
			mv_maps[i] = map;
			mv_pk3[i] = pk3;
			map = strzone(strcat(config_get("mv_screenshot_dir", "maps"), "/", map));
			mv_pics[i] = map;

			mv_preview[i] = false;

			//print(strcat("RECV: ", map, " in ", pk3, "\n"));
			MapVote_CheckPic(map, pk3, i);
		}
		else
		{
			mv_maps[i] = strzone("if-you-see-this-the-code-is-broken");
			mv_pk3[i] = strzone("if-you-see-this-the-code-is-broken");
			mv_pics[i] = strzone("if-you-see-this-the-code-is-broken");
			mv_preview[i] = false;
		}
	}
}

void MapVote_Update()
{
	float i, power;
	float m;
	if(mv_num_maps <= 8)
		m = ReadByte();
	else
		m = ReadShort();
	for(i = 0, power = 1; i < mv_num_maps; ++i, power *= 2)
	{
		if(m & power)
		{
			if(mv_detail)
				mv_votes[i] = ReadByte();
			else
				mv_votes[i] = 0;
		}
		else
			mv_votes[i] = -1;
	}
}

string Net_ReadPicture();
void Net_Mapvote()
{
	float type;
	type = ReadByte();
	switch(type)
	{
	case MAPVOTE_NET_INIT:
		MapVote_Init();
		// do we NEED this, or can we handle key presses directly in CSQC?
		localcmd("\nin_bind 7 1 \"impulse 1\"; in_bind 7 2 \"impulse 2\"; in_bind 7 3 \"impulse 3\"; in_bind 7 4 \"impulse 4\"; in_bind 7 5 \"impulse 5\"; in_bind 7 6 \"impulse 6\"; in_bind 7 7 \"impulse 7\"; in_bind 7 8 \"impulse 8\"; in_bind 7 9 \"impulse 9\"; in_bind 7 0 \"impulse 10\"; in_bind 7 KP_1 \"impulse 1\"; in_bind 7 KP_2 \"impulse 2\"; in_bind 7 KP_3 \"impulse 3\"; in_bind 7 KP_4 \"impulse 4\"; in_bind 7 KP_5 \"impulse 5\"; in_bind 7 KP_6 \"impulse 6\"; in_bind 7 KP_7 \"impulse 7\"; in_bind 7 KP_8 \"impulse 8\"; in_bind 7 KP_9 \"impulse 9\"; in_bind 7 KP_0 \"impulse 10\"; in_bindmap 7 0\n");
		break;
	case MAPVOTE_NET_UPDATE:
		MapVote_Update();
		break;
	case MAPVOTE_NET_OWNVOTE:
		mv_ownvote = ReadByte()-1;
		break;
	case MAPVOTE_NET_PIC:
		type = ReadByte();
		mv_preview[type] = true;
		mv_pics[type] = strzone(Net_ReadPicture());
		break;
	}
}
