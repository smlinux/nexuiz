string draw_mousepointer;

void draw_setMousePointer(string pic)
{
	draw_mousepointer = pic;
}

void draw_drawMousePointer(vector where)
{
	drawpic(boxToGlobal(where, draw_shift, draw_scale), draw_mousepointer, '32 32 0', '1 1 1', draw_alpha, 0);
}

void draw_reset()
{
	draw_shift = '0 0 0';
	draw_scale = '1 0 0' * cvar("vid_conwidth") + '0 1 0' * cvar("vid_conheight");
	draw_alpha = 1;
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

void draw_Picture(vector theOrigin, string pic, vector theSize, vector theColor, float theAlpha)
{
	drawpic(boxToGlobal(theOrigin, draw_shift, draw_scale), pic, boxToGlobalSize(theSize, draw_scale), theColor, theAlpha * draw_alpha, 0);
}

void draw_Text(vector theOrigin, string theText, vector theSize, vector theColor, float theAlpha)
{
	drawstring(boxToGlobal(theOrigin, draw_shift, draw_scale), theText, boxToGlobalSize(theSize, draw_scale), theColor, theAlpha * draw_alpha, 0);
}

float draw_TextWidth(string theText)
{
	return strlen(theText);
}
