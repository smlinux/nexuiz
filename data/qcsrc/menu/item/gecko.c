// Andreas Kirsch Gecko item (to test it)
#ifdef INTERFACE
CLASS(Gecko) EXTENDS(Item)
	METHOD( Gecko, configureBrowser, void( entity, string ) )
	METHOD( Gecko, draw, void(entity))
	METHOD( Gecko, keyDown, float(entity, float, float, float))
	METHOD( Gecko, keyUp, float(entity, float, float, float))
	METHOD( Gecko, mouseMove, float(entity, vector))
	METHOD( Gecko, mouseDrag, float(entity, vector))
	METHOD( Gecko, resizeNotify, void(entity, vector, vector, vector, vector))
	ATTRIB( Gecko, texturePath, string, string_null )
	ATTRIB( Gecko, textureExtent, vector, '0 0 0')
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
	vector drawSize;
  
	if( me.texturePath ) {
		/* The gecko browser is actually only drawn to a part of the
		   texture. Correct scaling so that part fills up the whole
		   item area. */
		drawSize_x = 1.0 / me.textureExtent_x;
		drawSize_y = 1.0 / me.textureExtent_y;
		draw_Picture( '0 0 0', strcat( "/", me.texturePath ), 
			drawSize, '1 1 1', 1.0 );
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
	if (ascii >= 32)
		return gecko_keyevent( me.texturePath, ascii, GECKO_BUTTON_DOWN );
	else
		return gecko_keyevent( me.texturePath, scan, GECKO_BUTTON_DOWN );
}

float keyUpGecko(entity me, float scan, float ascii, float shift)
{
	if (ascii >= 32)
		return gecko_keyevent( me.texturePath, ascii, GECKO_BUTTON_UP );
	else
		return gecko_keyevent( me.texturePath, scan, GECKO_BUTTON_UP );
}

float mouseMoveGecko(entity me, vector pos)
{
	gecko_mousemove( me.texturePath, pos_x, pos_y );
	return 1;
}

float mouseDragGecko(entity me, vector pos)
{
	gecko_mousemove( me.texturePath, pos_x, pos_y );
	return 1;
}

void resizeNotifyGecko(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	resizeNotifyItem(me, relOrigin, relSize, absOrigin, absSize);
	gecko_resize( me.texturePath, absSize_x, absSize_y );
	me.textureExtent = gecko_get_texture_extent( me.texturePath );
}

string toStringGecko(entity me)
{
	return me.texturePath;
}

#endif
