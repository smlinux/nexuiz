float CSQCProjectile_SendEntity(entity to, float sf)
{
	sf = sf & 0x3F;

	if(self.csqcprojectile_clientanimate)
		sf |= 0x80; // client animated, not interpolated

	if((self.scale != 0 && self.scale != 1) || self.effects != 0)
		sf |= 0x40; // scale used

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
	{
		WriteShort(MSG_ENTITY, self.modelindex);
		if(sf & 0x40)
		{
			WriteByte(MSG_ENTITY, bound(0, self.scale / 16.0, 255));
			WriteShort(MSG_ENTITY, self.effects & 65535);
			WriteByte(MSG_ENTITY, floor(self.effects / 65536));
		}
		WriteShort(MSG_ENTITY, self.csqcprojectile_flysound);
		WriteByte(MSG_ENTITY, 0); // size category
	}

	return 1;
}

void CSQCProjectile(entity e)
{
	e.SendEntity = CSQCProjectile_SendEntity;
}

void UpdateCSQCProjectile(entity e)
{
	if(e.SendEntity == CSQCProjectile_SendEntity)
		e.SendFlags |= 1; // send new origin data
}
