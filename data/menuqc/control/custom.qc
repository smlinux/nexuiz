// DP/Nex Menu
// control/custom.qc

////////////////
// Item_Custom
///
// TODO: Remove Item_Custom - No, it should be the only customizable item

void() Item_Custom_Spawn =
{
	self._reinit = CtCall_Reinit;
	self._destroy = CtCall_Destroy;
	self._key = CtCall_Key;
	self._draw = CtCall_Draw;
	self._mouseEnter = CtCall_MouseEnter;
	self._mouseLeave = CtCall_MouseLeave;
	self._select = CtCall_Select;
	self._update = CtCall_Update;

	CtCall_Init();
};

