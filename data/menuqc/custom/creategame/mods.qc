// Property of Alientrap/AK
// custom/creategame/mods.qc

/*
===================
Item_DataLink_Nex_ModSwitch
===================
*/

// first line  filename
// second line mod name
// repeat
void() _IDLNMS_Build =
{
	local float  	lSearchHandle;
	local float 	lSearchSize;
	local float 	lSearchCounter;

	lSearchHandle = search_begin( "*.modinfo", true, true );
	if( lSearchHandle < 0 ) {
		String_EntitySet( self, valueList, "'progs.dat'" );
		String_EntitySet( self, descList, "'Deathmatch'" );
		return;
	}

	lSearchCounter = 0;
	for( lSearchSize = search_getsize( lSearchHandle );
	lSearchCounter < lSearchSize; ++lSearchCounter ) {
		local float 	lHandle;
		local string	lFilename;

		local string	lModName;
		local string	lModPath;
		local string 	lLine;

		lFilename = search_getfilename( lSearchHandle, lSearchCounter );
		lHandle = fopen( lFilename, FILE_READ );
		if( lHandle < 0 ) {
			print( "Menu: Couldn't open modinfo file '", lFilename, "'\n" );
			continue;
		}

		lModPath = String_Create();
		lModName = String_Create();
		while( 1 ) {
			lLine = fgets( lHandle );
			if( !validstring( lLine ) )
				break;

			lModPath = String_Set( lModPath, lLine );

			lLine = fgets( lHandle );
			if( !validstring( lLine ) )
				break;

			lModName = String_Set( lModName, lLine );

			String_EntitySet( self, valueList, strcat( self.valueList, lModPath, " " ) );
			String_EntitySet( self, descList, strcat( self.descList, lModName, " " ) );
		}
		String_Free( lModPath );
		String_Free( lModName );

		fclose( lHandle );
	}

	search_end( lSearchHandle );
};

void() Item_DataLink_Nex_ModSwitch_Spawn =
{
	local string lTemp1, lTemp2;

	String_EntityCreate( self, valueList );
	String_EntityCreate( self, descList );

	_IDLNMS_Build();

	lTemp1 = self.descList;
	lTemp2 = self.valueList;
	Item_DataLink_TextSwitch_Spawn();
	String_Free( lTemp1 );
	String_Free( lTemp2 );
};

