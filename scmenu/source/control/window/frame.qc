// DP/Nex Menu
// control/window/frame.qc

void() Item_Frame_Spawn =
{
	Item_Window_Spawn();

	self.flag = self.flag - FLAG_NOSELECT;
};
