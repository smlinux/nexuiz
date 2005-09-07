void SV_ParseClientCommand(string s) {
	tokenize(s);
	
	if(cvar("sv_clientcommands")) {
		if(argv(0) == "clogin") {
			if(self.adminstatus < -5) {
				sprint(self, "Too many unsuccessful tries.\n");			
			} else if(argv(1) == cvar_string("sv_clientcommands_password")) {
				self.adminstatus = 1;
				sprint(self, "You now have remote admin status.\n");
			} else {
				sprint(self, "Wrong password.\n");
				self.adminstatus--;
			}
		} else if(argv(0) == "ccmd") {
			if(self.adminstatus > 0)
				localcmd(strcat(argv(1)," ",argv(2)," ",argv(3)," ",argv(4),"\n"));
			else
				sprint(self, "You don't have remote admin status.\n");
		} else {
			clientcommand(self,s);
		}
				
	} else {
		clientcommand(self,s);	
	}
}
