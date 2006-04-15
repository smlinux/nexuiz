// Property of Alientrap/AK
// custom/messagebox.qc

var event Nex_MessageBox_LeftEvent = __NULL__;
var event Nex_MessageBox_RightEvent = __NULL__;

void( string pTitle, string pText, string pLeftButton, string pRightButton, event pLeftEvent, event pRightEvent )
Nex_MessageBox =
{
	local entity lItem;

	lItem = Menu_GetItem( "MessageBoxWnd::Layout::Title::Caption" );
	String_EntitySet( lItem, normal, pTitle );
	// reset its size since this one has to be centered and AlignCenter takes care of everything
	//lItem.size = '0 0 0';

	lItem = Menu_GetItem( "MessageBoxWnd::Layout::Text" );
	String_EntitySet( lItem, text, pText );
	lItem.size = '0 0 0';

	lItem = Menu_GetItem( "MessageBoxWnd::Layout::Buttons::Left" );
	String_EntitySet( lItem, normal, pLeftButton );
	lItem.size = '0 0 0';
	// select the left button since it has to be available
	Menu_Select( lItem, false );

	lItem = Menu_GetItem( "MessageBoxWnd::Layout::Buttons::Right" );
	String_EntitySet( lItem, normal, pRightButton );
	lItem.size = '0 0 0';
	if( strlen( pRightButton ) != 0 ) {
		// select the right button since we prefer it (standard scheme is Yes No or Ok Cancel)
		Menu_Select( lItem, false );

		if( lItem.flag & FLAG_HIDDEN ) {
			lItem.flag = lItem.flag - FLAG_HIDDEN;
		}
	} else {
		lItem.flag = lItem.flag | FLAG_HIDDEN;
	}

	Nex_MessageBox_LeftEvent = pLeftEvent;
	Nex_MessageBox_RightEvent = pRightEvent;

	lItem = Menu_GetItem( "MessageBoxWnd" );
	if( lItem.flag & FLAG_HIDDEN ) {
		lItem.flag = lItem.flag - FLAG_HIDDEN;
	}
};

void() Nex_MessageBox_Hide =
{
	local entity lEntity;

	lEntity = Menu_GetItem( "MessageBoxWnd" );
	if( !(lEntity.flag & FLAG_HIDDEN) ) {
		lEntity.flag = lEntity.flag + FLAG_HIDDEN;
		Menu_Reselect( false );
	}
}

void() Nex_MessageBox_LeftButton =
{
	if( Nex_MessageBox_LeftEvent ) {
		Nex_MessageBox_LeftEvent();
	}
	Nex_MessageBox_Hide();
};

void() Nex_MessageBox_RightButton =
{
	if( Nex_MessageBox_RightEvent ) {
		Nex_MessageBox_RightEvent();
	}
	Nex_MessageBox_Hide();
};

bool( float pKey, float pAscii ) Nex_MessageBox_Key =
{
	if( pKey == K_ESCAPE ) {
		// escape == right button!
		Nex_MessageBox_RightButton();
		return true;
	}
	return false;
};
