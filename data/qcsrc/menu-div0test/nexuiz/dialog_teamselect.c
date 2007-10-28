#ifdef INTERFACE
CLASS(TeamSelectDialog) EXTENDS(NexuizDialog)
	METHOD(TeamSelectDialog, fill, void(entity)) // to be overridden by user to fill the dialog with controls
	METHOD(TeamSelectDialog, open, void(entity))
	ATTRIB(TeamSelectDialog, title, string, "Team Selection") // ;)
	ATTRIB(TeamSelectDialog, color, vector, '1 1 1')
	ATTRIB(TeamSelectDialog, intendedWidth, float, 0.4)
	ATTRIB(TeamSelectDialog, rows, float, 5)
	ATTRIB(TeamSelectDialog, columns, float, 4)
	ATTRIB(TeamSelectDialog, name, string, "TeamSelect")
	ATTRIB(TeamSelectDialog, team1, entity, NULL)
	ATTRIB(TeamSelectDialog, team2, entity, NULL)
	ATTRIB(TeamSelectDialog, team3, entity, NULL)
	ATTRIB(TeamSelectDialog, team4, entity, NULL)
ENDCLASS(TeamSelectDialog)
#endif

#ifdef IMPLEMENTATION
entity makeTeamButton(string theName, vector theColor, string commandtheName)
{
	entity b;
	b = makeCommandButton(theName, theColor, commandtheName, 1);
	return b;
}

void openTeamSelectDialog(entity me)
{
	float teams, nTeams;
	teams = cvar("_teams_available");
	nTeams = 0;
	me.team1.disabled = !(teams & 1); nTeams += !!(teams & 1);
	me.team2.disabled = !(teams & 2); nTeams += !!(teams & 2);
	me.team3.disabled = !(teams & 4); nTeams += !!(teams & 4);
	me.team4.disabled = !(teams & 8); nTeams += !!(teams & 8);
}

void fillTeamSelectDialog(entity me)
{
	me.TR(me);
		me.TD(me, 2, 4, makeTeamButton("auto", '0 0 0', "cmd selectteam auto; cmd join"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 2, 1, me.team1 = makeTeamButton("red", '1 0.5 0.5', "cmd selectteam red; cmd join"));
		me.TD(me, 2, 1, me.team2 = makeTeamButton("blue", '0.5 0.5 1', "cmd selectteam blue; cmd join"));
		me.TD(me, 2, 1, me.team3 = makeTeamButton("yellow", '1 1 0.5', "cmd selectteam yellow; cmd join"));
		me.TD(me, 2, 1, me.team4 = makeTeamButton("pink", '1 0.5 1', "cmd selectteam pink; cmd join"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 4, makeTeamButton("spectate", '0 0 0', "cmd spectate"));
}
#endif

// click. The C-word so you can grep for it.
