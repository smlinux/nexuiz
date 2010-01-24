string draw_mousepointer;
vector draw_mousepointer_offset;
vector draw_mousepointer_size;

string draw_UseSkinFor(string pic)
{
	if(substring(pic, 0, 1) == "/")
		return substring(pic, 1, strlen(pic)-1);
	else
		return strcat(draw_currentSkin, "/", pic);
}

void draw_setMousePointer(string pic, vector theSize, vector theOffset)
{
	draw_mousepointer = strzone(draw_UseSkinFor(pic));
	draw_mousepointer_size = theSize;
	draw_mousepointer_offset = eX * (theOffset_x * theSize_x) + eY * (theOffset_y * theSize_y);
}

void draw_drawMousePointer(vector where)
{
	drawpic(boxToGlobal(where, draw_shift, draw_scale) - draw_mousepointer_offset, draw_mousepointer, draw_mousepointer_size, '1 1 1', draw_alpha, 0);
}

void draw_reset(float cw, float ch, float ox, float oy)
{
	drawfont = FONT_USER+0;
	draw_shift = '1 0 0' * ox + '0 1 0' * oy;
	draw_scale = '1 0 0' * cw + '0 1 0' * ch;
	draw_alpha = 1;
	draw_fontscale = '1 1 0';
}

vector globalToBox(vector v, vector theOrigin, vector theScale)
{
	v -= theOrigin;
	v_x /= theScale_x;
	v_y /= theScale_y;
	return v;
}

vector globalToBoxSize(vector v, vector theScale)
{
	v_x /= theScale_x;
	v_y /= theScale_y;
	return v;
}

vector boxToGlobal(vector v, vector theOrigin, vector theScale)
{
	v_x *= theScale_x;
	v_y *= theScale_y;
	v += theOrigin;
	return v;
}

vector boxToGlobalSize(vector v, vector theScale)
{
	v_x *= theScale_x;
	v_y *= theScale_y;
	return v;
}

void draw_PreloadPicture(string pic)
{
	pic = draw_UseSkinFor(pic);
	precache_pic(pic);
}

void draw_Picture(vector theOrigin, string pic, vector theSize, vector theColor, float theAlpha)
{
	pic = draw_UseSkinFor(pic);
	drawpic(boxToGlobal(theOrigin, draw_shift, draw_scale), pic, boxToGlobalSize(theSize, draw_scale), theColor, theAlpha * draw_alpha, 0);
}

vector draw_PictureSize(string pic)
{
	pic = draw_UseSkinFor(pic);
	return drawgetimagesize(pic);
}

void draw_Fill(vector theOrigin, vector theSize, vector theColor, float theAlpha)
{
	drawfill(boxToGlobal(theOrigin, draw_shift, draw_scale), boxToGlobalSize(theSize, draw_scale), theColor, theAlpha * draw_alpha, 0);
}

// a button picture is a texture containing three parts:
//   1/4 width: left part
//   1/2 width: middle part (stretched)
//   1/4 width: right part
// it is assumed to be 4x as wide as high for aspect ratio purposes, which
// means, the parts are a square, two squares and a square.
void draw_ButtonPicture(vector theOrigin, string pic, vector theSize, vector theColor, float theAlpha)
{
	vector square;
	vector width, height;
	vector bW;
	pic = draw_UseSkinFor(pic);
	theOrigin = boxToGlobal(theOrigin, draw_shift, draw_scale);
	theSize = boxToGlobalSize(theSize, draw_scale);
	theAlpha *= draw_alpha;
	width = eX * theSize_x;
	height = eY * theSize_y;
	if(theSize_x <= theSize_y * 2)
	{
		// button not wide enough
		// draw just left and right part then
		square = eX * theSize_x * 0.5;
		bW = eX * (0.25 * theSize_x / (theSize_y * 2));
		drawsubpic(theOrigin,          square + height, pic, '0 0 0', eY + bW, theColor, theAlpha, 0);
		drawsubpic(theOrigin + square, square + height, pic, eX - bW, eY + bW, theColor, theAlpha, 0);
	}
	else
	{
		square = eX * theSize_y;
		drawsubpic(theOrigin,                  height  +     square, pic, '0    0 0', '0.25 1 0', theColor, theAlpha, 0);
		drawsubpic(theOrigin +         square, theSize - 2 * square, pic, '0.25 0 0', '0.5  1 0', theColor, theAlpha, 0);
		drawsubpic(theOrigin + width - square, height  +     square, pic, '0.75 0 0', '0.25 1 0', theColor, theAlpha, 0);
	}
}

// a vertical button picture is a texture containing three parts:
//   1/4 height: left part
//   1/2 height: middle part (stretched)
//   1/4 height: right part
// it is assumed to be 4x as high as wide for aspect ratio purposes, which
// means, the parts are a square, two squares and a square.
void draw_VertButtonPicture(vector theOrigin, string pic, vector theSize, vector theColor, float theAlpha)
{
	vector square;
	vector width, height;
	vector bH;
	pic = draw_UseSkinFor(pic);
	theOrigin = boxToGlobal(theOrigin, draw_shift, draw_scale);
	theSize = boxToGlobalSize(theSize, draw_scale);
	theAlpha *= draw_alpha;
	width = eX * theSize_x;
	height = eY * theSize_y;
	if(theSize_y <= theSize_x * 2)
	{
		// button not high enough
		// draw just upper and lower part then
		square = eY * theSize_y * 0.5;
		bH = eY * (0.25 * theSize_y / (theSize_x * 2));
		drawsubpic(theOrigin,          square + width, pic, '0 0 0', eX + bH, theColor, theAlpha, 0);
		drawsubpic(theOrigin + square, square + width, pic, eY - bH, eX + bH, theColor, theAlpha, 0);
	}
	else
	{
		square = eY * theSize_x;
		drawsubpic(theOrigin,                   width   +     square, pic, '0 0    0', '1 0.25 0', theColor, theAlpha, 0);
		drawsubpic(theOrigin +          square, theSize - 2 * square, pic, '0 0.25 0', '1 0.5  0', theColor, theAlpha, 0);
		drawsubpic(theOrigin + height - square, width   +     square, pic, '0 0.75 0', '1 0.25 0', theColor, theAlpha, 0);
	}
}

// a border picture is a texture containing nine parts:
//   1/4 width: left part
//   1/2 width: middle part (stretched)
//   1/4 width: right part
// divided into
//   1/4 height: top part
//   1/2 height: middle part (stretched)
//   1/4 height: bottom part
void draw_BorderPicture(vector theOrigin, string pic, vector theSize, vector theColor, float theAlpha, vector theBorderSize)
{
	vector dX, dY;
	vector width, height;
	vector bW, bH;
	pic = draw_UseSkinFor(pic);
	theOrigin = boxToGlobal(theOrigin, draw_shift, draw_scale);
	theSize = boxToGlobalSize(theSize, draw_scale);
	theBorderSize = boxToGlobalSize(theBorderSize, draw_scale);
	theAlpha *= draw_alpha;
	width = eX * theSize_x;
	height = eY * theSize_y;
	if(theSize_x <= theBorderSize_x * 2)
	{
		// not wide enough... draw just left and right then
		bW = eX * (0.25 * theSize_x / (theBorderSize_x * 2));
		if(theSize_y <= theBorderSize_y * 2)
		{
			// not high enough... draw just corners
			bH = eY * (0.25 * theSize_y / (theBorderSize_y * 2));
			drawsubpic(theOrigin,                 width * 0.5 + height * 0.5, pic, '0 0 0',           bW + bH, theColor, theAlpha, 0);
			drawsubpic(theOrigin + width   * 0.5, width * 0.5 + height * 0.5, pic, eX - bW,           bW + bH, theColor, theAlpha, 0);
			drawsubpic(theOrigin + height  * 0.5, width * 0.5 + height * 0.5, pic, eY - bH,           bW + bH, theColor, theAlpha, 0);
			drawsubpic(theOrigin + theSize * 0.5, width * 0.5 + height * 0.5, pic, eX + eY - bW - bH, bW + bH, theColor, theAlpha, 0);
		}
		else
		{
			dY = theBorderSize_x * eY;
			drawsubpic(theOrigin,                             width * 0.5          +     dY, pic, '0 0    0',           '0 0.25 0' + bW, theColor, theAlpha, 0);
			drawsubpic(theOrigin + width * 0.5,               width * 0.5          +     dY, pic, '0 0    0' + eX - bW, '0 0.25 0' + bW, theColor, theAlpha, 0);
			drawsubpic(theOrigin                        + dY, width * 0.5 + height - 2 * dY, pic, '0 0.25 0',           '0 0.5  0' + bW, theColor, theAlpha, 0);
			drawsubpic(theOrigin + width * 0.5          + dY, width * 0.5 + height - 2 * dY, pic, '0 0.25 0' + eX - bW, '0 0.5  0' + bW, theColor, theAlpha, 0);
			drawsubpic(theOrigin               + height - dY, width * 0.5          +     dY, pic, '0 0.75 0',           '0 0.25 0' + bW, theColor, theAlpha, 0);
			drawsubpic(theOrigin + width * 0.5 + height - dY, width * 0.5          +     dY, pic, '0 0.75 0' + eX - bW, '0 0.25 0' + bW, theColor, theAlpha, 0);
		}
	}
	else
	{
		if(theSize_y <= theBorderSize_y * 2)
		{
			// not high enough... draw just top and bottom then
			bH = eY * (0.25 * theSize_y / (theBorderSize_y * 2));
			dX = theBorderSize_x * eX;
			drawsubpic(theOrigin,                                         dX + height * 0.5, pic, '0    0 0',           '0.25 0 0' + bH, theColor, theAlpha, 0);
			drawsubpic(theOrigin + dX,                        width - 2 * dX + height * 0.5, pic, '0.25 0 0',           '0.5  0 0' + bH, theColor, theAlpha, 0);
			drawsubpic(theOrigin + width - dX,                            dX + height * 0.5, pic, '0.75 0 0',           '0.25 0 0' + bH, theColor, theAlpha, 0);
			drawsubpic(theOrigin              + height * 0.5,             dX + height * 0.5, pic, '0    0 0' + eY - bH, '0.25 0 0' + bH, theColor, theAlpha, 0);
			drawsubpic(theOrigin + dX         + height * 0.5, width - 2 * dX + height * 0.5, pic, '0.25 0 0' + eY - bH, '0.5  0 0' + bH, theColor, theAlpha, 0);
			drawsubpic(theOrigin + width - dX + height * 0.5,             dX + height * 0.5, pic, '0.75 0 0' + eY - bH, '0.25 0 0' + bH, theColor, theAlpha, 0);
		}
		else
		{
			dX = theBorderSize_x * eX;
			dY = theBorderSize_x * eY;
			drawsubpic(theOrigin,                                        dX          +     dY, pic, '0    0    0', '0.25 0.25 0', theColor, theAlpha, 0);
			drawsubpic(theOrigin                  + dX,      width - 2 * dX          +     dY, pic, '0.25 0    0', '0.5  0.25 0', theColor, theAlpha, 0);
			drawsubpic(theOrigin          + width - dX,                  dX          +     dY, pic, '0.75 0    0', '0.25 0.25 0', theColor, theAlpha, 0);
			drawsubpic(theOrigin          + dY,                          dX + height - 2 * dY, pic, '0    0.25 0', '0.25 0.5  0', theColor, theAlpha, 0);
			drawsubpic(theOrigin          + dY         + dX, width - 2 * dX + height - 2 * dY, pic, '0.25 0.25 0', '0.5  0.5  0', theColor, theAlpha, 0);
			drawsubpic(theOrigin          + dY + width - dX,             dX + height - 2 * dY, pic, '0.75 0.25 0', '0.25 0.5  0', theColor, theAlpha, 0);
			drawsubpic(theOrigin + height - dY,                          dX          +     dY, pic, '0    0.75 0', '0.25 0.25 0', theColor, theAlpha, 0);
			drawsubpic(theOrigin + height - dY         + dX, width - 2 * dX          +     dY, pic, '0.25 0.75 0', '0.5  0.25 0', theColor, theAlpha, 0);
			drawsubpic(theOrigin + height - dY + width - dX,             dX          +     dY, pic, '0.75 0.75 0', '0.25 0.25 0', theColor, theAlpha, 0);
		}
	}
}
void draw_Text(vector theOrigin, string theText, vector theSize, vector theColor, float theAlpha, float ICanHasKallerz)
{
	vector fs;
	if(theSize_x <= 0 || theSize_y <= 0)
		error("Drawing zero size text?\n");
	if not(cvar("menu_font_size_snapping_fix")) // FIXME remove this, this is to detect old engines
	{
		fs = draw_fontscale;
		draw_fontscale = '1 1 0';
	}
	if(ICanHasKallerz)
		drawcolorcodedstring(boxToGlobal(theOrigin, draw_shift, draw_scale), theText, globalToBoxSize(boxToGlobalSize(theSize, draw_scale), draw_fontscale), theAlpha * draw_alpha, 0);
	else
		drawstring(boxToGlobal(theOrigin, draw_shift, draw_scale), theText, globalToBoxSize(boxToGlobalSize(theSize, draw_scale), draw_fontscale), theColor, theAlpha * draw_alpha, 0);
	if not(cvar("menu_font_size_snapping_fix")) // FIXME remove this, this is to detect old engines
	{
		draw_fontscale = fs;
	}
}
void draw_CenterText(vector theOrigin, string theText, vector theSize, vector theColor, float theAlpha, float ICanHasKallerz)
{
	//print(strcat("orig = ", vtos(theOrigin) ," tx = ", ftos(draw_TextWidth(theText, ICanHasKallerz, theSize)), "\n"));
	draw_Text(theOrigin - eX * 0.5 * draw_TextWidth(theText, ICanHasKallerz, theSize), theText, theSize, theColor, theAlpha, ICanHasKallerz);
}

float draw_TextWidth(string theText, float ICanHasKallerz, vector SizeThxBye)
{
	//return strlen(theText);
	//print("draw_TextWidth \"", theText, "\"\n");
	vector fs;
	vector v;
	v = '0 0 0';
	//float r;
	if not(cvar("menu_font_size_snapping_fix")) // FIXME remove this, this is to detect old engines
	{
		fs = draw_fontscale;
		draw_fontscale = '1 1 0';
	}
	v_x = stringwidth(theText, ICanHasKallerz, boxToGlobalSize(SizeThxBye, draw_scale)) / draw_fontscale_x;
	if not(cvar("menu_font_size_snapping_fix")) // FIXME remove this, this is to detect old engines
	{
		draw_fontscale = fs;
	}
	v = globalToBoxSize(v, draw_scale);
	return v_x;
}

float draw_clipSet;
void draw_SetClip()
{
	if(draw_clipSet)
		error("Already clipping, no stack implemented here, sorry");
	drawsetcliparea(draw_shift_x, draw_shift_y, draw_scale_x, draw_scale_y);
	draw_clipSet = 1;
}

void draw_SetClipRect(vector theOrigin, vector theScale)
{
	vector o, s;
	if(draw_clipSet)
		error("Already clipping, no stack implemented here, sorry");
	o = boxToGlobal(theOrigin, draw_shift, draw_scale);
	s = boxToGlobalSize(theScale, draw_scale);
	drawsetcliparea(o_x, o_y, s_x, s_y);
	draw_clipSet = 1;
}

void draw_ClearClip()
{
	if(!draw_clipSet)
		error("Not clipping, can't clear it then");
	drawresetcliparea();
	draw_clipSet = 0;
}

string draw_TextShortenToWidth(string theText, float maxWidth, float ICanHasKallerz, vector SizeThxBye)
{
	/*
	if(draw_TextWidth(theText, ICanHasKallerz, SizeThxBye) <= maxWidth)
		return theText;
	else
		return strcat(substring(theText, 0, draw_TextLengthUpToWidth(theText, maxWidth - draw_TextWidth("...", ICanHasKallerz, SizeThxBye), ICanHasKallerz, SizeThxBye)), "...");
	*/
	if(ICanHasKallerz)
		return textShortenToWidth(theText, maxWidth, SizeThxBye, draw_TextWidth_WithColors);
	else
		return textShortenToWidth(theText, maxWidth, SizeThxBye, draw_TextWidth_WithoutColors);
}

float draw_TextWidth_WithColors(string s, vector theFontSize)
{
	return draw_TextWidth(s, TRUE, theFontSize);
}

float draw_TextWidth_WithoutColors(string s, vector theFontSize)
{
	return draw_TextWidth(s, FALSE, theFontSize);
}

float draw_TextLengthUpToWidth(string theText, float maxWidth, float allowColorCodes, vector theFontSize)
{
	if(allowColorCodes)
		return textLengthUpToWidth(theText, maxWidth, theFontSize, draw_TextWidth_WithColors);
	else
		return textLengthUpToWidth(theText, maxWidth, theFontSize, draw_TextWidth_WithoutColors);
}
