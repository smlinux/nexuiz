
void worldspawn (void)
{
	precache_model ("models/player/player.zym");
	
	precache_model ("models/w_lazer.zym");
	precache_model ("models/w_uzi.md3");
	precache_model ("models/w_shotgun.md3");
	precache_model ("models/w_gl.md3");
	precache_model ("models/w_electro.md3");
	precache_model ("models/w_crylink.md3");
	precache_model ("models/w_nex.md3");
	precache_model ("models/w_hagar.md3");
	precache_model ("models/w_rl.md3");
	
	precache_model ("models/muzzleflash.spr32");
	precache_model ("models/plasmashot.spr32");
	precache_model ("models/dpexplosion.spr32");
	
	precache_model ("models/grenademodel.md3");
	precache_model ("models/hagarmissile.mdl");
	precache_model ("models/rocketmissile.mdl");
	precache_model ("models/bullet.mdl");
	precache_model ("models/casing.mdl");
	
	precache_model ("models/g_h1.md3");
	precache_model ("models/g_h25.md3");
	precache_model ("models/g_h100.md3");
	
	precache_model ("models/g_a1.md3");
	precache_model ("models/g_a25.md3");
	
	precache_model ("models/g_uzi.md3");
	precache_model ("models/g_shotgun.md3");
	precache_model ("models/g_gl.md3");
	precache_model ("models/g_electro.md3");
	precache_model ("models/g_crylink.md3");
	precache_model ("models/g_nex.md3");
	precache_model ("models/g_hagar.md3");
	precache_model ("models/g_rl.md3");
	
	precache_model ("models/a_shells.md3");
	precache_model ("models/a_cells.md3");
	precache_model ("models/a_rockets.md3");
	precache_model ("models/a_bullets.zym");
	
	precache_model ("models/g_strength.zym");
	precache_model ("models/g_invincible.zym");
	precache_model ("models/g_slowmo.zym");
	precache_model ("models/g_speed.zym");
	
	precache_model ("models/eye.zym");
	precache_model ("models/gib1.zym");
	precache_model ("models/gib2.zym");
	precache_model ("models/gib3.zym");
	precache_model ("models/pancres.zym");
	precache_model ("models/bloodyskull.md3");

	precache_sound ("weapons/LazerGun_Fire.wav");
	precache_sound ("weapons/Uzi_Fire.wav");
	precache_sound ("weapons/Shotgun_fire.wav");
	precache_sound ("weapons/Grenade_fire.wav");
	precache_sound ("weapons/Grenade_Impact.wav");
	precache_sound ("weapons/Grenade_Bounce.wav");
	precache_sound ("weapons/NexFire.wav");
	precache_sound ("weapons/NexImpact.wav");
	precache_sound ("weapons/Electro_fire.wav");
	precache_sound ("weapons/Rocket_Fire.wav");
	precache_sound ("weapons/Rocket_Impact.wav");
	precache_sound ("weapons/Hagar_fire.wav");
	precache_sound ("weapons/hagexp1.wav");
	precache_sound ("weapons/hagexp2.wav");
	precache_sound ("weapons/hagexp3.wav");
	precache_sound ("weapons/ric1.wav");
	precache_sound ("weapons/ric2.wav");
	precache_sound ("weapons/ric3.wav");
	precache_sound ("weapons/tink1.wav");
	precache_sound ("weapons/WeaponPickup.wav");
	precache_sound ("weapons/hyprbf1a.wav");
	precache_sound ("weapons/plasmx1a.wav");
	
	precache_sound ("misc/BodyImpact1.wav");
	precache_sound ("misc/BodyImpact2.wav");
	precache_sound ("misc/Teleport.wav");
	
	precache_sound ("player/HitGround1.wav");
	precache_sound ("player/HitGround2.wav");
	precache_sound ("demon/dland2.wav");
}

void light (void)
{
	makestatic (self);
}