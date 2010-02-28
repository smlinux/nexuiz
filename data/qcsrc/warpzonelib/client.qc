float FL_CAMERA = 8192;
.vector warpzone_transform;
void WarpZone_Read(float isnew)
{
	if not(self.enemy)
	{
		self.enemy = spawn();
		self.enemy.classname = "warpzone_from";
	}
	self.classname = "warpzone_to";
	self.origin_x = ReadCoord();
	self.origin_y = ReadCoord();
	self.origin_z = ReadCoord();
	self.modelindex = ReadShort();
	self.mins_x = ReadCoord();
	self.mins_y = ReadCoord();
	self.mins_z = ReadCoord();
	self.maxs_x = ReadCoord();
	self.maxs_y = ReadCoord();
	self.maxs_z = ReadCoord();
	self.enemy.oldorigin_x = ReadCoord();
	self.enemy.oldorigin_y = ReadCoord();
	self.enemy.oldorigin_z = ReadCoord();
	self.enemy.avelocity_x = ReadCoord();
	self.enemy.avelocity_y = ReadCoord();
	self.enemy.avelocity_z = ReadCoord();
	self.oldorigin_x = ReadCoord();
	self.oldorigin_y = ReadCoord();
	self.oldorigin_z = ReadCoord();
	self.avelocity_x = ReadCoord();
	self.avelocity_y = ReadCoord();
	self.avelocity_z = ReadCoord();

	self.avelocity = AnglesTransform_TurnDirectionFR(self.avelocity);
	self.warpzone_transform = AnglesTransform_Divide(self.avelocity, self.enemy.avelocity);

	self.flags = FL_CAMERA;
	self.drawmask = MASK_NORMAL;

	// link me
	//setmodel(self, self.model);
	setorigin(self, self.origin);
	setsize(self, self.mins, self.maxs);
}

float warpzone_saved;
vector warpzone_saved_origin;
vector warpzone_saved_angles;
void WarpZone_FixView()
{
	entity e;
	float roll;
	warpzone_saved = 0;
	for(e = world; (e = find(e, classname, "warpzone_to")); )
	{
		//print(sprintf("does %s (%s to %s) touch %s?\n", e.model, vtos(e.absmin), vtos(e.absmax), vtos(pmove_org)));
		if(WarpZoneLib_BoxTouchesBrush(pmove_org, pmove_org, e, world))
		{
			warpzone_saved_origin = warpzone_fixview_origin;
			warpzone_saved_angles = warpzone_fixview_angles;
			warpzone_saved = 1;
			roll = warpzone_fixview_angles_z;
			warpzone_fixview_angles_z = 0;
			warpzone_fixview_origin = AnglesTransform_Apply(e.warpzone_transform, warpzone_fixview_origin - e.enemy.oldorigin) + e.oldorigin;
			warpzone_fixview_angles = WarpZone_TransformVAngles(e.warpzone_transform, warpzone_fixview_angles);
			warpzone_fixview_angles_z = roll;
			R_SetView(VF_ORIGIN, warpzone_fixview_origin);
			R_SetView(VF_ANGLES, warpzone_fixview_angles);
			break;
		}
	}
}
void WarpZone_UnFixView()
{
	if(warpzone_saved)
	{
		warpzone_fixview_origin = warpzone_saved_origin;
		warpzone_fixview_angles = warpzone_saved_angles;
		R_SetView(VF_ORIGIN, warpzone_fixview_origin);
		R_SetView(VF_ANGLES, warpzone_fixview_angles);
	}
}
