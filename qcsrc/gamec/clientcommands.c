void SV_ParseClientCommand(string s) {
	tokenize(s);
	
	if(cvar("sv_clientcommands")) {
		if(argv(0) == "clogin") {
			if(argv(1) == cvar_string("sv_clientcommands_password")) {
				self.adminstatus = 1;
				sprint(self, "You now have remote admin status.\n");
			}
		} else if(argv(0) == "ccmd" && self.adminstatus) {
			localcmd(strcat(argv(1)," ",argv(2)," ",argv(3)," ",argv(4),"\n"));
		} else {
			clientcommand(self,s);
		}
				
	} else {
		clientcommand(self,s);	
	}
}
