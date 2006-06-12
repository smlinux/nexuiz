// NG-Menu
// base/snd.qc

void( string pText ) _Sound_DPrint =
{
	if( sys_debug_sound )
		print( pText );
};

bool( string pSnd )  Sound_Precache =
{
	_Sound_DPrint( strcat( "Precaching sound '", pSnd, "'\n" ) );
	if( pSnd == "" )
		return false;
	if( pSnd != precache_sound( pSnd ) )
		return false;
	else
		return true;
};

void( string pSnd ) Sound_Free =
{
};

void( string pSnd) Sound_Play =
{
	if( pSnd != "" ) {
		_Sound_DPrint( strcat( "Playing sound '", pSnd, "'\n" ) );
		localsound( pSnd );
	}
};

