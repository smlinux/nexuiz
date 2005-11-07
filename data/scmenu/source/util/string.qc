// NG Menu
// util/string.qc

/*
===================
String_Create
===================
*/
string() String_Create =
{
	//return strzone( strcat( "Static, ", self.name ) );
	return strzone( "" );
};

/*
===================
String_Make
===================
*/
string( string pStr ) String_Zone =
{
	return strzone( pStr );
};

/*
===================
String_Normal
===================
*/
string( string pStr ) String_Normal =
{
	local string lResult;

	lResult = strcat( pStr );
	strunzone( pStr );

	return lResult;
};

/*
===================
String_Free
===================
*/
string( string pStr ) String_Free =
{
	strunzone( pStr );
	return "";
};

/*
===================
String_EntityCreate
===================
*/
void( entity pEntity, .string pField ) String_EntityCreate =
{
	//pEntity.pField = strzone( strcat( "Field, ", pEntity.name ) );
	pEntity.pField = strzone( "" );
};

/*
===================
String_EntityZone
===================
*/
void( entity pEntity, .string pField ) String_EntityZone =
{
	pEntity.pField = strzone( pEntity.pField );
};

/*
===================
String_EntitySet
===================
*/
void( entity pEntity, .string pField, string pSet ) String_EntitySet =
{
#ifdef AVOIDSTRZONES
	if( pEntity.pField == pSet ) {
		return;
	}
#endif

	strunzone( pEntity.pField );
	pEntity.pField = strzone( pSet );
};

/*
===================
String_EntityFree
===================
*/
void( entity pEntity, .string pField ) String_EntityFree =
{
	strunzone( pEntity.pField );
	pEntity.pField = "";
};

/*
===================
String_Append
===================
*/
string( string pStr, string pApp ) String_Append =
{
	return String_Set( pStr, strcat( pStr, pApp ) );
};

/*
===================
String_Substring
===================
*/
string( string pStr, float pStart, float pLength ) String_Substring =
{
	return strzone( substring( pStr, pStart, pLength ) );
};

/*
===================
String_Set
===================
*/
string( string pStr, string pSet ) String_Set =
{
#ifdef AVOIDSTRZONES
	if( pStr == pSet ) {
		return pStr;
	}
#endif
	strunzone( pStr );
	return strzone( pSet );
};
