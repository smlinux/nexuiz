.float csqcprojectile_type;

float CSQCProjectile_SendEntity(entity to, float sf)
{
	// note: flag 0x20 = no trail please
	sf = sf & 0x3F;

	if(self.csqcprojectile_clientanimate)
		sf |= 0x80; // client animated, not interpolated

	if(self.flags & FL_ONGROUND)
		sf |= 0x40;

	WriteByte(MSG_ENTITY, ENT_CLIENT_PROJECTILE);
	WriteByte(MSG_ENTITY, sf);

	if(sf & 1)
	{
		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
		WriteCoord(MSG_ENTITY, self.origin_z);

		if(sf & 0x80)
		{
			WriteCoord(MSG_ENTITY, self.velocity_x);
			WriteCoord(MSG_ENTITY, self.velocity_y);
			WriteCoord(MSG_ENTITY, self.velocity_z);
			WriteCoord(MSG_ENTITY, self.gravity);
		}
	}

	if(sf & 2)
		WriteByte(MSG_ENTITY, self.csqcprojectile_type); // TODO maybe put this into sf?

	return 1;
}

.vector csqcprojectile_oldorigin;
void CSQCProjectile_Check(entity e)
{
	if(e.csqcprojectile_clientanimate)
	if(e.flags & FL_ONGROUND)
	if(e.origin != e.csqcprojectile_oldorigin)
		UpdateCSQCProjectile(e);
	e.csqcprojectile_oldorigin = e.origin;
}

void CSQCProjectile(entity e, float clientanimate, float type, float docull)
{
	Net_LinkEntity(e, docull, 0, CSQCProjectile_SendEntity);
	
	e.csqcprojectile_clientanimate = clientanimate;
	
	if(e.movetype == MOVETYPE_TOSS || e.movetype == MOVETYPE_BOUNCE)
	{
		if(e.gravity == 0)
			e.gravity = 1;
	}
	else
		e.gravity = 0;

	e.csqcprojectile_type = type;
	if(!sound_allowed(MSG_BROADCAST, e))
		type |= 0x80;
}

void UpdateCSQCProjectile(entity e)
{
	if(e.SendEntity == CSQCProjectile_SendEntity)
	{
		// send new origin data
		e.SendFlags |= 1;
	}
}

void UpdateCSQCProjectileAfterTeleport(entity e)
{
	if(e.SendEntity == CSQCProjectile_SendEntity)
	{
		// send new origin data and mark as teleported
		e.SendFlags |= 0x21;
	}
}

.void(void) csqcprojectile_oldthink;
.float csqcprojectile_oldnextthink;

void CSQCProjectile_Update_Think()
{
	UpdateCSQCProjectile(self);
	self.think = self.csqcprojectile_oldthink;
	self.nextthink = max(time, self.csqcprojectile_oldnextthink);
}

void UpdateCSQCProjectileNextFrame(entity e)
{
	if(e.SendEntity == CSQCProjectile_SendEntity)
	if(e.think != CSQCProjectile_Update_Think)
	{
		e.csqcprojectile_oldthink = e.think;
		e.csqcprojectile_oldnextthink = e.nextthink;
		e.think = CSQCProjectile_Update_Think;
		e.nextthink = time;
	}
}
