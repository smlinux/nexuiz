//   nebula skybox
//   =============

textures/skies/blacksky
{
	qer_editorimage textures/harlequin_sky/nebula_qer1.tga
	surfaceparm sky
	surfaceparm noimpact
	surfaceparm nolightmap
	surfaceparm nomarks
	q3map_surfacelight 50
// note: Change the surfacelight value if you want more ambient light from the sky.
	q3map_sun 1 .98 .9 100 0 90
// note: Change the fourth value (100) if you want a brighter or dimmer sun
	skyparms textures/harlequin_sky/env/nebular - -
}