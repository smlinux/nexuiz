float (entity e, float healamount, float ignore) T_Heal =
{
	if ((e.health <= 0))
	{
		return (0);
	}
	if ((!ignore && (e.health >= e.max_health)))
	{
		return (0);
	}
	healamount = ceil (healamount);
	e.health = (e.health + healamount);
	if ((!ignore && (e.health >= e.max_health)))
	{
		e.health = e.max_health;
	}
	if ((e.health > 250))
	{

		e.health = 250;
	}
	/*					// There are no snipers in NexTF
	if (e.leg_damage)
	{
		if ((e.health > 95))
		{
			e.leg_damage = 0;
		}
		else
		{
			e.leg_damage = (e.leg_damage - ceil ((e.health / 20)));
		}
		if ((e.leg_damage < 1))
		{
			e.leg_damage = 0;
		}
		TeamFortress_SetSpeed (e);
	}*/
	return (1);
};