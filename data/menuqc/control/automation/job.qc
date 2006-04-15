// DP/Nex Menu
// control/automation/job.qc

void() Item_Automation_Job_Spawn =
{
	Item_Automation_Init();

	//print( "AutoJob: ", self.name, "\n" );

	CtCall_Action();
};

void() Item_Task_Job_Spawn =
{
	Item_Task_Init();

	self._reinit = CtCall_Reinit;
	self._destroy = CtCall_Destroy;
	self._update = CtCall_Update;

	CtCall_Init();
};
