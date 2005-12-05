// NG-Menu
// base/key.qc

void() Key_Init =
{
};

void() Key_Quit =
{
};

void() Key_Display =
{
	setkeydest( KEY_MENU );
};

void() Key_Update =
{
#ifdef BRAVEMENU
	// make sure that we have the input focus
	setkeydest( KEY_MENU );
#else
	if( getkeydest() != KEY_MENU ) {
		m_hide();
	}
#endif
};

void() Key_Hide =
{
	setkeydest( KEY_GAME );
};

void( string pKey ) Key_Unbind =
{
	cmd( "unbind ", pKey, "\n" );
};

string( float pKey ) Key_GetName =
{
	return keynumtostring( pKey );
};

float( string pKey ) Key_GetNum =
{
	return stringtokeynum( pKey );
};

string( string pCommand ) Key_GetBindList =
{
	return String_Zone( findkeysforcommand( pCommand ) );
};

void(string pKey, string pCommand) Key_Bind =
{
	cmd( "bind \"", pKey, "\" \"", pCommand, "\"\n" );
};

void(float pNum, string pCommand)  Key_LimitBinds =
{
	local string lAltlist;
	local float  lCounter;
	local float  lMaxnum;
	local float  lValue;

	lAltlist = Key_GetBindList( pCommand );
	lMaxnum = Util_GetAltStringCount( lAltlist );

	for( lCounter = 0 ; lCounter < lMaxnum ; lCounter = lCounter + 1 ) {
		lValue = stof( String_Normal( Util_GetAltStringItem( lAltlist, lCounter ) ) );

		if( lValue == -1 )
			break;
		if( lCounter >= pNum )
			Key_Unbind( Key_GetName( lValue ) );
	}

	String_Free( lAltlist );
};

