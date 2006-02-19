/*
==================================================
Menu.qc (originally) By: Chris Voss 3-18-99 (I simplified it a bit -Urre)
==================================================
*/

void(entity navn, entity delplane) RemovePlane;

void(float i) Select =
{
	local entity e;

	if (self.confirm == C_DELETE_NAVNODE)
	{
		if (i == 1)
		{
			if (self.current_navnode.plane_chain)
			{
				e = self.current_navnode.plane_chain;
				if (e)
				{
					e.think = SUB_Remove;
					e.nextthink = time;
					e = e.plane_next;
					while (e != self.current_navnode.plane_chain)
					{
						e.think = SUB_Remove;
						e.nextthink = time;
						e = e.plane_next;
					}
				}
			}
			e = navnode_chain;
			while (e)
			{
				if (e.link0 == self.current_navnode)
					PushLinks(e, 0);
				else if (e.link1 == self.current_navnode)
					PushLinks(e, 1);
				else if (e.link2 == self.current_navnode)
					PushLinks(e, 2);
				else if (e.link3 == self.current_navnode)
					PushLinks(e, 3);
				else if (e.link4 == self.current_navnode)
					PushLinks(e, 4);
				else if (e.link5 == self.current_navnode)
					PushLinks(e, 5);
				else if (e.link6 == self.current_navnode)
					PushLinks(e, 6);
				else if (e.link7 == self.current_navnode)
					PushLinks(e, 7);
				else if (e.link8 == self.current_navnode)
					PushLinks(e, 8);
				else if (e.link9 == self.current_navnode)
					PushLinks(e, 9);
				else if (e.link10 == self.current_navnode)
					PushLinks(e, 10);
				else if (e.link11 == self.current_navnode)
					PushLinks(e, 11);
				else if (e.link12 == self.current_navnode)
					PushLinks(e, 12);
				else if (e.link13 == self.current_navnode)
					PushLinks(e, 13);
				else if (e.link14 == self.current_navnode)
					PushLinks(e, 14);
				else if (e.link15 == self.current_navnode)
					PushLinks(e, 15);
				else if (e.link16 == self.current_navnode)
					PushLinks(e, 16);
				else if (e.link17 == self.current_navnode)
					PushLinks(e, 17);
				else if (e.link18 == self.current_navnode)
					PushLinks(e, 18);
				else if (e.link19 == self.current_navnode)
					PushLinks(e, 19);
				e = e.list;
			}
			remove(self.current_navnode);
		}
		self.current_navnode = world;
		self.confirm = 0;
		self.lockselection = FALSE;
		return;
	}
	else if (self.confirm == C_DELETE_PLANE)
	{
		if (i == 1)
			RemovePlane(self.current_navnode, self.current_plane);
		self.current_plane = world;
		self.confirm = 0;
		self.lockselection = FALSE;
		return;
	}
	else if (self.confirm == C_AUTOFLAGGER)
	{
		if (i == 1)
			AutoFlagger();
		self.current_plane = world;
		self.confirm = C_WAIT;
		self.lockselection = FALSE;
		return;
	}
	centerprint(self, "\n");
};

void() MainMenu =
{
	local string s;

	if (self.menu_time < time)
	{
		self.menu_time = time + 0.5;

		if (!self.confirm)
		{
			if (self.current_navnode)
			{
				s = strcat("^5Gridsize^7: ", ftos(self.gridsize));
				s = strcat(s, "\n^2self^7.origin: ");
				s = strcat(s, vtos(self.origin));
				s = strcat(s, "\nCURRENT AXIS: ");
				if (self.axis == 0)
					s = strcat(s, "^4X^7");
				else if (self.axis == 1)
					s = strcat(s, "^3Y^7");
				else if (self.axis == 2)
					s = strcat(s, "^1Z^7");
				if (self.current_navnode.sflags)
				{
					s = strcat(s, "\nnavnode.sflags:");
					if (self.current_navnode.sflags & S_TELEPORT)
						s = strcat(s, " S_TELEPORT");
					if (self.current_navnode.sflags & S_DOOR)
						s = strcat(s, " S_DOOR");
					if (self.current_navnode.sflags & S_TOUCH)
						s = strcat(s, " S_TOUCH");
				}
				if (self.current_navnode.lflags0)
				{
					s = strcat(s, "\nnavnode.lflags0:");
					if (self.current_navnode.lflags0 & LF_NOLINK)
						s = strcat(s, " LF_NOLINK");
					if (self.current_navnode.lflags0 & LF_NOWALK)
						s = strcat(s, " LF_NOWALK");
					if (self.current_navnode.lflags0 & LF_BAD)
						s = strcat(s, " LF_BAD");
					if (self.current_navnode.lflags0 & LF_BIGDROP)
						s = strcat(s, " LF_BIGDROP");
					if (self.current_navnode.lflags0 & LF_REMOTE)
						s = strcat(s, " LF_REMOTE");
				}
				if (self.current_navnode.lflags1)
				{
					s = strcat(s, "\nnavnode.lflags1:");
					if (self.current_navnode.lflags1 & LF_NOLINK)
						s = strcat(s, " LF_NOLINK");
					if (self.current_navnode.lflags1 & LF_NOWALK)
						s = strcat(s, " LF_NOWALK");
					if (self.current_navnode.lflags1 & LF_BAD)
						s = strcat(s, " LF_BAD");
					if (self.current_navnode.lflags1 & LF_BIGDROP)
						s = strcat(s, " LF_BIGDROP");
					if (self.current_navnode.lflags1 & LF_REMOTE)
						s = strcat(s, " LF_REMOTE");
				}
				if (self.current_navnode.lflags2)
				{
					s = strcat(s, "\nnavnode.lflags2:");
					if (self.current_navnode.lflags2 & LF_NOLINK)
						s = strcat(s, " LF_NOLINK");
					if (self.current_navnode.lflags2 & LF_NOWALK)
						s = strcat(s, " LF_NOWALK");
					if (self.current_navnode.lflags2 & LF_BAD)
						s = strcat(s, " LF_BAD");
					if (self.current_navnode.lflags2 & LF_BIGDROP)
						s = strcat(s, " LF_BIGDROP");
					if (self.current_navnode.lflags2 & LF_REMOTE)
						s = strcat(s, " LF_REMOTE");
				}
				if (self.current_navnode.lflags3)
				{
					s = strcat(s, "\nnavnode.lflags3:");
					if (self.current_navnode.lflags3 & LF_NOLINK)
						s = strcat(s, " LF_NOLINK");
					if (self.current_navnode.lflags3 & LF_NOWALK)
						s = strcat(s, " LF_NOWALK");
					if (self.current_navnode.lflags3 & LF_BAD)
						s = strcat(s, " LF_BAD");
					if (self.current_navnode.lflags3 & LF_BIGDROP)
						s = strcat(s, " LF_BIGDROP");
					if (self.current_navnode.lflags3 & LF_REMOTE)
						s = strcat(s, " LF_REMOTE");
				}
				if (self.current_navnode.lflags4)
				{
					s = strcat(s, "\nnavnode.lflags4:");
					if (self.current_navnode.lflags4 & LF_NOLINK)
						s = strcat(s, " LF_NOLINK");
					if (self.current_navnode.lflags4 & LF_NOWALK)
						s = strcat(s, " LF_NOWALK");
					if (self.current_navnode.lflags4 & LF_BAD)
						s = strcat(s, " LF_BAD");
					if (self.current_navnode.lflags4 & LF_BIGDROP)
						s = strcat(s, " LF_BIGDROP");
					if (self.current_navnode.lflags4 & LF_REMOTE)
						s = strcat(s, " LF_REMOTE");
				}
				if (self.current_navnode.lflags5)
				{
					s = strcat(s, "\nnavnode.lflags5:");
					if (self.current_navnode.lflags5 & LF_NOLINK)
						s = strcat(s, " LF_NOLINK");
					if (self.current_navnode.lflags5 & LF_NOWALK)
						s = strcat(s, " LF_NOWALK");
					if (self.current_navnode.lflags5 & LF_BAD)
						s = strcat(s, " LF_BAD");
					if (self.current_navnode.lflags5 & LF_BIGDROP)
						s = strcat(s, " LF_BIGDROP");
					if (self.current_navnode.lflags5 & LF_REMOTE)
						s = strcat(s, " LF_REMOTE");
				}
				if (self.current_navnode.lflags6)
				{
					s = strcat(s, "\nnavnode.lflags6:");
					if (self.current_navnode.lflags6 & LF_NOLINK)
						s = strcat(s, " LF_NOLINK");
					if (self.current_navnode.lflags6 & LF_NOWALK)
						s = strcat(s, " LF_NOWALK");
					if (self.current_navnode.lflags6 & LF_BAD)
						s = strcat(s, " LF_BAD");
					if (self.current_navnode.lflags6 & LF_BIGDROP)
						s = strcat(s, " LF_BIGDROP");
					if (self.current_navnode.lflags6 & LF_REMOTE)
						s = strcat(s, " LF_REMOTE");
				}
				if (self.current_navnode.lflags7)
				{
					s = strcat(s, "\nnavnode.lflags7:");
					if (self.current_navnode.lflags7 & LF_NOLINK)
						s = strcat(s, " LF_NOLINK");
					if (self.current_navnode.lflags7 & LF_NOWALK)
						s = strcat(s, " LF_NOWALK");
					if (self.current_navnode.lflags7 & LF_BAD)
						s = strcat(s, " LF_BAD");
					if (self.current_navnode.lflags7 & LF_BIGDROP)
						s = strcat(s, " LF_BIGDROP");
					if (self.current_navnode.lflags7 & LF_REMOTE)
						s = strcat(s, " LF_REMOTE");
				}
				if (self.current_navnode.lflags8)
				{
					s = strcat(s, "\nnavnode.lflags8:");
					if (self.current_navnode.lflags8 & LF_NOLINK)
						s = strcat(s, " LF_NOLINK");
					if (self.current_navnode.lflags8 & LF_NOWALK)
						s = strcat(s, " LF_NOWALK");
					if (self.current_navnode.lflags8 & LF_BAD)
						s = strcat(s, " LF_BAD");
					if (self.current_navnode.lflags8 & LF_BIGDROP)
						s = strcat(s, " LF_BIGDROP");
					if (self.current_navnode.lflags8 & LF_REMOTE)
						s = strcat(s, " LF_REMOTE");
				}
				if (self.current_navnode.lflags9)
				{
					s = strcat(s, "\nnavnode.lflags9:");
					if (self.current_navnode.lflags9 & LF_NOLINK)
						s = strcat(s, " LF_NOLINK");
					if (self.current_navnode.lflags9 & LF_NOWALK)
						s = strcat(s, " LF_NOWALK");
					if (self.current_navnode.lflags9 & LF_BAD)
						s = strcat(s, " LF_BAD");
					if (self.current_navnode.lflags9 & LF_BIGDROP)
						s = strcat(s, " LF_BIGDROP");
					if (self.current_navnode.lflags9 & LF_REMOTE)
						s = strcat(s, " LF_REMOTE");
				}
				if (self.current_navnode.lflags10)
				{
					s = strcat(s, "\nnavnode.lflags10:");
					if (self.current_navnode.lflags10 & LF_NOLINK)
						s = strcat(s, " LF_NOLINK");
					if (self.current_navnode.lflags10 & LF_NOWALK)
						s = strcat(s, " LF_NOWALK");
					if (self.current_navnode.lflags10 & LF_BAD)
						s = strcat(s, " LF_BAD");
					if (self.current_navnode.lflags10 & LF_BIGDROP)
						s = strcat(s, " LF_BIGDROP");
					if (self.current_navnode.lflags10 & LF_REMOTE)
						s = strcat(s, " LF_REMOTE");
				}
				if (self.current_navnode.lflags11)
				{
					s = strcat(s, "\nnavnode.lflags11:");
					if (self.current_navnode.lflags11 & LF_NOLINK)
						s = strcat(s, " LF_NOLINK");
					if (self.current_navnode.lflags11 & LF_NOWALK)
						s = strcat(s, " LF_NOWALK");
					if (self.current_navnode.lflags11 & LF_BAD)
						s = strcat(s, " LF_BAD");
					if (self.current_navnode.lflags11 & LF_BIGDROP)
						s = strcat(s, " LF_BIGDROP");
					if (self.current_navnode.lflags11 & LF_REMOTE)
						s = strcat(s, " LF_REMOTE");
				}
				if (self.current_navnode.lflags12)
				{
					s = strcat(s, "\nnavnode.lflags12:");
					if (self.current_navnode.lflags12 & LF_NOLINK)
						s = strcat(s, " LF_NOLINK");
					if (self.current_navnode.lflags12 & LF_NOWALK)
						s = strcat(s, " LF_NOWALK");
					if (self.current_navnode.lflags12 & LF_BAD)
						s = strcat(s, " LF_BAD");
					if (self.current_navnode.lflags12 & LF_BIGDROP)
						s = strcat(s, " LF_BIGDROP");
					if (self.current_navnode.lflags12 & LF_REMOTE)
						s = strcat(s, " LF_REMOTE");
				}
				if (self.current_navnode.lflags13)
				{
					s = strcat(s, "\nnavnode.lflags13:");
					if (self.current_navnode.lflags13 & LF_NOLINK)
						s = strcat(s, " LF_NOLINK");
					if (self.current_navnode.lflags13 & LF_NOWALK)
						s = strcat(s, " LF_NOWALK");
					if (self.current_navnode.lflags13 & LF_BAD)
						s = strcat(s, " LF_BAD");
					if (self.current_navnode.lflags13 & LF_BIGDROP)
						s = strcat(s, " LF_BIGDROP");
					if (self.current_navnode.lflags13 & LF_REMOTE)
						s = strcat(s, " LF_REMOTE");
				}
				if (self.current_navnode.lflags14)
				{
					s = strcat(s, "\nnavnode.lflags14:");
					if (self.current_navnode.lflags14 & LF_NOLINK)
						s = strcat(s, " LF_NOLINK");
					if (self.current_navnode.lflags14 & LF_NOWALK)
						s = strcat(s, " LF_NOWALK");
					if (self.current_navnode.lflags14 & LF_BAD)
						s = strcat(s, " LF_BAD");
					if (self.current_navnode.lflags14 & LF_BIGDROP)
						s = strcat(s, " LF_BIGDROP");
					if (self.current_navnode.lflags14 & LF_REMOTE)
						s = strcat(s, " LF_REMOTE");
				}
				if (self.current_navnode.lflags15)
				{
					s = strcat(s, "\nnavnode.lflags15:");
					if (self.current_navnode.lflags15 & LF_NOLINK)
						s = strcat(s, " LF_NOLINK");
					if (self.current_navnode.lflags15 & LF_NOWALK)
						s = strcat(s, " LF_NOWALK");
					if (self.current_navnode.lflags15 & LF_BAD)
						s = strcat(s, " LF_BAD");
					if (self.current_navnode.lflags15 & LF_BIGDROP)
						s = strcat(s, " LF_BIGDROP");
					if (self.current_navnode.lflags15 & LF_REMOTE)
						s = strcat(s, " LF_REMOTE");
				}
				if (self.current_navnode.lflags16)
				{
					s = strcat(s, "\nnavnode.lflags16:");
					if (self.current_navnode.lflags16 & LF_NOLINK)
						s = strcat(s, " LF_NOLINK");
					if (self.current_navnode.lflags16 & LF_NOWALK)
						s = strcat(s, " LF_NOWALK");
					if (self.current_navnode.lflags16 & LF_BAD)
						s = strcat(s, " LF_BAD");
					if (self.current_navnode.lflags16 & LF_BIGDROP)
						s = strcat(s, " LF_BIGDROP");
					if (self.current_navnode.lflags16 & LF_REMOTE)
						s = strcat(s, " LF_REMOTE");
				}
				if (self.current_navnode.lflags17)
				{
					s = strcat(s, "\nnavnode.lflags17:");
					if (self.current_navnode.lflags17 & LF_NOLINK)
						s = strcat(s, " LF_NOLINK");
					if (self.current_navnode.lflags17 & LF_NOWALK)
						s = strcat(s, " LF_NOWALK");
					if (self.current_navnode.lflags17 & LF_BAD)
						s = strcat(s, " LF_BAD");
					if (self.current_navnode.lflags17 & LF_BIGDROP)
						s = strcat(s, " LF_BIGDROP");
					if (self.current_navnode.lflags17 & LF_REMOTE)
						s = strcat(s, " LF_REMOTE");
				}
				if (self.current_navnode.lflags18)
				{
					s = strcat(s, "\nnavnode.lflags18:");
					if (self.current_navnode.lflags18 & LF_NOLINK)
						s = strcat(s, " LF_NOLINK");
					if (self.current_navnode.lflags18 & LF_NOWALK)
						s = strcat(s, " LF_NOWALK");
					if (self.current_navnode.lflags18 & LF_BAD)
						s = strcat(s, " LF_BAD");
					if (self.current_navnode.lflags18 & LF_BIGDROP)
						s = strcat(s, " LF_BIGDROP");
					if (self.current_navnode.lflags18 & LF_REMOTE)
						s = strcat(s, " LF_REMOTE");
				}
				if (self.current_navnode.lflags19)
				{
					s = strcat(s, "\nnavnode.lflags19:");
					if (self.current_navnode.lflags19 & LF_NOLINK)
						s = strcat(s, " LF_NOLINK");
					if (self.current_navnode.lflags19 & LF_NOWALK)
						s = strcat(s, " LF_NOWALK");
					if (self.current_navnode.lflags19 & LF_BAD)
						s = strcat(s, " LF_BAD");
					if (self.current_navnode.lflags19 & LF_BIGDROP)
						s = strcat(s, " LF_BIGDROP");
					if (self.current_navnode.lflags19 & LF_REMOTE)
						s = strcat(s, " LF_REMOTE");
				}
				s = strcat(s, "\n^6NavNode^7.origin: ");
				s = strcat(s, vtos(self.current_navnode.origin));
				s = strcat(s, "\n^6NavNode^7.absmin: ");
				s = strcat(s, vtos(self.current_navnode.origin + self.current_navnode.mins));
				s = strcat(s, "\n^6NavNode^7.absmax: ");
				s = strcat(s, vtos(self.current_navnode.origin + self.current_navnode.maxs));
				s = strcat(s, "\n");
				centerprint(self, s);
			}
			else
			{
				s = strcat("^5Gridsize^7: ", ftos(self.gridsize));
				s = strcat(s, "\n^2Self^7.origin: ");
				s = strcat(s, vtos(self.origin));
				s = strcat(s, "\nCURRENT AXIS: ");
				if (self.axis == 0)
					s = strcat(s, "^4X^7");
				else if (self.axis == 1)
					s = strcat(s, "^3Y^7");
				else if (self.axis == 2)
					s = strcat(s, "^1Z^7");
				s = strcat(s, "\n");
				centerprint(self, s);
			}
		}
		else if (self.confirm == C_DELETE_NAVNODE)
			centerprint(self, "Are you sure you wish to delete this NavNode?\n^11. Yes\n^42. No\n^7");
		else if (self.confirm == C_DELETE_PLANE)
			centerprint(self, "Are you sure you wish to delete this Plane?\n^11. Yes\n^42. No\n^7");
		else if (self.confirm == C_AUTOFLAGGER)
			centerprint(self, "Are you sure you wish to automaticly generate link flags (this will override all current link flags)?\n^11. Yes\n^42. No\n^7");
		else if (self.confirm == C_WAIT)
			centerprint(self, "^1PLEASE WAIT\n^7");
	}
};