entity	lastspawn;

void worldspawn (void)
{
	lastspawn = world;
	BotInit();

	game = cvar ("gamecfg");	// load game options

	if (game & GAME_LOW_GRAVITY)
		localcmd ("sv_gravity 200\n");
	else
		localcmd ("sv_gravity 800\n");

	precache_model ("models/player/player.zym");
	precache_model ("models/player/marine.zym");
	precache_model ("models/player/grunt.zym");
	precache_model ("models/player/specop.zym");
	precache_model ("models/player/pyria.zym");
	precache_model ("models/player/lurk.zym");
	precache_model ("models/player/headhunter.zym");
	precache_model ("models/player/jeandarc.zym");
	precache_model ("models/player/visitant.zym");
	precache_model ("models/player/mulder.zym");
	precache_model ("models/player/insurrectionist.zym");
	precache_model ("models/player/lycanthrope.zym");
	precache_model ("models/player/robot.zym");
	precache_model ("models/player/shock.zym");
	precache_model ("models/player/fshock.zym");

	precache_model ("models/weapons/g_uzi.md3");
	precache_model ("models/weapons/g_shotgun.md3");
	precache_model ("models/weapons/g_gl.md3");
	precache_model ("models/weapons/g_electro.md3");
	precache_model ("models/weapons/g_crylink.md3");
	precache_model ("models/weapons/g_nex.md3");
	precache_model ("models/weapons/g_hagar.md3");
	precache_model ("models/weapons/g_rl.md3");
	
	precache_model ("models/sprites/plasmahitwall.spr32");
	precache_model ("models/sprites/muzzleflash.spr32");
	precache_model ("models/sprites/plasmashot.spr32");
	precache_model ("models/sprites/dpexplosion1.spr32");
	precache_model ("models/sprites/dpexplosion2.spr32");
	precache_model ("models/sprites/bubbles.spr");

	precache_model ("models/grenademodel.md3");
	precache_model ("models/hagarmissile.mdl");
	precache_model ("models/rocketmissile.mdl");
	precache_model ("models/bullet.mdl");
	precache_model ("models/casing.mdl");
	precache_model ("models/beam.mdl");
	precache_model ("models/flash.md3");
	precache_model ("models/laser.mdl");
	precache_model ("models/fire.mdl");
	
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
	precache_model ("models/gibs/gib1.md3");
	precache_model ("models/gibs/gib2.mdl");
	precache_model ("models/gibs/gib3.mdl");
	precache_model ("models/gibs/gib4.mdl");
	precache_model ("models/gibs/bloodyskull.md3");

	precache_sound ("weapons/lasergun_fire.wav");
	precache_sound ("weapons/laserimpact.wav");
	precache_sound ("weapons/uzi_fire.wav");
	precache_sound ("weapons/shotgun_fire.wav");
	precache_sound ("weapons/grenade_fire.wav");
	precache_sound ("weapons/grenade_impact.wav");
	precache_sound ("weapons/grenade_bounce.wav");
	precache_sound ("weapons/nexfire.wav");
	precache_sound ("weapons/neximpact.wav");
	precache_sound ("weapons/electro_fire.wav");
	precache_sound ("weapons/rocket_fire.wav");
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
	precache_sound ("weapons/plasmahit.wav");
	precache_sound ("weapons/uzi_fire_secondary.wav");
	
	precache_sound ("misc/itempickup.wav");
	precache_sound ("misc/bodyimpact1.wav");
	precache_sound ("misc/bodyimpact2.wav");
	precache_sound ("misc/enemyimpact.wav");
	precache_sound ("misc/teleport.wav");
	precache_sound ("misc/megahealth.wav");
	precache_sound ("misc/gib.wav");

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

	// plays music for the level if there is any
	if (self.noise)
	{
        	precache_sound (self.noise);
        	ambientsound ('0 0 0', self.noise, 1.00, ATTN_NONE);
	}

}

void light (void)
{
	makestatic (self);
}