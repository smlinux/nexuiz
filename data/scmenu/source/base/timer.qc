// NG-Menu
// base/timer.qc

float _Timer_LastTime;

void() Timer_Init =
{
	Timer_Time = gettime();
	Timer_Delta = 0.0;
};

void() Timer_Update =
{
	_Timer_LastTime = Timer_Time;
	Timer_Time = gettime();
	Timer_Delta = Timer_Time - _Timer_LastTime;
};

void() Timer_Quit =
{
};

