void SV_ParseClientCommand(string s) {
	local float index;

	tokenize(s);

	if(argv(0) == "clogin") {
		if(cvar("sv_clientcommands")) {
			if(self.adminstatus < -5) {
				sprint(self, "Too many unsuccessful tries.\n");
			} else if(argv(1) == cvar_string("sv_clientcommands_password")) {
				self.adminstatus = 1;
				sprint(self, "You now have remote admin status.\n");
			} else {
				sprint(self, "Wrong password.\n");
				// use of -- produces compiler warning in the if() line???
				self.adminstatus = self.adminstatus - 1;
				if(self.adminstatus == 0)
					sprint(self, "You lost remote admin status.\n");
			}
		} else {
			sprint(self, "Clientside commands NOT allowed.\n");
		}
	} else if(argv(0) == "ccmd") {
		if(cvar("sv_clientcommands")) {
			if(self.adminstatus > 0) {
				local string command;
				command = argv(1);
				index = 2;
				while(argv(index) != "") {
					command = strcat(command, " ", argv(index));
					index++;
				}
				localcmd(command);
			} else
				sprint(self, "You don't have remote admin status.\n");
		} else {
			sprint(self, "Clientside commands NOT allowed.\n");
		}
	} else if(argv(0) == "vote") {
		if(argv(1) == "help") {
			sprint(self, "^1You can use voting with \"^2cmd vote help^1\" \"^2cmd vote status^1\" \"^2cmd vote call ^3COMMAND ARGUMENTS^1\" \"^2cmd vote stop^1\" \"^2cmd vote yes^1\" \"^2cmd vote no^1\".\n");
			sprint(self, "^1Or if your version is up to date you can use these aliases \"^2vhelp^1\" \"^2vstatus^1\" \"^2vcall ^3COMMAND ARGUMENTS^1\" \"^2vstop^1\" \"^2vyes^1\" \"^2vno^1\".\n");
			sprint(self, "^1\"^2help^1\" shows this info.\n");
			sprint(self, "^1\"^2status^1\" shows if there is a vote called and who called it.\n");
			sprint(self, "^1\"^2call^1\" is used to call a vote. See the list of allowed commands.\n");
			sprint(self, "^1If more then 50% of the players vote yes the vote is executed.\n");
			sprint(self, "^1If more then 50% of the players vote no the vote fails.\n");
			sprint(self, "^1\"^2stop^1\" can be used by the vote caller to stop a vote and maybe correct it.\n");
			sprint(self, "^1\"^2yes^1\" and \"^2no^1\" to make your vote.\n");
			sprint(self, "^1You can call a vote with these commands:\n");
			sprint(self, strcat("^1\"^2vcall^1\" ^3", cvar_string("sv_vote_allowed"), "^1 and further ^3arguments^1\n"));
		} else if(argv(1) == "status") {
			if(votecalled == "") {
				sprint(self, "^1No vote called.\n");
			} else {
				sprint(self, strcat("^7Vote for \"^1", votecalled, "^7\" called by \"", votecaller.netname, "^7\".\n"));
			}
		} else if(argv(1) == "call") {
			if(votecalled == "") {
				local string vote;
				vote = argv(2);
				index = 3;
				while(argv(index) != "") {
					vote = strcat(vote, " ", argv(index));
					index++;
				}

				// necessary for some of the string operations
				vote = strzone(vote);

				// now we remove some things that could be misused
				index = 0;
				local float found;
				found = FALSE;
				local float votelength;
				votelength = strlen(vote);
				while(!found && index < votelength)
				{
					local string badchar;
					badchar = substring(vote, index, 1);
					if(badchar == ";"
					   || badchar == "\n")
					{
						found = TRUE;
					} else {
						index++;
					}
				}
				vote = substring(vote, 0, index);

				if(vote == "") {
					sprint(self, "^1You have to vote for something.\n");
				} else if(time < self.vote_next) {
					sprint(self, strcat("^1You have to wait ^2", ftos(self.vote_next - time), "^1 seconds before you can again call a vote.\n"));
				} else if(VoteAllowed(strcat(argv(2)))) { // strcat seems to be necessary
					votecalled = strzone(vote);
					votecaller = self; // remember who called the vote
					self.vote_vote = 1; // of course you vote yes
					self.vote_finished = time + cvar("sv_vote_timeout");
					self.vote_next = time + cvar("sv_vote_wait");
					bprint(strcat("^3Vote for \"^1", votecalled, "^3\" called by \"", self.netname, "^3\".\n"));
					VoteCount(); // needed if you are the only one
				} else {
					sprint(self, "^1This vote is not ok. See help for more info.\n");
				}
			} else {
				sprint(self, "^1There is already a vote called.\n");
			}
		} else if(argv(1) == "stop") {
			if(votecalled == "") {
				sprint(self, "^1No vote called.\n");
			} else if(votecaller == self
				  || self.adminstatus > 0) { // the votecaller and admins can stop a vote
				if(votecaller == self) {
					// disable next votetimer so you can correct your vote
					self.vote_next = 0;
				}
				VoteTimeout(votecaller);
			} else {
				sprint(self, "^1You are not allowed to stop that Vote.\n");
			}
		} else if(argv(1) == "yes") {
			if(votecalled == "") {
				sprint(self, "^1No vote called.\n");
			} else if(self.vote_vote == 0
				  || cvar("sv_vote_change")) {
				self.vote_vote = 1;
				if(!cvar("sv_vote_singlecount")) {
					VoteCount();
				}
			} else {
				sprint(self, "^1You have already voted.\n");
			}
		} else if(argv(1) == "no") {
			if(votecalled == "") {
				sprint(self, "^1No vote called.\n");
			} else if(self.vote_vote == 0
				  || cvar("sv_vote_change")) {
				self.vote_vote = -1;
				if(!cvar("sv_vote_singlecount")) {
					VoteCount();
				}
			} else {
				sprint(self, "^1You have already voted.\n");
			}
		} else {
			// ignore this?
			sprint(self, "^1Unknown vote command.\n");
		}
	} else if(argv(0) == "autoswitch") {
		// be backwards compatible with older clients (enabled)
		self.autoswitch = ("0" != argv(1));
		local string autoswitchmsg;
		if (self.autoswitch) {
			autoswitchmsg = "on";
		} else {
			autoswitchmsg = "off";
		}
		sprint(self, strcat("^1autoswitch turned ", autoswitchmsg, "\n"));
	} else if(argv(0) == "clientversion") {
		local string versionmsg;
		if (argv(1) == "$g_nexuizversion_gamedata") {
			versionmsg = "^1client is too old to get versioninfo.\nUPDATE!!! (http://www.nexuiz.com)^8";
			// either that or someone wants to be funny
		} else if (stof(argv(1)) != cvar("g_nexuizversion_gamedata")) {
			versionmsg = "^3client version and server version are different.\nYou might have to update!!!^8";
		} else {
			versionmsg = "^2client version and server version are the same.^8";
		}
		self.versionmessage = strzone(versionmsg);
	} else if(argv(0) == "spectate") {
		if(cvar("g_lms"))
			return; // don't allow spectating in lms, unless player runs out of lives
		if(self.classname == "player" && cvar("sv_spectate") == 1) {
			self.classname = "observer";
			PutClientInServer();
		}
	} else if(argv(0) == "crosshair") {
		self.crosshair_static = argv(1);
	} else {
		clientcommand(self,s);
	}
}

float VoteAllowed(string votecommand) {
	tokenize(cvar_string("sv_vote_allowed"));
	local float index;
	index = 0;
	while(argv(index) != "") {
		local string allowed;
		allowed = argv(index);
		if(votecommand == allowed) {
			return TRUE;
		}
		index++;
	}
	return FALSE;
}

void VoteCount() {
	local float playercount;
	playercount = 0;
	local float yescount;
	yescount = 0;
	local float nocount;
	nocount = 0;
	local entity player;
	local entity voter;
	player = find(player, classname, "player");
	while(player)
	{
		if(player.vote_vote < 0) {
			nocount++;
		} else if(player.vote_vote > 0) {
			yescount++;
		}

		if(self.vote_finished > 0) {
			voter = player;
		}

		playercount++;
		player = find(player, classname, "player");
	}

	if((playercount / 2) < yescount) { // vote passed
		VoteDo(voter);
	} else if((playercount / 2) < nocount) { // vote rejected
		VoteTimeout(voter);
	} // else still running
}

void VoteDo(entity voter) {
	bprint(strcat("^2The vote for \"^1", votecalled, "^2\" from \"", voter.netname, "^2\" DID PASS.\n"));
	localcmd(votecalled);
	VoteReset();
}

void VoteTimeout(entity voter) {
	bprint(strcat("^5The vote for \"^1", votecalled, "^5\" from \"", voter.netname, "^5\" did NOT pass.\n"));
	VoteReset();
}

void VoteReset() {
	local entity player;
	player = find(player, classname, "player");
	while(player)
	{
		player.vote_vote = 0;
		player.vote_finished = 0;
		player = find(player, classname, "player");
	}
	votecalled = "";
}
