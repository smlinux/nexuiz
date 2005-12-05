// NG Menu
// util/text.qc

//INFO: I only care about \n and \0 and the col if in wrapped mode
vector( string pText, vector pLast ) Util_GetEndOfLine =
{
	local string lChar;

	pLast_x = pLast_y;
	pLast_z = 0;
	while( 1 ) {
		lChar = substring( pText, pLast_x, 1 );

		// newline -> the current char isnt valid
		if( lChar == "\n" ) {
			// the next valid is char can only be after the \n
			pLast_y = pLast_x + 1;
			--pLast_x;
			return pLast;
		} else if( lChar == "" ) {
			pLast_y = --pLast_x;
			return pLast;
		} else {
			++pLast_x;
			++pLast_z;
		}
	}
};

vector( string pText, vector pLast, float pWrapLength ) Util_GetEndOfWrappedLine =
{
	local string lChar;

	pLast_x = pLast_y;
	pLast_z = 0;
	while( 1 ) {
		lChar = substring( pText, pLast_x, 1 );

		// newline -> the current char isnt valid
		if( lChar == "\n" ) {
			--pLast_x;
			// the next valid is char can only be after the \n
			pLast_y = pLast_x + 2;
			return pLast;
		} else if( lChar == "" ) {
			pLast_y = --pLast_x;
			return pLast;
		} else {
			++pLast_x;
			++pLast_z;
			if( !--pWrapLength ) {
				// the current char is one too much
				pLast_y = pLast_x;
				--pLast_x;
				return pLast;
			}
		}
	}
};

string( float pValue, float pStep ) Util_FloatToClampedText =
{
	local float lLen;
	local float lClampedStep;
	local float lInverseClamped;
	lClampedStep = pStep - floor( pStep );
	if( lClampedStep == 0.0 )
		return ftos( pValue );
	// get the integer length
	lLen = strlen( ftos( floor( pValue ) ) );
	// Example data: 0.1 -> 10 - 1 = 9; 0.9 -> 1.^1 - 0.1 = 1.0^1 ; 0.01 -> 100 - 1 = 99 ; 0.09 -> 11.^1 - 0.1 = 10.0^1
	lInverseClamped = 1.0 / lClampedStep - 0.1;
	// add the fraction length and 1 for the .
	lLen += strlen( ftos( floor( lInverseClamped ) ) ) + 1;
	return substring( ftos( pValue + 0.0001 ), 0, lLen );
}
