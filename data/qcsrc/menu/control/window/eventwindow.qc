// DP/Nex Menu
// control/window/eventwindow.qc

void() Item_EventWindow_Spawn =
{
	Item_Window_Spawn();

	self._destroy = CtCall_Destroy;
	self._reinit = CtCall_Reinit;
	self._update = CtCall_Update;

	CtCall_Init();
};
