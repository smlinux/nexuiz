#ifdef INTERFACE
CLASS(ListBox) EXTENDS(Item)
	METHOD(ListBox, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(ListBox, configureListBox, void(entity, float, float))
	METHOD(ListBox, draw, void(entity))
	METHOD(ListBox, keyDown, float(entity, float, float, float))
	METHOD(ListBox, mousePress, float(entity, vector))
	METHOD(ListBox, mouseDrag, float(entity, vector))
	METHOD(ListBox, mouseRelease, float(entity, vector))
	ATTRIB(ListBox, focusable, float, 1)
	ATTRIB(ListBox, selectedItem, float, 0)
	ATTRIB(ListBox, size, vector, '0 0 0')
	ATTRIB(ListBox, scrollPos, float, 0) // measured in window heights, fixed when needed
	ATTRIB(ListBox, previousValue, float, 0)
	ATTRIB(ListBox, pressed, float, 0)
	ATTRIB(ListBox, pressOffset, float, 0)

	METHOD(ListBox, updateControlTopBottom, void(entity))
	ATTRIB(ListBox, controlTop, float, 0)
	ATTRIB(ListBox, controlBottom, float, 0)
	ATTRIB(ListBox, controlWidth, float, 0)
	ATTRIB(ListBox, dragScrollTimer, float, 0)
	ATTRIB(ListBox, dragScrollPos, vector, '0 0 0')

	ATTRIB(ListBox, src, string, "") // scrollbar
	ATTRIB(ListBox, tolerance, vector, '0 0 0') // drag tolerance
	ATTRIB(ListBox, scrollbarWidth, float, 0) // pixels
	ATTRIB(ListBox, nItems, float, 0)
	ATTRIB(ListBox, itemHeight, float, 0)
	METHOD(ListBox, drawListBoxItem, void(entity, float, vector, float)) // item number, width/height, selected
	METHOD(ListBox, clickListBoxItem, void(entity, float, vector)) // item number, relative clickpos
ENDCLASS(ListBox)
#endif

#ifdef IMPLEMENTATION
void resizeNotifyListBox(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	me.size = absSize;
	me.controlWidth = me.scrollbarWidth / absSize_x;
}
void configureListBoxListBox(entity me, float theScrollbarWidth, float theItemHeight)
{
	me.scrollbarWidth = theScrollbarWidth;
	me.itemHeight = theItemHeight;
}
float keyDownListBox(entity me, float key, float ascii, float shift)
{
	if(key == K_DOWNARROW)
		me.selectedItem += 1;
	else if(key == K_UPARROW)
		me.selectedItem -= 1;
	else if(key == K_MWHEELUP)
	{
		me.scrollPos = max(me.scrollPos - 0.5, 0);
		me.selectedItem = min(me.selectedItem, floor((me.scrollPos + 1) / me.itemHeight - 1));
	}
	else if(key == K_MWHEELDOWN)
	{
		me.scrollPos = min(me.scrollPos + 0.5, me.nItems * me.itemHeight - 1);
		me.selectedItem = max(me.selectedItem, ceil(me.scrollPos / me.itemHeight));
	}
	else if(key == K_PGUP)
		me.selectedItem = me.selectedItem - 1 / me.itemHeight;
	else if(key == K_PGDN)
		me.selectedItem = me.selectedItem + 1 / me.itemHeight;
	else if(key == K_HOME)
		me.selectedItem = 0;
	else if(key == K_END)
		me.selectedItem = me.nItems - 1;
	else
		return 0;
	me.selectedItem = floor(0.5 + bound(0, me.selectedItem, me.nItems - 1));
	return 1;
}
float mouseDragListBox(entity me, vector pos)
{
	float hit;
	float v;
	me.updateControlTopBottom(me);
	me.dragScrollPos = pos;
	if(me.pressed == 1)
	{
		hit = 1;
		if(pos_x < 1 - me.controlWidth - me.tolerance_x) hit = 0;
		if(pos_y < 0 - me.tolerance_y) hit = 0;
		if(pos_x >= 1 + me.tolerance_x) hit = 0;
		if(pos_y >= 1 + me.tolerance_y) hit = 0;
		if(hit)
		{
			// calculate new pos to v
			float delta;
			delta = (pos_y - me.pressOffset) / (1 - 1 / (me.nItems * me.itemHeight)) * (me.nItems * me.itemHeight - 1);
			me.scrollPos = me.previousValue + delta;
		}
		else
			me.scrollPos = me.previousValue;
		me.scrollPos = min(me.scrollPos, me.nItems * me.itemHeight - 1);
		me.scrollPos = max(me.scrollPos, 0);
		me.selectedItem = min(me.selectedItem, floor((me.scrollPos + 1) / me.itemHeight - 1));
		me.selectedItem = max(me.selectedItem, ceil(me.scrollPos / me.itemHeight));
	}
	else if(me.pressed == 2)
	{
		me.selectedItem = (me.scrollPos + pos_y) / me.itemHeight;
		me.selectedItem = floor(0.5 + bound(0, me.selectedItem, me.nItems - 1));
	}
	return 1;
}
float mousePressListBox(entity me, vector pos)
{
	if(pos_x < 0) return 0;
	if(pos_y < 0) return 0;
	if(pos_x >= 1) return 0;
	if(pos_y >= 1) return 0;
	me.updateControlTopBottom(me);
	if(pos_x >= 1 - me.controlWidth)
	{
		// if hit, set me.pressed, otherwise scroll by one page
		if(pos_y < me.controlTop)
		{
			// page up
			me.scrollPos = max(me.scrollPos - 1, 0);
			me.selectedItem = min(me.selectedItem, floor((me.scrollPos + 1) / me.itemHeight - 1));
		}
		else if(pos_y > me.controlBottom)
		{
			// page down
			me.scrollPos = min(me.scrollPos + 1, me.nItems * me.itemHeight - 1);
			me.selectedItem = max(me.selectedItem, ceil(me.scrollPos / me.itemHeight));
		}
		else
		{
			me.pressed = 1;
			me.pressOffset = pos_y;
			me.previousValue = me.scrollPos;
		}
	}
	else
	{
		// an item has been clicked. Select it, ...
		me.selectedItem = (me.scrollPos + pos_y) / me.itemHeight;
		me.selectedItem = floor(0.5 + bound(0, me.selectedItem, me.nItems - 1));
		// continue doing that while dragging (even when dragging outside). When releasing, forward the click to the then selected item.
		me.pressed = 2;
	}
	return 1;
}
float mouseReleaseListBox(entity me, vector pos)
{
	vector absSize, clickOrigin;
	if(me.pressed == 1)
	{
		// slider dragging mode
		// in that case, nothing happens on releasing
	}
	else if(me.pressed == 2)
	{
		// item dragging mode
		// select current one one last time...
		me.selectedItem = (me.scrollPos + pos_y) / me.itemHeight;
		me.selectedItem = floor(0.5 + bound(0, me.selectedItem, me.nItems - 1));
		// and give it a nice click event
		if(me.nItems > 0)
		{
			absSize = boxToGlobalSize(me.size, eX * (1 - me.controlWidth) + eY);
			me.clickListBoxItem(me, me.selectedItem, globalToBox(pos, eX * (me.selectedItem * me.itemHeight - me.scrollPos), absSize));
		}
	}
	me.pressed = 0;
	return 1;
}
void updateControlTopBottomListBox(entity me)
{
	// scrollPos is in 0..1 and indicates where the "page" currently shown starts.
	if(me.nItems * me.itemHeight <= 1)
	{
		// we don't need no stinkin' scrollbar, we don't need no view control...
		me.controlTop = 0;
		me.controlBottom = 1;
		me.scrollPos = 0;
	}
	else
	{
		if(frametime) // only do this in draw frames
		{
			me.dragScrollTimer -= frametime;
			if(me.dragScrollTimer < 0)
			{
				float save;
				save = me.scrollPos;
				// if selected item is below listbox, increase scrollpos so it is in
				me.scrollPos = max(me.scrollPos, me.selectedItem * me.itemHeight - 1 + me.itemHeight);
				// if selected item is above listbox, decrease scrollpos so it is in
				me.scrollPos = min(me.scrollPos, me.selectedItem * me.itemHeight);
				if(me.scrollPos != save)
					me.dragScrollTimer = 0.2;
			}
		}
		// if scroll pos is below end of list, fix it
		me.scrollPos = min(me.scrollPos, me.nItems * me.itemHeight - 1);
		// if scroll pos is above beginning of list, fix it
		me.scrollPos = max(me.scrollPos, 0);
		// now that we know where the list is scrolled to, find out where to draw the control
		me.controlTop = max(0, me.scrollPos / (me.nItems * me.itemHeight));
		me.controlBottom = min((me.scrollPos + 1) / (me.nItems * me.itemHeight), 1);
	}
}
void drawListBox(entity me)
{
	float i;
	vector absSize;
	vector oldshift, oldscale;
	if(me.pressed == 2)
		me.mouseDrag(me, me.dragScrollPos); // simulate mouseDrag event
	me.updateControlTopBottom(me);
	draw_VertButtonPicture(eX * (1 - me.controlWidth), strcat(me.src, "_s"), eX * me.controlWidth + eY, '1 1 1', 1);
	if(me.nItems * me.itemHeight > 1)
	{
		vector o, s;
		o = eX * (1 - me.controlWidth) + eY * me.controlTop;
		s = eX * me.controlWidth + eY * (me.controlBottom - me.controlTop);
		if(me.pressed)
			draw_VertButtonPicture(o, strcat(me.src, "_c"), s, '1 1 1', 1);
		else if(me.focused)
			draw_VertButtonPicture(o, strcat(me.src, "_f"), s, '1 1 1', 1);
		else
			draw_VertButtonPicture(o, strcat(me.src, "_n"), s, '1 1 1', 1);
	}
	draw_SetClip();
	oldshift = draw_shift;
	oldscale = draw_scale;
	absSize = boxToGlobalSize(me.size, eX * (1 - me.controlWidth) + eY * me.itemHeight);
	for(i = floor(me.scrollPos / me.itemHeight); i < me.nItems; ++i)
	{
		float y;
		y = i * me.itemHeight - me.scrollPos;
		if(y >= 1)
			break;
		draw_shift = boxToGlobal(eY * y, oldshift, oldscale);
		draw_scale = boxToGlobalSize(eY * me.itemHeight + eX * (1 - me.controlWidth), oldscale);
		me.drawListBoxItem(me, i, absSize, (me.selectedItem == i));
	}
	draw_ClearClip();
}

void clickListBoxItemListBox(entity me, float i, vector where)
{
	// itemclick, itemclick, does whatever itemclick does
}

void drawListBoxItemListBox(entity me, float i, vector absSize, float selected)
{
	draw_Text('0 0 0', strcat("Item ", ftos(i)), eX * (8 / absSize_x) + eY * (8 / absSize_y), (selected ? '0 1 0' : '1 1 1'), 1);
}
#endif
