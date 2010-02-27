void error(string e) = #10;
float test();

void spawnfunc_worldspawn()
{
	float r;
	r = test();
	if(r == 1)
		error("TESTCASE: PASS"); 
	else if(r == 0)
		error("TESTCASE: FAIL"); 
	else
		error("TESTCASE: INVALID"); 
}
