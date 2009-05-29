.float lip;
.float bgmscriptangular;

void Ent_Wall_Draw()
{
	float f;
	vector save;
	var .vector fld;

	InterpolateOrigin_Do();

	if(self.bgmscriptangular)
		fld = angles;
	else
		fld = origin;
	
	save = self.fld;
	f = BGMScript(self);
	if(f >= 0)
	{
		if(self.lip < 0) // < 0: alpha goes from 1 to 1-|lip| when toggled (toggling subtracts lip)
			self.alpha = 1 + self.lip * f;
		else // > 0: alpha goes from 1-|lip| to 1 when toggled (toggling adds lip)
			self.alpha = 1 - self.lip * (1 - f);
		self.fld = self.fld + self.movedir * f;
	}
	else
		self.alpha = 1;

	if(self.alpha >= ALPHA_MIN_VISIBLE)
		R_AddEntity(self);

	self.fld = save;
}

void Ent_Wall_Remove()
{
	if(self.bgmscript)
		strunzone(self.bgmscript);
	self.bgmscript = string_null;
}

void Ent_Wall()
{
	float f;
	InterpolateOrigin_Undo();
	self.iflags = IFLAG_ANGLES;

	f = ReadByte();

	if(f & 1)
	{
		if(f & 0x40)
			self.colormap = ReadShort();
		else
			self.colormap = 0;
	}

	if(f & 2)
	{
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
	}

	if(f & 4)
	{
		if(f & 0x10)
		{
			self.angles_x = ReadAngle();
			self.angles_y = ReadAngle();
			self.angles_z = ReadAngle();
		}
		else
			self.angles = '0 0 0';
	}

	if(f & 8)
	{
		self.modelindex = ReadShort();
		self.solid = ReadByte();
		self.scale = ReadByte() / 16.0;
		if(f & 0x20)
		{
			self.mins_x = ReadCoord();
			self.mins_y = ReadCoord();
			self.mins_z = ReadCoord();
			self.maxs_x = ReadCoord();
			self.maxs_y = ReadCoord();
			self.maxs_z = ReadCoord();
		}
		else
			self.mins = self.maxs = '0 0 0';

		if(self.bgmscript)
			strunzone(self.bgmscript);
		self.bgmscript = ReadString();
		if(substring(self.bgmscript, 0, 1) == "<")
		{
			self.bgmscript = strzone(substring(self.bgmscript, 1, -1));
			self.bgmscriptangular = 1;
		}
		else
		{
			self.bgmscript = strzone(self.bgmscript);
			self.bgmscriptangular = 0;
		}
		if(self.bgmscript != "")
		{
			self.bgmscriptattack = ReadByte() / 64.0;
			self.bgmscriptdecay = ReadByte() / 64.0;
			self.bgmscriptsustain = ReadByte() / 255.0;
			self.bgmscriptrelease = ReadByte() / 64.0;
			self.movedir_x = ReadCoord();
			self.movedir_y = ReadCoord();
			self.movedir_z = ReadCoord();
			self.lip = ReadByte() / 255.0;
		}
		BGMScript_InitEntity(self);
	}

	InterpolateOrigin_Note();

	self.entremove = Ent_Wall_Remove;
	self.draw = Ent_Wall_Draw;
}
