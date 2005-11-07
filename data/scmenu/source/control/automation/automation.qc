// DP/Nex Menu
// control/automation/factory.qc

void() Item_Automation_Init =
{
	self.flag = FLAG_TEMPLATE;
	Menu_DeleteAfterFrame( self );
};

void() Item_Task_Init =
{
	self.flag = FLAG_HIDDEN;
};
