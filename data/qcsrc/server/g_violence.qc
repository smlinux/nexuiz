float Violence_GibSplash_SendEntity(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_GIBSPLASH);
	WriteByte(MSG_ENTITY, self.state); // actually type
	WriteByte(MSG_ENTITY, bound(1, self.cnt * 16, 255)); // gibbage amount multiplier
	WriteShort(MSG_ENTITY, floor(self.origin_x / 4)); // not using a coord here, as gibs don't need this accuracy
	WriteShort(MSG_ENTITY, floor(self.origin_y / 4)); // not using a coord here, as gibs don't need this accuracy
	WriteShort(MSG_ENTITY, floor(self.origin_z / 4)); // not using a coord here, as gibs don't need this accuracy
	WriteShort(MSG_ENTITY, self.oldorigin_x); // acrually compressed velocity
	WriteShort(MSG_ENTITY, self.oldorigin_y); // acrually compressed mins
	WriteShort(MSG_ENTITY, self.oldorigin_z); // acrually compressed maxs
	return TRUE;
}

// TODO maybe convert this to a TE?
void Violence_GibSplash_At(vector org, vector mi, vector ma, vector dir, float type, float amount)
{
	entity e;

	e = spawn();
	e.classname = "gibsplash";
	e.cnt = amount;
	e.state = type;
	if(sv_gentle)
		e.state |= 0x80; // "force gentle" bit
	setorigin(e, org);
	setsize(e, mi, ma);
	e.velocity = dir;

	e.oldorigin_x = compressShortVector(e.velocity);
	e.oldorigin_y = compressShortVector(e.mins);
	e.oldorigin_z = compressShortVector(e.maxs);

	Net_LinkEntity(e, FALSE, 0.2, Violence_GibSplash_SendEntity);
}

void Violence_GibSplash(entity source, float type, float amount)
{
	Violence_GibSplash_At(source.origin + source.view_ofs, source.mins - source.view_ofs, source.maxs - source.view_ofs, source.velocity, type, amount);
}
