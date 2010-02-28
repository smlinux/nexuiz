void WarpZone_Read(float isnew)
{
	if not(self.enemy)
	{
		self.enemy = spawn();
		self.enemy.classname = "warpzone_from";
	}
	self.classname = "trigger_warpzone";
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
	self.scale = ReadByte() / 16;
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

	// common stuff
	WarpZone_SetUp(self, self.enemy.oldorigin, self.enemy.avelocity, self.oldorigin, self.avelocity);

	// engine currently wants this
	self.avelocity = AnglesTransform_TurnDirectionFR(self.avelocity);
	self.drawmask = MASK_NORMAL;

	// link me
	//setmodel(self, self.model);
	setorigin(self, self.origin);
	setsize(self, self.mins, self.maxs);
}

vector WarpZone_Camera_camera_transform(vector org, vector ang)
{
	// a fixed camera view
	trace_endpos = self.oldorigin;
	makevectors(self.avelocity);
	return self.oldorigin;
}

void WarpZone_Camera_Read(float isnew)
{
	self.classname = "func_warpzone_camera";
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
	self.scale = ReadByte() / 16;
	self.oldorigin_x = ReadCoord();
	self.oldorigin_y = ReadCoord();
	self.oldorigin_z = ReadCoord();
	self.avelocity_x = ReadCoord();
	self.avelocity_y = ReadCoord();
	self.avelocity_z = ReadCoord();

	// engine currently wants this
	self.drawmask = MASK_NORMAL;
	self.camera_transform = WarpZone_Camera_camera_transform;

	// link me
	//setmodel(self, self.model);
	setorigin(self, self.origin);
	setsize(self, self.mins, self.maxs);
}

float warpzone_fixingview;
float warpzone_fixingview_drawexteriormodel;
//float warpzone_fixingview_sidespeed;
//float warpzone_fixingview_forwardspeed;
void WarpZone_Inside()
{
	if(warpzone_fixingview)
		return;
	warpzone_fixingview = 1;
	warpzone_fixingview_drawexteriormodel = cvar("r_drawexteriormodel");
	//warpzone_fixingview_sidespeed = cvar("cl_sidespeed");
	//warpzone_fixingview_forwardspeed = cvar("cl_forwardspeed");
	cvar_set("r_drawexteriormodel", "0");
	//cvar_set("cl_sidespeed", ftos(warpzone_fixingview_sidespeed / 100)); // just keep a bit of it in case player gets stuck
	//cvar_set("cl_forwardspeed", ftos(warpzone_fixingview_forwardspeed / 100)); // just keep a bit of it in case player gets stuck
}

void WarpZone_Outside()
{
	if(!warpzone_fixingview)
		return;
	warpzone_fixingview = 0;
	cvar_set("r_drawexteriormodel", ftos(warpzone_fixingview_drawexteriormodel));
	//cvar_set("cl_sidespeed", ftos(warpzone_fixingview_sidespeed));
	//cvar_set("cl_forwardspeed", ftos(warpzone_fixingview_forwardspeed));
}

float warpzone_saved;
vector warpzone_saved_origin;
vector warpzone_saved_angles;
#ifndef KEEP_ROLL
var float autocvar_cl_rollkillspeed = 10;
#endif
void WarpZone_FixView()
{
	float pd;
	entity e;
	warpzone_saved = 0;
	warpzone_saved_origin = warpzone_fixview_origin;
	warpzone_saved_angles = warpzone_fixview_angles;

#ifndef KEEP_ROLL
	if(autocvar_cl_rollkillspeed)
		R_SetView(VF_CL_VIEWANGLES_Z, input_angles_z * max(0, (1 - frametime * autocvar_cl_rollkillspeed)));
	else
		R_SetView(VF_CL_VIEWANGLES_Z, 0);
#endif

	e = WarpZone_Find(warpzone_fixview_origin, warpzone_fixview_origin);
	if(e)
	{
		warpzone_saved = 1;
		warpzone_fixview_origin = WarpZone_TransformOrigin(e, warpzone_fixview_origin);
		warpzone_fixview_angles = WarpZone_TransformVAngles(e, warpzone_fixview_angles);
		WarpZone_Inside();
	}
	else
		WarpZone_Outside();

	// if we are near any warpzone planes - MOVE AWAY (work around nearclip)
	float nearclip = 2;
	e = WarpZone_Find(warpzone_fixview_origin - '1 1 1' * nearclip, warpzone_fixview_origin + '1 1 1' * nearclip);
	if(e)
	{
		pd = WarpZone_PlaneDist(e, warpzone_fixview_origin);
		if(pd >= 0 && pd < nearclip)
		{
			warpzone_saved = 1;
			warpzone_fixview_origin = warpzone_fixview_origin + e.warpzone_forward * (nearclip - pd);
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

void WarpZone_Init()
{
}

void WarpZone_Shutdown()
{
	WarpZone_Outside();
}
