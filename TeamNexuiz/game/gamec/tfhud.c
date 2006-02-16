		/****************************/
		/*Team:Nexuiz HUD Items Code*/
		/****************************/
.entity grenadeoneentity;
//.entity grenadetwoentity;

void () CL_GrenadeOneEntity_Think =
{
	return;
};

// Displays a grenade model on screen for every grenade a player has
// ok this was a dumb idea >.< lets just use csqc
void () TeamNexuiz_HUD_ShowGrenadeOne =
{
	precache_model("models/hud_nobul.sp2");
	self.grenadeoneentity = spawn();
	self.grenadeoneentity.solid = SOLID_NOT;
	self.grenadeoneentity.owner = self;
	self.grenadeoneentity.grenadeoneentity = self.grenadeoneentity;
	setmodel(self.grenadeoneentity, "models/hud_nobul.sp2");
	self.grenadeoneentity.scale = .1;
	self.grenadeoneentity.origin = '40 0 0';
	self.grenadeoneentity.angles = '0 0 0';
	self.grenadeoneentity.viewmodelforclient = self;
	self.grenadeoneentity.flags = 0;
	self.grenadeoneentity.think = CL_GrenadeOneEntity_Think;
	self.grenadeoneentity.nextthink = time;
};