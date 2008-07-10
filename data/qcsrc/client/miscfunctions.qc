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
	float i, tmp;
	registercvar("csqc_flags", "0");
	csqc_flags = cvar("csqc_flags");

	if(csqc_flags & CSQC_FLAG_STRINGWIDTH)
	{
		stringwidth = stringwidth_engine;
		sbar_font = FONT_USER+1;
	} else {
		stringwidth = stringwidth_oldfont;
		sbar_font = FONT_DEFAULT;
	}
}

vector Sbar_GetFontsize()
{
	if(csqc_flags & CSQC_FLAG_STRINGWIDTH)
		return stov(cvar_string("sbar_fontsize"));
	return '8 8' ;
}
