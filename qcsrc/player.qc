
void PlayerHurt (vector hitloc, float damage)
{
	te_blood (hitloc, '0 0 20', floor (damage / 2));
}

void PlayerDie (void)
{
	
}