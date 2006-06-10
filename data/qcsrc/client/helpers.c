void RegisterCvar (string name, string defvalue, float save)
{
	if(registercvar(name, defvalue) && save)
		localcmd("seta ", name, " ", cvar_string(name), "\n");
}

float DotProduct (vector x, vector y)
{
	// LordHavoc: why does this function exist?  vec*vec in QC is dotproduct
	return x*y;
	//return (x_x*y_x + x_y*y_y + x_z*y_z);
}

// dummy function to shut up compiler warnings
void foo()
{
	self.alpha = 0;
	self.renderflags = 0;
	self = NULL;
}
