float teamplay;
float myteam;

float TeamByColor(float color)
{
	switch(color)
	{
	case COLOR_TEAM1: return 0;
	case COLOR_TEAM2: return 1;
	case COLOR_TEAM3: return 2;
	case COLOR_TEAM4: return 3;
	default: return 0;
	}
}

float GetPlayerColorForce(float i)
{
	if(!teamplay)
		return 0;
	else
		return stof(getplayerkey(i, "colors")) & 15;
}

float GetPlayerColor(float i)
{
	if not(playerslots[i].gotscores) // unconnected
		return COLOR_SPECTATOR;
	else if(stof(getplayerkey(i, "frags")) == FRAGS_SPECTATOR)
		return COLOR_SPECTATOR;
	else
		return GetPlayerColorForce(i);
}

string GetPlayerName(float i)
{
	return ColorTranslateRGB(getplayerkey(i, "name"));
}

vector GetTeamRGB(float color)
{
	switch(color)
	{
	default: return '1 1 1';
	case COLOR_TEAM1: return '1 0 0'; // red
	case COLOR_TEAM2: return '0 0 1'; // blue
	case COLOR_TEAM3: return '1 1 0'; // yellow
	case COLOR_TEAM4: return '1 0 1'; // pink
	}
}

string GetTeamName(float color)
{
	switch(color)
	{
	default: return "Spectators";
	case COLOR_TEAM1: return "Red Team";
	case COLOR_TEAM2: return "Blue Team";
	case COLOR_TEAM3: return "Yellow Team";
	case COLOR_TEAM4: return "Pink Team";
	}
}
