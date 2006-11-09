// Team:Nexuiz Client Commands w/ Nexuiz 1.5 RCON/Vote system
.float adminstatus;
.float autoswitch;			// need function for this!!
.float version;
.float ready;
// stahl's voting
float votecalled;
string votecalledvote;
float votecalledmaster;
entity votecaller;
float votefinished;
.float vote_master;
.float vote_next;
.float vote_vote;
void VoteThink();
string VoteParse();
float VoteAllowed(string vote);
void VoteReset();
void VoteAccept();
void VoteReject();
void VoteTimeout();
void VoteStop(entity stopper);
void VoteCount();
void ReadyCount();
// Parse team join, class etc.
void SV_ParseClientCommand (string s)
{
	local float index;
	local float args;
//	local float h;
	local string c;
	local string d;
	local string f;
	local string g;
	local string i;
	args = tokenize(s);
	c = argv(0);
	d = argv(1);
	f = argv(2);
	g = argv(3);
	i = argv(4);

	if (c == "join")
    {
		return;
	}
	if (c == "changeclass")
	{
		stuffcmd(self, "set scmenu_directmenu ClassSelect; togglemenu\n");
		return;
	}
	if (c == "selectteam")
    {
		if (self.team_no > 0)
		{
			sprint(self, "You are already on a team!\n");
			return;
		}
		if (d == "auto" || d == "5")
		{
			TeamFortress_TeamPutPlayerInTeam();
			PutClientInServer ();
		}
		if (d == "blue" || d == "1")
		{
			TeamFortress_TeamSet (1);
			PutClientInServer ();
		}
		if (d == "red" || d == "2")
		{
			TeamFortress_TeamSet (2);
			PutClientInServer ();
		}
		if (d == "yellow" || d == "3")
		{
			TeamFortress_TeamSet (3);
			PutClientInServer ();
		}
		if (d == "green" || d == "pink" || d == "4")		// Morphed set it to Pink in the menus. I think
		{													// we should make it white instead.
			TeamFortress_TeamSet (4);
			PutClientInServer ();
		}
		return;
	}
	if (c == "selectclass")
    {
		if (self.team_no < 1)
		{
			sprint(self, "You must select a team to join first!\n");
			return;
		}
		if (TeamFortress_TeamIsCivilian (self.team_no))
		{
			self.impulse = 1;
			TeamFortress_ChangeClass ();
			return;
		}
		if (self.playerclass > 0)		// if a class is already chosen
		{
			self.tfstate = self.tfstate - (self.tfstate & 8);
			local string cname;
			if (d == ftos(TF_CLASS_SCOUT))
			{
				cname = "scout";
			}
			if (d == ftos(TF_CLASS_SOLDIER))
			{
				cname = "soldier";
			}
			if (d == ftos(TF_CLASS_MEDIC))
			{
				cname = "medic";
			}
			if (d == ftos(TF_CLASS_PYRO))
			{
				cname = "pyro";
			}
			if (d == ftos(TF_CLASS_ENGINEER))
			{
				cname = "engineer";
			}
			if (d == ftos(TF_CLASS_SPY))
			{
				cname = "spy";
			}
			if (d == ftos(TF_CLASS_RANDOM))
			{
				self.tfstate = self.tfstate | 8;
				sprint(self, "You will respawn as a random class.\n");
			}
			if (cname != "")
			{
//				stuffcmd(self, "_cl_playermodel \"models/class/");
//				stuffcmd(self, cname);
//				stuffcmd(self, "_mechanical.zym\"\n");
				if (cname == "engineer")
				{
					self.playermodel = strcat("models/class/",cname,"_other.zym");
				}
				else
				{
					self.playermodel = strcat("models/class/",cname,"_mechanical.zym");
				}
				if (self.is_dead == 1)		// if player is dead, can change class
					CheckForClassChange();
			}
		}
		else			// if no class is chosen
		{
			if (d == ftos(TF_CLASS_SCOUT))
			{
				self.impulse = TF_CLASS_SCOUT;
			}
			if (d == ftos(TF_CLASS_SOLDIER))
			{
				self.impulse = TF_CLASS_SOLDIER;
			}
			if (d == ftos(TF_CLASS_MEDIC))
			{
				self.impulse = TF_CLASS_MEDIC;
			}
			if (d == ftos(TF_CLASS_PYRO))
			{
				self.impulse = TF_CLASS_PYRO;
			}
			if (d == ftos(TF_CLASS_ENGINEER))
			{
				self.impulse = TF_CLASS_ENGINEER;
			}
			if (d == ftos(TF_CLASS_SPY))
			{
				self.impulse = TF_CLASS_SPY;
			}
			if (d == ftos(TF_CLASS_RANDOM))
			{
				self.impulse = TF_CLASS_RANDOM;
			}
			TeamFortress_ChangeClass();
		}
		return;
	}
	else if (c == "check_val")
	{
		if (d == "r_bloom")
		{
			if (f == "1")
				self.uses_bloom = 1;
			else
				self.uses_bloom = 0;
		}
	}
	else if(argv(0) == "clogin") {
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
			local string vmasterdis;
			if(!cvar("sv_vote_master")) {
				vmasterdis = " ^1(disabled)";
			}
			local string vcalldis;
			if(!cvar("sv_vote_call")) {
				vcalldis = " ^1(disabled)";
			}
			sprint(self, "^7You can use voting with \"^2cmd vote help^7\" \"^2cmd vote status^7\" \"^2cmd vote call ^3COMMAND ARGUMENTS^7\" \"^2cmd vote stop^7\" \"^2cmd vote master^7\" \"^2cmd vote do ^3COMMAND ARGUMENTS^7\" \"^2cmd vote yes^7\" \"^2cmd vote no^7\".\n");
			sprint(self, "^7Or if your version is up to date you can use these aliases \"^2vhelp^7\" \"^2vstatus^7\" \"^2vcall ^3COMMAND ARGUMENTS^7\" \"^2vstop^7\" \"^2vmaster^7\" \"^2vdo ^3COMMAND ARGUMENTS^7\" \"^2vyes^7\" \"^2vno^7\".\n");
			sprint(self, "^7\"^2help^7\" shows this info.\n");
			sprint(self, "^7\"^2status^7\" shows if there is a vote called and who called it.\n");
			sprint(self, strcat("^7\"^2call^7\" is used to call a vote. See the list of allowed commands.", vcalldis, "^7\n"));
			sprint(self, "^7\"^2stop^7\" can be used by the vote caller or an admin to stop a vote and maybe correct it.\n");
			sprint(self, strcat("^7\"^2master^7\" is used to call a vote to become a master.", vmasterdis, "^7\n"));
			sprint(self, "^7\"^2do^7\" If you are a master you can execute a command without a vote. See the list of allowed commands.\n");
			sprint(self, "^7\"^2yes^7\" and \"^2no^7\" to make your vote.\n");
			sprint(self, "^7If more then 50% of the players vote yes the vote is accepted.\n");
			sprint(self, "^7If more then 50% of the players vote no the vote is rejected.\n");
			sprint(self, strcat("^7The vote will end after ", cvar_string("sv_vote_timeout"), "^7 seconds.\n"));
			sprint(self, "^7You can call a vote for or execute these commands:\n");
			sprint(self, strcat("^3", cvar_string("sv_vote_commands"), "^7 and maybe further ^3arguments^7\n"));
		} else if(argv(1) == "status") {
			if(votecalled) {
				sprint(self, strcat("^7Vote for \"^1", votecalledvote, "^7\" called by \"^7", votecaller.netname, "^7\".\n"));
			} else {
				sprint(self, "^1No vote called.\n");
			}
		} else if(argv(1) == "call") {
			if(cvar("sv_vote_call")) {
				if(votecalled) {
					sprint(self, "^1There is already a vote called.\n");
				} else {
					local string vote;
					vote = VoteParse();
					if(vote == "") {
						sprint(self, "^1Your vote is empty. See help for more info.\n");
					} else if(time < self.vote_next) {
						sprint(self, strcat("^1You have to wait ^2", ftos(self.vote_next - time), "^1 seconds before you can again call a vote.\n"));
					} else if(VoteAllowed(strcat(argv(2)))) { // strcat seems to be necessary
						votecalled = TRUE;
						votecalledmaster = FALSE;
						votecalledvote = strzone(vote);
						votecaller = self; // remember who called the vote
						votefinished = time + cvar("sv_vote_timeout");
						votecaller.vote_vote = 1; // of course you vote yes
						votecaller.vote_next = time + cvar("sv_vote_wait");
						bprint(strcat("^3Vote for \"^1", votecalledvote, "^3\" called by \"^7", votecaller.netname, "^3\".\n"));
						VoteCount(); // needed if you are the only one
					} else {
						sprint(self, "^1This vote is not ok. See help for more info.\n");
					}
				}
			} else {
				sprint(self, "^1Vote calling is NOT allowed.\n");
			}
		} else if(argv(1) == "stop") {
			if(!votecalled) {
				sprint(self, "^1No vote called.\n");
			} else if(self == votecaller
				  || self.adminstatus > 0) { // the votecaller and admins can stop a vote
				VoteStop(self);
			} else {
				sprint(self, "^1You are not allowed to stop that Vote.\n");
			}
		} else if(argv(1) == "master") {
			if(cvar("sv_vote_master")) {
				if(votecalled) {
					sprint(self, "^1There is already a vote called.\n");
				} else {
					votecalled = TRUE;
					votecalledmaster = TRUE;
					votecalledvote = strzone("^3master");
					votecaller = self; // remember who called the vote
					votefinished = time + cvar("sv_vote_timeout");
					votecaller.vote_vote = 1; // of course you vote yes
					votecaller.vote_next = time + cvar("sv_vote_wait");
					bprint(strcat("\"^3", votecaller.netname, "^3\" called a vote to become ^3master^3.\n"));
					VoteCount(); // needed if you are the only one
				}
			} else {
				sprint(self, "^1Vote to become master is NOT allowed.\n");
			}
		} else if(argv(1) == "do") {
			if(self.vote_master) {
				local string dovote;
				dovote = VoteParse();
				if(dovote == "") {
					sprint(self, "^1Your command was empty. See help for more info.\n");
				} else if(VoteAllowed(strcat(argv(2)))) { // strcat seems to be necessary
					bprint("\"^7", strcat(self.netname, "^2 used his ^3master^2 status to do \"^2", dovote, "^2\".\n"));
					localcmd(dovote);
				} else {
					sprint(self, "^1This command is not ok. See help for more info.\n");
				}
			} else {
				sprint(self, "^1You are NOT a master.\n");
			}
		} else if(argv(1) == "yes") {
			if(!votecalled) {
				sprint(self, "^1No vote called.\n");
			} else if(self.vote_vote == 0
				  || cvar("sv_vote_change")) {
				sprint(self, "^1You accepted the vote.\n");
				self.vote_vote = 1;
				if(!cvar("sv_vote_singlecount")) {
					VoteCount();
				}
			} else {
				sprint(self, "^1You have already voted.\n");
			}
		} else if(argv(1) == "no") {
			if(!votecalled) {
				sprint(self, "^1No vote called.\n");
			} else if(self.vote_vote == 0
				  || cvar("sv_vote_change")) {
				sprint(self, "^1You rejected the vote.\n");
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
		if (argv(1) == "$g_nexuizversion_major") {
			//versionmsg = "^1client is too old to get versioninfo.\nUPDATE!!! (http://www.nexuiz.com)^8";
			// either that or someone wants to be funny
			self.version = 1;
		} else {
			self.version = stof(argv(1));
		}
	} else if(argv(0) == "spectate") {
		if(cvar("g_lms"))
			return; // don't allow spectating in lms, unless player runs out of lives
		if(self.classname == "player" && cvar("sv_spectate") == 1) {
			self.classname = "observer";
			PutClientInServer();
		}
	} else if(argv(0) == "join") {
		self.classname = "player";
		self.frags = 0;
		// TODO: I have no idea whether this is needed or not
		if(!cvar("g_lms")) {
			bprint (strcat("^4", self.netname, "^4 is playing now\n"));
		}
		PutClientInServer();
	} else if(argv(0) == "ready") {
		if(cvar("sv_ready_restart"))
		{
			self.ready = TRUE;
			bprint(self.netname, "^2 is ready\n");
			ReadyCount();
		}
	}
	else
	{
		clientcommand(self, s);
	}
};

void VoteThink() {
	if(votefinished > 0 // a vote was called
	    && time > votefinished) // time is up
	{
		VoteCount();
	}
}

string VoteParse() {
	local float index;
	index = 3;
	local string vote;
	vote = argv(2);
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
	return substring(vote, 0, index);
}

float VoteAllowed(string votecommand) {
	tokenize(cvar_string("sv_vote_commands"));
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

void VoteReset() {
	local string searchclass;
	searchclass = "player";

	while (TRUE)
	{
		local entity player;
		player = find(player, classname, searchclass);
		while(player)
		{
			player.vote_vote = 0;
			player = find(player, classname, searchclass);
		}

		if("player" == searchclass) {
			searchclass = "observer";
		} else if("observer" == searchclass) {
			searchclass = "spectator";
		} else {
			break;
		}
	}

	votecalled = FALSE;
	votecalledmaster = FALSE;
	votefinished = 0;
}

void VoteAccept() {
	bprint(strcat("^2The vote for \"^1", votecalledvote, "^2\" from \"^7", votecaller.netname, "^2\" was accepted.\n"));
	if(votecalledmaster)
	{
		votecaller.vote_master = 1;
	} else {
		localcmd(votecalledvote);
	}
	votecaller.vote_next = 0; // people like your votes, no wait for next vote
	VoteReset();
}

void VoteReject() {
	bprint(strcat("^2The vote for \"^1", votecalledvote, "^2\" from \"^7", votecaller.netname, "^2\" was rejected.\n"));
	VoteReset();
}

void VoteTimeout() {
	bprint(strcat("^5The vote for \"^1", votecalledvote, "^5\" from \"^7", votecaller.netname, "^5\" did timeout.\n"));
	VoteReset();
}

void VoteStop(entity stopper) {
	bprint(strcat("^5The vote for \"^1", votecalledvote, "^5\" from \"^7", votecaller.netname, "^5\" was stopped by \"^5", stopper.netname, "^5\".\n"));
	if(stopper == votecaller) {
		// no wait for next vote so you can correct your vote
		votecaller.vote_next = 0;
	}
	VoteReset();
}

void VoteCount() {
	local float playercount;
	playercount = 0;
	local float yescount;
	yescount = 0;
	local float nocount;
	nocount = 0;
	local string searchclass;
	searchclass = "player";

	while (TRUE)
	{
		local entity player;
		player = find(player, classname, searchclass);

		while(player)
		{
			if(clienttype(player) != CLIENTTYPE_BOT) {
				if(player.vote_vote < 0) {
					nocount++;
				} else if(player.vote_vote > 0) {
					yescount++;
				}
				playercount++;
			}
			player = find(player, classname, searchclass);
		}

		if("player" == searchclass) {
			searchclass = "observer";
		} else if("observer" == searchclass) {
			searchclass = "specator";
		} else {
			break;
		}
	}

	if((playercount == 1) && votecalledmaster) {
		// if only one player is on the server becoming vote
		// master is not allowed.  This could be used for
		// trolling or worse. 'self' is the user who has
		// called the vote because this function is called
		// by SV_ParseClientCommand. Maybe all voting should
		// be disabled for a single player?
		sprint(self, "^1You are the only player on this server so you can not become vote master.\n");
		votecaller.vote_next = 0;
		VoteReset();
	} else if((playercount / 2) < yescount) { // vote accepted
		VoteAccept();
	} else if((playercount / 2) < nocount) { // vote rejected
		VoteReject();
	} else if(time > votefinished) { // vote timedout
		VoteTimeout();
	} // else still running
}


void ReadyCount()
{
	local entity e;
	local float r, p;

	e = find(world, classname, "player");

	while(e)
	{
		if(clienttype(e) == CLIENTTYPE_REAL)
		{
			p += 1;
			if(e.ready) r += 1;
		}
		e = find(e, classname, "player");
	}

	if(p && r == p)
	{
		bprint("^1Server is restarting...\n");
		localcmd("restart\n");
	}
}
