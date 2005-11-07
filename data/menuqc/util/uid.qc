// NG Menu
// util/uid.qc

// name format: "M_UID_" number

var float _m_uid_counter = 0;
string() Util_CreateUID =
{
	local string lName;

	lName = strzone( strcat( "M_UID_", ftos( _m_uid_counter ) ) );
	_m_uid_counter = _m_uid_counter + 1;
	return lName;
};

string( float pNum ) Util_GetUIDName =
{
	local string lName;

	lName = strzone( strcat( "M_UID_", ftos( pNum ) ) );
	return lName;
};

float( string pUid ) Util_GetUIDNum =
{
	local string lNum;

	lNum = substring( pUid, 6, 100000 );
	return stof( lNum );
};



