float max_ups;
vector angle_alive;

void View_Update (void)
{
	float f;
	string s;

	vieworg = pmove_org;
	angle_alive = input_angles;
	makevectors(input_angles);

	if(player_flags & PFL_DEAD)
	{
		R_SetView(VF_ORIGIN, vieworg+'0 0 4');
		angle_alive_z = 80;
		R_SetView(VF_ANGLES, angle_alive);
		R_SetView(VF_CL_VIEWANGLES, angle_alive);
		return;
	}

	if(input_buttons & 16 && getstati(STAT_HEALTH) != 6666)
		vieworg += PL_CROUCH_VIEW_OFS;
	else
		vieworg += PL_VIEW_OFS;

	if(cvar("chase_active") && getstati(STAT_HEALTH) != 6666)
		vieworg = vieworg + v_up * cvar("chase_up") - v_forward * cvar("chase_back");

	R_SetView(VF_ORIGIN, vieworg);
	R_SetView(VF_ANGLES, input_angles);

	if(!cvar("cg_showvelocity"))
		return;

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
