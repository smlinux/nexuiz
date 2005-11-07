// NG Menu
// util/rect.qc

/*
===================
Util_InRect
===================
*/
bool( vector pPoint, vector pPos, vector pSize ) Util_InRect =
{
	if( pPoint_x < pPos_x || pPoint_y < pPos_y || pPoint_x > pPos_x + pSize_x || pPoint_y > pPos_y + pSize_y )
		return false;
	return true;
};

bool( vector pPos1, vector pSize1, vector pPos2, vector pSize2 ) Util_RectInRect =
{
	local vector lFPos1, lFPos2;

	lFPos1 = pPos1 + pSize1;
	lFPos2 = pPos2 + pSize2;

	if( pPos1_x <= lFPos2_x && pPos2_x <= lFPos1_x && pPos1_y <= lFPos2_y && pPos2_y <= lFPos1_y )
		return false;
	return true;
};

/*
===================
Util_ClipPoint
===================
*/
/*
vector( vector pPoint, vector pPos, vector pSize ) Util_ClipPoint =
{
	local vector lPoint;
	lPoint_x = bound( pPos_x, pPoint_x, pPos_x + pSize_x );
	lPoint_y = bound( pPos_y, pPoint_y, pPos_y + pSize_y );
	lPoint_z = 0;

	return lPoint;
};
*/

vector( vector pPoint, vector pClipPos, vector pClipSize ) Util_GetClipDelta =
{
	local vector lPoint;
	lPoint_x = bound( pClipPos_x, pPoint_x, pClipPos_x + pClipSize_x ) - pPoint_x;
	lPoint_y = bound( pClipPos_y, pPoint_y, pClipPos_y + pClipSize_y ) - pPoint_y;
	lPoint_z = 0;

	return lPoint;
};

/*
===================
Util_ClipRect
===================
*/
vector( vector pPos, vector pSize, vector pClipPos, vector pClipSize ) Util_ClipRect =
{
	vector lSize;

	//DEBUG: Safe version
	//lSize_x = bound( pClipPos_x, pPos_x + pSize_x, pClipPos_x + pClipSize_x ) - bound( pClipPos_x, pPos_x, pClipPos_x + pClipSize_x );
	//lSize_y = bound( pClipPos_y, pPos_y + pSize_y, pClipPos_y + pClipSize_y ) - bound( pClipPos_y, pPos_y, pClipPos_y + pClipSize_y );
	//lSize_x = min( pPos_x + pSize_x, pClipPos_x + pClipSize_x ) - max( pPos_x, pClipPos_x );
	//lSize_y = min( pPos_y + pSize_y, pClipPos_y + pClipSize_y ) - max( pPos_y, pClipPos_y );
	//INFO: we suppose pPos to be already clipped and pSize to have been adjusted(!!)
	lSize_x = min( pPos_x + pSize_x, pClipPos_x + pClipSize_x ) - pPos_x;
	lSize_y = min( pPos_y + pSize_y, pClipPos_y + pClipSize_y ) - pPos_y;
	lSize_z = 0;

	if( lSize_x <= 0 || lSize_y <= 0 )
		return '0 0 0';

	return lSize;
};

/*
===================
Util_ClipStack_Reset
===================
*/
string( string pStack ) Util_ClipStack_Reset =
{
	String_Free( pStack );
	return String_Create();
};

/*
===================
Util_ClipStack_Push
===================
*/
string( string pStack, vector pPos, vector pSize ) Util_ClipStack_Push =
{
	local vector lOldPos, lOldSize, lDelta;

	lOldPos = Util_ClipStack_GetPosition( pStack );
	lOldSize = Util_ClipStack_GetSize( pStack );

	if( pPos == '0 0 0' && pSize == '0 0 0' ) {
		pPos  = lOldPos;
		pSize = lOldSize;
	} else if( lOldPos != '0 0 0' || lOldSize != '0 0 0'  ) {
		lDelta = Util_GetClipDelta( pPos, lOldPos, lOldSize );
		pPos = pPos + lDelta;
		pSize = Util_ClipRect( pPos, pSize - lDelta, lOldPos, lOldSize );
	}

	pStack = Util_AltStringPush( pStack, vtos( pSize ) );
	pStack = Util_AltStringPush( pStack, vtos( pPos ) );

	return pStack;
};

/*
===================
Util_ClipStack_Pop
===================
*/
string( string pStack ) Util_ClipStack_Pop =
{
	pStack = Util_AltStringPop( pStack );
	pStack = Util_AltStringPop( pStack );
	return pStack;
};

/*
===================
Util_ClipStack_GetPosition
===================
*/
vector( string pStack ) Util_ClipStack_GetPosition =
{
	return stov( String_Normal( Util_GetAltStringItem( pStack, 0 ) ) );
};

/*
===================
Util_ClipStack_GetSize
===================
*/
vector( string pStack ) Util_ClipStack_GetSize =
{
	return stov( String_Normal( Util_GetAltStringItem( pStack, 1 ) ) );
};

/*
===================
Util_OriginStack_Reset
===================
*/
string( string pStack ) Util_OriginStack_Reset =
{
	String_Free( pStack );
	return String_Create();
};

/*
===================
Util_OriginStack_Push
===================
*/
string( string pStack, vector pOrigin ) Util_OriginStack_Push =
{
	return Util_AltStringPush( pStack, vtos( pOrigin ) );
};

/*
===================
Util_OriginStack_Pop
===================
*/
string( string pStack ) Util_OriginStack_Pop =
{
	return Util_AltStringPop( pStack );
};

/*
===================
Util_OriginStack_Get
===================
*/
vector( string pStack ) Util_OriginStack_Get =
{
	return stov( String_Normal( Util_GetAltStringTop( pStack ) ) );
};
