///////////////////////////////////////////////
// Functions Source File
///////////////////////
// This file belongs to dpmod/darkplaces
// AK contains all menu controlling stuff (sub-menus)
///////////////////////////////////////////////

// raise function
/* template

void(entity ent)	raise_x =
{
	entity old;
	if(!ent._x)
		return;

	old = self;
	self = ent;
	self._x();
	self = old;
};
*/

void(entity ent)	raise_reinit =
{
	entity old;
	if(!ent._reinit)
		return;

	old = self;
	self = ent;
	self._reinit();
	self = old;
};

void(entity ent)	raise_destroy =
{
	entity old;
	if(!ent._destroy)
		return;

	old = self;
	self = ent;
	self._destroy();
	self = old;
};

void(entity ent, float keynr, float ascii)	raise_key =
{
	entity old;
	if(!ent._key)
		return;

	old = self;
	self = ent;
	self._key(keynr, ascii);
	self = old;
};

void(entity ent)	raise_draw =
{
	entity old;
	if(!ent._draw)
		return;

	old = self;
	self = ent;
	self._draw();
	self = old;
};

void(entity ent)	raise_mouse_enter =
{
	entity old;
	if(!ent._mouse_enter)
		return;

	old = self;
	self = ent;
	self._mouse_enter();
	self = old;
};

void(entity ent)	raise_mouse_leave =
{
	entity old;
	if(!ent._mouse_leave)
		return;

	old = self;
	self = ent;
	self._mouse_leave();
	self = old;
};

void(entity ent)	raise_action =
{
	entity old;
	if(!ent._action)
		return;

	old = self;
	self = ent;
	self._action();
	self = old;
};

void(entity ent)	raise_refresh =
{
	entity old;
	if(!ent._refresh)
		return;

	old = self;
	self = ent;
	self._refresh();
	self = old;
};

// safe call control function functions
// default control functions
/* template

void(void) ctcall_x	=
{
	if(self.x)
		self.x();
};

*/
void(void)	ctcall_init =
{
	if(self.init)
		self.init();
};

void(void)  ctcall_reinit =
{
	if(self.reinit)
		self.reinit();
};

void(void) ctcall_destroy =
{
	if(self.destroy)
		self.destroy();
};

float(float keynr, float ascii)  ctcall_key =
{
	if(self.key)
		return self.key(keynr, ascii);
};

void(void)	ctcall_draw =
{
	if(self.draw)
		self.draw();
};

void(void)	ctcall_mouse_enter =
{
	if(self.mouse_enter)
		self.mouse_enter();
};

void(void)	ctcall_mouse_leave =
{
	if(self.mouse_leave)
		self.mouse_leave();
};

void(void)	ctcall_action =
{
	if(self.action)
		self.action();
};

void(void) ctcall_refresh =
{
	if(self.refresh)
		self.refresh();
}

// default control functions
/* template (expect defct_key)

void(void) defct_x =
{
	ctcall_x();
};

*/
// defct_init not needed cause its the same like the type function

void(void) defct_reinit =
{
	ctcall_reinit();
};

void(void) defct_destroy =
{
	ctcall_destroy();
};

void(float keynr, float ascii)  defct_key =
{
	if(!ctcall_key(keynr, ascii))
		def_keyevent(keynr, ascii);
};

void(void)	defct_draw =
{
	ctcall_draw();
};

void(void)	defct_mouse_enter =
{
	ctcall_mouse_enter();
};

void(void)	defct_mouse_leave =
{
	ctcall_mouse_leave();
};

void(void)	defct_action =
{
	ctcall_action();
};

void(void)	defct_refresh =
{
	// do first the own fresh stuff and *then* call refresh
	def_refresh();
	ctcall_refresh();
}

// default refresh function
void(void)	def_refresh =
{
	// refresh stuff
	if(self.flag & FLAG_AUTOSETCLICK)
	{
		self.click_pos = self.pos;
		self.click_size = self.size;
	}
	if(self.flag & FLAG_AUTOSETCLIP)
	{
		self.clip_pos = self.pos;
		self.clip_size = self.size;
	}
};

// default key function
void(float keynr, float ascii)	def_keyevent =
{
	if(keynr == K_ESCAPE)
	{
		// move up to the parent
		menu_selectup();
	} else if(keynr == K_LEFTARROW || keynr == K_UPARROW)
	{
		// move to the previous element
		menu_loopprev();

		if(menu_selected == self)
		{
			if(self._prev)
			{
				menu_selected = self._prev;
				menu_selectdown();
				if(menu_selected != self._prev)
				{
					return;
				}
			}
			menu_selected = self;
		}
	} else if(keynr == K_RIGHTARROW || keynr == K_DOWNARROW)
	{
		// move to the  next element
		menu_loopnext();

		if(menu_selected == self)
		{
			if(self._next)
			{
				menu_selected = self._next;
				menu_selectdown();
				if(menu_selected != self._next)
				{
					return;
				}
			}
			menu_selected = self;
		}
	} else if(keynr == K_ENTER || keynr == K_MOUSE1)
	{
		eprint(self);
		print("Action called\n");
		if(self._action)
			self._action();
		// move to the child menu
		menu_selectdown();
	} else if(keynr == K_TAB)
	{
		// select next and try to "go" down
		// TODO: make a loop out of that !
		if(self._next)
		{
			menu_selected = self._next;
			menu_selectdown();
			if(menu_selected != self._next)
			{
				return;
			}
		}
		if(self._prev)
		{
			menu_selected = self._prev;
			menu_selectdown();
			if(menu_selected != self._prev)
			{
				return;
			}
		}
		menu_selected = self;
	}
};

// a rect is described by the top-left point and its size
float(vector point, vector r_pos, vector r_size) inrect =
{
	if(point_x < r_pos_x)
		return false;
	if(point_y < r_pos_y)
		return false;
	if(point_x > (r_pos_x + r_size_x))
		return false;
	if(point_y > (r_pos_y + r_size_y))
		return false;
	return true;
};

vector(vector r_pos, vector r_size, vector c_pos, vector c_size) cliprectpos =
{
	vector v;

	// clip r_pos only
	v_x = max(c_pos_x, r_pos_x);
	v_y = max(c_pos_y, r_pos_y);

	return v;
};

vector(vector r_pos, vector r_size, vector c_pos, vector c_size) cliprectsize =
{
	vector v;
	// safe version
	//r_size_x = bound(c_pos_x, r_pos_x + r_size_x, c_pos_x + c_size_x) - bound(c_pos_x, r_pos_x, c_pos_x + c_size_x);
	//r_size_y = bound(c_pos_y, r_pos_y + r_size_y, c_pos_y + c_size_y) - bound(c_pos_y, r_pos_y, c_pos_y + c_size_y);
	v_x = min(c_pos_x + c_size_x, r_pos_x + r_size_x) - max(c_pos_x, r_pos_x);
	v_y = min(c_pos_y + c_size_y, r_pos_y + r_size_y) - max(c_pos_y, r_pos_y);

	if(v_x <= 0 || v_y <= 0)
		v = '0 0 0';

	return v;
}

void(void(void) reinitevent, void(void) destroyevent, void(float key, float ascii) keyevent, void(void) drawevent, void(void) mouse_enterevent, void(void) mouse_leaveevent, void(void) actionevent, void(void) refreshevent)
	item_init =
{
	self._reinit  = reinitevent;
	self._destroy = destroyevent;

	self._key 	= keyevent;
	self._draw 	= drawevent;
	self._mouse_enter = mouse_enterevent;
	self._mouse_leave = mouse_leaveevent;
	self._action = actionevent;
	self._refresh = refreshevent;
};

float(float tfactor) getflicker =
{
	// TODO: use tfactor to vary the result
	return (sin(tfactor * time) + 1)/2;
};

float(string s) getaltstringcount =
{
	float len;
	float count;
	float pos;

	len = strlen(s);
	count = 0;
	for(pos = 0; pos < len; pos = pos + 1)
	{
		if(substring(s,pos,1) == "'")
			count = count + 1;
	}

	if(mod(count,2) == 1)
		return 0; // bad string

	return (count / 2);
};

string(float n, string s) getaltstring =
{
	float start, length;
	float tmp;

	n = rint(n);

	if(n >= getaltstringcount(s) || n < 0)
		return "";

	// go to the beginning of the altstring
	tmp = 0;
	for(start = 0;tmp <= n * 2 ; start = start + 1)
	{
		if(substring(s, start, 1) == "'")
			tmp = tmp + 1;
	}

	for(length = 0; substring(s, start + length, 1) != "'"; length = length + 1)
	{
	}

	return substring(s, start, length);
};

