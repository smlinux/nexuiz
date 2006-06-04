float maxspawned;
float numspawned;
float arena_roundbased;
.float spawned;
.entity spawnqueue_next;
.entity spawnqueue_prev;
.float spawnqueue_in;
entity spawnqueue_first;
entity spawnqueue_last;
entity champion;
.float arena_warmup_end;

void PutObserverInServer();
void PutClientInServer();
void(entity e) DropFlag;
void(entity e) ReturnFlag;
void(entity e) removedecor;

void reset_map()
{
	float warmup;
	
	self = nextent(world);

	warmup = cvar("g_arena_warmup");
	
	while(self)
	{
		if(self.classname == "droppedweapon"		// cleanup
				|| self.classname == "gib"
				|| self.classname == "body")
		{
			remove(self);
		}
		else if(self.flags & FL_ITEM)			// reset items
		{
			self.model = self.mdl;
			self.solid = SOLID_TRIGGER;
			setorigin (self, self.origin);
			self.think = SUB_Null;
			self.nextthink = 0;
			self.effects = self.effects - (self.effects & EF_STARDUST);
		}
		else if(self.flags & FL_PROJECTILE)		// remove any projectiles left
		{
			sound(self, CHAN_BODY, "misc/null.wav", 1, ATTN_NORM);
			remove(self);
		}
		else if(self.isdecor)
		{
			removedecor(self);			
		}
		else if(self.flags & FL_CLIENT)			// reset all players
		{
			if(self.spawned)
			{
				if(warmup)
					self.arena_warmup_end = time + warmup;
				PutClientInServer();
			}
			else if(self.deadflag)
				PutClientInServer();

			if(self.exteriorweaponentity)
				setmodel(self.exteriorweaponentity, "");
			if(self.weaponentity)
				setmodel(self.weaponentity, "");
		}
		self = nextent(self);
	}

	if(champion)
		champion.frags += 1;
}

void Spawnqueue_Insert(entity e)
{
	if(e.spawnqueue_in)
		return;
	dprint(strcat("Into queue: ", e.netname, "\n"));
	e.spawnqueue_in = TRUE;
	e.spawnqueue_prev = spawnqueue_last;
	e.spawnqueue_next = world;
	if(spawnqueue_last)
		spawnqueue_last.spawnqueue_next = e;
	spawnqueue_last = e;
	if(!spawnqueue_first)
		spawnqueue_first = e;
}

void Spawnqueue_Remove(entity e)
{
	if(!e.spawnqueue_in)
		return;
	dprint(strcat("Out of queue: ", e.netname, "\n"));
	e.spawnqueue_in = FALSE;
	if(e == spawnqueue_first)
		spawnqueue_first = e.spawnqueue_next;
	if(e == spawnqueue_last)
		spawnqueue_last = e.spawnqueue_prev;
	if(e.spawnqueue_prev)
		e.spawnqueue_prev.spawnqueue_next = e.spawnqueue_next;
	if(e.spawnqueue_next)
		e.spawnqueue_next.spawnqueue_prev = e.spawnqueue_prev;
	e.spawnqueue_next = world;
	e.spawnqueue_prev = world;
}

void Spawnqueue_Unmark(entity e)
{
	if(!e.spawned)
		return;
	e.spawned = FALSE;
	numspawned = numspawned - 1;
}

void Spawnqueue_Mark(entity e)
{
	if(e.spawned)
		return;
	e.spawned = TRUE;
	numspawned = numspawned + 1;
}

void Arena_Warmup()
{
	string msg;

	if(!arena_roundbased)
		return;

	msg = newlines;
	if(time < self.arena_warmup_end)
	{
		float f;
		f = rint(self.arena_warmup_end - time);
		
		if(champion)
			msg = strcat(msg, "The Champion is ", champion.netname, "^7\n\n\n");
		
		if(f)
			msg = strcat(msg, "Round will start in ", ftos(rint(self.arena_warmup_end - time)));
		else
		{
			if(self.spawned)
				msg = strcat(msg, "^1Fight!");
		}

		centerprint(self, msg);
		
		if(self.spawned)
			self.movetype = MOVETYPE_NONE;
	}
	else if(self.movetype == MOVETYPE_NONE)
	{
		self.movetype = MOVETYPE_WALK;
		centerprint(self, "\n");
	}
	
}

float next_round;
void Spawnqueue_Check()
{
	if(!next_round)
	if(numspawned < 2)
		next_round = time + 3;

	if(!arena_roundbased || (next_round && next_round < time && player_count > 1))
	{
		next_round = 0;

		if(arena_roundbased)
		{
			champion = find(world, classname, "player");
			while(champion && champion.deadflag)
				champion = find(champion, classname, "player");
		}
		
		while(numspawned < maxspawned && spawnqueue_first)
		{
			self = spawnqueue_first;

			bprint (strcat("^4", self.netname, "^4 is the next challenger\n"));

			Spawnqueue_Remove(self);
			Spawnqueue_Mark(self);
		
			self.classname = "player";
			PutClientInServer();
		}
		if(arena_roundbased)
			reset_map();
	}
}
