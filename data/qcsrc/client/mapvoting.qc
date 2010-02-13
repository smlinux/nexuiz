float mv_num_maps;

float mv_active;
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
float mv_maps_mask;

vector mv_mousepos;
float mv_selection;

string MapVote_FormatMapItem(float id, string map, float count, float maxwidth, vector fontsize)
{
	string pre, post;
	pre = strcat(ftos(id+1), ". ");
	if(mv_detail)
	{
		if(count == 1)
			post = strcat(" (1 vote)");
		else
			post = strcat(" (", ftos(count), " votes)");
	}
	else
		post = "";
	maxwidth -= stringwidth(pre, FALSE, fontsize) + stringwidth(post, FALSE, fontsize);
	map = textShortenToWidth(map, maxwidth, fontsize, stringwidth_nocolors);
	return strcat(pre, map, post);
}

vector MapVote_RGB(float id)
{
	if(id == mv_ownvote)
		return '0 1 0';
	else if (id == mv_selection)
		return '1 1 0';
	else
		return '1 1 1';
}

void MapVote_DrawMapItem(vector pos, float isize, float tsize, string map, string pic, float count, float id)
{
	vector img_size;
	vector rgb;
	string label;
	float text_size;
	
	isize -= sbar_fontsize_y; // respect the text when calculating the image size

	rgb = MapVote_RGB(id);
	
	img_size_y = isize;
	img_size_x = isize / 0.75; // 4:3 x can be stretched easily, height is defined in isize

	drawfont = sbar_font;
	pos_y = pos_y + img_size_y;
	
	label = MapVote_FormatMapItem(id, map, count, tsize, sbar_fontsize);

	text_size = stringwidth(label, false, sbar_fontsize);
	
	pos_x -= text_size*0.5;
	drawstring(pos, label, sbar_fontsize, rgb, 1, DRAWFLAG_NORMAL);
	
	pos_x = pos_x + text_size*0.5 - img_size_x*0.5;
	pos_y = pos_y - img_size_y;

	pos += sbar_border_thickness * '1 1 0';
	img_size -= (sbar_border_thickness * 2) * '1 1 0';
	if(pic == "")
	{
		drawfill(pos, img_size, '.5 .5 .5', .7, DRAWFLAG_NORMAL);
	}
	else
	{
		drawpic(pos, pic, img_size, '1 1 1', 1, DRAWFLAG_NORMAL);
	}
	
	drawpic(pos + '1 0 0', strcat("gfx/hud/num_", ftos(id+1)), (img_size_y / 5) * '1 1 0', '1 1 1', 0.6, DRAWFLAG_NORMAL);

	if(id == mv_ownvote || pic == "")
	{
		drawborderlines(sbar_border_thickness, pos, img_size, rgb, 1, DRAWFLAG_NORMAL);
		drawpic(pos + '1 0 0', strcat("gfx/hud/num_", ftos(id+1)), (img_size_y / 5) * '1 1 0', rgb, 0.6, DRAWFLAG_NORMAL);
	}
	else
	{
		drawborderlines(sbar_border_thickness, pos, img_size, '0 0 0', 1, DRAWFLAG_NORMAL);
		drawpic(pos + '1 0 0', strcat("gfx/hud/num_", ftos(id+1)), (img_size_y / 5) * '1 1 0', '1 1 1', 0.6, DRAWFLAG_NORMAL);
	}
}

void MapVote_DrawAbstain(vector pos, float isize, float tsize, float count, float id)
{
	vector rgb;
	float text_size;
	string label;
	
	rgb = MapVote_RGB(id);

	drawfont = sbar_font;
	pos_y = pos_y + sbar_fontsize_y;
	
	label = MapVote_FormatMapItem(id, "Don't care", count, tsize, sbar_fontsize);

	text_size = stringwidth(label, false, sbar_fontsize);
	
	pos_x -= text_size*0.5;
	drawstring(pos, label, sbar_fontsize, rgb, 1, DRAWFLAG_NORMAL);
}

vector MapVote_GridVec(vector gridspec, float i, float m)
{
	float r;
	r = mod(i, m);
	return
		'1 0 0' * (gridspec_x * r)
		+
		'0 1 0' * (gridspec_y * (i - r) / m);
}

float MapVote_Selection(vector topleft, vector cellsize, float rows, float columns)
{
	float cell;
	float c, r;

	cell = -1;

	for (r = 0; r < rows; ++r)
		for (c = 0; c < columns; ++c)
		{
			if (mv_mousepos_x >= topleft_x + cellsize_x *  c &&
				mv_mousepos_x <= topleft_x + cellsize_x * (c + 1) &&
				mv_mousepos_y >= topleft_y + cellsize_y *  r &&
				mv_mousepos_y <= topleft_y + cellsize_y * (r + 1))
			{
				cell = r * columns + c;
				break;
			}
		}

	if (cell >= mv_num_maps)
		cell = -1;

	if (mv_abstain && cell < 0)
		return mv_num_maps;

	return cell;
}

void MapVote_Draw()
{
	string map;
	float i, tmp;
	vector pos;
	float isize;
	float center;
	float columns, rows;
	float tsize;
	vector dist;

	if(!mv_active)
		return;
	
	mv_mousepos = mv_mousepos + getmousepos();

	mv_mousepos_x = bound(0, mv_mousepos_x, vid_conwidth);
	mv_mousepos_y = bound(0, mv_mousepos_y, vid_conheight);

	center = (vid_conwidth - 1)/2;
	xmin = vid_conwidth*0.05; // 5% border must suffice
	xmax = vid_conwidth - xmin;
	ymin = 20;
	i = cvar("con_chatpos"); //*cvar("con_chatsize");
	if(i < 0)
		ymax = vid_conheight + (i - cvar("con_chat")) * cvar("con_chatsize");
	if(i >= 0 || ymax < (vid_conheight*0.5))
		ymax = vid_conheight - ymin;

	drawfont = sbar_bigfont;
	sbar_fontsize = Sbar_GetFontsize("sbar_fontsize");

	pos_y = ymin;
	pos_z = 0;
	//pos_x = center - stringwidth("Vote for a map", false) * 0.5 * 24;
	pos_x = center - stringwidth("Vote for a map", false, '12 0 0');
	drawstring(pos, "Vote for a map", '24 24 0', '1 1 1', 1, DRAWFLAG_NORMAL);
	pos_y += 26;

	i = ceil(max(0, mv_timeout - time));
	map = strcat(ftos(i), " seconds left");
	//pos_x = center - stringwidth(map, false) * 0.5 * 16;
	pos_x = center - stringwidth(map, false, '8 0 0');
	drawstring(pos, map, '16 16 0', '0 1 0', 1, DRAWFLAG_NORMAL);
	pos_y += 22;
	pos_x = xmin;

	drawfont = sbar_font;
	
	// base for multi-column stuff...
	ymin = pos_y;
	if(mv_abstain)
		mv_num_maps -= 1;
	
	if(mv_num_maps > 3)
	{
		columns = 3;
	} else {
		columns = mv_num_maps;
	}
	rows = ceil(mv_num_maps / columns);

	dist_x = (xmax - xmin) / columns;
	dist_y = (ymax - pos_y) / rows;
	tsize = dist_x - 10;
	isize = min(dist_y - 10, 0.75 * tsize);

	mv_selection = MapVote_Selection(pos, dist, rows, columns);

	pos_x += (xmax - xmin) / (2 * columns);
	pos_y += (dist_y - isize) / 2;
	ymax -= isize;

	for(i = 0; i < mv_num_maps; ++i)
	{
		tmp = mv_votes[i]; // FTEQCC bug: too many array accesses in the function call screw it up
		if(tmp < 0)
			continue;
		map = mv_maps[i];
		if(mv_preview[i])
			MapVote_DrawMapItem(pos + MapVote_GridVec(dist, i, columns), isize, tsize, map, mv_pics[i], tmp, i);
		else
			MapVote_DrawMapItem(pos + MapVote_GridVec(dist, i, columns), isize, tsize, map, "", tmp, i);
	}

	if(mv_abstain)
		++mv_num_maps;
	
	if(mv_abstain && i < mv_num_maps) {
		tmp = mv_votes[i];
		pos_y = ymax + isize - sbar_fontsize_y;
		pos_x = (xmax+xmin)*0.5;
		MapVote_DrawAbstain(pos, isize, xmax - xmin, tmp, i);
	}

	drawpic(mv_mousepos, strcat("gfx/menu/", cvar_string("menu_skin"), "/cursor.tga"), '32 32 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);
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
	} else {
		print("Requesting preview...\n");
		localcmd(strcat("\ncmd mv_getpic ", ftos(id), "\n"));
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
	
	if(pk3 != "")
	{
		localcmd(strcat("\ncurl --pak ", pk3, "; wait; cl_cmd mv_download ", ftos(id), "\n"));
	}
	else
	{
		Cmd_MapVote_MapDownload(tokenize_console(strcat("mv_download ", ftos(id))));
	}
}

void MapVote_CheckPic(string pic, string pk3, float id)
{
	// never try to retrieve a pic for the "don't care" 'map'
	if(mv_abstain && id == mv_num_maps - 1)
		return;

	if(PreviewExists(pic))
	{
		mv_preview[id] = true;
		return;
	}
	MapVote_CheckPK3(pic, pk3, id);
}

#define NUM_SSDIRS 4
string ssdirs[NUM_SSDIRS];
float n_ssdirs;
void MapVote_Init()
{
	float i, j, power;
	string map, pk3, s;

	precache_sound ("misc/invshot.wav");

	registercmd("+showscores");
	registercmd("-showscores");

	mv_active = 1;

	mv_mousepos = '0.5 0 0' * vid_conwidth + '0 0.5 0' * vid_conheight;
	mv_selection = -1;

	for(n_ssdirs = 0; ; ++n_ssdirs)
	{
		s = ReadString();
		if(s == "")
			break;
		if(n_ssdirs < NUM_SSDIRS)
			ssdirs[n_ssdirs] = s;
	}
	n_ssdirs = min(n_ssdirs, NUM_SSDIRS);

	mv_num_maps = min(MAPVOTE_COUNT, ReadByte());
	mv_abstain = ReadByte();
	if(mv_abstain)
		mv_abstain = 1; // must be 1 for bool-true, makes stuff easier
	mv_detail = ReadByte();

	mv_ownvote = -1;
	mv_timeout = ReadCoord();

	if(mv_num_maps <= 8)
		mv_maps_mask = ReadByte();
	else
		mv_maps_mask = ReadShort();
	
	// Assume mv_pk3list is NULL, there should only be 1 mapvote per round
	mv_pk3list = NULL; // I'm still paranoid!
	
	for(i = 0, power = 1; i < mv_num_maps; ++i, power *= 2)
	{
		mv_votes[i] = 0;

		if(mv_maps_mask & power)
		{
			map = strzone(ReadString());
			pk3 = strzone(ReadString());
			j = bound(0, ReadByte(), n_ssdirs - 1);
	
			mv_maps[i] = map;
			mv_pk3[i] = pk3;
			map = strzone(strcat(ssdirs[j], "/", map));
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

	for(i = 0; i < n_ssdirs; ++i)
		ssdirs[n_ssdirs] = string_null;
	n_ssdirs = 0;
}

float MapVote_InputEvent(float bInputType, float nPrimary, float nSecondary)
{
	float imp;

	if (!mv_active)
		return false;

	if (bInputType != 0)
		return false;

	if ('0' <= nPrimary && nPrimary <= '9')
	{
		imp = nPrimary - '0';
		if (imp == 0) imp = 10;
		localcmd(strcat("\nimpulse ", ftos(imp), "\n"));
		return true;
	}

	if (nPrimary == K_MOUSE1)
		if (mv_selection >= 0)
		{
			imp = min(mv_selection + 1, mv_num_maps);
			localcmd(strcat("\nimpulse ", ftos(imp), "\n"));
			return true;
		}

	return false;
}

void MapVote_UpdateMask()
{
	float i, power;
	float oldmask;

	oldmask = mv_maps_mask;
	if(mv_num_maps <= 8)
		mv_maps_mask = ReadByte();
	else
		mv_maps_mask = ReadShort();

	if(oldmask & mv_maps_mask != oldmask)
		if(oldmask & mv_maps_mask == mv_maps_mask)
			 sound(world, CHAN_AUTO, "misc_invshot.wav", VOL_BASE, ATTN_NONE);

	// remove votes that no longer apply
	for(i = 0, power = 1; i < mv_num_maps; ++i, power *= 2)
		if not(mv_maps_mask & power)
			mv_votes[i] = -1;
}

void MapVote_UpdateVotes()
{
	float i, power;
	for(i = 0, power = 1; i < mv_num_maps; ++i, power *= 2)
	{
		if(mv_maps_mask & power)
		{
			if(mv_detail)
				mv_votes[i] = ReadByte();
			else
				mv_votes[i] = 0;
		}
		else
			mv_votes[i] = -1;
	}

	mv_ownvote = ReadByte()-1;
}

void Ent_MapVote()
{
	float sf;

	sf = ReadByte();

	if(sf & 1)
		MapVote_Init();

	if(sf & 2)
		MapVote_UpdateMask();

	if(sf & 4)
		MapVote_UpdateVotes();
}

void Net_MapVote_Picture()
{
	float type;
	type = ReadByte();
	mv_preview[type] = true;
	mv_pics[type] = strzone(ReadPicture());
}
