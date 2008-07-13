float databuf;
var float(string text, float handleColors) stringwidth;

float stringwidth_oldfont(string text, float handleColors)
{
	float i, len, ch, width;
	len = strlen(text);
	if(!handleColors)
		return len;
	width = 0;
	for(i = 0; i < len; ++i)
	{
		if(substring(text, i, 1) == "^")
		{
			ch = str2chr(text, i+1);
			if(ch >= '0' && ch <= '9')
				++i;
			else
				++width;
		}
		else
			++width;
	}
	return width;
}

void CSQC_CheckEngine()
{
	/*
	registercvar("csqc_flags", "0");
	csqc_flags = cvar("csqc_flags");
	*/

	csqc_flags = 0;
	
	if(checkextension("DP_SV_WRITEPICTURE"))
	{
		stringwidth = stringwidth_engine;
		sbar_font = FONT_USER+1;
		csqc_flags |= CSQC_FLAG_READPICTURE;
	} else {
		stringwidth = stringwidth_oldfont;
		sbar_font = FONT_DEFAULT;
	}
}

vector Sbar_GetFontsize()
{
	if(csqc_flags & CSQC_FLAG_READPICTURE)
		return stov(cvar_string("sbar_fontsize"));
	return '8 8' ;
}

float PreviewExists(string name)
{
	float f;
	string file;
	file = strcat(name, ".tga");
	f = fopen(file, FILE_READ);
	if(f >= 0)
	{
		fclose(f);
		return true;
	}
	file = strcat(name, ".png");
	f = fopen(file, FILE_READ);
	if(f >= 0)
	{
		fclose(f);
		return true;
	}
	file = strcat(name, ".jpg");
	f = fopen(file, FILE_READ);
	if(f >= 0)
	{
		fclose(f);
		return true;
	}
	file = strcat(name, ".pcx");
	f = fopen(file, FILE_READ);
	if(f >= 0)
	{
		fclose(f);
		return true;
	}
	return false;
}
