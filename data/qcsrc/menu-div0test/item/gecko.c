// Andreas Kirsch Gecko item (to test it)
#ifdef INTERFACE
CLASS(Gecko) EXTENDS(Item)
	METHOD( Gecko, configureBrowser, void( entity, string ) )
	METHOD( Gecko, draw, void(entity))
	METHOD( Gecko, keyDown, float(entity, float, float, float))
	METHOD( Gecko, keyUp, float(entity, float, float, float))
	METHOD( Gecko, mouseMove, float(entity, vector))
	METHOD( Gecko, mousePress, float(entity, vector))
	METHOD( Gecko, mouseDrag, float(entity, vector))
	METHOD( Gecko, mouseRelease, float(entity, vector))
	ATTRIB( Gecko, texturePath, string, string_null )
ENDCLASS(Item)
#endif

#ifdef IMPLEMENTATION
// define static members
float _gecko_instanceNumber;

void configureBrowserGecko( entity me, string URI ) {
	me.focusable = 1;

	//create a new gecko object if needed
	if( !me.texturePath ) {
		me.texturePath = strzone( strcat( "_dynamic/gecko/menu/",  ftos( _gecko_instanceNumber ) ) );
		_gecko_instanceNumber+=1;
		// TODO: add error checks
		gecko_create( me.texturePath );
	}
	gecko_navigate( me.texturePath, URI );
}

void drawGecko(entity me)
{
	if( me.texturePath ) {
		draw_Picture( '0 0 0', strcat( "/", me.texturePath ), '1 1 0', '1 1 1', 1.0 );
	} else {
		local vector fontsize;
		fontsize_x = fontsize_y = 1.0 / 30.0;
		fontsize_z = 0.0;
		draw_Text( '0 0 0', "Browser not initialized!", fontsize, '1 1 1', 1.0, 0 );
	}
}

float keyDownGecko(entity me, float scan, float ascii, float shift)
{
	if( scan == K_ESCAPE ) {
		return 0;
	}
	return gecko_keyevent( me.texturePath, scan, GECKO_BUTTON_DOWN );
}

float keyUpGecko(entity me, float scan, float ascii, float shift)
{
	return gecko_keyevent( me.texturePath, scan, GECKO_BUTTON_UP );
}

float mouseMoveGecko(entity me, vector pos)
{
	gecko_mousemove( me.texturePath, pos_x, pos_y );
	return 1;
}

float mousePressGecko(entity me, vector pos)
{
	return gecko_keyevent( me.texturePath, K_MOUSE1, GECKO_BUTTON_DOWN );
}

float mouseDragGecko(entity me, vector pos)
{
	gecko_mousemove( me.texturePath, pos_x, pos_y );
	return 1;
}

float mouseReleaseGecko(entity me, vector pos)
{
	return gecko_keyevent( me.texturePath, K_MOUSE1, GECKO_BUTTON_UP );
}

string toStringGecko(entity me)
{
	return me.texturePath;
}

#endif
