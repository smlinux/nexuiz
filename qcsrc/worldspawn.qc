entity	lastspawn;

void worldspawn (void)
{
	lastspawn = world;
	BotInit();
	precache_model ("models/player/player.zym");
	precache_model ("models/player/dummy.zym");
	
	precache_model ("models/weapons/w_laser.md3");
	precache_model ("models/weapons/w_uzi.md3");
	precache_model ("models/weapons/w_shotgun.md3");
	precache_model ("models/weapons/w_gl.md3");
	precache_model ("models/weapons/w_electro.md3");
	precache_model ("models/weapons/w_crylink.md3");
	precache_model ("models/weapons/w_nex.md3");
	precache_model ("models/weapons/w_hagar.md3");
	precache_model ("models/weapons/w_rl.md3");
	
	precache_model ("models/sprites/plasmahitwall.spr32");
	precache_model ("models/sprites/muzzleflash.spr32");
	precache_model ("models/sprites/plasmashot.spr32");
	precache_model ("models/sprites/dpexplosion1.spr32");
	precache_model ("models/sprites/dpexplosion2.spr32");
	
	precache_model ("models/grenademodel.md3");
	precache_model ("models/hagarmissile.mdl");
	precache_model ("models/rocketmissile.mdl");
	precache_model ("models/bullet.mdl");
	precache_model ("models/casing.mdl");
	precache_model ("models/beam.mdl");
	
	precache_model ("models/items/g_h1.md3");
	precache_model ("models/items/g_h25.md3");
	precache_model ("models/items/g_h100.md3");
	
	precache_model ("models/items/g_a1.md3");
	precache_model ("models/items/g_a25.md3");
	
	precache_model ("models/weapons/w_uzi.zym");
	precache_model ("models/weapons/w_laser.zym");
	precache_model ("models/weapons/w_shotgun.zym");
	precache_model ("models/weapons/w_gl.zym");
	precache_model ("models/weapons/w_electro.zym");
	precache_model ("models/weapons/w_crylink.zym");
	precache_model ("models/weapons/w_nex.zym");
	precache_model ("models/weapons/w_hagar.zym");
	precache_model ("models/weapons/w_rl.zym");
	
	precache_model ("models/items/a_shells.md3");
	precache_model ("models/items/a_cells.md3");
	precache_model ("models/items/a_rockets.md3");
	precache_model ("models/items/a_bullets.zym");
	
	precache_model ("models/items/g_strength.zym");
	precache_model ("models/items/g_invincible.zym");
	precache_model ("models/items/g_slowmo.zym");
	precache_model ("models/items/g_speed.zym");
	
	precache_model ("models/gibs/eye.md3");
	precache_model ("models/gibs/gib1.mdl");
	precache_model ("models/gibs/gib2.mdl");
	precache_model ("models/gibs/gib3.mdl");
	precache_model ("models/gibs/gib4.mdl");
	precache_model ("models/gibs/bloodyskull.md3");

	precache_sound ("weapons/lasergun_fire.wav");
	precache_sound ("weapons/uzi_fire.wav");
	precache_sound ("weapons/shotgun_fire.wav");
	precache_sound ("weapons/grenade_fire.wav");
	precache_sound ("weapons/grenade_impact.wav");
	precache_sound ("weapons/grenade_bounce.wav");
	precache_sound ("weapons/nexfire.wav");
	precache_sound ("weapons/neximpact.wav");
	precache_sound ("weapons/electro_fire.wav");
	precache_sound ("weapons/rocket_Fire.wav");
	precache_sound ("weapons/rocket_impact.wav");
	precache_sound ("weapons/hagar_fire.wav");
	precache_sound ("weapons/hagexp1.wav");
	precache_sound ("weapons/hagexp2.wav");
	precache_sound ("weapons/hagexp3.wav");
	precache_sound ("weapons/ric1.wav");
	precache_sound ("weapons/ric2.wav");
	precache_sound ("weapons/ric3.wav");
	precache_sound ("weapons/weaponpickup.wav");
	precache_sound ("weapons/hyprbf1a.wav");
	precache_sound ("weapons/plasmx1a.wav");
	precache_sound ("weapons/crylink.wav");
	precache_sound ("weapons/gunswitch.wav");
	
	precache_sound ("misc/bodyimpact1.wav");
	precache_sound ("misc/bodyimpact2.wav");
	precache_sound ("misc/teleport.wav");

	precache_sound ("misc/itemrespawn.wav");
	
	precache_sound ("player/hitground1.wav");
	precache_sound ("player/hitground2.wav");
	precache_sound ("demon/dland2.wav");


	//testing
	precache_sound ("1.wav");
	precache_sound ("2.wav");
	precache_sound ("3.wav");
	precache_sound ("4.wav");
	precache_sound ("5.wav");
	precache_sound ("6.wav");

}

void light (void)
{
	makestatic (self);
}