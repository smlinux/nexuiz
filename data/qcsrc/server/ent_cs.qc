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

.entity entcs;

void entcs_init()
{
	print("Initializing ClientSide information entities\n");
};

float entcs_customize()
{
	entity o;
	o = self.owner;
	if(o.deadflag != DEAD_NO)
		return FALSE;
	if(o.classname != "player")
		return FALSE;
	if(other == o)
		return FALSE;
	if(other.classname == "player")
		if(o.team != other.team)
			if not (radar_showennemies)
				return FALSE;
	return TRUE;
}

float entcs_send(entity to, float sf)
{
	entity o;
	o = self.owner;
	WriteByte(MSG_ENTITY, ENT_CLIENT_ENTCS);
	WriteByte(MSG_ENTITY, num_for_edict(o));
	WriteShort(MSG_ENTITY, o.origin_x);
	WriteShort(MSG_ENTITY, o.origin_y);
	WriteShort(MSG_ENTITY, o.origin_z);
	WriteByte(MSG_ENTITY, o.angles_y * 256.0 / 360);
	return TRUE;
};

void entcs_think()
{
	self.nextthink = time;

	entity o;
	o = self.owner;

	if(o.origin != self.origin || o.angles != self.angles)
	{
		setorigin(self, o.origin);
		self.angles = o.angles;
		self.SendFlags |= 1;
	}
};

entity attach_entcs()
{
	local entity ent;

	ent = spawn();
	ent.classname = "entcs_sender_v2";
	ent.owner = self;
	ent.think = entcs_think;
	ent.nextthink = time;

	Net_LinkEntity(ent, FALSE, 0, entcs_send);
	ent.customizeentityforclient = entcs_customize;

	self.entcs = ent;

	return ent;
};

void detach_entcs()
{
	remove(self.entcs);
	self.entcs = world;
};
