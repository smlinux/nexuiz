// DP/Nex menu
// system/events.qc

// raise function
/* template

void( entity pEntity )	Raise_x =
{
	local entity lOld;
	if( !pEntity._y )
		return;

	lOld = self;
	self = pEntity;
	self._y();
	self = lOld;
};
*/

void( entity pEntity ) Raise_Reinit =
{
	local entity lOld;
	if(!pEntity._reinit)
		return;

	lOld = self;
	self = pEntity;
	self._reinit();
	self = lOld;
};

void( entity pEntity ) Raise_Destroy =
{
	local entity lOld;
	if( !pEntity._destroy )
		return;

	lOld = self;
	self = pEntity;
	self._destroy();
	self = lOld;
};

bool( entity pEntity, float pKey, float pAscii) Raise_Key =
{
	local entity lOld;
	local bool   lResult;

	if( !pEntity._key )
		return false;

	lOld = self;
	self = pEntity;
	lResult = self._key( pKey, pAscii );
	self = lOld;

	return lResult;
};

void( entity pEntity ) Raise_Draw =
{
	local entity lOld;
	if( !pEntity._draw )
		return;

	lOld = self;
	self = pEntity;
	self._draw();
	self = lOld;
};

void( entity pEntity ) Raise_MouseEnter =
{
	local entity lOld;
	if( !pEntity._mouseEnter )
		return;

	lOld = self;
	self = pEntity;
	self._mouseEnter();
	self = lOld;
};

void( entity pEntity ) Raise_MouseLeave =
{
	local entity lOld;
	if( !pEntity._mouseLeave )
		return;

	lOld = self;
	self = pEntity;
	self._mouseLeave();
	self = lOld;
};

void( entity pEntity ) Raise_Update =
{
	local entity lOld;
	if( !pEntity._update )
		return;

	lOld = self;
	self = pEntity;
	self._update();
	self = lOld;
};

void( entity pEntity, bool pSelect, bool pUser ) Raise_Select =
{
	local entity lOld;
	if( !pEntity._select )
		return;

	lOld = self;
	self = pEntity;
	self._select( pSelect, pUser );
	self = lOld;
};

// safe call control function functions
// default control functions
/* template

void() CtCall_x	=
{
	if( self.y )
		self.y();
};

*/
void()	CtCall_Init =
{
	if( self.init )
		self.init();
};

void()  CtCall_Reinit =
{
	if( self.reinit )
		self.reinit();
};

void() CtCall_Destroy =
{
	if( self.destroy )
		self.destroy();
};

bool( float pKey, float pAscii )  CtCall_Key =
{
	if( self.key )
		return self.key( pKey, pAscii );
	return false;
};

void()	CtCall_Draw =
{
	if( self.draw )
		self.draw();
};

void()	CtCall_MouseEnter =
{
	if( self.mouseEnter )
		self.mouseEnter();
};

void()	CtCall_MouseLeave =
{
	if( self.mouseLeave )
		self.mouseLeave();
};

void()	CtCall_Action =
{
	if( self.action )
		self.action();
};

void() CtCall_Update =
{
	if( self.update )
		self.update();
}

void( bool pSelect, bool pUser ) CtCall_Select =
{
	if( self.select )
		self.select( pSelect, pUser );
};

// default control functions
/* template (expect DefCt_Key)

void(void) defct_x =
{
	CtCall_x();
};

*/
// defct_init not needed cause its the same like the type function

void() DefCt_Reinit =
{
};

void() DefCt_Destroy =
{
};

bool( float pKey, float pAscii ) DefCt_Key =
{
	return false;
};

void() DefCt_Draw =
{
};

void() DefCt_MouseEnter =
{
};

void() DefCt_MouseLeave =
{
};

void()	DefCt_Action =
{
};

void( float pSelect, bool pUser )  DefCt_Select =
{
};

void()	DefCt_Update =
{
};

// default key function
/*void(float keynr, float ascii)	def_keyevent =
{
	if(keynr == K_ESCAPE)
	{
		// move up to the parent
		menu_selectup();
	} else if(keynr == K_LEFTARROW || keynr == K_UPARROW)
	{
		// move to the previous element
		menu_loopprev();

		if(Menu_ActiveItem == self)
		{
			if(self._prev)
			{
				Menu_ActiveItem = self._prev;
				menu_selectdown();
				if(Menu_ActiveItem != self._prev)
				{
					return;
				}
			}
			Menu_ActiveItem = self;
		}
	} else if(keynr == K_RIGHTARROW || keynr == K_DOWNARROW)
	{
		// move to the  next element
		menu_loopnext();

		if(Menu_ActiveItem == self)
		{
			if(self._next)
			{
				Menu_ActiveItem = self._next;
				menu_selectdown();
				if(Menu_ActiveItem != self._next)
				{
					return;
				}
			}
			Menu_ActiveItem = self;
		}
	} else if(keynr == K_ENTER || keynr == K_MOUSE1)
	{
		if(self._action)
			self._action();
		// move to the child menu
		menu_selectdown();
	}
};*/
