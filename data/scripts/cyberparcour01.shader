//------------------------------------------------------------------------------
// Shaders for the CyberParcour map project by sev
// All editor images are placed in textures/cyberparcour01_shaders/
//------------------------------------------------------------------------------

textures/cyberparcour01_shaders/celshader
{
    qer_editorimage textures/cyberparcour01_shaders/celshader.tga

    q3map_notjunc
    q3map_nonplanar
    q3map_bounce 0.0
    q3map_shadeangle 120
    q3map_texturesize 1 1
    q3map_invert
    q3map_offset -2.0

    surfaceparm nolightmap
    surfaceparm trans
    surfaceparm nonsolid
    surfaceparm nomarks

    {
        map textures/cyberparcour01_textures/black.tga
        rgbGen identity
    }
}

textures/cyberparcour01_shaders/sky
{
        qer_editorimage textures/cyberparcour01_shaders/sky.tga

        surfaceparm sky
        surfaceparm noimpact
        surfaceparm nolightmap
        surfaceparm nodlight
        surfaceparm nomarks

        nopicmip
        nomipmaps

        skyparms env/desert/desert - -
        q3map_sunExt 1 0.975 0.95 300 315 50 0 16
}
