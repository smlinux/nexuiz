		/****************************/
		/*Team:Nexuiz HUD Items Code*/
		/****************************/
.entity grenadeoneentity;
//.entity grenadetwoentity;

void () TeamNexuiz_HUD_GrenThink =
{
	if (self.frame >= 10)
		dremove(self);
	self.frame = self.frame + 1;
	self.nextthink = time + .4;
};

void () TeamNexuiz_HUD_SignThink =
{
	if (self.alpha <= 0)
		dremove(self);
	self.alpha = self.alpha - .2;
	self.nextthink = time + .1;
};

// Displays "No Ammo" sign
// ok this was a dumb idea >.< lets just use csqc
void (entity ownr, float selection) TeamNexuiz_HUD_ShowSign =
{
	precache_model("models/hud_nobul.sp2");
	ownr.grenadeoneentity = spawn();
	ownr.grenadeoneentity.solid = SOLID_NOT;
	ownr.grenadeoneentity.owner = ownr;
	ownr.grenadeoneentity.grenadeoneentity = ownr.grenadeoneentity;
	ownr.grenadeoneentity.think = TeamNexuiz_HUD_SignThink;
	ownr.grenadeoneentity.nextthink = time + 1;
	if (selection == NO_AMMO_WARNING)
		setmodel(ownr.grenadeoneentity, "models/hud_nobul.sp2");
	else if (selection == HUD_PRIME_GREN)
	{
		setmodel(ownr.grenadeoneentity, "models/grentimer.sp2");
		ownr.grenadeoneentity.frame = 2;
		ownr.grenadeoneentity.think = TeamNexuiz_HUD_GrenThink;
		ownr.grenadeoneentity.nextthink = time + .4;
	}
	ownr.grenadeoneentity.scale = .1;
	ownr.grenadeoneentity.alpha = 1;
	ownr.grenadeoneentity.origin = '40 0 0';
	ownr.grenadeoneentity.angles = '0 0 0';
	ownr.grenadeoneentity.viewmodelforclient = ownr;
	ownr.grenadeoneentity.flags = 0;
};