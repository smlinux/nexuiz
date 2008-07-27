.float scores[MAX_SCORE];
.float teamscores[MAX_TEAMSCORE];

.entity scorekeeper;
entity teamscorekeepers[16];
string scores_label[MAX_SCORE];
float scores_flags[MAX_SCORE];
string teamscores_label[MAX_TEAMSCORE];
float teamscores_flags[MAX_TEAMSCORE];
float teamscores_entities_count;
var .float scores_primary;
var .float teamscores_primary;

void Net_LinkEntity(entity e)
{
	e.model = "net_entity";
	e.modelindex = 1;
	e.effects = EF_NODEPTHTEST | EF_LOWPRECISION;
}

vector ScoreField_Compare(entity t1, entity t2, .float field, float fieldflags, vector previous) // returns: cmp value, best prio
{
	if(!(fieldflags & SFL_SORT_PRIO_MASK)) // column does not sort
		return previous;
	if(fieldflags & SFL_SORT_PRIO_MASK < previous_y)
		return previous;
	if(t1.field == t2.field)
		return previous;

	previous_y = fieldflags & SFL_SORT_PRIO_MASK;

	if(fieldflags & SFL_LOWER_IS_BETTER)
		previous_x = (t2.field - t1.field);
	else
		previous_x = (t1.field - t2.field);

	return previous;
}

/*
 * teamscore entities
 */

float TeamScore_SendEntity(entity to)
{
	float i;

	WriteByte(MSG_ENTITY, ENT_CLIENT_TEAMSCORES);
	WriteByte(MSG_ENTITY, self.team - 1);
	for(i = 0; i < MAX_TEAMSCORE; ++i)
		WriteShort(MSG_ENTITY, self.teamscores[i]);

	return TRUE;
}

void TeamScore_Spawn(float t, string name)
{
	entity ts;
	ts = spawn();
	ts.classname = "csqc_score_team";
	ts.SendEntity = TeamScore_SendEntity;
	ts.netname = name; // not used yet, FIXME
	ts.Version = 1; // immediately send, so csqc knows about the team
	ts.team = t;
	Net_LinkEntity(ts);
	teamscorekeepers[t - 1] = ts;
	++teamscores_entities_count;
}

float TeamScore_AddToTeam(float t, float scorefield, float score)
{
	entity s;
	if(!scores_initialized) return 0; // FIXME remove this when everything uses this system
	if(t <= 0 || t >= 16)
		error("Adding score to invalid team!");
	s = teamscorekeepers[t - 1];
	if(!s)
		error("Adding score to unknown team!");
	if(score)
		s.Version += 1;
	return (s.(teamscores[scorefield]) += score);
}

float TeamScore_Add(entity player, float scorefield, float score)
{
	return TeamScore_AddToTeam(player.team, scorefield, score);
}

float TeamScore_Compare(entity t1, entity t2)
{
	if(!t1 || !t2) return (!t2) - !t1;

	vector result;
	float i;
	for(i = 0; i < MAX_TEAMSCORE; ++i)
	{
		var .float f;
		f = teamscores[i];
		result = ScoreField_Compare(t1, t2, f, teamscores_flags[i], result);
	}
	return result_x;
}

/*
 * the scoreinfo entity
 */

void ScoreInfo_SetLabel_PlayerScore(float i, string label, float scoreflags)
{
	scores_label[i] = label;
	scores_flags[i] = scoreflags;
	if(scoreflags & SFL_SORT_PRIO_MASK == SFL_SORT_PRIO_PRIMARY)
		scores_primary = scores[i];
}

void ScoreInfo_SetLabel_TeamScore(float i, string label, float scoreflags)
{
	teamscores_label[i] = label;
	teamscores_flags[i] = scoreflags;
	if(scoreflags & SFL_SORT_PRIO_MASK == SFL_SORT_PRIO_PRIMARY)
		teamscores_primary = teamscores[i];
}

float ScoreInfo_SendEntity(entity to)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_SCORES_INFO);
	float i;
	WriteByte(MSG_ENTITY, game);
	for(i = 0; i < MAX_SCORE; ++i)
	{
		WriteString(MSG_ENTITY, scores_label[i]);
		WriteByte(MSG_ENTITY, scores_flags[i]);
	}
	for(i = 0; i < MAX_TEAMSCORE; ++i)
	{
		WriteString(MSG_ENTITY, teamscores_label[i]);
		WriteByte(MSG_ENTITY, teamscores_flags[i]);
	}
	return TRUE;
}

void ScoreInfo_Init(float teams)
{
	scores_initialized = 1;
	if(teams >= 1)
		TeamScore_Spawn(COLOR_TEAM1, "Red");
	if(teams >= 2)
		TeamScore_Spawn(COLOR_TEAM2, "Blue");
	if(teams >= 3)
		TeamScore_Spawn(COLOR_TEAM3, "Yellow");
	if(teams >= 4)
		TeamScore_Spawn(COLOR_TEAM4, "Pink");
	entity si;
	si = spawn();
	Net_LinkEntity(si);
	si.classname = "csqc_score_info";
	si.SendEntity = ScoreInfo_SendEntity;
	si.Version = 1;
}

/*
 * per-player score entities
 */

float PlayerScore_SendEntity()
{
	float i;

	WriteByte(MSG_ENTITY, ENT_CLIENT_SCORES);
	WriteByte(MSG_ENTITY, num_for_edict(self.owner));
	for(i = 0; i < MAX_SCORE; ++i)
		WriteShort(MSG_ENTITY, self.scores[i]);

	return TRUE;
}

void PlayerScore_Clear(entity player)
{
	entity sk;
	float i;

	if(teamscores_entities_count)
		return;
	if(g_lms)
		return;

	sk = player.scorekeeper;
	for(i = 0; i < MAX_SCORE; ++i)
		sk.(scores[i]) = 0;
	sk.Version += 1;
}

void Score_ClearAll()
{
	entity p, sk;
	float i;
	FOR_EACH_CLIENTSLOT(p)
	{
		sk = p.scorekeeper;
		if(!sk)
			continue;
		for(i = 0; i < MAX_SCORE; ++i)
			sk.(scores[i]) = 0;
		sk.Version += 1;
	}
	for(i = 0; i < 16; ++i)
	{
		sk = teamscorekeepers[i];
		if(!sk)
			continue;
		for(i = 0; i < MAX_SCORE; ++i)
			sk.(teamscores[i]) = 0;
		sk.Version += 1;
	}
}

void PlayerScore_Attach(entity player)
{
	entity sk;
	if(player.scorekeeper)
		error("player already has a scorekeeper");
	sk = spawn();
	sk.owner = player;
	sk.Version = 1;
	sk.SendEntity = PlayerScore_SendEntity;
	Net_LinkEntity(sk);
	player.scorekeeper = sk;
}

void PlayerScore_Detach(entity player)
{
	if(!player.scorekeeper)
		error("player has no scorekeeper");
	remove(player.scorekeeper);
	player.scorekeeper = world;
}

float PlayerScore_Add(entity player, float scorefield, float score)
{
	entity s;
	if(!scores_initialized) return 0; // FIXME remove this when everything uses this system
	s = player.scorekeeper;
	if(!s)
		error("Adding score to unknown player!");
	if(score)
		s.Version += 1;
	return (s.(scores[scorefield]) += score);
}

void PlayerTeamScore_Add(entity player, float pscorefield, float tscorefield, float score)
{
	PlayerScore_Add(player, pscorefield, score);
	if(teamscores_entities_count) // only for teamplay
		TeamScore_Add(player, tscorefield, score);
}

float PlayerScore_Compare(entity t1, entity t2)
{
	if(!t1 || !t2) return (!t2) - !t1;

	vector result;
	float i;
	for(i = 0; i < MAX_SCORE; ++i)
	{
		var .float f;
		f = scores[i];
		result = ScoreField_Compare(t1, t2, f, scores_flags[i], result);
	}
	return result_x;
}

void WinningConditionHelper()
{
	float c;
	if(teamscores_entities_count)
	{
		float t;
		WinningConditionHelper_equality = 1;
		WinningConditionHelper_winnerteam = 0;
		for(t = 1; t < 16; ++t)
		{
			entity sk1, sk2;
			sk1 = teamscorekeepers[WinningConditionHelper_winnerteam];
			sk2 = teamscorekeepers[t];
			c = TeamScore_Compare(sk1, sk2);
			if(c == 0)
				WinningConditionHelper_equality = 1;
			else if(c < 0)
			{
				WinningConditionHelper_equality = 0;
				WinningConditionHelper_winnerteam = t;
			}
		}

		WinningConditionHelper_topscore = teamscorekeepers[WinningConditionHelper_winnerteam].teamscores_primary;

		WinningConditionHelper_winner = world;
		if(WinningConditionHelper_equality)
			WinningConditionHelper_winnerteam = -1;
		else
			++WinningConditionHelper_winnerteam; // map to Nexuiz team numbers (as opposed to colors)
	}
	else
	{
		entity p;
		WinningConditionHelper_equality = 1;
		WinningConditionHelper_winner = world;
		FOR_EACH_PLAYER(p)
		{
			c = PlayerScore_Compare(WinningConditionHelper_winner.scorekeeper, p.scorekeeper);
			if(c == 0)
				WinningConditionHelper_equality = 1;
			else if(c < 0)
			{
				WinningConditionHelper_equality = 0;
				WinningConditionHelper_winner = p;
			}
		}

		WinningConditionHelper_topscore = WinningConditionHelper_winner.scorekeeper.scores_primary;

		if(WinningConditionHelper_equality)
			WinningConditionHelper_winner = world;
		WinningConditionHelper_winnerteam = -1;
	}
}

void Score_DebugPrint()
{
	entity p, sk;
	float i, t;

	print("netname");
	for(i = 0; i < MAX_SCORE; ++i)
		print(":", scores_label[i]);
	print("\n");
	FOR_EACH_PLAYER(p)
	{
		sk = p.scorekeeper;
		print(p.netname);
		for(i = 0; i < MAX_SCORE; ++i)
			print(":", ftos(sk.(scores[i])));
		print("\n");
	}

	print("teamname");
	for(i = 0; i < MAX_TEAMSCORE; ++i)
		print(":", teamscores_label[i]);
	print("\n");
	for(t = 0; t < 16; ++t)
	{
		sk = teamscorekeepers[t];
		if(sk)
		{
			print(ftos(t));
			for(i = 0; i < MAX_TEAMSCORE; ++i)
				print(":", ftos(sk.(teamscores[i])));
			print("\n");
		}
	}
}
