// NG-Menu
// util/altstring.qc

#ifdef UTILALTSTRING
/*
===================
Util_GetAltStringCount
===================
*/
float( string pStr )	Util_GetAltStringCount =
{
	local float lLength;
	local float lCount;
	local float lPosition;
	local string lLetter;

	lPosition = lCount = 0;
	for( lLength = strlen( pStr ) ; lPosition < lLength ; lPosition++ ) {
		lLetter = substring( pStr, lPosition, 1 );
		if( lLetter == "'" )
			lCount++;
		else if( lLetter == "\\" )
			lPosition++;
	}

	return floor( lCount / 2 );
};

/*
===================
Util_GetAltStringItem
===================
*/
string( string pStr, float pCount ) Util_GetAltStringItem =
{
	local float lCount;
	local float lPosition;
	local float lLength;
	local string lLetter;
	local string lOut;

	pCount = pCount*2 + 1; // number of ' until item starts
	lCount = lPosition = 0;
	for( lLength = strlen( pStr ) ; lPosition < lLength && lCount < pCount ; lPosition++ ) {
		lLetter = substring( pStr, lPosition, 1 );

		if( lLetter == "'" )
			lCount = lCount + 1;
		else if( lLetter == "\\" )
			lPosition++;
	}

	if( lCount != pCount )
		return String_Create();

	for( lOut = "" ; lPosition < lLength ; lPosition++ ) {
		lLetter = substring( pStr, lPosition, 1 );

		if( lLetter == "'" )
			break;
		else if( lLetter == "\\" ) {
			lPosition++;
			if( lPosition >= lLength )
				break;
			lLetter = substring( pStr, lPosition, 1 );
		}

		// no need for strzone since there are 16 buffers and we use 2 in the for
		lOut = strcat( lOut, lLetter );
	}

	return String_Zone( lOut ); // return a strzoned string
};
#else
float( string pStr )	Util_GetAltStringCount =
{
	return altstr_count( pStr );
};
string( string pStr, float pCount ) Util_GetAltStringItem =
{
	return String_Zone( altstr_get( pStr, pCount ) );
};
#endif


/*
===================
Util_SetAltStringItem
===================
*/
#ifdef UTILALTSTRING
string( string pAlt, float pIndex, string pSet ) Util_SetAltStringItem =
{
	local float lCount;
	local float lPosition;
	local float lStart;
	local float lLength;
	local string lLetter;
	local string lOut;

	pSet = String_Zone( pSet );

	pIndex = pIndex*2 + 1; // number of ' until item starts
	lCount = lPosition = 0;
	for( lLength = strlen( pAlt ) ; lPosition < lLength && lCount < pIndex ; lPosition = lPosition + 1 ) {
		lLetter = substring( pAlt, lPosition, 1 );

		if( lLetter == "'" )
			lCount = lCount + 1;
		else if( lLetter == "\\" )
			lPosition = lPosition + 1;
	}

	if( lCount != pIndex )
		return pAlt;

	lStart = lPosition;
	// find the end of it
	for( ; lPosition < lLength ; lPosition++ ) {
		lLetter = substring( pAlt, lPosition, 1 );

		if( lLetter == "'" )
			break;
		else if( lLetter == "\\" )
			lPosition = lPosition + 1;
	}

	lOut = String_Substring( pAlt, 0, lStart );
	pSet = String_Normal( Util_AltStringPrepare( String_Normal( pSet ) ) );
	lOut = strcat( lOut, pSet, substring( pAlt, lPosition, lLength - lPosition ) );

	return String_Set( pAlt, lOut );
};
#else
string( string pAlt, float pIndex, string pSet ) Util_SetAltStringItem =
{
	return String_Set( pAlt, altstr_set( pAlt, pIndex, pSet ) );
};
#endif

/*
===================
Util_DelAltStringItem
===================
*/
string( string pAlt, float pIndex ) Util_DelAltStringItem =
{
	local float lCount;
	local float lPosition;
	local float lStart;
	local float lLength;
	local string lLetter;
	local string lOut;

	pIndex = pIndex*2 + 1; // number of ' until item starts
	lCount = lPosition = 0;
	for( lLength = strlen( pAlt ) ; lPosition < lLength && lCount < pIndex ; lPosition = lPosition + 1 ) {
		lLetter = substring( pAlt, lPosition, 1 );

		if( lLetter == "'" )
			lCount = lCount + 1;
		else if( lLetter == "\\" )
			lPosition = lPosition + 1;
	}

	if( lCount != pIndex )
		return pAlt;

	lStart = lPosition;
	// find the end of it
	for( ; lPosition < lLength ; lPosition++ ) {
		lLetter = substring( pAlt, lPosition, 1 );

		if( lLetter == "'" )
			break;
		else if( lLetter == "\\" )
			lPosition = lPosition + 1;
	}

	if( lStart > 0 )
		lOut = substring( pAlt, 0, lStart - 1 );
	if( lPosition < lLength - 1)
		lOut = strcat( lOut, substring( pAlt, lPosition + 1, lLength - lPosition - 1) );

	return String_Set( pAlt, lOut );
};

/*
===================
Util_InsAltStringItem
===================
*/
#ifdef UTILALTSTRING
string( string pAlt, float pIndex, string pSet ) Util_InsAltStringItem =
{
	local float lCount;
	local float lPosition;
	local float lLength;
	local string lLetter;
	local string lOut;

	pSet = String_Zone( pSet );

	pIndex = pIndex*2 + 2; // number of ' until item starts
	lCount = lPosition = 0;
	for( lLength = strlen( pAlt ) ; lPosition < lLength && lCount < pIndex ; lPosition = lPosition + 1 ) {
		lLetter = substring( pAlt, lPosition, 1 );

		if( lLetter == "'" )
			lCount = lCount + 1;
		else if( lLetter == "\\" )
			lPosition = lPosition + 1;
	}

	if( lCount != pIndex )
		return pAlt;

	lOut = String_Substring( pAlt, 0, lPosition );
	pSet = String_Normal( Util_AltStringPrepare( String_Normal( pSet ) ) );
	lOut = strcat( lOut, "'", pSet, "'", substring( pAlt, lPosition, lLength - lPosition ) );

	return String_Set( pAlt, lOut );
};
#else
string( string pAlt, float pIndex, string pSet ) Util_InsAltStringItem =
{
	return String_Set( pAlt, altstr_ins( pAlt, pIndex, pSet ) );
};
#endif

/*
===================
Util_AltStringPrepare
===================
*/
#ifdef UTILALTSTRING
string( string pString ) Util_AltStringPrepare =
{
	local string lOut, lChar;
	local float lPos, lLength;

	pString = String_Zone( pString );

	lOut = "";
	lLength = strlen( pString );
	for( lPos = 0; lPos < lLength  ; lPos = lPos + 1 ) {
		lChar = substring( pString, lPos, 1 );
		if( lChar == "'" )
			lChar = "\\'";
		lOut = strcat( lOut, lChar );
	}

	String_Free( pString );
	return String_Zone( lOut );
};
#else
string( string pString ) Util_AltStringPrepare =
{
	return String_Zone( altstr_prepare( pString ) );
};
#endif

/*
===================
Util_AltStringPush
===================
*/
string( string pAlt, string pPush ) Util_AltStringPush =
{
	return String_Set( pAlt, strcat( "'", altstr_prepare( pPush ), "'", pAlt ) );
};

/*
===================
Util_AltStringPushBack
===================
*/
string( string pAlt, string pPush ) 	Util_AltStringPushBack =
{
	return String_Set( pAlt, strcat( pAlt, "'", altstr_prepare( pPush ), "'" ) );
};

/*
===================
Util_GetAltStringTop
===================
*/
string( string pAlt ) Util_GetAltStringTop =
{
	return Util_GetAltStringItem( pAlt, 0 );
};

/*
===================
Util_AltStringPop
===================
*/
string( string pAlt ) Util_AltStringPop =
{
	local float lPos, lCount, lLength;
	local string lChar;

	lCount = 0;
	lLength = strlen( pAlt );
	for( lPos = 0 ; lPos < lLength && lCount < 2 ; lPos++) {
		lChar = substring( pAlt, lPos, 1 );
		if( lChar == "\\" )
			lPos++;
		else if( lChar == "'" )
			lCount++;
	}

	return String_Set( pAlt, substring( pAlt, lPos, lLength - lPos ) ); // no - 1 because this time we dont break after the '
};
