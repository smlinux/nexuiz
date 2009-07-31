#ifdef INTERFACE
CLASS(NexuizTeamSelectDialog) EXTENDS(NexuizRootDialog)
	METHOD(NexuizTeamSelectDialog, fill, void(entity)) // to be overridden by user to fill the dialog with controls
	METHOD(NexuizTeamSelectDialog, showNotify, void(entity))
	ATTRIB(NexuizTeamSelectDialog, title, string, "Team Selection") // ;)
	ATTRIB(NexuizTeamSelectDialog, color, vector, SKINCOLOR_DIALOG_TEAMSELECT)
	ATTRIB(NexuizTeamSelectDialog, intendedWidth, float, 0.4)
	ATTRIB(NexuizTeamSelectDialog, rows, float, 5)
	ATTRIB(NexuizTeamSelectDialog, columns, float, 4)
	ATTRIB(NexuizTeamSelectDialog, name, string, "TeamSelect")
	ATTRIB(NexuizTeamSelectDialog, team1, entity, NULL)
	ATTRIB(NexuizTeamSelectDialog, team2, entity, NULL)
	ATTRIB(NexuizTeamSelectDialog, team3, entity, NULL)
	ATTRIB(NexuizTeamSelectDialog, team4, entity, NULL)
ENDCLASS(NexuizTeamSelectDialog)
#endif

#ifdef IMPLEMENTATION
entity makeTeamButton(string theName, vector theColor, string commandtheName)
{
	entity b;
	b = makeNexuizBigCommandButton(theName, theColor, commandtheName, 1);
	return b;
}

void showNotifyNexuizTeamSelectDialog(entity me)
{
	float teams, nTeams;
	teams = cvar("_teams_available");
	nTeams = 0;
	me.team1.disabled = !(teams & 1); nTeams += !!(teams & 1);
	me.team2.disabled = !(teams & 2); nTeams += !!(teams & 2);
	me.team3.disabled = !(teams & 4); nTeams += !!(teams & 4);
	me.team4.disabled = !(teams & 8); nTeams += !!(teams & 8);
}

void fillNexuizTeamSelectDialog(entity me)
{
	entity e;
	me.TR(me);
		me.TD(me, 2, 4, e = makeTeamButton("join 'best' team (auto-select)", '0 0 0', "cmd selectteam auto; cmd join"));
			e.preferredFocusPriority = 1;
	me.TR(me);
	me.TR(me);
		me.TD(me, 2, 1, me.team1 = makeTeamButton("red", '1 0.5 0.5', "cmd selectteam red; cmd join"));
		me.TD(me, 2, 1, me.team2 = makeTeamButton("blue", '0.5 0.5 1', "cmd selectteam blue; cmd join"));
		me.TD(me, 2, 1, me.team3 = makeTeamButton("yellow", '1 1 0.5', "cmd selectteam yellow; cmd join"));
		me.TD(me, 2, 1, me.team4 = makeTeamButton("pink", '1 0.5 1', "cmd selectteam pink; cmd join"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 4, makeNexuizCommandButton("spectate", '0 0 0', "cmd spectate", 1));
}
#endif

/* Click. The c-word is here so you can grep for it :-) */
