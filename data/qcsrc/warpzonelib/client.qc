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
	float pd;
	entity e;
	warpzone_saved = 0;
	warpzone_saved_origin = warpzone_fixview_origin;
	warpzone_saved_angles = warpzone_fixview_angles;

	for(e = world; (e = find(e, classname, "warpzone_to")); )
	{
		if(WarpZoneLib_BoxTouchesBrush(warpzone_fixview_origin, warpzone_fixview_origin, e, world))
		{
			warpzone_saved = 1;
			warpzone_fixview_origin = AnglesTransform_Apply(e.warpzone_transform, warpzone_fixview_origin - e.enemy.oldorigin) + e.oldorigin;
			warpzone_fixview_angles = WarpZone_TransformVAngles(e.warpzone_transform, warpzone_fixview_angles);
			break;
		}
	}

	// if we are near any warpzone planes - MOVE AWAY (work around nearclip)
	float nearclip = 2;
	for(e = world; (e = find(e, classname, "warpzone_to")); )
	{
		if(WarpZoneLib_BoxTouchesBrush(warpzone_fixview_origin - '1 1 1' * nearclip, warpzone_fixview_origin + '1 1 1' * nearclip, e, world))
		{
			fixedmakevectors(e.enemy.avelocity);
			pd = (warpzone_fixview_origin - e.enemy.oldorigin) * v_forward;
			if(pd >= 0 && pd < nearclip)
			{
				warpzone_saved = 1;
				warpzone_fixview_origin = warpzone_fixview_origin + v_forward * (nearclip - pd);
				pd = (warpzone_fixview_origin - e.enemy.oldorigin) * v_forward;
			}
		}
	}

	if(warpzone_saved)
	{
		R_SetView(VF_ORIGIN, warpzone_fixview_origin);
		R_SetView(VF_ANGLES, warpzone_fixview_angles);
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
