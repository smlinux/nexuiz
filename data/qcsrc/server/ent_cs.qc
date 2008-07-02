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

entity entcs_start;

void() entcs_init =
{
	print("Initializing ClientSide information entities\n");
	entcs_start = spawn();
	entcs_start.solid = SOLID_NOT;
	entcs_start.chain = world;
};

entity(float num) get_entcs_ent =
{
	entity entcs;
	entcs = spawn();
	entcs.chain = entcs_start.chain;
	entcs_start.chain = entcs;
	return entcs;
};


float(entity to) entcs_send =
{
	if(to == self.owner || self.team != to.team)
		return FALSE;
	if(self.owner.classname == "observer" || to.classname == "observer")
		return FALSE;
	
	WriteByte(MSG_ENTITY, ENT_CLIENT_ENTCS);
	WriteByte(MSG_ENTITY, self.health); // serves as entitynumber
	WriteCoord(MSG_ENTITY, self.owner.origin_x);
	WriteCoord(MSG_ENTITY, self.owner.origin_y);
	WriteCoord(MSG_ENTITY, self.owner.angles_y);
	// write health maybe?
	return TRUE;
};

void() entcs_think =
{
	self.team = self.owner.team;
	self.Version++;
	setorigin(self, self.owner.origin);
	self.nextthink = time + 0.1;
};

void() attach_entcs =
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
		
	ent.SendEntity = entcs_send;
};

void() detach_entcs =
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
