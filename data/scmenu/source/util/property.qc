// NG Menu
// util/property.qc

#ifdef DEBUG
	#define DebugValidate(str)	Property_Validate( str )
#else
	#define DebugValidate(str)  	true
#endif

/*
===================
Property_Create
===================
*/
string() Property_Create =
{
	return String_Create();
};

string( string pString ) Property_Zone =
{
	return String_Zone( pString );
};

string( string pString ) Propery_Free =
{
	return String_Free( pString );
};

/*
===================
Property_Validate
===================
*/
bool( string pString ) Property_Validate =
{
	local float lCount;

	lCount = Util_GetAltStringCount( pString );
	// check whether this is a valid property string
	if( rint( lCount / 2 ) != lCount / 2 )
#ifdef STRICTRULES
		error( __FUNC__, "Invalid property string \"", pString , "\"!\n" );
#else
	{
		dprint( __FUNC__, "Invalid property string \"", pString, "\"!\n" );
		return false;
	}
#endif
	return true;
};

/*
===================
Property_Exists
===================
*/
bool( string pString, string pName ) Property_Exists =
{
	local float lCount;
	local float lCounter;

	if( !DebugValidate( pString ) )
		return false;

	lCount = Util_GetAltStringCount( pString );
	for( lCounter = 0 ; lCounter < lCount ; lCounter += 2 )
		if( String_Normal( Util_GetAltStringItem( pString, lCounter ) ) == pName )
			return true;
	return false;
};

/*
===================
Property_Register
===================
*/
string( string pString, string pName, string pInitValue ) Property_Register =
{
	local float lCount;
	local float lCounter;

	if( !DebugValidate( pString ) )
		return pString;

	// If the entry already exists, do nothing (thus exit the function)
	lCount = Util_GetAltStringCount( pString );
	for( lCounter = 0 ; lCounter < lCount ; lCounter += 2 )
		if( String_Normal( Util_GetAltStringItem( pString, lCounter ) ) == pName )
			return pString;

	// If it hasnt been added yet, create it
	pString = Util_AltStringPush( pString, pInitValue );
	pString = Util_AltStringPush( pString, pName );

	return pString;
}

/*
===================
Property_Set
===================
*/
string( string pString, string pName, string pValue ) Property_Set =
{
	local float lCount;
	local float lCounter;

	if( !DebugValidate( pString ) )
		return pString;

	// Found the entry and set it to the new value
	lCount = Util_GetAltStringCount( pString );
	for( lCounter = 0 ; lCounter < lCount ; lCounter += 2 )
		if( String_Normal( Util_GetAltStringItem( pString, lCounter ) ) == pName )
			return Util_SetAltStringItem( pString, lCounter + 1, pValue );

	// If the property isnt found, it depends on DEBUG and STRICT
#ifdef STRICTRULES
	error( __FUNC__, "The property \"", pName, "\" hasn't been declared!\npString = \"", pString, "\"" );
#else
	dprint( __FUNC__, "The property \"", pName, "\" hasn't been declared!\npString = \"", pString, "\"" );
#endif

	return pString;
};

string( string pString, string pOldName, string pNewName ) Property_Rename =
{
	local float lCount;
	local float lCounter;

	if( !DebugValidate( pString ) )
		return pString;

	// Found the entry if it already exists
	lCount = Util_GetAltStringCount( pString );
	for( lCounter = 0 ; lCounter < lCount ; lCounter += 2 )
		if( String_Normal( Util_GetAltStringItem( pString, lCounter ) ) == pOldName )
			return Util_SetAltStringItem( pString, lCounter, pNewName );

	// If the property isnt found, it depends on DEBUG and STRICT
#ifdef STRICTRULES
	error( __FUNC__, "The property \"", pOldName, "\" hasn't been declared!\npString = \"", pString, "\"" );
#else
	dprint( __FUNC__, "The property \"", pOldName, "\" hasn't been declared!\npString = \"", pString, "\"" );
#endif
	return pString;
};

string( string pString, string pName )	Property_Delete =
{
	local float lCount;
	local float lCounter;

	if( !DebugValidate( pString ) )
		return pString;

	// Found the entry if it already exists
	lCount = Util_GetAltStringCount( pString );
	for( lCounter = 0 ; lCounter < lCount ; lCounter += 2 )
		if( String_Normal( Util_GetAltStringItem( pString, lCounter ) ) == pName ) {
			pString = Util_DelAltStringItem( pString, lCounter );
			pString = Util_DelAltStringItem( pString, lCounter );
			return pString;
		}

	// If the property isnt found, it depends on DEBUG and STRICT
#ifdef STRICTRULES
	error( __FUNC__, "The property \"", pName, "\" hasn't been declared!\npString = \"", pString, "\"" );
#else
	dprint( __FUNC__, "The property \"", pName, "\" hasn't been declared!\npString = \"", pString, "\"" );
#endif
	return pString;
};

/*
===================
Property_Set
===================
*/
/*
string( string pString, string pName, string pValue ) 	  Property_Set =
{
	local float lCount;
	local float lCounter;
	local float lProp;

	// save pValue
	pValue = strzone( pValue );

	if( !DebugValidate( pString ) )
		return pString;

	// Found the entry if it already exists
	lCount = Util_GetAltStringCount( pString );
	lProp = -1;
	for( lCounter = 0 ; lCounter < lCount ; lCounter += 2 )
		if( Util_GetAltStringItem( pString, lCounter ) == pName ) {
			lProp = lCounter;
			break;
		}

	// If it hasnt been added yet, create it
	if( lProp == -1 ) {
		pString = Util_AltStringPush( pString, pValue );
		pString = Util_AltStringPush( pString, pName );
	} else
		pString = Util_SetAltStringItem( pString, lProp + 1, pValue );

	strunzone( pValue );
	return pString;
};
*/

/*
===================
Property_Get
===================
*/
string( string pString, string pName )	Property_Get =
{
	local float lCount;
	local float lCounter;

	if( !DebugValidate( pString ) )
		return pString;

	// Found the entry and return its value
	lCount = Util_GetAltStringCount( pString );
	for( lCounter = 0 ; lCounter < lCount ; lCounter += 2 )
		if( String_Normal( Util_GetAltStringItem( pString, lCounter ) ) == pName )
			return Util_GetAltStringItem( pString, lCounter + 1);

	// If the property isnt found, it depends on DEBUG and STRICT
#ifdef STRICTRULES
	error( "The property \"", pName, "\" hasn't been declared!\npString = \"", pString, "\"" );
#else
	dprint( "The property \"", pName, "\" hasn't been declared!\npString = \"", pString, "\"" );
#endif

	return String_Zone( "" );
};

/*
===================
Property_GetString
===================
*/
string( string pString, string pName ) 	Property_GetString =
{
	return Property_Get( pString, pName );
};

/*
===================
Property_GetFloatProperty
===================
*/
float( string pString, string pName ) 	Property_GetFloat =
{
	return stof( String_Normal( Property_Get( pString, pName ) ) );
};

vector( string pString, string pName ) 	Property_GetVector =
{
	return stov( String_Normal( Property_Get( pString, pName ) ) );
};

entity( string pString, string pName )  Property_GetEntity =
{
	return ftoe( Property_GetFloat( pString, pName ) );
};

#undef DebugValidate()
