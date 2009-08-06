//   nebula skybox
//   =============

textures/harlequin_sky/jf-nebula_sky
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

//   Nebula skybox without Surfacelight (ie NO-GLOW)
//   =====================================================

textures/harlequin_sky/jf-nebula_sky_noglow
{
	qer_editorimage textures/harlequin_sky/nebula_qer2.tga
	surfaceparm sky
	surfaceparm noimpact
	surfaceparm nolightmap
	surfaceparm nomarks
	q3map_sun 1 .98 .9 10 0 90
// note: Change the fourth value (100) if you want a brighter or dimmer sun
	skyparms textures/harlequin_sky/env/nebular - -
}

//   ---cut here---

//   asteroid skybox
//   =============

textures/harlequin_sky/jf-asteroid_sky
{
	qer_editorimage textures/harlequin_sky/astr_qer1.tga
	surfaceparm sky
	surfaceparm noimpact
	surfaceparm nolightmap
	q3map_globaltexture
	surfaceparm nomarks
	q3map_surfacelight 50
// note: Change the surfacelight value if you want more ambient light from the sky.
	q3map_sun 1 .98 .9 50 0 90
// note: Change the fourth value (50) if you want a brighter or dimmer sun
	skyparms textures/harlequin_sky/env/astr - -
}

//   Asteroid skybox without Surfacelight (ie NO-GLOW)
//   =====================================================

textures/harlequin_sky/jf-asteroid_sky_noglow
{
	qer_editorimage textures/harlequin_sky/astr_qer2.tga
	surfaceparm sky
	surfaceparm noimpact
	surfaceparm nolightmap
	q3map_globaltexture
	surfaceparm nomarks
	q3map_sun 1 .98 .9 50 0 90
// note: Change the fourth value (50) if you want a brighter or dimmer sun
	skyparms textures/harlequin_sky/env/astr - -
}

//   ---stop cutting here---

//   ---cut here---

//   the Jupiter moon Io
//   ===================

textures/harlequin_sky/jf-io_sky
{
	qer_editorimage textures/harlequin_sky/io_qer1.tga
	surfaceparm sky
	surfaceparm noimpact
	surfaceparm nolightmap
	surfaceparm nomarks
	q3map_surfacelight 300
// note: Change the surfacelight value if you want more ambient light from the sky.
	q3map_sun 1 .9 .8 100 0 90
// note: Change the fourth value (100) if you want a brighter or dimmer sun
	skyparms textures/harlequin_sky/env/io - -
}

//   the Jupiter moon Io without Surfacelight (ie NO-GLOW)
//   =====================================================

textures/harlequin_sky/jf-io_sky_noglow
{
	qer_editorimage textures/harlequin_sky/io_qer2.tga
	surfaceparm sky
	surfaceparm noimpact
	surfaceparm nolightmap
	surfaceparm nomarks
	q3map_sun 1 .9 .8 100 0 90
// note: Change the fourth value (200) if you want a brighter or dimmer sun
	skyparms textures/harlequin_sky/env/io - -
}

//   ---stop cutting here---

//   ---cut here---

//   nebula skybox
//   =============

textures/harlequin_sky/jf-nebula_sky2
{
	qer_editorimage textures/harlequin_sky/nebula_qer1.tga
	surfaceparm sky
	surfaceparm noimpact
	surfaceparm nolightmap
	surfaceparm nomarks
	q3map_surfacelight 10
// note: Change the surfacelight value if you want more ambient light from the sky.
	q3map_sun 1 .98 .9 25 0 90
// note: Change the fourth value (100) if you want a brighter or dimmer sun
	skyparms textures/harlequin_sky/env/nebular - -
}

//   the Imperial Palace Sky
//   =======================

textures/harlequin_sky/jf-palace
{
	qer_editorimage textures/harlequin_sky/palace_qer1.tga
	surfaceparm sky
	surfaceparm noimpact
	surfaceparm nolightmap
	surfaceparm nomarks
	q3map_surfacelight 300
// note: Change the surfacelight value if you want more ambient light from the sky.
	q3map_sun 1 1 1 200 130 50
// note: Change the fourth value (200) if you want a brighter or dimmer sun
	skyparms textures/harlequin_sky/env/palace - -
}

//   the Imperial Palace Sky without Surfacelight (ie NO-GLOW)
//   =========================================================

textures/harlequin_sky/jf-palace_noglow
{
	qer_editorimage textures/harlequin_sky/palace_qer2.tga
	surfaceparm sky
	surfaceparm noimpact
	surfaceparm nolightmap
	surfaceparm nomarks
	q3map_sun 1 1 1 200 130 50
// note: Change the fourth value (200) if you want a brighter or dimmer sun
	skyparms textures/harlequin_sky/env/palace - -
}

//   ---stop cutting here---
