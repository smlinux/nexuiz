// NG-Menu
// base/gfx.qc

// cvar ngmenu_menu_height
void() gfx_updateres =
{
	Gfx_Real_Width = cvar( "vid_conwidth" );
	Gfx_Real_Height = cvar( "vid_conheight" );
	Gfx_Menu_Width = cvar( CVAR_SCMENU_MENU_WIDTH );
	Gfx_Menu_Height = cvar( CVAR_SCMENU_MENU_HEIGHT );

	if( Gfx_Menu_Width == 0.0 )
		Gfx_Menu_Width = GFX_MENU_DEFAULT_WIDTH;
	if( Gfx_Menu_Height == 0.0 )
		Gfx_Menu_Height = GFX_MENU_DEFAULT_HEIGHT;
};

void() Gfx_Init =
{
	local string lWidth, lHeight;

	lWidth = ftos( GFX_MENU_DEFAULT_WIDTH );
	lHeight = ftos( GFX_MENU_DEFAULT_HEIGHT );

	registercvar( CVAR_SCMENU_MENU_WIDTH, lWidth, CVAR_SAVE );
	registercvar( CVAR_SCMENU_MENU_HEIGHT, lHeight, CVAR_SAVE );

	gfx_updateres();
};

void() Gfx_Quit =
{
};

void() Gfx_Display =
{
	Gfx_ResetClipArea();
};

void() Gfx_Hide =
{
};

void() Gfx_Update =
{
	gfx_updateres();
};

void() Gfx_Draw =
{
};

bool( string pPic )	Gfx_IsCached =
{
	return iscachedpic( pPic );
};

bool( string pPic )	Gfx_Precache =
{
	if( pPic == "" )
		return false;

	if( iscachedpic( pPic ) )
		return true;
	if( precache_pic( pPic ) == pPic )
		return true;
	return false;
};

void( string pPic )	Gfx_Free
{
	// DO NOTHING UNTIL A REF COUNTER IS IMPLEMENTED
};

vector( string pPic ) 	Gfx_GetImageSize
{
	return drawgetimagesize( pPic );
};

vector( vector pPos )  Gfx_ConToMen =
{
	pPos_x = pPos_x * Gfx_Menu_Width / Gfx_Real_Width;
	pPos_y = pPos_y * Gfx_Menu_Height / Gfx_Real_Height;
	pPos_z = 0.0;

	return pPos;
};

vector( vector pPos )  Gfx_MenToCon =
{
	pPos_x = pPos_x * Gfx_Real_Width / Gfx_Menu_Width;
	pPos_y = pPos_y * Gfx_Real_Height / Gfx_Menu_Height;
	pPos_z = 0.0;

	return pPos;
};

void() Gfx_ResetClipArea =
{
	drawresetcliparea();
};

vector( vector pPosition ) _Gfx_FitCenter =
{
	return (pPosition + '0.375 0.375 0');
};

float( vector pPosition, float pCharacter, vector pScale, vector pRGB, float pAlpha, float pFlag )
Gfx_DrawCharacter =
{
	pPosition = _Gfx_FitCenter( Gfx_MenToCon( pPosition ) );
	pScale = Gfx_MenToCon( pScale );

	return drawcharacter( pPosition, pCharacter, pScale, pRGB, pAlpha, pFlag );
};

float( vector pPosition, string pText, vector pScale, vector pRGB, float pAlpha, float pFlag )
Gfx_DrawString =
{
	pPosition = _Gfx_FitCenter( Gfx_MenToCon( pPosition ) );
	pScale = Gfx_MenToCon( pScale );

	return drawstring( pPosition, pText, pScale, pRGB, pAlpha, pFlag );
};

float( vector pPosition, string pPicture, vector pSize, vector pRGB, float pAlpha, float pFlag )
Gfx_DrawPic =
{
	pPosition = _Gfx_FitCenter( Gfx_MenToCon( pPosition ) );
	pSize = Gfx_MenToCon( pSize );

	return drawpic( pPosition, pPicture, pSize, pRGB, pAlpha, pFlag );
};

float( vector pPosition, vector pSize, vector pRGB, float pAlpha, float pFlag )
Gfx_Fill =
{
	pPosition = _Gfx_FitCenter( Gfx_MenToCon( pPosition ) );
	pSize = Gfx_MenToCon( pSize );

	return drawfill( pPosition, pSize, pRGB, pAlpha, pFlag );
};

void( float pX, float pY, float pWidth, float pHeight )
Gfx_SetClipArea =
{
	local vector lPosition, lSize;

	lPosition_x = pX;
	lPosition_y = pY;

	lSize_x = pWidth;
	lSize_y = pHeight;

	lPosition = _Gfx_FitCenter( Gfx_MenToCon( lPosition ) );
	lSize = Gfx_MenToCon( lSize ) + '1 1 0';

	drawsetcliparea( lPosition_x, lPosition_y, lSize_x, lSize_y );
};
