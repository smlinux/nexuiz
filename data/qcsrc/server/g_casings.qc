float Casing_SendEntity(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_CASING);
	WriteByte(MSG_ENTITY, self.state); // actually type
	WriteCoord(MSG_ENTITY, self.origin_x);
	WriteCoord(MSG_ENTITY, self.origin_y);
	WriteCoord(MSG_ENTITY, self.origin_z);
	WriteShort(MSG_ENTITY, self.oldorigin_x); // acrually compressed velocity
	WriteByte(MSG_ENTITY, self.angles_x * 256 / 360);
	WriteByte(MSG_ENTITY, self.angles_y * 256 / 360);
	WriteByte(MSG_ENTITY, self.angles_z * 256 / 360);
	return TRUE;
}

void SpawnCasing(vector org, vector vel, float randomvel, vector ang, vector avel, float randomavel, float casingtype)
{
	entity e;

	e = spawn();
	e.state = casingtype;
	e.origin = org;
	e.velocity = vel;
	e.angles = ang;
	e.oldorigin_x = compressShortVector(e.velocity);

	Net_LinkEntity(e, TRUE, 0.2, Casing_SendEntity);
		// 0.2s should be enough time for all clients to receive this ent once, do the gibbage and be done with it
}
