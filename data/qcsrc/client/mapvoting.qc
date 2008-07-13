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

void MapVote_DrawMapItem(vector pos, float isize, string map, string pic, float count, float id)
{
	vector img_size;
	//img_size_x = img_size_y = isize;
	img_size_y = isize;
	img_size_x = isize / 0.75; // 4:3 x can be stretched easily, height is defined in isize

	drawpic(pos, pic, img_size, '1 1 1', 1, DRAWFLAG_NORMAL);

	// half size for the impulse number
	img_size_x = img_size_y = isize*0.5;
	pos_y += img_size_y*0.5;

	if(id == mv_ownvote)
		drawstring(pos - '40 0', strcat(ftos(id+1), "."), img_size, '1 1 0', 1, DRAWFLAG_NORMAL);
	else
		drawstring(pos - '40 0', strcat(ftos(id+1), "."), img_size, '1 1 1', 1, DRAWFLAG_NORMAL);

	// half again for the mapname
	img_size = img_size * 0.5; // *= broken???
	pos_y += img_size_y*0.5;
	pos_x += isize/0.75 + 10;

	if(mv_detail)
		drawstring(pos, strcat(ftos(count), " : ", map), img_size, '1 1 1', 1, DRAWFLAG_NORMAL);
	else
		drawstring(pos, map, img_size, '1 1 1', 1, DRAWFLAG_NORMAL);
}

void MapVote_DrawMapNotAvailable(vector pos, float isize, string map, float count, float id)
{
	vector img_size, a, b;
	img_size_y = isize;
	img_size_x = isize / 0.75;

	a_x = img_size_x; // for the lines
	b_y = img_size_y;
	drawfill(pos, img_size, '.5 .5 .5', .7, DRAWFLAG_NORMAL);
	drawline(2, pos, pos + a, '1 1 1', 1, DRAWFLAG_NORMAL);
	drawline(2, pos, pos + b, '1 1 1', 1, DRAWFLAG_NORMAL);
	drawline(2, pos + img_size, pos + a, '1 1 1', 1, DRAWFLAG_NORMAL);
	drawline(2, pos + img_size, pos + b, '1 1 1', 1, DRAWFLAG_NORMAL);

	img_size_x = img_size_y = isize*0.5;
	pos_y += img_size_y*0.5;

	if(id == mv_ownvote)
		drawstring(pos - '40 0', strcat(ftos(id+1), "."), img_size, '1 1 0', 1, DRAWFLAG_NORMAL);
	else
		drawstring(pos - '40 0', strcat(ftos(id+1), "."), img_size, '1 1 1', 1, DRAWFLAG_NORMAL);
	
	img_size = img_size * 0.5; // *= broken???
	pos_y += img_size_y*0.5;
	pos_x += isize/0.75 + 10;

	if(mv_detail)
		drawstring(pos, strcat(ftos(count), " : ", map), img_size, '1 1 1', 1, DRAWFLAG_NORMAL);
	else
		drawstring(pos, map, img_size, '1 1 1', 1, DRAWFLAG_NORMAL);
}

void MapVote_DrawAbstain(vector pos, float isize, float count, float id)
{
	vector img_size;
	img_size_y = isize;
	img_size_x = isize / 0.75;

	img_size_x = img_size_y = isize*0.5;
	pos_y += img_size_y*0.5;

	if(id == mv_ownvote)
		drawstring(pos - '40 0', strcat(ftos(id+1), "."), img_size, '1 1 0', 1, DRAWFLAG_NORMAL);
	else
		drawstring(pos - '40 0', strcat(ftos(id+1), "."), img_size, '1 1 1', 1, DRAWFLAG_NORMAL);
	
	img_size = img_size * 0.5; // *= broken???
	pos_y += img_size_y*0.5;
	pos_x += isize/0.75 + 10;

	if(mv_detail)
		drawstring(pos, strcat(ftos(count), " : Don't care"), img_size, '1 1 1', 1, DRAWFLAG_NORMAL);
	else
		drawstring(pos, "Don't care", img_size, '1 1 1', 1, DRAWFLAG_NORMAL);
}

void MapVote_Draw()
{
	string map;
	float i, tmp;
	vector pos;
	vector center;
	float isize;
	
	center_x = (vid_conwidth - 1)/2;
	xmin = vid_conwidth*0.2;
	xmax = vid_conwidth - xmin;
	ymin = 24;
	i = cvar("con_chatpos"); //*cvar("con_chatsize");
	if(i < 0)
		ymax = vid_conheight + (i - cvar("con_chat")) * cvar("con_chatsize");
	if(i >= 0 || ymax < (vid_conheight*0.5))
		ymax = vid_conheight - ymin;

	drawfont = sbar_font;
	sbar_fontsize = stov(cvar_string("sbar_fontsize"));
	if(sbar_fontsize_x == 0)
		sbar_fontsize = '8 8 0';
	if(sbar_fontsize_y == 0)
		sbar_fontsize_y = sbar_fontsize_x;

	pos_y = ymin;
	pos_z = 0;
	pos_x = center_x - stringwidth("Vote for a map", false) * 0.5 * 24;
	drawstring(pos, "Vote for a map", '24 24', '1 1 1', 1, DRAWFLAG_NORMAL);

	pos_x = xmin;
	pos_y += 32;
	isize = (ymax - ymin - mv_num_maps*10) / mv_num_maps;
	isize = min(isize, 64);
	for(i = 0; i < (mv_num_maps - mv_abstain); ++i) // - mv_abstain safe? make sure it's 0 or 1
	{
		tmp = mv_votes[i]; // FTEQCC bug: too many array accesses in the function call screw it up
		if(tmp < 0)
			continue;
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
		//print(strcat("^2Exists... ", pic, "\n"));
		mv_preview[id] = true;
		return;
	}
	MapVote_CheckPK3(pic, pk3, id);
}

void MapVote_Init()
{
	float i;
	string map, pk3;
	
	mv_num_maps = min(MAPVOTE_COUNT, ReadByte());
	mv_abstain = ReadByte();
	if(mv_abstain)
		mv_abstain = 1; // must be 1
	mv_detail = ReadByte();
	mv_ownvote = -1;
	
	// Assume mv_pk3list is NULL, there should only be 1 mapvote per round
	mv_pk3list = NULL; // I'm still paranoid!
	
	for(i = 0; i < mv_num_maps; ++i)
	{
		mv_votes[i] = 0;
		map = strzone(ReadString());
		pk3 = strzone(ReadString());
		mv_maps[i] = map;
		mv_pk3[i] = pk3;
		map = strzone(strcat("maps/", map));
		mv_pics[i] = map;

		mv_preview[i] = false;

		//print(strcat("RECV: ", map, " in ", pk3, "\n"));
		MapVote_CheckPic(map, pk3, i);
	}
}

void MapVote_Update()
{
	float i, e;
	for(i = 0; i < mv_num_maps; ++i)
	{
		e = ReadByte();
		mv_votes[i] = ReadByte();
		if(!e)
			mv_votes[i] = -1;
	}
}

void Net_Mapvote()
{
	float type;
	type = ReadByte();
	switch(type)
	{
	case MAPVOTE_NET_INIT:
		MapVote_Init();
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
		//print(strcat("MAPVOTE_NET_PIC: ^2", ftos(type), "\n"));
		break;
	}
}
