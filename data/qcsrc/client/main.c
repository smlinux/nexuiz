void SysParms_UPDATE (void)
{
	float f;

	vid_width = cvar("vid_conwidth");
	vid_height = cvar("vid_conheight");
	makevectors(input_angles);
	pl_view_forward = v_forward;
	pl_view_right = v_right;
	pl_view_up = v_up;
	pl_xyspeed = floor(sqrt(pmove_vel_x*pmove_vel_x + pmove_vel_y*pmove_vel_y));

	f = getstati(STAT_HEALTH);
	spec = (f == -666);
	if(f < 1 && !(player_flags & PFL_DEAD))
		player_flags |= PFL_DEAD;
	else if(f >= 1 && player_flags & PFL_DEAD)
		player_flags -= player_flags & (PFL_DEAD | PFL_GIBBED);
}

void CSQC_Ent_Update (float isnew)
{
	float i;
	i = ReadByte();
}

void CSQC_Ent_Remove ()
{
	remove(self);
};


void CSQC_Init (void)
{
}

void CSQC_Shutdown (void)
{
}

void CSQC_ConsoleCommand (string str)
{
}

void CSQC_UpdateView (void)
{
	SysParms_UPDATE();
	View_Update();

	R_ClearScene();

	R_SetView(VF_DRAWWORLD, 1);

	if(getstati(STAT_HEALTH) == 6666)
	{
		R_SetView(VF_DRAWCROSSHAIR, 0);
		R_SetView(VF_DRAWENGINESBAR, 0);
	}
	else
	{
		R_SetView(VF_DRAWCROSSHAIR, 1);
		R_SetView(VF_DRAWENGINESBAR, 1);
	}

	R_AddEntities(MASK_NORMAL | MASK_ENGINE | MASK_ENGINEVIEWMODELS);
	R_RenderScene();

	if(cvar("cg_showvelocity"))
	{
		local float f;
		local string s;
		f = pl_xyspeed;
		if(max_ups < f)
			max_ups = f;
		s = ftos(f);
		s = strcat(s, " ups");
		drawstring('1 0 0'*vid_width + '-64 64 0', s, '8 8 0', VEC_1, 1, 0);
		s = ftos(max_ups);
		s = strcat(s, " max");
		drawstring('1 0 0'*vid_width + '-64 72 0', s, '8 8 0', VEC_1, 1, 0);
	}
}

float CSQC_InputEvent (float event, float parama)
{
	return false;
}

void CSQC_Parse_StuffCmd (string msg)
{
	// doesn't work, dp obviously doesn't execute csprogs.dat on demo playback
	if(isdemo() && msg == "menu_showteamselect\n")
		return;
	localcmd(msg);
}

void CSQC_Parse_Print (string msg)
{
	print(msg);
}

void CSQC_Parse_CenterPrint (string msg)
{
	cprint(msg);
}
