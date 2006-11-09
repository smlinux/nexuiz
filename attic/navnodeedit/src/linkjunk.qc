void (entity navn, float field, float flag) LFlagChange =
{
	if (!navn)
		return;
	if (field == -1)
	{
		if (self.other_navnode == self.current_navnode)
			return;
		if (navn.link0 == self.other_navnode)
			field = 0;
		else if (navn.link1 == self.other_navnode)
			field = 1;
		else if (navn.link2 == self.other_navnode)
			field = 2;
		else if (navn.link3 == self.other_navnode)
			field = 3;
		else if (navn.link4 == self.other_navnode)
			field = 4;
		else if (navn.link5 == self.other_navnode)
			field = 5;
		else if (navn.link6 == self.other_navnode)
			field = 6;
		else if (navn.link7 == self.other_navnode)
			field = 7;
		else if (navn.link8 == self.other_navnode)
			field = 8;
		else if (navn.link9 == self.other_navnode)
			field = 9;
		else if (navn.link10 == self.other_navnode)
			field = 10;
		else if (navn.link11 == self.other_navnode)
			field = 11;
		else if (navn.link12 == self.other_navnode)
			field = 12;
		else if (navn.link13 == self.other_navnode)
			field = 13;
		else if (navn.link14 == self.other_navnode)
			field = 14;
		else if (navn.link15 == self.other_navnode)
			field = 15;
		else if (navn.link16 == self.other_navnode)
			field = 16;
		else if (navn.link17 == self.other_navnode)
			field = 17;
		else if (navn.link18 == self.other_navnode)
			field = 18;
		else if (navn.link19 == self.other_navnode)
			field = 19;
		else
			return;
	}
	if (field == 0)
	{
		if (navn.lflags0 & flag)
			navn.lflags0 = navn.lflags0 - (navn.lflags0 & flag);
		else
			navn.lflags0 = navn.lflags0 | flag;
	}
	else if (field == 1)
	{
		if (navn.lflags1 & flag)
			navn.lflags1 = navn.lflags1 - (navn.lflags1 & flag);
		else
			navn.lflags1 = navn.lflags1 | flag;
	}
	else if (field == 2)
	{
		if (navn.lflags2 & flag)
			navn.lflags2 = navn.lflags2 - (navn.lflags2 & flag);
		else
			navn.lflags2 = navn.lflags2 | flag;
	}
	else if (field == 3)
	{
		if (navn.lflags3 & flag)
			navn.lflags3 = navn.lflags3 - (navn.lflags3 & flag);
		else
			navn.lflags3 = navn.lflags3 | flag;
	}
	else if (field == 4)
	{
		if (navn.lflags4 & flag)
			navn.lflags4 = navn.lflags4 - (navn.lflags4 & flag);
		else
			navn.lflags4 = navn.lflags4 | flag;
	}
	else if (field == 5)
	{
		if (navn.lflags5 & flag)
			navn.lflags5 = navn.lflags5 - (navn.lflags5 & flag);
		else
			navn.lflags5 = navn.lflags5 | flag;
	}
	else if (field == 6)
	{
		if (navn.lflags6 & flag)
			navn.lflags6 = navn.lflags6 - (navn.lflags6 & flag);
		else
			navn.lflags6 = navn.lflags6 | flag;
	}
	else if (field == 7)
	{
		if (navn.lflags7 & flag)
			navn.lflags7 = navn.lflags7 - (navn.lflags7 & flag);
		else
			navn.lflags7 = navn.lflags7 | flag;
	}
	else if (field == 8)
	{
		if (navn.lflags8 & flag)
			navn.lflags8 = navn.lflags8 - (navn.lflags8 & flag);
		else
			navn.lflags8 = navn.lflags8 | flag;
	}
	else if (field == 9)
	{
		if (navn.lflags9 & flag)
			navn.lflags9 = navn.lflags9 - (navn.lflags9 & flag);
		else
			navn.lflags9 = navn.lflags9 | flag;
	}
	else if (field == 10)
	{
		if (navn.lflags10 & flag)
			navn.lflags10 = navn.lflags10 - (navn.lflags10 & flag);
		else
			navn.lflags10 = navn.lflags10 | flag;
	}
	else if (field == 11)
	{
		if (navn.lflags11 & flag)
			navn.lflags11 = navn.lflags11 - (navn.lflags11 & flag);
		else
			navn.lflags11 = navn.lflags11 | flag;
	}
	else if (field == 12)
	{
		if (navn.lflags12 & flag)
			navn.lflags12 = navn.lflags12 - (navn.lflags12 & flag);
		else
			navn.lflags12 = navn.lflags12 | flag;
	}
	else if (field == 13)
	{
		if (navn.lflags13 & flag)
			navn.lflags13 = navn.lflags13 - (navn.lflags13 & flag);
		else
			navn.lflags13 = navn.lflags13 | flag;
	}
	else if (field == 14)
	{
		if (navn.lflags14 & flag)
			navn.lflags14 = navn.lflags14 - (navn.lflags14 & flag);
		else
			navn.lflags14 = navn.lflags14 | flag;
	}
	else if (field == 15)
	{
		if (navn.lflags15 & flag)
			navn.lflags15 = navn.lflags15 - (navn.lflags15 & flag);
		else
			navn.lflags15 = navn.lflags15 | flag;
	}
	else if (field == 16)
	{
		if (navn.lflags16 & flag)
			navn.lflags16 = navn.lflags16 - (navn.lflags16 & flag);
		else
			navn.lflags16 = navn.lflags16 | flag;
	}
	else if (field == 17)
	{
		if (navn.lflags17 & flag)
			navn.lflags17 = navn.lflags17 - (navn.lflags17 & flag);
		else
			navn.lflags17 = navn.lflags17 | flag;
	}
	else if (field == 18)
	{
		if (navn.lflags18 & flag)
			navn.lflags18 = navn.lflags18 - (navn.lflags18 & flag);
		else
			navn.lflags18 = navn.lflags18 | flag;
	}
	else if (field == 19)
	{
		if (navn.lflags19 & flag)
			navn.lflags19 = navn.lflags19 - (navn.lflags19 & flag);
		else
			navn.lflags19 = navn.lflags19 | flag;
	}
};

void (entity navcurrent, entity navother) RemoteLinkHandling =
{
	if (!navcurrent)
		return;
	if (!navother)
		return;
	if (navother == navcurrent)
		return;
	else if (navother == navcurrent.link0)
	{
		if (navcurrent.lflags0 & LF_REMOTE)
		{
			navother.effects = 0;
			navother.frame = 20;
			navcurrent.link0 = world;
			LFlagChange(navcurrent, 0, LF_REMOTE);
		}
		return;
	}
	else if (navother == navcurrent.link1)
	{
		if (navcurrent.lflags1 & LF_REMOTE)
		{
			navother.effects = 0;
			navother.frame = 20;
			navcurrent.link1 = world;
			LFlagChange(navcurrent, 1, LF_REMOTE);
		}
		return;
	}
	else if (navother == navcurrent.link2)
	{
		if (navcurrent.lflags2 & LF_REMOTE)
		{
			navother.effects = 0;
			navother.frame = 20;
			navcurrent.link2 = world;
			LFlagChange(navcurrent, 2, LF_REMOTE);
		}
		return;
	}
	else if (navother == navcurrent.link3)
	{
		if (navcurrent.lflags3 & LF_REMOTE)
		{
			navother.effects = 0;
			navother.frame = 20;
			navcurrent.link3 = world;
			LFlagChange(navcurrent, 3, LF_REMOTE);
		}
		return;
	}
	else if (navother == navcurrent.link4)
	{
		if (navcurrent.lflags4 & LF_REMOTE)
		{
			navother.effects = 0;
			navother.frame = 20;
			navcurrent.link4 = world;
			LFlagChange(navcurrent, 4, LF_REMOTE);
		}
		return;
	}
	else if (navother == navcurrent.link5)
	{
		if (navcurrent.lflags5 & LF_REMOTE)
		{
			navother.effects = 0;
			navother.frame = 20;
			navcurrent.link5 = world;
			LFlagChange(navcurrent, 5, LF_REMOTE);
		}
		return;
	}
	else if (navother == navcurrent.link6)
	{
		if (navcurrent.lflags6 & LF_REMOTE)
		{
			navother.effects = 0;
			navother.frame = 20;
			navcurrent.link6 = world;
			LFlagChange(navcurrent, 6, LF_REMOTE);
		}
		return;
	}
	else if (navother == navcurrent.link7)
	{
		if (navcurrent.lflags7 & LF_REMOTE)
		{
			navother.effects = 0;
			navother.frame = 20;
			navcurrent.link7 = world;
			LFlagChange(navcurrent, 7, LF_REMOTE);
		}
		return;
	}
	else if (navother == navcurrent.link8)
	{
		if (navcurrent.lflags8 & LF_REMOTE)
		{
			navother.effects = 0;
			navother.frame = 20;
			navcurrent.link8 = world;
			LFlagChange(navcurrent, 8, LF_REMOTE);
		}
		return;
	}
	else if (navother == navcurrent.link9)
	{
		if (navcurrent.lflags9 & LF_REMOTE)
		{
			navother.effects = 0;
			navother.frame = 20;
			navcurrent.link9 = world;
			LFlagChange(navcurrent, 9, LF_REMOTE);
		}
		return;
	}
	else if (navother == navcurrent.link10)
	{
		if (navcurrent.lflags10 & LF_REMOTE)
		{
			navother.effects = 0;
			navother.frame = 20;
			navcurrent.link10 = world;
			LFlagChange(navcurrent, 10, LF_REMOTE);
		}
		return;
	}
	else if (navother == navcurrent.link11)
	{
		if (navcurrent.lflags11 & LF_REMOTE)
		{
			navother.effects = 0;
			navother.frame = 20;
			navcurrent.link11 = world;
			LFlagChange(navcurrent, 11, LF_REMOTE);
		}
		return;
	}
	else if (navother == navcurrent.link12)
	{
		if (navcurrent.lflags12 & LF_REMOTE)
		{
			navother.effects = 0;
			navother.frame = 20;
			navcurrent.link12 = world;
			LFlagChange(navcurrent, 12, LF_REMOTE);
		}
		return;
	}
	else if (navother == navcurrent.link13)
	{
		if (navcurrent.lflags13 & LF_REMOTE)
		{
			navother.effects = 0;
			navother.frame = 20;
			navcurrent.link13 = world;
			LFlagChange(navcurrent, 13, LF_REMOTE);
		}
		return;
	}
	else if (navother == navcurrent.link14)
	{
		if (navcurrent.lflags14 & LF_REMOTE)
		{
			navother.effects = 0;
			navother.frame = 20;
			navcurrent.link14 = world;
			LFlagChange(navcurrent, 14, LF_REMOTE);
		}
		return;
	}
	else if (navother == navcurrent.link15)
	{
		if (navcurrent.lflags15 & LF_REMOTE)
		{
			navother.effects = 0;
			navother.frame = 20;
			navcurrent.link15 = world;
			LFlagChange(navcurrent, 15, LF_REMOTE);
		}
		return;
	}
	else if (navother == navcurrent.link16)
	{
		if (navcurrent.lflags16 & LF_REMOTE)
		{
			navother.effects = 0;
			navother.frame = 20;
			navcurrent.link16 = world;
			LFlagChange(navcurrent, 16, LF_REMOTE);
		}
		return;
	}
	else if (navother == navcurrent.link17)
	{
		if (navcurrent.lflags17 & LF_REMOTE)
		{
			navother.effects = 0;
			navother.frame = 20;
			navcurrent.link17 = world;
			LFlagChange(navcurrent, 17, LF_REMOTE);
		}
		return;
	}
	else if (navother == navcurrent.link18)
	{
		if (navcurrent.lflags18 & LF_REMOTE)
		{
			navother.effects = 0;
			navother.frame = 20;
			navcurrent.link18 = world;
			LFlagChange(navcurrent, 18, LF_REMOTE);
		}
		return;
	}
	else if (navother == navcurrent.link19)
	{
		if (navcurrent.lflags19 & LF_REMOTE)
		{
			navother.effects = 0;
			navother.frame = 20;
			navcurrent.link19 = world;
			LFlagChange(navcurrent, 19, LF_REMOTE);
		}
		return;
	}

	if (!navcurrent.link0)
	{
		navcurrent.link0 = navother;
		LFlagChange(navcurrent, 0, LF_REMOTE);
	}
	else if (!navcurrent.link1)
	{
		navcurrent.link1 = navother;
		LFlagChange(navcurrent, 1, LF_REMOTE);
	}
	else if (!navcurrent.link2)
	{
		navcurrent.link2 = navother;
		LFlagChange(navcurrent, 2, LF_REMOTE);
	}
	else if (!navcurrent.link3)
	{
		navcurrent.link3 = navother;
		LFlagChange(navcurrent, 3, LF_REMOTE);
	}
	else if (!navcurrent.link4)
	{
		navcurrent.link4 = navother;
		LFlagChange(navcurrent, 4, LF_REMOTE);
	}
	else if (!navcurrent.link5)
	{
		navcurrent.link5 = navother;
		LFlagChange(navcurrent, 5, LF_REMOTE);
	}
	else if (!navcurrent.link6)
	{
		navcurrent.link6 = navother;
		LFlagChange(navcurrent, 6, LF_REMOTE);
	}
	else if (!navcurrent.link7)
	{
		navcurrent.link7 = navother;
		LFlagChange(navcurrent, 7, LF_REMOTE);
	}
	else if (!navcurrent.link8)
	{
		navcurrent.link8 = navother;
		LFlagChange(navcurrent, 8, LF_REMOTE);
	}
	else if (!navcurrent.link9)
	{
		navcurrent.link9 = navother;
		LFlagChange(navcurrent, 9, LF_REMOTE);
	}
	else if (!navcurrent.link10)
	{
		navcurrent.link10 = navother;
		LFlagChange(navcurrent, 10, LF_REMOTE);
	}
	else if (!navcurrent.link11)
	{
		navcurrent.link11 = navother;
		LFlagChange(navcurrent, 11, LF_REMOTE);
	}
	else if (!navcurrent.link12)
	{
		navcurrent.link12 = navother;
		LFlagChange(navcurrent, 12, LF_REMOTE);
	}
	else if (!navcurrent.link13)
	{
		navcurrent.link13 = navother;
		LFlagChange(navcurrent, 13, LF_REMOTE);
	}
	else if (!navcurrent.link14)
	{
		navcurrent.link14 = navother;
		LFlagChange(navcurrent, 14, LF_REMOTE);
	}
	else if (!navcurrent.link15)
	{
		navcurrent.link15 = navother;
		LFlagChange(navcurrent, 15, LF_REMOTE);
	}
	else if (!navcurrent.link16)
	{
		navcurrent.link16 = navother;
		LFlagChange(navcurrent, 16, LF_REMOTE);
	}
	else if (!navcurrent.link17)
	{
		navcurrent.link17 = navother;
		LFlagChange(navcurrent, 17, LF_REMOTE);
	}
	else if (!navcurrent.link18)
	{
		navcurrent.link18 = navother;
		LFlagChange(navcurrent, 18, LF_REMOTE);
	}
	else if (!navcurrent.link19)
	{
		navcurrent.link19 = navother;
		LFlagChange(navcurrent, 19, LF_REMOTE);
	}
	else
		dprint("WARNING: Too many linking NavNodes!\n");
};

void(entity navn, float start) PushLinks =
{
	if (start == 0)
	{
		navn.link0 = navn.link1;
		navn.link1 = navn.link2;
		navn.link2 = navn.link3;
		navn.link3 = navn.link4;
		navn.link4 = navn.link5;
		navn.link5 = navn.link6;
		navn.link6 = navn.link7;
		navn.link7 = navn.link8;
		navn.link8 = navn.link9;
		navn.link9 = navn.link10;
		navn.link10 = navn.link11;
		navn.link11 = navn.link12;
		navn.link12 = navn.link13;
		navn.link13 = navn.link14;
		navn.link14 = navn.link15;
		navn.link15 = navn.link16;
		navn.link16 = navn.link17;
		navn.link17 = navn.link18;
		navn.link18 = navn.link19;
		navn.link19 = world;
		navn.lflags0 = navn.lflags1;
		navn.lflags1 = navn.lflags2;
		navn.lflags2 = navn.lflags3;
		navn.lflags3 = navn.lflags4;
		navn.lflags4 = navn.lflags5;
		navn.lflags5 = navn.lflags6;
		navn.lflags6 = navn.lflags7;
		navn.lflags7 = navn.lflags8;
		navn.lflags8 = navn.lflags9;
		navn.lflags9 = navn.lflags10;
		navn.lflags10 = navn.lflags11;
		navn.lflags11 = navn.lflags12;
		navn.lflags12 = navn.lflags13;
		navn.lflags13 = navn.lflags14;
		navn.lflags14 = navn.lflags15;
		navn.lflags15 = navn.lflags16;
		navn.lflags16 = navn.lflags17;
		navn.lflags17 = navn.lflags18;
		navn.lflags18 = navn.lflags19;
		navn.lflags19 = 0;
	}
	else if (start == 1)
	{
		navn.link1 = navn.link2;
		navn.link2 = navn.link3;
		navn.link3 = navn.link4;
		navn.link4 = navn.link5;
		navn.link5 = navn.link6;
		navn.link6 = navn.link7;
		navn.link7 = navn.link8;
		navn.link8 = navn.link9;
		navn.link9 = navn.link10;
		navn.link10 = navn.link11;
		navn.link11 = navn.link12;
		navn.link12 = navn.link13;
		navn.link13 = navn.link14;
		navn.link14 = navn.link15;
		navn.link15 = navn.link16;
		navn.link16 = navn.link17;
		navn.link17 = navn.link18;
		navn.link18 = navn.link19;
		navn.link19 = world;
		navn.lflags1 = navn.lflags2;
		navn.lflags2 = navn.lflags3;
		navn.lflags3 = navn.lflags4;
		navn.lflags4 = navn.lflags5;
		navn.lflags5 = navn.lflags6;
		navn.lflags6 = navn.lflags7;
		navn.lflags7 = navn.lflags8;
		navn.lflags8 = navn.lflags9;
		navn.lflags9 = navn.lflags10;
		navn.lflags10 = navn.lflags11;
		navn.lflags11 = navn.lflags12;
		navn.lflags12 = navn.lflags13;
		navn.lflags13 = navn.lflags14;
		navn.lflags14 = navn.lflags15;
		navn.lflags15 = navn.lflags16;
		navn.lflags16 = navn.lflags17;
		navn.lflags17 = navn.lflags18;
		navn.lflags18 = navn.lflags19;
		navn.lflags19 = 0;
	}
	else if (start == 2)
	{
		navn.link2 = navn.link3;
		navn.link3 = navn.link4;
		navn.link4 = navn.link5;
		navn.link5 = navn.link6;
		navn.link6 = navn.link7;
		navn.link7 = navn.link8;
		navn.link8 = navn.link9;
		navn.link9 = navn.link10;
		navn.link10 = navn.link11;
		navn.link11 = navn.link12;
		navn.link12 = navn.link13;
		navn.link13 = navn.link14;
		navn.link14 = navn.link15;
		navn.link15 = navn.link16;
		navn.link16 = navn.link17;
		navn.link17 = navn.link18;
		navn.link18 = navn.link19;
		navn.link19 = world;
		navn.lflags2 = navn.lflags3;
		navn.lflags3 = navn.lflags4;
		navn.lflags4 = navn.lflags5;
		navn.lflags5 = navn.lflags6;
		navn.lflags6 = navn.lflags7;
		navn.lflags7 = navn.lflags8;
		navn.lflags8 = navn.lflags9;
		navn.lflags9 = navn.lflags10;
		navn.lflags10 = navn.lflags11;
		navn.lflags11 = navn.lflags12;
		navn.lflags12 = navn.lflags13;
		navn.lflags13 = navn.lflags14;
		navn.lflags14 = navn.lflags15;
		navn.lflags15 = navn.lflags16;
		navn.lflags16 = navn.lflags17;
		navn.lflags17 = navn.lflags18;
		navn.lflags18 = navn.lflags19;
		navn.lflags19 = 0;
	}
	else if (start == 3)
	{
		navn.link3 = navn.link4;
		navn.link4 = navn.link5;
		navn.link5 = navn.link6;
		navn.link6 = navn.link7;
		navn.link7 = navn.link8;
		navn.link8 = navn.link9;
		navn.link9 = navn.link10;
		navn.link10 = navn.link11;
		navn.link11 = navn.link12;
		navn.link12 = navn.link13;
		navn.link13 = navn.link14;
		navn.link14 = navn.link15;
		navn.link15 = navn.link16;
		navn.link16 = navn.link17;
		navn.link17 = navn.link18;
		navn.link18 = navn.link19;
		navn.link19 = world;
		navn.lflags3 = navn.lflags4;
		navn.lflags4 = navn.lflags5;
		navn.lflags5 = navn.lflags6;
		navn.lflags6 = navn.lflags7;
		navn.lflags7 = navn.lflags8;
		navn.lflags8 = navn.lflags9;
		navn.lflags9 = navn.lflags10;
		navn.lflags10 = navn.lflags11;
		navn.lflags11 = navn.lflags12;
		navn.lflags12 = navn.lflags13;
		navn.lflags13 = navn.lflags14;
		navn.lflags14 = navn.lflags15;
		navn.lflags15 = navn.lflags16;
		navn.lflags16 = navn.lflags17;
		navn.lflags17 = navn.lflags18;
		navn.lflags18 = navn.lflags19;
		navn.lflags19 = 0;
	}
	else if (start == 4)
	{
		navn.link4 = navn.link5;
		navn.link5 = navn.link6;
		navn.link6 = navn.link7;
		navn.link7 = navn.link8;
		navn.link8 = navn.link9;
		navn.link9 = navn.link10;
		navn.link10 = navn.link11;
		navn.link11 = navn.link12;
		navn.link12 = navn.link13;
		navn.link13 = navn.link14;
		navn.link14 = navn.link15;
		navn.link15 = navn.link16;
		navn.link16 = navn.link17;
		navn.link17 = navn.link18;
		navn.link18 = navn.link19;
		navn.link19 = world;
		navn.lflags4 = navn.lflags5;
		navn.lflags5 = navn.lflags6;
		navn.lflags6 = navn.lflags7;
		navn.lflags7 = navn.lflags8;
		navn.lflags8 = navn.lflags9;
		navn.lflags9 = navn.lflags10;
		navn.lflags10 = navn.lflags11;
		navn.lflags11 = navn.lflags12;
		navn.lflags12 = navn.lflags13;
		navn.lflags13 = navn.lflags14;
		navn.lflags14 = navn.lflags15;
		navn.lflags15 = navn.lflags16;
		navn.lflags16 = navn.lflags17;
		navn.lflags17 = navn.lflags18;
		navn.lflags18 = navn.lflags19;
		navn.lflags19 = 0;
	}
	else if (start == 5)
	{
		navn.link5 = navn.link6;
		navn.link6 = navn.link7;
		navn.link7 = navn.link8;
		navn.link8 = navn.link9;
		navn.link9 = navn.link10;
		navn.link10 = navn.link11;
		navn.link11 = navn.link12;
		navn.link12 = navn.link13;
		navn.link13 = navn.link14;
		navn.link14 = navn.link15;
		navn.link15 = navn.link16;
		navn.link16 = navn.link17;
		navn.link17 = navn.link18;
		navn.link18 = navn.link19;
		navn.link19 = world;
		navn.lflags5 = navn.lflags6;
		navn.lflags6 = navn.lflags7;
		navn.lflags7 = navn.lflags8;
		navn.lflags8 = navn.lflags9;
		navn.lflags9 = navn.lflags10;
		navn.lflags10 = navn.lflags11;
		navn.lflags11 = navn.lflags12;
		navn.lflags12 = navn.lflags13;
		navn.lflags13 = navn.lflags14;
		navn.lflags14 = navn.lflags15;
		navn.lflags15 = navn.lflags16;
		navn.lflags16 = navn.lflags17;
		navn.lflags17 = navn.lflags18;
		navn.lflags18 = navn.lflags19;
		navn.lflags19 = 0;
	}
	else if (start == 6)
	{
		navn.link6 = navn.link7;
		navn.link7 = navn.link8;
		navn.link8 = navn.link9;
		navn.link9 = navn.link10;
		navn.link10 = navn.link11;
		navn.link11 = navn.link12;
		navn.link12 = navn.link13;
		navn.link13 = navn.link14;
		navn.link14 = navn.link15;
		navn.link15 = navn.link16;
		navn.link16 = navn.link17;
		navn.link17 = navn.link18;
		navn.link18 = navn.link19;
		navn.link19 = world;
		navn.lflags6 = navn.lflags7;
		navn.lflags7 = navn.lflags8;
		navn.lflags8 = navn.lflags9;
		navn.lflags9 = navn.lflags10;
		navn.lflags10 = navn.lflags11;
		navn.lflags11 = navn.lflags12;
		navn.lflags12 = navn.lflags13;
		navn.lflags13 = navn.lflags14;
		navn.lflags14 = navn.lflags15;
		navn.lflags15 = navn.lflags16;
		navn.lflags16 = navn.lflags17;
		navn.lflags17 = navn.lflags18;
		navn.lflags18 = navn.lflags19;
		navn.lflags19 = 0;
	}
	else if (start == 7)
	{
		navn.link7 = navn.link8;
		navn.link8 = navn.link9;
		navn.link9 = navn.link10;
		navn.link10 = navn.link11;
		navn.link11 = navn.link12;
		navn.link12 = navn.link13;
		navn.link13 = navn.link14;
		navn.link14 = navn.link15;
		navn.link15 = navn.link16;
		navn.link16 = navn.link17;
		navn.link17 = navn.link18;
		navn.link18 = navn.link19;
		navn.link19 = world;
		navn.lflags7 = navn.lflags8;
		navn.lflags8 = navn.lflags9;
		navn.lflags9 = navn.lflags10;
		navn.lflags10 = navn.lflags11;
		navn.lflags11 = navn.lflags12;
		navn.lflags12 = navn.lflags13;
		navn.lflags13 = navn.lflags14;
		navn.lflags14 = navn.lflags15;
		navn.lflags15 = navn.lflags16;
		navn.lflags16 = navn.lflags17;
		navn.lflags17 = navn.lflags18;
		navn.lflags18 = navn.lflags19;
		navn.lflags19 = 0;
	}
	else if (start == 8)
	{
		navn.link8 = navn.link9;
		navn.link9 = navn.link10;
		navn.link10 = navn.link11;
		navn.link11 = navn.link12;
		navn.link12 = navn.link13;
		navn.link13 = navn.link14;
		navn.link14 = navn.link15;
		navn.link15 = navn.link16;
		navn.link16 = navn.link17;
		navn.link17 = navn.link18;
		navn.link18 = navn.link19;
		navn.link19 = world;
		navn.lflags8 = navn.lflags9;
		navn.lflags9 = navn.lflags10;
		navn.lflags10 = navn.lflags11;
		navn.lflags11 = navn.lflags12;
		navn.lflags12 = navn.lflags13;
		navn.lflags13 = navn.lflags14;
		navn.lflags14 = navn.lflags15;
		navn.lflags15 = navn.lflags16;
		navn.lflags16 = navn.lflags17;
		navn.lflags17 = navn.lflags18;
		navn.lflags18 = navn.lflags19;
		navn.lflags19 = 0;
	}
	else if (start == 9)
	{
		navn.link9 = navn.link10;
		navn.link10 = navn.link11;
		navn.link11 = navn.link12;
		navn.link12 = navn.link13;
		navn.link13 = navn.link14;
		navn.link14 = navn.link15;
		navn.link15 = navn.link16;
		navn.link16 = navn.link17;
		navn.link17 = navn.link18;
		navn.link18 = navn.link19;
		navn.link19 = world;
		navn.lflags9 = navn.lflags10;
		navn.lflags10 = navn.lflags11;
		navn.lflags11 = navn.lflags12;
		navn.lflags12 = navn.lflags13;
		navn.lflags13 = navn.lflags14;
		navn.lflags14 = navn.lflags15;
		navn.lflags15 = navn.lflags16;
		navn.lflags16 = navn.lflags17;
		navn.lflags17 = navn.lflags18;
		navn.lflags18 = navn.lflags19;
		navn.lflags19 = 0;
	}
	else if (start == 10)
	{
		navn.link10 = navn.link11;
		navn.link11 = navn.link12;
		navn.link12 = navn.link13;
		navn.link13 = navn.link14;
		navn.link14 = navn.link15;
		navn.link15 = navn.link16;
		navn.link16 = navn.link17;
		navn.link17 = navn.link18;
		navn.link18 = navn.link19;
		navn.link19 = world;
		navn.lflags10 = navn.lflags11;
		navn.lflags11 = navn.lflags12;
		navn.lflags12 = navn.lflags13;
		navn.lflags13 = navn.lflags14;
		navn.lflags14 = navn.lflags15;
		navn.lflags15 = navn.lflags16;
		navn.lflags16 = navn.lflags17;
		navn.lflags17 = navn.lflags18;
		navn.lflags18 = navn.lflags19;
		navn.lflags19 = 0;
	}
	else if (start == 11)
	{
		navn.link11 = navn.link12;
		navn.link12 = navn.link13;
		navn.link13 = navn.link14;
		navn.link14 = navn.link15;
		navn.link15 = navn.link16;
		navn.link16 = navn.link17;
		navn.link17 = navn.link18;
		navn.link18 = navn.link19;
		navn.link19 = world;
		navn.lflags11 = navn.lflags12;
		navn.lflags12 = navn.lflags13;
		navn.lflags13 = navn.lflags14;
		navn.lflags14 = navn.lflags15;
		navn.lflags15 = navn.lflags16;
		navn.lflags16 = navn.lflags17;
		navn.lflags17 = navn.lflags18;
		navn.lflags18 = navn.lflags19;
		navn.lflags19 = 0;
	}
	else if (start == 12)
	{
		navn.link12 = navn.link13;
		navn.link13 = navn.link14;
		navn.link14 = navn.link15;
		navn.link15 = navn.link16;
		navn.link16 = navn.link17;
		navn.link17 = navn.link18;
		navn.link18 = navn.link19;
		navn.link19 = world;
		navn.lflags12 = navn.lflags13;
		navn.lflags13 = navn.lflags14;
		navn.lflags14 = navn.lflags15;
		navn.lflags15 = navn.lflags16;
		navn.lflags16 = navn.lflags17;
		navn.lflags17 = navn.lflags18;
		navn.lflags18 = navn.lflags19;
		navn.lflags19 = 0;
	}
	else if (start == 13)
	{
		navn.link13 = navn.link14;
		navn.link14 = navn.link15;
		navn.link15 = navn.link16;
		navn.link16 = navn.link17;
		navn.link17 = navn.link18;
		navn.link18 = navn.link19;
		navn.link19 = world;
		navn.lflags13 = navn.lflags14;
		navn.lflags14 = navn.lflags15;
		navn.lflags15 = navn.lflags16;
		navn.lflags16 = navn.lflags17;
		navn.lflags17 = navn.lflags18;
		navn.lflags18 = navn.lflags19;
		navn.lflags19 = 0;
	}
	else if (start == 14)
	{
		navn.link14 = navn.link15;
		navn.link15 = navn.link16;
		navn.link16 = navn.link17;
		navn.link17 = navn.link18;
		navn.link18 = navn.link19;
		navn.link19 = world;
		navn.lflags14 = navn.lflags15;
		navn.lflags15 = navn.lflags16;
		navn.lflags16 = navn.lflags17;
		navn.lflags17 = navn.lflags18;
		navn.lflags18 = navn.lflags19;
		navn.lflags19 = 0;
	}
	else if (start == 15)
	{
		navn.link15 = navn.link16;
		navn.link16 = navn.link17;
		navn.link17 = navn.link18;
		navn.link18 = navn.link19;
		navn.link19 = world;
		navn.lflags15 = navn.lflags16;
		navn.lflags16 = navn.lflags17;
		navn.lflags17 = navn.lflags18;
		navn.lflags18 = navn.lflags19;
		navn.lflags19 = 0;
	}
	else if (start == 16)
	{
		navn.link16 = navn.link17;
		navn.link17 = navn.link18;
		navn.link18 = navn.link19;
		navn.link19 = world;
		navn.lflags16 = navn.lflags17;
		navn.lflags17 = navn.lflags18;
		navn.lflags18 = navn.lflags19;
		navn.lflags19 = 0;
	}
	else if (start == 17)
	{
		navn.link17 = navn.link18;
		navn.link18 = navn.link19;
		navn.link19 = world;
		navn.lflags17 = navn.lflags18;
		navn.lflags18 = navn.lflags19;
		navn.lflags19 = 0;
	}
	else if (start == 18)
	{
		navn.link18 = navn.link19;
		navn.link19 = world;
		navn.lflags18 = navn.lflags19;
		navn.lflags19 = 0;
	}
	else if (start == 19)
	{
		navn.link19 = world;
		navn.lflags19 = 0;
	}
};