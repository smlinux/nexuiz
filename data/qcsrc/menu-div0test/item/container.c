#ifdef INTERFACE
CLASS(Container) EXTENDS(Item)
	METHOD(Container, draw, void(entity))
	METHOD(Container, keyUp, float(entity, float, float, float))
	METHOD(Container, keyDown, float(entity, float, float, float))
	METHOD(Container, mouseMove, float(entity, vector))
	METHOD(Container, mousePress, float(entity, vector))
	METHOD(Container, mouseDrag, float(entity, vector))
	METHOD(Container, mouseRelease, float(entity, vector))
	METHOD(Container, focusLeave, void(entity))
	METHOD(Container, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(Container, resizeNotifyLie, void(entity, vector, vector, vector, vector, .vector, .vector))
	METHOD(Container, addItem, void(entity, entity, vector, vector, float))
	METHOD(Container, removeItem, void(entity, entity))
	METHOD(Container, setFocus, void(entity, entity))
	METHOD(Container, itemFromPoint, entity(entity, vector))
	ATTRIB(Container, focusable, float, 0)
	ATTRIB(Container, firstChild, entity, NULL)
	ATTRIB(Container, lastChild, entity, NULL)
	ATTRIB(Container, focusedChild, entity, NULL)
ENDCLASS(Container)
#endif

#ifdef IMPLEMENTATION
.vector Container_origin;
.vector Container_size;
.float Container_alpha;
.entity Container_nextSibling;
.entity Container_prevSibling;

void resizeNotifyLieContainer(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize, .vector originField, .vector sizeField)
{
	entity e;
	vector o, s;
	for(e = me.lastChild; e; e = e.Container_prevSibling)
	{
		o = e.originField;
		s = e.sizeField;
		e.resizeNotify(e, o, s, boxToGlobal(o, absOrigin, absSize), boxToGlobalSize(s, absSize));
	}
	resizeNotifyItem(me, relOrigin, relSize, absOrigin, absSize);
}

void resizeNotifyContainer(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	me.resizeNotifyLie(me, relOrigin, relSize, absOrigin, absSize, Container_origin, Container_size);
}

entity itemFromPointContainer(entity me, vector pos)
{
	entity e;
	vector o, s;
	for(e = me.lastChild; e; e = e.Container_prevSibling)
	{
		o = e.Container_origin;
		s = e.Container_size;
		if(pos_x < o_x) continue;
		if(pos_y < o_y) continue;
		if(pos_x >= o_x + s_x) continue;
		if(pos_y >= o_y + s_y) continue;
		return e;
	}
	return NULL;
}

void drawContainer(entity me)
{
	vector oldshift;
	vector oldscale;
	float oldalpha;
	entity e;

	oldshift = draw_shift;
	oldscale = draw_scale;
	oldalpha = draw_alpha;
	me.focusable = 0;
	for(e = me.firstChild; e; e = e.Container_nextSibling)
	{
		if(e.focusable)
			me.focusable += 1;
		if(!e.Container_alpha)
			continue;
		draw_shift = boxToGlobal(e.Container_origin, oldshift, oldscale);
		draw_scale = boxToGlobalSize(e.Container_size, oldscale);
		draw_alpha *= e.Container_alpha;
		e.draw(e);
		draw_shift = oldshift;
		draw_scale = oldscale;
		draw_alpha = oldalpha;
	}
};

void focusLeaveContainer(entity me)
{
	if(me.focusedChild)
		me.focusedChild.focused = 0;
	me.focusedChild = NULL;
}

float keyUpContainer(entity me, float scan, float ascii, float shift)
{
	entity f;
	f = me.focusedChild;
	if(f)
		return f.keyUp(f, scan, ascii, shift);
	return 0;
}

float keyDownContainer(entity me, float scan, float ascii, float shift)
{
	entity f;
	f = me.focusedChild;
	if(f)
		return f.keyDown(f, scan, ascii, shift);
	return 0;
}

float mouseMoveContainer(entity me, vector pos)
{
	entity f;
	f = me.focusedChild;
	if(f)
		return f.mouseMove(f, globalToBox(pos, f.Container_origin, f.Container_size));
	return 0;
}
float mousePressContainer(entity me, vector pos)
{
	entity f;
	f = me.focusedChild;
	if(f)
		return f.mousePress(f, globalToBox(pos, f.Container_origin, f.Container_size));
	return 0;
}
float mouseDragContainer(entity me, vector pos)
{
	entity f;
	f = me.focusedChild;
	if(f)
		return f.mouseDrag(f, globalToBox(pos, f.Container_origin, f.Container_size));
	return 0;
}
float mouseReleaseContainer(entity me, vector pos)
{
	entity f;
	f = me.focusedChild;
	if(f)
		return f.mouseRelease(f, globalToBox(pos, f.Container_origin, f.Container_size));
	return 0;
}

void addItemContainer(entity me, entity other, vector theOrigin, vector theSize, float theAlpha)
{
	if(other.parent)
		error("Can't add already added item!");

	if(other.focusable)
		me.focusable += 1;

	other.parent = me;
	other.Container_origin = theOrigin;
	other.Container_size = theSize;
	other.Container_alpha = theAlpha;

	entity f, l;
	f = me.firstChild;
	l = me.lastChild;

	if(l)
		l.Container_nextSibling = other;
	else
		me.firstChild = other;

	other.Container_prevSibling = l;
	other.Container_nextSibling = NULL;
	me.lastChild = other;

	draw_NeedResizeNotify = 1;
}

void removeItemContainer(entity me, entity other)
{
	if(other.parent != me)
		error("Can't remove from wrong container!");

	if(other.focusable)
		me.focusable -= 1;

	other.parent = NULL;

	entity n, p, f, l;
	f = me.firstChild;
	l = me.lastChild;
	n = other.Container_nextSibling;
	p = other.Container_prevSibling;

	if(p)
		p.Container_nextSibling = n;
	else
		me.firstChild = n;

	if(n)
		n.Container_prevSibling = p;
	else
		me.lastChild = p;
}

void setFocusContainer(entity me, entity other)
{
	if(me.focusedChild == other)
		return;
	if(me.focusedChild)
	{
		me.focusedChild.focused = 0;
		me.focusedChild.focusLeave(me.focusedChild);
	}
	if(other)
	{
		other.focused = 1;
		other.focusEnter(other);
	}
	me.focusedChild = other;
}
#endif
