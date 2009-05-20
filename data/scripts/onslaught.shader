ons_shield
{
 {
	map textures/ons_shield.tga
	tcMod rotate 15
	tcMod scale 0.3 0.3
	tcMod scroll 0.03 0.001
	tcGen environment
 }
}

ons_pad_text
{
	cull none
 {
	map textures/ons_text.tga
	tcMod scroll 0.1 0
	blendfunc add

 }
}

ons_icon_text
{
 {
	map textures/ons_text.tga
	tcMod scroll 0.1 0
 }
}

ons_icon_thrust
{
 {
	map textures/ons_icon_thrust.tga
	tcMod scroll 3 0
	tcMod rotate 10
 }
}
ons_gen_spark
{
	cull none
 {
	animmap 9 textures/generator_lightning.tga textures/generator_lightning2.tga
	tcMod scroll 0.5 0
	blendfunc add

 }
}
ons_fire
{
 {
	map textures/ons_boom1.tga
	tcMod scroll 0.05 0.1
	tcMod rotate 0.01
	blendfunc add

 }
}
ons_smoke
{
	deformVertexes wave sin 1 3 2 0.2
 {
	map textures/ons_smoke1.tga
	tcMod scroll 0.01 0.04
	tcMod rotate 0.01
	alphaFunc GE128

 }
}
ons_shockwave
{
	cull none
 {
	map textures/ons_shockwave1.tga
	tcMod scroll 0.2 0
	blendfunc add

 }
}
ons_shockwave2
{
 {
	map textures/ons_shockwave2.tga
	tcMod rotate 85
	tcMod scroll 0.03 0.6
	tcGen environment
	blendfunc add
 }
}

ons_ray
{
cull none
 {
	map textures/ons_ray.tga
	tcMod rotate 85
	blendfunc add
 }
}