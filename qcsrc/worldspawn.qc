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
	
	precache_model ("models/items/g_h1.md3");
	precache_model ("models/items/g_h25.md3");
	precache_model ("models/items/g_h100.md3");
	
	precache_model ("models/items/g_a1.md3");
	precache_model ("models/items/g_a25.md3");
	
	precache_model ("models/weapons/g_uzi.md3");
	precache_model ("models/weapons/g_shotgun.md3");
	precache_model ("models/weapons/g_gl.md3");
	precache_model ("models/weapons/g_electro.md3");
	precache_model ("models/weapons/g_crylink.md3");
	precache_model ("models/weapons/g_nex.md3");
	precache_model ("models/weapons/g_hagar.md3");
	precache_model ("models/weapons/g_rl.md3");
	
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
	precache_sound ("weapons/Hagar_Fire.wav");
	precache_sound ("weapons/hagexp1.wav");
	precache_sound ("weapons/hagexp2.wav");
	precache_sound ("weapons/hagexp3.wav");
	precache_sound ("weapons/ric1.wav");
	precache_sound ("weapons/ric2.wav");
	precache_sound ("weapons/ric3.wav");
	precache_sound ("weapons/WeaponPickup.wav");
	precache_sound ("weapons/hyprbf1a.wav");
	precache_sound ("weapons/plasmx1a.wav");
	precache_sound ("weapons/crylink.wav");
	
	precache_sound ("misc/BodyImpact1.wav");
	precache_sound ("misc/BodyImpact2.wav");
	precache_sound ("misc/Teleport.wav");

	precache_sound ("misc/ItemRespawn.wav");
	
	precache_sound ("player/HitGround1.wav");
	precache_sound ("player/HitGround2.wav");
	precache_sound ("demon/dland2.wav");
}

void light (void)
{
	makestatic (self);
}