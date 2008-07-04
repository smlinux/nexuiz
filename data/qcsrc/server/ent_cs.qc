/**
 * The point of these entities is to avoid the problems
 * with clientprediction.
 * If you add SendEntity to players, the engine will not
 * do any prediction anymore, and you'd have to write the whole
 * prediction code in CSQC, you want that? :P
 * Data can depend on gamemode. For now, it serves as GPS entities
 * in onslaught... YAY ;)
 */

// Beware: do not redefine those in other files
// and NO, you cannot use ".version", which already exists (at least
// it did when I added this) But you have to use .Version
// Capital V

.float(entity to) SendEntity;
.float Version;

.float pingtime;

entity entcs_start;

void entcs_init()
{
	print("Initializing ClientSide information entities\n");
	entcs_start = spawn();
	entcs_start.solid = SOLID_NOT;
	entcs_start.chain = world;
};

entity get_entcs_ent(float num)
{
	entity entcs;
	entcs = spawn();
	entcs.chain = entcs_start.chain;
	entcs_start.chain = entcs;
	return entcs;
};

void entcs_ons(entity to)
{
	if(to == self.owner || self.team != to.team)
		return;
	if(self.owner.classname == "observer" || to.classname == "observer")
		return;
	WriteByte(MSG_ENTITY, ENTCS_MSG_ONS);
	WriteCoord(MSG_ENTITY, self.owner.origin_x);
	WriteCoord(MSG_ENTITY, self.owner.origin_y);
	WriteCoord(MSG_ENTITY, self.owner.angles_y);
}

void entcs_common_self()
{
	entity pl;
	if(self.pingtime < time)
	{
		self.pingtime = time + 9; // keep it 1 below the non-ons update intervall
		// just to be safe... (blah)
		WriteByte(MSG_ENTITY, ENTCS_MSG_PING);
		FOR_EACH_REALCLIENT(pl)
		{
			WriteByte(MSG_ENTITY, num_for_edict(pl));
			WriteShort(MSG_ENTITY, pl.ping);
		}
		WriteByte(MSG_ENTITY, 0);
	}
}

float entcs_send(entity to)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_ENTCS);
	WriteByte(MSG_ENTITY, self.health); // serves as entitynumber
	
	if(to == self.owner)
	{
		entcs_common_self();
	}
	
	if(game == GAME_ONSLAUGHT)
		entcs_ons(to);
	
	WriteByte(MSG_ENTITY, ENTCS_MSG_END);
	return TRUE;
};

void entcs_think()
{
	self.team = self.owner.team;
	self.Version++;
	setorigin(self, self.owner.origin);
	if(game == GAME_ONSLAUGHT)
		self.nextthink = time + 0.1;
	else
		self.nextthink = time + 10; // update pings every 10 seconds
};

void attach_entcs()
{
	local float num;
	local entity ent;

	print("Attaching ENTCS entity\n");

	num = num_for_edict(self);
	ent = get_entcs_ent(num);

	ent.classname = "entcs_sender";
	ent.health = num;
	setorigin(ent, self.origin);
	ent.owner = self;
	ent.think = entcs_think;
	ent.nextthink = time;
	ent.effects = EF_NODEPTHTEST | EF_LOWPRECISION;
	ent.model = "entcs_sender";
	ent.modelindex = 1;
	setsize(ent, '0 0 0', '0 0 0');

	ent.pingtime = time + 5;
		
	ent.SendEntity = entcs_send;
};

void detach_entcs()
{
	local float num;
	local entity ent;
	num = num_for_edict(self);
	for(ent = entcs_start; ent.chain.owner != self && ent.chain != world; ent = ent.chain);
	if(ent.chain != world && ent.chain.owner == self)
	{
		remove(ent.chain);
		ent.chain = ent.chain.chain;
	}
};
