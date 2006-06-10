float max_ups;
vector angle_alive;

void View_Update (void)
{
	vieworg = pmove_org;
	angle_alive = input_angles;
	makevectors(input_angles);

	if(player_flags & PFL_DEAD && !spec)
	{
		R_SetView(VF_ORIGIN, vieworg+'0 0 4');
		angle_alive_z = 80;
		R_SetView(VF_ANGLES, angle_alive);
		R_SetView(VF_CL_VIEWANGLES, angle_alive);
		return;
	}

	if(input_buttons & 16 && !spec)
		vieworg += PL_CROUCH_VIEW_OFS;
	else
		vieworg += PL_VIEW_OFS;

	if(cvar("chase_active") && !spec)
		vieworg = vieworg + v_up * cvar("chase_up") - v_forward * cvar("chase_back");

	R_SetView(VF_ORIGIN, vieworg);
	R_SetView(VF_ANGLES, input_angles);
}
