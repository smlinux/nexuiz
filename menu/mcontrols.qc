///////////////////////////////////////////////
// Controls/Item Source File
///////////////////////
// This file belongs to dpmod/darkplaces
// AK contains all item specific stuff
////////////////////////////////////////////////

////////////////
// ITEM_WINDOW
//

void(void) ITEM_WINDOW =
{
	self.flag = self.flag | FLAG_NOSELECT | FLAG_DRAWONLY;

	item_init(
		defct_reinit,
		defct_destroy,
		defct_key,
		defct_draw,
		defct_mouse_enter,
		defct_mouse_leave,
		defct_action,
		defct_refresh);

	ctcall_init();
};

//////////////////
// ITEM_REFERENCE
///

void(void) ITEM_REFERENCE =
{
	self.flag = self.flag | FLAG_NOSELECT | FLAG_DRAWONLY;

	// if there is no link, this is a dynamic reference
	if(self.link != "")
	{
		self._child = menu_getitem(self.link);
		if(self._child == null_entity)
		{
			print(self.name, " removed, cause link ", self.link, " not found\n");
			remove(self);	// no need to call terminate
			return;
		}
	}

	item_init(
		defct_reinit,
		defct_destroy,
		defct_key,
		defct_draw,
		defct_mouse_enter,
		defct_mouse_leave,
		defct_action,
		defct_refresh);

	ctcall_init();
};

////////////////
// ITEM_CUSTOM
////

void(void) ITEM_CUSTOM =
{
	item_init(defct_reinit,	defct_destroy, defct_key, defct_draw, defct_mouse_enter, defct_mouse_leave, defct_action, defct_refresh);
	ctcall_init();
};

/////////////////
// ITEM_PICTURE
///

// ITEM_PICTURE has a special draw function
void(void) ITEM_PICTURE_DRAW =
{
	menu_drawpic(self.pos, self.picture, self.size, self.color, self.alpha, self.drawflag);

	ctcall_draw();
};

void(void) ITEM_PICTURE_DESTROY =
{
	gfx_unloadpic(self.picture);

	ctcall_destroy();
};

void(void) ITEM_PICTURE =
{
	if(self.picture == "")
		// a picture has to have a picture
		remove(self);		// no need to call terminate

	// load the picture if it isnt loaded already
	gfx_loadpic(self.picture, MENU_ENFORCELOADING);

	// if flag wasnt set yet, then set it to FLAG_DRAWONLY
	if(self.flag == 0)
		self.flag = FLAG_DRAWONLY;

	if(self.color == '0 0 0')
		self.color = ITEM_PICTURE_NORMAL_COLOR;
	if(self.alpha == 0)
		self.alpha = ITEM_PICTURE_NORMAL_ALPHA;

	item_init(
		defct_reinit,
		ITEM_PICTURE_DESTROY,
		defct_key,
		ITEM_PICTURE_DRAW,
		defct_mouse_enter,
		defct_mouse_leave,
		defct_action,
		defct_refresh);

	ctcall_init();
};

/////////////
// ITEM_TEXT
///

void(void) ITEM_TEXT_REFRESH =
{
	// first do own refresh, *then* call the default refresh !
	if(self.size == '0 0 0')
	{
		if(self.font_size == '0 0 0')
			self.font_size = ITEM_TEXT_FONT_SIZE;

		self.size_x = self.font_size_x * strlen(self.text);
		self.size_y = self.font_size_y;
	} else if(self.font_size == '0 0 0')
	{
			self.font_size_x = self.size_x / strlen(self.text);
			self.font_size_y = self.size_y;
	}

	def_refresh();
	ctcall_refresh();
};

void(void) ITEM_TEXT_DRAW =
{
	if(self.text != "")
	{
		// align to the rect pos - (pos + size)
		vector alignpos;
		// now check the alignement
		if(self.alignment & TEXT_ALIGN_CENTER)
			alignpos_x = self.pos_x + (self.size_x - strlen(self.text) * self.font_size_x) / 2;
		else if(self.alignment & TEXT_ALIGN_RIGHT)
			alignpos_x = self.pos_x + self.size_x - strlen(self.text) * self.font_size_x;
		else
			alignpos_x = self.pos_x;
		alignpos_y = self.pos_y;

		menu_drawstring(alignpos, self.text, self.font_size, self.color, self.alpha, self.drawflag);
	}
	ctcall_draw();
};

void(void) ITEM_TEXT =
{
	if(self.flag == 0)
		self.flag = FLAG_DRAWONLY;

	if(self.color == '0 0 0')
		self.color = ITEM_TEXT_NORMAL_COLOR;
	if(self.alpha == 0)
		self.alpha = ITEM_TEXT_NORMAL_ALPHA;

	ITEM_TEXT_REFRESH();
	if(self.alignment & TEXT_ALIGN_CENTERPOS)
	{
		self.pos_x = self.pos_x - self.size_x / 2;
	} else	if(self.alignment & TEXT_ALIGN_LEFTPOS)
	{
		self.pos_x = self.pos_x - self.size_x;
	}

	item_init(
		defct_reinit,
		defct_destroy,
		defct_key,
		ITEM_TEXT_DRAW,
		defct_mouse_enter,
		defct_mouse_leave,
		defct_action,
		ITEM_TEXT_REFRESH);

	ctcall_init();
};

/////////////////
// ITEM_RECTANLE
///

void(void) ITEM_RECTANGLE_DRAW =
{
	menu_fillarea(self.pos, self.size, self.color, self.alpha, self.drawflag);
};

void(void) ITEM_RECTANGLE =
{
	if(self.flag == 0)
		self.flag = FLAG_DRAWONLY;

	item_init(
		defct_reinit,
		defct_destroy,
		defct_key,
		ITEM_RECTANGLE_DRAW,
		defct_mouse_enter,
		defct_mouse_leave,
		defct_action,
		defct_refresh);

	ctcall_init();
};

////////////////
// ITEM_BUTTON
///

void(void) ITEM_BUTTON_DRAW =
{
	if(self._button_state == BUTTON_NORMAL)
		menu_drawpic(self.pos, self.picture, self.size, self.color, self.alpha, self.drawflag);
	else if(self._button_state == BUTTON_SELECTED)
		menu_drawpic(self.pos, self.picture_selected, self.size, self.color_selected, self.alpha_selected, self.drawflag_selected);
	else
		menu_drawpic(self.pos, self.picture_pressed, self.size, self.color_pressed, self.alpha_pressed, self.drawflag_pressed);

	ctcall_draw();
};

void(void) ITEM_BUTTON_REFRESH =
{
	if( self.hold_pressed + self._press_time < time )
	{
		if( menu_selected != self && self._button_state != BUTTON_NORMAL )
			self._button_state = BUTTON_NORMAL;
		else if( menu_selected == self && self._button_state != BUTTON_SELECTED)
		{
			self._button_state = BUTTON_SELECTED;
			if(self.sound_selected != "" && menu_automatedselection == false)
				snd_play(self.sound_selected);
		}
	}

	def_refresh();
	ctcall_refresh();
};

void(float keynr, float ascii) ITEM_BUTTON_KEY =
{
	if(ctcall_key(keynr, ascii))
		return;

	if(keynr == K_ENTER || keynr == K_MOUSE1)
	{
		self._action();
	} else
		def_keyevent(keynr, ascii);
};

void(void) ITEM_BUTTON_ACTION =
{
	self._press_time = time;
	self._button_state = BUTTON_PRESSED;
	if(self.sound_pressed)
		snd_play(self.sound_pressed);

	ctcall_action();
};
void(void) ITEM_BUTTON_REINIT =
{
	self._button_state = BUTTON_NORMAL;

	ctcall_reinit();
};

void(void) ITEM_BUTTON_DESTROY =
{
	gfx_unloadpic(self.picture);
	gfx_unloadpic(self.picture_selected);
	gfx_unloadpic(self.picture_pressed);

	ctcall_destroy();
};

void(void) ITEM_BUTTON =
{
	if(self.picture == "" || self.picture_selected == "" || self.picture_pressed == "")
		// a picture has to have pictures
		remove(self);	// no need to call terminate

	// load the picture if it isnt loaded already
	gfx_loadpic(self.picture, MENU_ENFORCELOADING);
	gfx_loadpic(self.picture_selected, MENU_ENFORCELOADING);
	gfx_loadpic(self.picture_pressed, MENU_ENFORCELOADING);

	if(self.sound_selected != "")
		snd_loadsound(self.sound_selected, SOUND_ENFORCELOADING);
	else
		self.sound_selected = SOUND_SELECT;

	if(self.sound_pressed != "")
		snd_loadsound(self.sound_pressed, SOUND_ENFORCELOADING);
	else
		self.sound_pressed = SOUND_ACTION;

	// if flag wasnt set yet, then set it to FLAG_DRAWONLY
	if(self.flag == 0)
		self.flag = FLAG_AUTOSETCLICK;

	if(self.color == '0 0 0')
		self.color = ITEM_PICTURE_NORMAL_COLOR;
	if(self.alpha == 0)
		self.alpha = ITEM_PICTURE_NORMAL_ALPHA;
	if(self.color_selected == '0 0 0')
		self.color_selected = ITEM_PICTURE_SELECTED_COLOR;
	if(self.alpha_selected == 0)
		self.alpha_selected = ITEM_PICTURE_SELECTED_ALPHA;
	if(self.color_pressed == '0 0 0')
		self.color_pressed = ITEM_PICTURE_PRESSED_COLOR;
	if(self.alpha_pressed == 0)
		self.alpha_pressed = ITEM_PICTURE_PRESSED_ALPHA;

	if(self.hold_pressed == 0)
		self.hold_pressed = ITEM_BUTTON_HOLD_PRESSED;

	item_init(
		ITEM_BUTTON_REINIT,
		ITEM_BUTTON_DESTROY,
		ITEM_BUTTON_KEY,
		ITEM_BUTTON_DRAW,
		defct_mouse_enter,
		defct_mouse_leave,
		ITEM_BUTTON_ACTION,
		ITEM_BUTTON_REFRESH);

	ctcall_init();
};

////////////////////
// ITEM_TEXTBUTTON
///

void(void) ITEM_TEXTBUTTON_REFRESH =
{
	// first do own refresh, *then* call the default refresh !
	if(self.size == '0 0 0')
	{
		if(self.font_size == '0 0 0')
			self.font_size = ITEM_TEXT_FONT_SIZE;

		self.size_x = self.font_size_x * strlen(self.text);
		self.size_y = self.font_size_y;
	} else if(self.font_size == '0 0 0')
	{
			self.font_size_x = self.size_x / strlen(self.text);
			self.font_size_y = self.size_y;
	}

	/*if((self.hold_pressed + self._press_time < time && self._button_state == BUTTON_PRESSED) || (menu_selected != self && self._button_state == BUTTON_SELECTED))
	{
		self._button_state = BUTTON_NORMAL;
	}
	if(menu_selected == self && self._button_state == BUTTON_NORMAL)
	{
		self._button_state = BUTTON_SELECTED;
		if(self.sound_selected != "" && menu_automatedselection == false)
			snd_play(self.sound_selected);
	}*/
	/*if( self.hold_pressed + self._press_time < time )
	{
		if( menu_selected != self && self._button_state != BUTTON_NORMAL )
			self._button_state = BUTTON_NORMAL;
		else if( menu_selected == self && self._button_state != BUTTON_SELECTED)
		{
			self._button_state = BUTTON_SELECTED;
			if(self.sound_selected != "" && menu_automatedselection == false)
				snd_play(self.sound_selected);
		}
	}*/
	if( self._button_state == BUTTON_PRESSED ) {
		if( self.hold_pressed + self._press_time < time )
			if( menu_selected == self )
				self._button_state = BUTTON_SELECTED;
			else
				self._button_state = BUTTON_NORMAL;
	} else if( self._button_state == BUTTON_NORMAL && menu_selected == self ) {
		self._button_state = BUTTON_SELECTED;
		if( self.sound_selected != "" && menu_automatedselection == false )
			snd_play( self.sound_selected );
	} else if( menu_selected != self )
		self._button_state = BUTTON_NORMAL;

	def_refresh();
	ctcall_refresh();
};

void(void) ITEM_TEXTBUTTON_DRAW =
{
	if(self.text == "")
		return;

	// align to the rect pos - (pos + size)
	vector alignpos;
	// now check the alignement
	if(self.alignment & TEXT_ALIGN_CENTER)
		alignpos_x = self.pos_x + (self.size_x - strlen(self.text) * self.font_size_x) / 2;
	else if(self.alignment & TEXT_ALIGN_RIGHT)
		alignpos_x = self.pos_x + self.size_x - strlen(self.text) * self.font_size_x;
	else
		alignpos_x = self.pos_x;
		alignpos_y = self.pos_y;

	if(self.style == TEXTBUTTON_STYLE_OUTLINE && self._button_state != BUTTON_NORMAL)
	{
		vector p,s;
		// left
		p_x = self.pos_x;
		p_y = self.pos_y;
		s_x = TEXTBUTTON_OUTLINE_WIDTH;
		s_y = self.size_y;
		if(self._button_state == BUTTON_PRESSED)
		{
			menu_fillarea(p, s, self.color_pressed, self.alpha_pressed, self.drawflag_pressed);
		}
		else if(self._button_state == BUTTON_SELECTED)
		{
			menu_fillarea(p, s, self.color_selected, self.alpha_selected, self.drawflag_selected);
		}
		// right
		p_x = self.pos_x + self.size_x - TEXTBUTTON_OUTLINE_WIDTH;
		p_y = self.pos_y;
		s_x = TEXTBUTTON_OUTLINE_WIDTH;
		s_y = self.size_y;
		if(self._button_state == BUTTON_PRESSED)
		{
			menu_fillarea(p, s, self.color_pressed, self.alpha_pressed, self.drawflag_pressed);
		}
		else if(self._button_state == BUTTON_SELECTED)
		{
			menu_fillarea(p, s, self.color_selected, self.alpha_selected, self.drawflag_selected);
		}
		// top
		p_x = self.pos_x;
		p_y = self.pos_y;
		s_y = TEXTBUTTON_OUTLINE_WIDTH;
		s_x = self.size_x;
		if(self._button_state == BUTTON_PRESSED)
		{
			menu_fillarea(p, s, self.color_pressed, self.alpha_pressed, self.drawflag_pressed);
		}
		else if(self._button_state == BUTTON_SELECTED)
		{
			menu_fillarea(p, s, self.color_selected, self.alpha_selected, self.drawflag_selected);
		}
		// bottom
		p_x = self.pos_x;
		p_y = self.pos_y + self.size_y - TEXTBUTTON_OUTLINE_WIDTH;
		s_y = TEXTBUTTON_OUTLINE_WIDTH;
		s_x = self.size_x;
		if(self._button_state == BUTTON_PRESSED)
		{
			menu_fillarea(p, s, self.color_pressed, self.alpha_pressed, self.drawflag_pressed);
		}
		else if(self._button_state == BUTTON_SELECTED)
		{
			menu_fillarea(p, s, self.color_selected, self.alpha_selected, self.drawflag_selected);
		}
	} else	if(self.style == TEXTBUTTON_STYLE_BOX)
	{
		if(self._button_state == BUTTON_PRESSED)
		{
			menu_fillarea(alignpos, self.size, self.color_pressed, self.alpha_pressed, self.drawflag_pressed);
		}
		else if(self._button_state == BUTTON_SELECTED)
		{
			menu_fillarea(alignpos, self.size, self.color_selected, self.alpha_selected, self.drawflag_selected);
		}
	}

	if(self._button_state == BUTTON_NORMAL || self.style == TEXTBUTTON_STYLE_BOX || self.style == TEXTBUTTON_STYLE_OUTLINE)
		menu_drawstring(alignpos, self.text, self.font_size, self.color, self.alpha, self.drawflag);

	if(self.style == TEXTBUTTON_STYLE_TEXT)
	{
		if(self._button_state == BUTTON_PRESSED)
		{
			menu_drawstring(alignpos, self.text, self.font_size, self.color_pressed, self.alpha_pressed, self.drawflag_pressed);
		}
		else if(self._button_state == BUTTON_SELECTED)
		{
			menu_drawstring(alignpos, self.text, self.font_size, self.color_selected, self.alpha_selected, self.drawflag_selected);
		}
	}

	ctcall_draw();
};

void(void) ITEM_TEXTBUTTON_ACTION =
{
	self._press_time = time;
	self._button_state = BUTTON_PRESSED;
	if(self.sound_pressed)
		snd_play(self.sound_pressed);

	ctcall_action();
};

void(float keynr, float ascii) ITEM_TEXTBUTTON_KEY =
{
	if(ctcall_key(keynr, ascii))
		return;

	if(keynr == K_ENTER || keynr == K_MOUSE1)
	{
		self._action();
	} else
		def_keyevent(keynr, ascii);
};

void(void) ITEM_TEXTBUTTON_REINIT =
{
	self._button_state = BUTTON_NORMAL;

	ctcall_reinit();
};

void(void) ITEM_TEXTBUTTON =
{
	if(self.flag == 0)
		self.flag = FLAG_AUTOSETCLICK;

	if(self.color == '0 0 0')
		self.color = ITEM_TEXT_NORMAL_COLOR;
	if(self.alpha == 0)
		self.alpha = ITEM_TEXT_NORMAL_ALPHA;
	if(self.color_selected == '0 0 0')
		self.color_selected = ITEM_TEXT_SELECTED_COLOR;
	if(self.alpha_selected == 0)
		self.alpha_selected = ITEM_TEXT_SELECTED_ALPHA;
	if(self.color_pressed == '0 0 0')
		self.color_pressed = ITEM_TEXT_PRESSED_COLOR;
	if(self.alpha_pressed == 0)
		self.alpha_pressed = ITEM_TEXT_PRESSED_ALPHA;

	if(self.hold_pressed == 0)
		self.hold_pressed = ITEM_BUTTON_HOLD_PRESSED;

	if(self.sound_selected != "")
		snd_loadsound(self.sound_selected, SOUND_ENFORCELOADING);
	else
		self.sound_selected = SOUND_SELECT;

	if(self.sound_pressed != "")
		snd_loadsound(self.sound_pressed, SOUND_ENFORCELOADING);
	else
		self.sound_pressed = SOUND_ACTION;

	ITEM_TEXTBUTTON_REFRESH();
	if(self.alignment & TEXT_ALIGN_CENTERPOS)
	{
		self.pos_x = self.pos_x - self.size_x / 2;
	} else	if(self.alignment & TEXT_ALIGN_LEFTPOS)
	{
		self.pos_x = self.pos_x - self.size_x;
	}

	item_init(
		ITEM_TEXTBUTTON_REINIT,
		defct_destroy,
		ITEM_TEXTBUTTON_KEY,
		ITEM_TEXTBUTTON_DRAW,
		defct_mouse_enter,
		defct_mouse_leave,
		ITEM_TEXTBUTTON_ACTION,
		ITEM_TEXTBUTTON_REFRESH);

	ctcall_init();
};

// ITEM_SLIDER

void(void) ITEM_SLIDER_DRAW =
{
	vector slider_pos;
	string t;

	// draw the bar
	if(self.picture_bar != "")
	{
		menu_drawpic(self.pos, self.picture_bar, self.size, self.color, self.alpha, self.drawflag);
	}
	else
	{
		menu_fillarea(self.pos, self.size, self.color, self.alpha, self.drawflag);
	}

	// draw the slider
	slider_pos = self.pos;
	slider_pos_x = slider_pos_x + self.left_margin + ((self.size_x - self.slider_size_x - self.left_margin - self.right_margin) / (self.max_value - self.min_value)) * (self.value - self.min_value);
	if(self.picture != "")
	{
		menu_drawpic(slider_pos, self.picture, self.slider_size, self.color, self.alpha, self.drawflag);
	}
	else
	{
		menu_fillarea(slider_pos, self.slider_size, self.color + ITEM_SLIDER_BAR_COLOR_DELTA, self.alpha, self.drawflag);
	}
};

void(void) ITEM_SLIDER_UPDATESLIDER =
{
	self.value = bound(self.min_value, self.value, self.max_value);
	if(self.slidermove)
		self.slidermove();
};

void(float keynr, float ascii) ITEM_SLIDER_KEY =
{
	float old;
	old = self.value;

	if(ctcall_key(keynr, ascii))
		return;

	if(keynr == K_LEFTARROW)
	{
		self.value = (rint(self.value / self.step) - 1) * self.step;
	}
	else if(keynr == K_RIGHTARROW)
	{
		self.value = (rint(self.value / self.step) + 1)* self.step;
	}
	else if(keynr == K_MOUSE1)
	{
		if(inrect(menu_cursor, self.pos, self.size))
		{
			if(menu_cursor_x - self.pos_x <= self.left_margin)
			{
				self.value = (rint(self.value / self.step) - 1)* self.step;
			}
			else if(menu_cursor_x - self.pos_x >= self.size_x - self.right_margin)
			{
				self.value = (rint(self.value / self.step) + 1)* self.step;
			}
			else
			{
				self.value = self.min_value + ((menu_cursor_x - self.slider_size_x / 2) - self.pos_x - self.left_margin) * ((self.max_value - self.min_value) / (self.size_x - self.slider_size_x - self.left_margin - self.right_margin));
			}
		}
	}
	else
	{
		def_keyevent(keynr, ascii);
		return;
	}
	// play sound
	if(old < self.value)
	{
		snd_play(self.sound_increase);
	}
	else if(self.value < old)
	{
		snd_play(self.sound_decrease);
	}

	ITEM_SLIDER_UPDATESLIDER();
	ctcall_action();
};

void(void) ITEM_SLIDER_DESTROY =
{
	if(self.picture != "" && self.picture != ITEM_SLIDER_DEFAULT_SLIDER)
		gfx_unloadpic(self.picture);
	if(self.picture_bar != "" && self.picture_bar != ITEM_SLIDER_DEFAULT_BAR)
		gfx_unloadpic(self.picture);
	if(self.sound_increase != SOUND_INCREASE)
		snd_unloadsound(self.sound_decrease);
	if(self.sound_increase != SOUND_INCREASE)
		snd_unloadsound(self.sound_increase);

	ctcall_destroy();
};

void(void) ITEM_SLIDER =
{
	if(self.picture != "")
		self.picture = gfx_loadpic(self.picture, MENU_ENFORCELOADING);
	if(self.picture == "")
		self.picture = gfx_loadpic(ITEM_SLIDER_DEFAULT_SLIDER, MENU_ENFORCELOADING);
	if(self.picture_bar != "")
		self.picture_bar = gfx_loadpic(self.picture_bar, MENU_ENFORCELOADING);
	if(self.picture_bar == "")
		self.picture_bar = gfx_loadpic(ITEM_SLIDER_DEFAULT_BAR, MENU_ENFORCELOADING);
	if(self.sound_decrease == "")
		self.sound_decrease = SOUND_DECREASE;
	else
		snd_loadsound(self.sound_decrease, MENU_ENFORCELOADING);
	if(self.sound_increase == "")
		self.sound_increase = SOUND_INCREASE;
	else
		snd_loadsound(self.sound_increase, MENU_ENFORCELOADING);

	if(self.color == '0 0 0')
		self.color = ITEM_SLIDER_COLOR;
	if(self.alpha == 0)
		self.alpha = ITEM_SLIDER_ALPHA;
	if(self.step == 0)
		self.step = ITEM_SLIDER_STEP;
	if(self.slider_size == '0 0 0')
	{
		/*if(self.picture != "")
			self.slider_size = gfx_getimagesize(self.picture);
		else*/
			self.slider_size = ITEM_SLIDER_SIZE;
	}
	if(self.left_margin == 0)
		self.left_margin = ITEM_SLIDER_LEFT_MARGIN;
	if(self.right_margin == 0)
		self.right_margin = ITEM_SLIDER_RIGHT_MARGIN;

	item_init(
		defct_reinit,
		defct_destroy,
		ITEM_SLIDER_KEY,
		ITEM_SLIDER_DRAW,
		defct_mouse_enter,
		defct_mouse_leave,
		defct_action,
		defct_refresh);

	ctcall_init();
};

// ITEM_TEXTSWITCH

void(void) ITEM_TEXTSWITCH_DRAW =
{
	string temp;

	// get the current text
	temp = self.text;
	self.text = getaltstring(self.value, self.text);
	// call ITEM_TEXT
	ITEM_TEXT_DRAW();
	self.text = temp;
};

void(void) ITEM_TEXTSWITCH_REFRESH =
{
	string temp;

	temp = self.text;
	self.text = getaltstring(self.value, self.text);

	ITEM_TEXT_REFRESH();

	self.text = temp;
};

void(float keynr, float ascii)	ITEM_TEXTSWITCH_KEY =
{
	float dir;
	if(ctcall_key(keynr, ascii))
		return;

	if(keynr == K_LEFTARROW || keynr == K_MOUSE2)
	{
		dir = 1;
		self.value = self.value - 1;
		if(self.value < 0)
			self.value = getaltstringcount(self.text) - 1;
	}
	else if(keynr == K_RIGHTARROW || keynr == K_MOUSE1 || keynr == K_ENTER)
	{
		dir = -1;
		self.value = self.value + 1;
		if(self.value > getaltstringcount(self.text) - 1)
			self.value = 0;
	} else
	{
		def_keyevent(keynr, ascii);
		return;
	}
	// play sound
	if( dir == -1 )
		snd_play(self.sound_increase);
	else if( dir == 1 )
		snd_play(self.sound_decrease);

	if(self.switchchange)
		self.switchchange();
};

void(void) ITEM_TEXTSWITCH_DESTROY =
{
	if(self.sound_increase != SOUND_INCREASE)
		snd_unloadsound(self.sound_decrease);
	if(self.sound_increase != SOUND_INCREASE)
		snd_unloadsound(self.sound_increase);
}

void(void) ITEM_TEXTSWITCH =
{
	string temp;

	if(self.sound_decrease == "")
		self.sound_decrease = SOUND_DECREASE;
	else
		snd_loadsound(self.sound_decrease, MENU_ENFORCELOADING);
	if(self.sound_increase == "")
		self.sound_increase = SOUND_INCREASE;
	else
		snd_loadsound(self.sound_increase, MENU_ENFORCELOADING);

	temp = self.text;
	self.text = getaltstring(self.value, self.text);
	ITEM_TEXT();
	self.text = temp;

	item_init(
		defct_reinit,
		ITEM_TEXTSWITCH_DESTROY,
		ITEM_TEXTSWITCH_KEY,
		ITEM_TEXTSWITCH_DRAW,
		defct_mouse_enter,
		defct_mouse_leave,
		defct_action,
		ITEM_TEXTSWITCH_REFRESH);

	ctcall_init();
};

// ITEM_EDITBOX

void(void) ITEM_EDITBOX_REINIT =
{
	self._cursorpos = 0;
	self._button_state = BUTTON_NORMAL;
};

void(void) ITEM_EDITBOX_DRAW =
{
	vector csize, cpos;

	if(self.text != "")
		ITEM_TEXT_DRAW();

	if(self._button_state == BUTTON_NORMAL || mod(time * 1000, 1000 / EDITBOX_CURSOR_FREQ) > 500 / EDITBOX_CURSOR_FREQ)
		return;

	csize_x = 1.5;
	csize_y = self.font_size_y;
	csize_z = 0;
	cpos = self.pos;
	cpos_x = cpos_x + self._cursorpos * self.font_size_x;

	menu_fillarea(cpos, csize, self.color_selected, self.alpha_selected, self.drawflag_selected);
};

void(float ascii) ITEM_EDITBOX_INSERT =
{
	string firsthalf, secondhalf;
	float len;

	if(self._cursorpos > strlen(self.text))
		return;

	if(self.format == "")
	{
		// no format stuff, so lets have fun
		firsthalf = substring(self.text, 0, self._cursorpos);
		secondhalf = substring(self.text, self._cursorpos, strlen(self.text) - self._cursorpos);
		strunzone(self.text);
		self.text = strcat(firsthalf, chr(ascii));
		self.text = strcat(self.text, secondhalf);
		if(self.maxlen >= 0 && strlen(self.text) > self.maxlen)
		{
			// remove the last char(s)
			self.text = substring(self.text, 0, self.maxlen);
		}
		// move the cursor forward
		if(strlen(self.text) >= self._cursorpos)
			self._cursorpos = self._cursorpos + 1;

		self.text = strzone(self.text);
	}
	else // here begins the funny part
	{
		// TODO: add wildcard support :-/
		// move the cursor to the next space
		len = strlen(self.format);
		while(substring(self.format, self._cursorpos, 1) != " " && len > self._cursorpos)
		{
			self._cursorpos = self._cursorpos + 1;
		}
		if(self._cursorpos >= len)
			return;

		firsthalf = substring(self.text, 0, self._cursorpos);
		secondhalf = substring(self.text, self._cursorpos + 1 , strlen(self.text) - self._cursorpos - 1);
		strunzone(self.text);
		self.text = strcat(firsthalf, chr(ascii), secondhalf);
		self.text = strzone(self.text);
	}
};

void(void) ITEM_EDITBOX_LEFT =
{
	if(self._cursorpos > 0)
		self._cursorpos = self._cursorpos - 1;
};

void(void) ITEM_EDITBOX_RIGHT =
{
	if(self._cursorpos < strlen(self.text))
		self._cursorpos = self._cursorpos + 1;
};

void(float keynr, float ascii) ITEM_EDITBOX_KEY =
{
	if(ctcall_key(keynr, ascii))
		return;

	if(ascii >= 30 && ascii <= 126)
	{
		ITEM_EDITBOX_INSERT(ascii);
	} else if(keynr == K_BACKSPACE)
	{
		if(self.format == "")
		{
			string firsthalf, secondhalf;

			firsthalf = substring(self.text,0, self._cursorpos - 1);
			secondhalf = substring(self.text,self._cursorpos, strlen(self.text) - self._cursorpos);
			strunzone(self.text);
			self.text = strcat(firsthalf, secondhalf);
			self.text = strzone(self.text);

			ITEM_EDITBOX_LEFT();
		}
	} else if(keynr == K_ENTER)
	{
		self._action();
		//snd_play(self.sound_action);
	} else if(keynr == K_LEFTARROW)
	{
		ITEM_EDITBOX_LEFT();
	}
	else if(keynr == K_RIGHTARROW)
	{
		ITEM_EDITBOX_RIGHT();
	}
	else
		def_keyevent(keynr, ascii);

	snd_play(self.sound_pressed);
};

void(void) ITEM_EDITBOX_REFRESH =
{
	if(menu_selected != self && menu_selected != self._parent)
		self._button_state = BUTTON_NORMAL;
	else if(self._button_state == BUTTON_NORMAL)
	{
		self._button_state = BUTTON_SELECTED;

		if(self.sound_selected != "" && menu_automatedselection == false)
			snd_play(self.sound_selected);
	}

	if(self._cursorpos > strlen(self.text))
		self._cursorpos = strlen(self.text);

	// hack: we want the text to scroll if possible
	// self.clip_pos holds the normal value
	if( self._cursorpos >= self.size_x / self.font_size_x - 1.5 && self.maxlen > self.size_x / self.font_size_x )
		self.pos_x = self.clip_pos_x -(self._cursorpos - floor( self.size_x / self.font_size_x - 1.5)) * self.font_size_x;
	else
		self.pos_x = self.clip_pos_x;

	ITEM_TEXT_REFRESH();
};

void(void) ITEM_EDITBOX =
{
	if(self.sound_selected != "")
		snd_loadsound(self.sound_selected, SOUND_ENFORCELOADING);
	else
		self.sound_selected = SOUND_SELECT;

	if(self.sound_pressed != "")
		snd_loadsound(self.sound_pressed, SOUND_ENFORCELOADING);
	else
		self.sound_pressed = SOUND_ACTION;

	// if flag wasnt set yet, then set it to FLAG_DRAWONLY
	if(self.flag == 0)
		self.flag = FLAG_AUTOSETCLICK;

	//init clip_pos
	self.clip_pos = self.pos;

	if(self.color == '0 0 0')
		self.color = ITEM_PICTURE_NORMAL_COLOR;
	if(self.alpha == 0)
		self.alpha = ITEM_PICTURE_NORMAL_ALPHA;
	if(self.color_selected == '0 0 0')
		self.color_selected = ITEM_PICTURE_SELECTED_COLOR;
	if(self.alpha_selected == 0)
		self.alpha_selected = ITEM_PICTURE_SELECTED_ALPHA;

	self.text = strzone(self.text);

	ITEM_TEXT_REFRESH();
	if(self.alignment & TEXT_ALIGN_CENTERPOS)
	{
		self.pos_x = self.pos_x - self.size_x / 2;
	} else	if(self.alignment & TEXT_ALIGN_LEFTPOS)
	{
		self.pos_x = self.pos_x - self.size_x;
	}

	item_init(
		defct_reinit,
		defct_destroy,
		ITEM_EDITBOX_KEY,
		ITEM_EDITBOX_DRAW,
		defct_mouse_enter,
		defct_mouse_leave,
		defct_action,
		ITEM_EDITBOX_REFRESH);

	ctcall_init();
};

/*
/////////////////////////////////////////////////////////////////////////
// The "actual" funtions

void(void) ctinit_picture =
{

};

// draws a text (uses the std. way)
void(string text, vector pos, vector size, float alignment, float style, float state) ctdrawtext =
{
	vector alignpos;

	if(text == "")
		return;

	// align to the rect pos - (pos + size)

	// now check the alignement
	if(alignment & TEXT_ALIGN_CENTER)
		alignpos_x = pos_x + (size_x - strlen(text) * self.font_size_x) / 2;
	else if(alignment & TEXT_ALIGN_RIGHT)
		alignpos_x = pos_x + size_x - strlen(text) * self.font_size_x;
	else
		alignpos_x = pos_x;
		alignpos_y = pos_y;

	if(style == TEXTBUTTON_STYLE_OUTLINE && state != BUTTON_NORMAL)
	{
		vector p,s;
		// left
		p_x = pos_x;
		p_y = pos_y;
		s_x = TEXTBUTTON_OUTLINE_WIDTH;
		s_y = size_y;
		if(state == BUTTON_PRESSED)
		{
			menu_fillarea(p, s, self.color_pressed, self.alpha_pressed, self.drawflag_pressed);
		}
		else if(state == BUTTON_SELECTED)
		{
			menu_fillarea(p, s, self.color_selected, self.alpha_selected, self.drawflag_selected);
		}
		// right
		p_x = pos_x + size_x - TEXTBUTTON_OUTLINE_WIDTH;
		p_y = pos_y;
		s_x = TEXTBUTTON_OUTLINE_WIDTH;
		s_y = size_y;
		if(state == BUTTON_PRESSED)
		{
			menu_fillarea(p, s, self.color_pressed, self.alpha_pressed, self.drawflag_pressed);
		}
		else if(state == BUTTON_SELECTED)
		{
			menu_fillarea(p, s, self.color_selected, self.alpha_selected, self.drawflag_selected);
		}
		// top
		p_x = pos_x;
		p_y = pos_y;
		s_y = TEXTBUTTON_OUTLINE_WIDTH;
		s_x = size_x;
		if(state == BUTTON_PRESSED)
		{
			menu_fillarea(p, s, self.color_pressed, self.alpha_pressed, self.drawflag_pressed);
		}
		else if(self._button_state == BUTTON_SELECTED)
		{
			menu_fillarea(p, s, self.color_selected, self.alpha_selected, self.drawflag_selected);
		}
		// bottom
		p_x = pos_x;
		p_y = pos_y + size_y - TEXTBUTTON_OUTLINE_WIDTH;
		s_y = TEXTBUTTON_OUTLINE_WIDTH;
		s_x = size_x;
		if(state == BUTTON_PRESSED)
		{
			menu_fillarea(p, s, self.color_pressed, self.alpha_pressed, self.drawflag_pressed);
		}
		else if(state == BUTTON_SELECTED)
		{
			menu_fillarea(p, s, self.color_selected, self.alpha_selected, self.drawflag_selected);
		}
	} else	if(style == TEXTBUTTON_STYLE_BOX)
	{
		if(state == BUTTON_PRESSED)
		{
			menu_fillarea(alignpos, size, self.color_pressed, self.alpha_pressed, self.drawflag_pressed);
		}
		else if(self._button_state == BUTTON_SELECTED)
		{
			menu_fillarea(alignpos, size, self.color_selected, self.alpha_selected, self.drawflag_selected);
		}
	}

	if(state == BUTTON_NORMAL || style == TEXTBUTTON_STYLE_BOX || style == TEXTBUTTON_STYLE_OUTLINE)
		menu_drawstring(alignpos, text, self.font_size, self.color, self.alpha, self.drawflag);

	if(style == TEXTBUTTON_STYLE_TEXT)
	{
		if(state == BUTTON_PRESSED)
		{
			menu_drawstring(alignpos, text, self.font_size, self.color_pressed, self.alpha_pressed, self.drawflag_pressed);
		}
		else if(state == BUTTON_SELECTED)
		{
			menu_drawstring(alignpos, text, self.font_size, self.color_selected, self.alpha_selected, self.drawflag_selected);
		}
	}
};*/
