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