///////////////////////////////////////////////
// Menu Manager Source File
///////////////////////
// This file belongs to dpmod/darkplaces
// AK contains the manager code
///////////////////////////////////////////////

void(void) menu_init =
{
	//registercvar("menu_reloadlist","0");

	menu_load();
};

void(void) menu_load =
{
	// load the menu files
	float count, i;

	count = tokenize(MENU_FILENAME_LIST);

	for(i = 0; i < count; i = i + 1)
	{
		menu_loadmenu(argv(i));
		dprint(argv(i), " loaded !\n");
	}

	menu_linkwindows();
};

void(string file) menu_addfiletolist =
{
	float count, i;

	count = tokenize(MENU_FILENAME_LIST);

	for(i = 0; i < count; i = i + 1)
	{
		if(argv(i) == file)
		{
			return;
		}
	}

	MENU_FILENAME_LIST = strcat(MENU_FILENAME_LIST," ",file);
};

void(void) menu_restart =
{
	// actually we empty the ent list and load everything one more time, thats it
	entity ent;
	float  selfused;
	string oldself;
	string oldactive;
	string oldselected;

	// we backup the active window name and the name of the selected item
	oldactive = menu_activewindow.name;
	oldselected = menu_selected.name;
	// backup self's name
	if(self != null_entity)
	{
		oldself = self.name;
		selfused = true;
	}
	else
	{
		selfused = false;
	}

	// first clear the history
	menu_clearhistory();

	// we remove all items
	ent = null_entity;
	while((ent = nextent(ent)) != null_entity)
	{
		menu_removeitem(ent);
	}

	// FIXME: here's a "little" hack (so PRVM_ED_Alloc replaces the items instead of creating new ones)
	time = time + 1.0;

	// now call menu_load
	menu_load();

	time = time - 1.0;	// we cant use gettime cause that always returns time :-/

	// perform the init
	menu_performreinit();

	ent = menu_getitem(oldactive);
	if(ent)
	{
		menu_activewindow = ent;
		ent = menu_getitem(oldselected);
		if(ent)
		{
			menu_selected = ent;
		}
	}

	if(selfused)
	{
		ent = menu_getitem(oldself);
		if(ent)
		{
			self = ent;
		} else // we have no current self...
		{
			error("Reloaded menu files, but the former self (", oldself ,") item is missing !\n");
		}
	}
};
void(string file) menu_loadmenu =
{
	loadfromfile(file);
};

entity(entity start, .entity find1, entity match, .float find2, float match2) findef =
{
	while(1)
	{
		start = findentity(start, find1, match);
		if(start == null_entity)
			break;
		if(start.find2 == match2)
			break;
	}

	return start;
	/*while((start = findentity(start,find1,match))!=null_entity)
		if(start.find2 == match2)
			break;
	return start;*/
};

void(void) menu_linkwindows =
{
	// first verify that MENU_NORMAL_NAME and MENU_INGAME_NAME exist
	// if not add the default strings
	entity ent;
	float x, opos;

	dprint("Loading defaults if necessary\n");

	ent = findstring(null_entity,name, MENU_NORMAL_NAME);
	if(ent == null_entity)
		loadfromdata(MENU_NORMAL_DEFAULT);

	// verify again if MENI_INGAME_NAME is there now
	ent = findstring(null_entity,name, MENU_NORMAL_NAME);
	if(ent == null_entity)
		error("Bad MENU_NORMAL_DEFAULT !\n");

	ent = findstring(null_entity,name, MENU_INGAME_NAME);
	if(ent == null_entity)
		loadfromdata(MENU_INGAME_DEFAULT);

	// verify again if MENI_INGAME_NAME is there now
	ent = findstring(null_entity,name, MENU_INGAME_NAME);
	if(ent == null_entity)
		error("Bad MENU_INGAME_DEFAULT !\n");

	dprint("Verifying that each name is used only once\n");

	// verify that every name is only used *once*
	ent = null_entity;
	while((ent = nextent(ent)) != null_entity)
	{
		self = ent;
		while((self = findstring(self, name, ent.name)) != null_entity)
		{
			if(self != null_entity)
			{
				objerror("Name ", ent.name, " already used !\n");
			}
		}
	}

	dprint("Verification/Setting of: type, parent, next, prev and child fields\n");

	// now we have to :
	// set the parent field with parent_name
	// set the next and prev fields
	// set the child field
	// check the type field
	self = null_entity;
	while((self = nextent(self)) != null_entity)
	{
		if(self.name == "")
		{
			objerror("Name is missing !\n");
			continue;
		}

		if(self.type == "")
		{
			objerror("Type is missing !\n");
			continue;
		}

		if(!isfunction(self.type))
		{
			objerror("Control ", self.type, " not found !\n");
			continue;
		}

		// find parent
		// if parent_name is "" do nothing else set parent
		if(self.parent != "")
		{
			ent = findstring(null_entity, name, self.parent);

			if(ent == null_entity)
			{
				objerror("Item ", self.parent, " not found !\n");
				continue;
			}

			self._parent = ent;
		}
		else
		{
			self._parent = null_entity;
		}
	}

	dprint("Calling the type functions\n");

	// call the type functions (former classname functions)
	ent = null_entity;
	while((ent = nextent(ent)) != null_entity)
	{
		self = ent;
		//dprint("Calling ",self.type," (", etos(self),")\n");
		callfunction(self.type);
	}

	dprint("Orderpos is verified or set\n");

	// now auto-set all ents with orderpos 0
	self = null_entity;
	while((self = findfloat(self,orderpos, 0)) != null_entity)
	{
		if(self.parent == "")
			continue;

		// now go through all orderpos' beginning from 1
		opos = 1;
		while((ent = findef(null_entity, _parent, self._parent, orderpos, opos)) != null_entity)
		{
			opos = opos + 1;
		}

		self.orderpos = opos;
	}

	dprint("Set the _child, _prev and _next fields\n");

	self = null_entity;
	while((self = nextent(self)) != null_entity)
	{
		// find first child
		// orderpos starts with 1
		ent = findef(null_entity, _parent, self, orderpos, 1);

		if(ent == null_entity)
		{
			if(findentity(ent, _parent, self) != null_entity)
			{
				objerror("Order pos 1 is missing in the child list of ", self.name, " !\n");
				continue;
			}
			//else doesnt have any chilren
		}
		else
			self._child = ent;

		// add to next, previous list
		// find orderpos - x (starting with x = 1)
		x = self.orderpos;

		while(x > 1)
		{
			x = x - 1;

			ent = findef(null_entity, _parent, self._parent, orderpos, x);
			if(ent != null_entity)
			{
				self._prev = ent;
				ent._next = self;
				break;
			}
		}

		// find orderpos + x (starting with x = 1 until x == self.oderpos + 100)
		x = self.orderpos;

		while(x < self.orderpos + 100)
		{
			x = x + 1;

			ent = findef(null_entity, _parent, self._parent, orderpos, x);
			if(ent != null_entity)
			{
				self._next = ent;
				ent._prev = self;
				break;
			}
		}
	}

	dprint("Linking windows finished.\n");
};

void(void) menu_toggle =
{
	// only let the qc toggle the menu if we are ingame or a developer
	if(gamestatus & GAME_CONNECTED || cvar("developer"))
	{
		// then allow toggling
		m_toggle();
	}// else do nothing
};

void(void) menu_performreinit =
{
	// clear history
	menu_clearhistory();

	// reset the key hook (if necessary at all)
	menu_keyhook = null_function;

	// and reinit all menu items
	self = null_entity;
	while((self = nextent(self)) != null_entity)
	{
		if(self.parent == "")
			self._parent = null_entity;
		//else actually this shouldnt happen
		else if(self._parent.name != self.parent)
			objerror("Parent (should be ", self.parent, ") of non-menu item ", self.name, " changed to ", self._parent.name, " !\n");

		raise_reinit(self); // always call reinit
	}

	// choose which menu to display
	if(MENU_ALLOWINGAME && (gamestatus & GAME_CONNECTED))
		menu_activewindow = findstring(null_entity, name, MENU_INGAME_NAME);
	else
		menu_activewindow = findstring(null_entity, name, MENU_NORMAL_NAME);

	// set the selected item
	menu_selected = menu_activewindow;
	// find first child that can be selected
	menu_selectdown();
};

void(entity par, float selectstate) menu_processmouse =
{
	// self is parent
	// loop through all childs
	// and try to find an object whose click rect fits to the mouse coords
	entity ent;
	vector old_cursor, local_cursor;
	vector old_c_size, old_c_pos, clipped_size;

	ent = par._child;
	if(ent == null_entity)
		return;

	if(menu_clip_size != '0 0 0')
	{
		clipped_size = cliprectsize(gfx_conmentogfx(par.clip_pos),par.clip_size, menu_clip_pos, menu_clip_size);
	}
	else
	{
		clipped_size = par.clip_size;
	}

	if(clipped_size != '0 0 0')
	{
		// do clip the clip area
		// save the old
		old_c_pos = menu_clip_pos;
		old_c_size = menu_clip_size;

		// clip the position
		menu_clip_pos = cliprectpos(gfx_conmentogfx(par.clip_pos), par.clip_size, menu_clip_pos, menu_clip_size);
		menu_clip_size = clipped_size;
	}

	menu_localorigin = menu_localorigin + par.origin;

	old_cursor = menu_cursor;
	local_cursor = gfx_congfxtomen(cursor);

	//print(vtos(cursor)," ");print(vtos(menu_clip_pos)," ");print(vtos(menu_clip_size),"\n");

	if(inrect(cursor, menu_clip_pos, menu_clip_size) || menu_clip_size == '0 0 0')
	{
		do
		{
			// if not visible, continue to the next item
			if(menu_isvisible(ent))
			{
				old_cursor = menu_cursor;
				menu_cursor = local_cursor;
				if(inrect(local_cursor, ent.click_pos, ent.click_size))
				{
					// call mouse_enter event ?
					if(!(ent.flag & _FLAG_MOUSEINAREA) && menu_hasevents(ent))
					{
						raise_mouse_enter(ent);

						ent.flag = ent.flag | _FLAG_MOUSEINAREA;
					}

					// select it ?
					if(menu_selectable(ent) && selectstate != MENU_SELECT_NEVER)
					{
						menu_selected = ent;
					}
					else if(selectstate == MENU_SELECT_ALWAYS)
					{
						if(menu_hasevents(ent))
						{
							menu_selected = ent;
						}
					}
				}
				else
				{
					// call mouse_leave event ?
					if((ent.flag & _FLAG_MOUSEINAREA) && menu_hasevents(ent))
					{
						raise_mouse_leave(ent);

						// this only works if _FLAG_MOUSEINAREA is set
						ent.flag = ent.flag - _FLAG_MOUSEINAREA;
					}
				}

				if(menu_selected != ent)
					menu_cursor = old_cursor;


				// if ent has children recurse through them
				if(ent._child != null_entity)
				{
					if((ent.flag & FLAG_CHILDDRAWONLY) || (ent.flag & FLAG_CHILDDRAWREFRESHONLY))
					{
						menu_processmouse(ent, MENU_SELECT_NEVER);
					}
					else
					{
						menu_processmouse(ent, selectstate);
					}
				}
			}
		} while((ent = ent._next) != null_entity);
	}

	menu_localorigin = menu_localorigin - par.origin;

	// restore the old menu_clip vars if necessary
	if(clipped_size != '0 0 0')
	{
		menu_clip_size = old_c_size;
		menu_clip_pos = old_c_pos;
	}
};

void(void) menu_frame =
{
	/*
	// this is only for debugging purposes
	// thus its unstable and *won't* work any more when Ive changed dp's behavior with
	// the builtin list (the precache functions will only work for menu_init)
	if(cvar("menu_reloadlist"))
	{
		cvar_set("menu_reloadlist","0");
		menu_restart();
	}*/
	// if mouse moved, process it
	if(cursor_rel != '0 0 0')
	{
		menu_processmouse(menu_activewindow, MENU_SELECT_SELECTABLE);
	}

}

void(entity menu) menu_drawwindow =
{
	// loop through all children and draw them
	entity ent;
	vector old_c_pos, old_c_size, clipped_size, clipped_pos;

	// set the clipping area
	// is this necessary at all ?
	if(menu_clip_size != '0 0 0')
	{
		clipped_size = cliprectsize(gfx_conmentogfx(menu.clip_pos),menu.clip_size, menu_clip_pos, menu_clip_size);
	}
	else
	{
		clipped_size = menu.clip_size;
	}

	if(clipped_size != '0 0 0')
	{
		// do clip the clip area
		// save the old
		old_c_pos = menu_clip_pos;
		old_c_size = menu_clip_size;

		// clip the position
		menu_clip_pos = cliprectpos( gfx_conmentogfx(menu.clip_pos) , menu.clip_size, menu_clip_pos, menu_clip_size);
		menu_clip_size = clipped_size;
		gfx_setcliparea(menu_clip_pos, menu_clip_size);
	}

	// set the localorigin (the clipping position wont be affected)
	menu_localorigin = menu_localorigin + menu.origin;

	ent = menu._child;
	do
	{
		// if it's not visible continue
		if(menu_isvisible(ent))
		{
			self = ent;
			if(menu_hasevents(ent))
			{
				raise_refresh(ent);
			} else if(ent.flag & FLAG_DRAWREFRESHONLY)
			{
				raise_refresh(ent);
			} else if(ent.flag & FLAG_DRAWONLY)
			{
				// TODO: find a better solution for this hack
			} else if(ent._parent)
			{
				if(ent._parent.flag & FLAG_CHILDDRAWREFRESHONLY)
					raise_refresh(ent);
			}

			raise_draw(ent);

			if(ent._child != null_entity)
			{
				menu_drawwindow(ent);
			}

		}
	} while((ent = ent._next) != null_entity);

	menu_localorigin = menu_localorigin - menu.origin;

	// restore the old menu_clip vars if necessary
	if(clipped_size != '0 0 0')
	{
		menu_clip_size = old_c_size;
		menu_clip_pos = old_c_pos;
	}

	// reset the clip area of the old menu
	if(menu_clip_size != '0 0 0')
		gfx_setcliparea(menu_clip_pos, menu_clip_size);
	else
		gfx_resetcliparea();
}

void(void) menu_draw =
{
	// if menu_activewindow is visible loop though it
	if(menu_isvisible(menu_activewindow))
	{
		//menu_setcliparea('100 100 0', '400 400 0');
		menu_drawwindow(menu_activewindow);
		menu_localorigin = '0 0 0';
		menu_clip_pos = '0 0 0';
		menu_clip_size = '0 0 0';
		menu_resetcliparea();
	}
}

float(entity e) menu_hasevents =
{
	if(e.flag & FLAG_DRAWONLY)
		return false;
	if(e.flag & FLAG_DRAWREFRESHONLY)
		return false;
	if(e._parent)
	{
		if(e._parent.flag & FLAG_CHILDDRAWONLY)
			return false;
		if(e._parent.flag & FLAG_CHILDDRAWREFRESHONLY)
			return false;
	}
	if(menu_isvisible(e))
		return true;
	return false;
};

float(entity e) menu_isvisible =
{
	if(e.flag & FLAG_HIDDEN)
		return false;

	if((e.flag & FLAG_SERVERONLY) && !(gamestatus & GAME_ISSERVER))
		return false;

	if((e.flag & FLAG_DEVELOPERONLY) && !(gamestatus & GAME_DEVELOPER))
		return false;

	return true;
};

float(entity e) menu_selectable =
{
	if(!menu_hasevents(e))
		return false;
	if(e.flag & FLAG_NOSELECT)
		return false;

	//if(e == menu_getitem("quit"))
	//	crash();

	return true;
};

void(void) menu_shutdown =
{
	// call the terminate event for each object
	self = null_entity;
	while((self = nextent(self)) != null_entity)
	{
		raise_destroy(self);
	}
};

void(float keynr, float ascii) menu_keydown =
{
	// is a keyhook set ?
	if(menu_keyhook != null_function)
	{
		// call it
		menu_keyhook(keynr, ascii);
		return;
	}
	// before calling the current keydown functions, process the mouse again
	// so only the correct item is called
	// (except mouse wheel up and down)
	// if the mouse doesnt point to an item, there wont be a reaction on the clicking
	if(K_MOUSE1 <= keynr && keynr <= K_MOUSE10)
	{
		entity key_selected;
		key_selected = menu_selected;
		menu_selected = null_entity;
		menu_processmouse(menu_activewindow, MENU_SELECT_ALWAYS);

		// if we find anything, we give it the key event, perhaps it can use it
		if(menu_selected != key_selected)
		{
			// pass the keyevent
			if(menu_selected != null_entity)
			{
				raise_key(menu_selected, keynr, ascii);
			}

			// if it is selectable the user perhaps wanted to reselect it
			if(menu_selectable(menu_selected) == false || menu_selected == null_entity)
			{
				menu_selected = key_selected;
			}

			return;
		}
		// go on
	}

	// call current selected keydown function
	// if nothing is selected -> window has no items -> call window key
	if(menu_selected == null_entity)
	{
		// call window keydown
		raise_key(menu_activewindow, keynr, ascii);
	}
	else if(menu_hasevents(menu_selected))
	{
		raise_key(menu_selected, keynr, ascii);
	}
};

void(void) menu_selectprev =
{
	entity temp;

	temp = menu_selected;
	// loop backward through the list until one item is selectable
	while((temp = temp._prev) != null_entity)
		if(menu_selectable(temp))
			break;

	if(temp != null_entity)
		menu_selected = temp;
};

void(void) menu_selectnext =
{
	entity temp;

	temp = menu_selected;
	// loop forward through the list until one item is selectable
	while((temp = temp._next) != null_entity)
		if(menu_selectable(temp))
			break;

	if(temp != null_entity)
		menu_selected = temp;
};

void(void) menu_loopnext =
{
	entity old;
	old = menu_selected;

	menu_selectnext();
	if(menu_selected == old)
	{
		menu_selected = old._parent._child;
		if(!menu_selectable(menu_selected))
			menu_selectnext();
	}
};

void(void) menu_loopprev =
{
	entity old;
	old = menu_selected;
	menu_selectprev();
	if(menu_selected == old)
	{
		while(old._next != null_entity)
		{
			old = old._next;
		}

		menu_selected = old;
		if(!menu_selectable(old))
		{
			menu_selectprev();
		}
	}
}

void(void) menu_selectdown =
{
	// move down a level, then search for a selectable child
	// if none is found, then search for a sub-menu
	// if one is found, recurse through it, else keep the old menu_selected
	// (while recursing set the history)

	entity ent, old_selected;

	// if there is no child, return
	if(menu_selected._child == null_entity)
	{
		return;
	}

	// loop through the children till a selectable is found
	ent = menu_selected._child;
	do
	{
		if(menu_selectable(ent))
		{
			// found one -> break
			menu_selected = ent;
			return;
		}
	} while((ent = ent._next) != null_entity);

	// we found no selectable child, thus we loop through the children once again
	// and recurse
	ent = menu_selected._child;
	old_selected = menu_selected;
	do
	{
		if(ent._child != null_entity)
		{
			if(!(ent.flag & FLAG_CHILDDRAWONLY) && !(ent.flag & FLAG_CHILDDRAWREFRESHONLY))
			{
				// give it a try
				menu_selected = ent;
				menu_selectdown();

				// found one ?
				if(menu_selected != ent)
				{
					return;
				}
			}


		}
	} while((ent = ent._next) != null_entity);

	// we didnt find anything
	menu_selected = old_selected;
}


void(void) menu_selectup =
{
	// if we try to up from the current activewindow pop the history.
	// else move up in the hierarchy and try to select and item.

	//print( "Check whether menu_selected == menu_activewindow\n" );
	if( menu_selected == menu_activewindow ) {
		//print( "Pop history\n" );
		if( menu_history == null_entity ) {
			//print( "History empty!\n" );
			menu_toggle();
			menu_reselect();
		}
		menu_pophistory();
		return;
	}

	//print( "Check whether parent exists\n" );
	if( menu_selected._parent == null_entity )
		return;

	//print( "Try to select the parent\n" );
	menu_selected = menu_selected._parent;
	if( menu_selectable( menu_selected ) )
		return;

	//print( "Try to select an item after the parent\n" );
	menu_selectnext();
	if( menu_selectable( menu_selected ) )
		return;

	//print( "Try to select an item before the parent\n" );
	menu_selectprev();
	if( menu_selectable( menu_selected ) )
		return;

	//print( "Try to select the parent of the parent\n" );
	menu_selectup();

	//print( "Selected:\n" );
	//eprint( menu_selected );
};

void(void) menu_reselect =
{
	menu_selected = menu_activewindow;
	menu_selectdown();
};

void(entity menu, float setactive) menu_jumptowindow =
{
	// only jump to windows
	if(menu.type != "ITEM_WINDOW" && menu.type != "ITEM_REFERENCE")
		error("Cant jump to ", menu.name, " !\n");

	// add a history point
	if(setactive) {
		menu_pushhistory(menu);
		menu_activewindow = menu;
	}

	// now set the selected to the first selectable child
	menu_selected = menu;
	menu_selectdown();
};

entity(string item_name) menu_getitem =
{
	entity item;

	item = findstring(null_entity,  name, item_name);
	if( item == null_entity )
		error( "Couldn't find item '", item_name, "'!" );

	return item;
};

void(entity ent) menu_removeitem =
{
	// raise the destroy event
	raise_destroy(ent);
	remove(ent);
};


// history stuff

void(entity ent) menu_pushhistory =
{
	entity his;

	/*
	// dont create multiple histories for the same 'trigger'
	if(menu_history)
	{
		if(menu_history._next == ent)
			return;
	}*/

	menu_keyhook = null_function;

	his = spawn();

	his.type = "MMANAGER_HISTORY";
	his._prev = menu_history;
	his._child = menu_selected;
	his._parent = menu_activewindow;
	his._next = ent; // "used for"

	menu_history = his;
};

void(void) menu_pophistory =
{
	entity tmp;

	if(menu_history == null_entity)
	{
		return;
	}

	menu_keyhook = null_function;

	menu_selected = menu_history._child;
	menu_activewindow = menu_history._parent;

	tmp = menu_history;
	menu_history = menu_history._prev;

	remove(tmp);
};

float(entity ent) menu_verifyhistory =
{
	if(menu_history == null_entity)
		return false;

	if(menu_history._next == ent)
		return true;
	return false;
};

void(void) menu_clearhistory =
{
	entity ent;

	ent = null_entity;
	while((ent = findstring(ent, type, "MMANAGER_HISTORY")) != null_entity)
	{
		remove(ent);
	}

	menu_history = null_entity;
};
