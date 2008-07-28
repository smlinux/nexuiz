float c1, c2, c3, c4;
void CheckAllowedTeams (entity for_whom);

// NOTE: SP_ constants may not be >= MAX_SCORE; ST_constants may not be >= MAX_TEAMSCORE
// scores that should be in all modes:
void ScoreRules_basics(float teams, float sprio)
{
	ScoreInfo_Init(teams);
	if(sprio)
		ScoreInfo_SetLabel_TeamScore  (ST_SCORE,        "score",     sprio);
	ScoreInfo_SetLabel_PlayerScore(SP_KILLS,        "kills",     0);
	ScoreInfo_SetLabel_PlayerScore(SP_DEATHS,       "deaths",    SFL_LOWER_IS_BETTER);
	ScoreInfo_SetLabel_PlayerScore(SP_SUICIDES,     "suicides",  SFL_LOWER_IS_BETTER);
	if(sprio)
		ScoreInfo_SetLabel_PlayerScore(SP_SCORE,        "score",     sprio);
}
void ScoreRules_generic()
{
	CheckAllowedTeams(world);
	if(teamplay)
	{
		CheckAllowedTeams(world);
		ScoreRules_basics(((c4>=0) ? 4 : (c3>=0) ? 3 : 2), SFL_SORT_PRIO_PRIMARY);
	}
	else
		ScoreRules_basics(0, SFL_SORT_PRIO_PRIMARY);
}

// g_ctf
#define ST_CTF_CAPS 1
#define SP_CTF_CAPS 4
#define SP_CTF_PICKUPS 5
#define SP_CTF_FCKILLS 6
#define SP_CTF_RETURNS 7
void ScoreRules_ctf()
{
	float sp_score, sp_caps;
	sp_score = sp_caps = 0;
	switch(cvar("g_ctf_win_mode"))
	{
		case 0: // caps only
			sp_caps = SFL_SORT_PRIO_PRIMARY;
			break;
		case 1: // caps, then score
			sp_caps = SFL_SORT_PRIO_PRIMARY;
			sp_score = SFL_SORT_PRIO_SECONDARY;
			break;
		case 2: // score only
		default:
			sp_score = SFL_SORT_PRIO_PRIMARY;
			sp_caps = SFL_SORT_PRIO_SECONDARY; // looks better ;)
			break;
	}

	CheckAllowedTeams(world);
	ScoreRules_basics(2 + (c3>=0), sp_score); // NOTE this assumes that the rogue team is team 3
	ScoreInfo_SetLabel_TeamScore  (ST_CTF_CAPS,     "caps",      sp_caps);
	ScoreInfo_SetLabel_PlayerScore(SP_CTF_CAPS,     "caps",      sp_caps);
	ScoreInfo_SetLabel_PlayerScore(SP_CTF_PICKUPS,  "pickups",   0);
	ScoreInfo_SetLabel_PlayerScore(SP_CTF_FCKILLS,  "fckills",   0);
	ScoreInfo_SetLabel_PlayerScore(SP_CTF_RETURNS,  "returns",   0);
}

// g_domination
#define ST_DOM_TICKS 1
#define SP_DOM_TICKS 4
#define SP_DOM_TAKES 5
void ScoreRules_dom()
{
	float sp_domticks, sp_score;
	sp_score = sp_domticks = 0;
	if(cvar("g_domination_disable_frags"))
		sp_domticks = SFL_SORT_PRIO_PRIMARY;
	else
		sp_score = SFL_SORT_PRIO_PRIMARY;
	CheckAllowedTeams(world);
	ScoreRules_basics(((c4>=0) ? 4 : (c3>=0) ? 3 : 2), sp_score);
	ScoreInfo_SetLabel_TeamScore  (ST_DOM_TICKS,    "ticks",     sp_domticks);
	ScoreInfo_SetLabel_PlayerScore(SP_DOM_TICKS,    "ticks",     sp_domticks);
	ScoreInfo_SetLabel_PlayerScore(SP_DOM_TAKES,    "takes",     0);
}

// LMS stuff
#define SP_LMS_LIVES 4
#define SP_LMS_RANK 5
void ScoreRules_lms()
{
	ScoreRules_basics(0, 0);
	ScoreInfo_SetLabel_PlayerScore(SP_LMS_LIVES,    "lives",     SFL_SORT_PRIO_SECONDARY);
	ScoreInfo_SetLabel_PlayerScore(SP_LMS_RANK,     "rank",      SFL_LOWER_IS_BETTER | SFL_HIDE_ZERO | SFL_SORT_PRIO_PRIMARY | SFL_ALLOW_HIDE);
}

// Key hunt stuff
#define ST_KH_CAPS 1
#define SP_KH_CAPS 4
#define SP_KH_PUSHES 5
#define SP_KH_DESTROYS 6
#define SP_KH_PICKUPS 7
#define SP_KH_KCKILLS 8
#define SP_KH_LOSSES 9
void ScoreRules_kh(float teams)
{
	ScoreRules_basics(teams, SFL_SORT_PRIO_PRIMARY);
	ScoreInfo_SetLabel_TeamScore  (ST_KH_CAPS,      "caps",      SFL_SORT_PRIO_SECONDARY);
	ScoreInfo_SetLabel_PlayerScore(SP_KH_CAPS,      "caps",      SFL_SORT_PRIO_SECONDARY);
	ScoreInfo_SetLabel_PlayerScore(SP_KH_PUSHES,    "pushes",    0);
	ScoreInfo_SetLabel_PlayerScore(SP_KH_DESTROYS,  "destroyed", SFL_LOWER_IS_BETTER);
	ScoreInfo_SetLabel_PlayerScore(SP_KH_PICKUPS,   "pickups",   0);
	ScoreInfo_SetLabel_PlayerScore(SP_KH_KCKILLS,   "kckills",   0);
	ScoreInfo_SetLabel_PlayerScore(SP_KH_LOSSES,    "losses",    SFL_LOWER_IS_BETTER);
}
