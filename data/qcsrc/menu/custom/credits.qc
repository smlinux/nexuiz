// Property of Alientrap/AK
// custom/credits.qc

void() Item_Nex_Credits_Spawn =
{
	local float lFile;
	local string lText, lLine;

	lFile = fopen( self.target, FILE_READ );
	if( lFile < 0 ) {
		// shut up
		Menu_DeleteAfterToggle( self );
		return;
	}

	lText = String_Create();
	do {
		lLine = fgets( lFile );
		lText = String_Append( lText, strcat( lLine, "\n" ) );
	} while( validstring( lLine ) );
	self.text = lText;
	fclose( lFile );

	Item_MultiLabel_Spawn();
	String_Free( lText );
};
