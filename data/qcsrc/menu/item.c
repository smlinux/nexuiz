#ifdef INTERFACE
CLASS(Item) EXTENDS(Object)
	METHOD(Item, draw, void(entity))
	METHOD(Item, keyDown, float(entity, float, float, float))
	METHOD(Item, keyUp, float(entity, float, float, float))
	METHOD(Item, mouseMove, float(entity, vector))
	METHOD(Item, mousePress, float(entity, vector))
	METHOD(Item, mouseDrag, float(entity, vector))
	METHOD(Item, mouseRelease, float(entity, vector))
	METHOD(Item, focusEnter, void(entity))
	METHOD(Item, focusLeave, void(entity))
	METHOD(Item, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(Item, relinquishFocus, void(entity))
	METHOD(Item, showNotify, void(entity))
	METHOD(Item, hideNotify, void(entity))
	METHOD(Item, toString, string(entity))
	METHOD(Item, destroy, void(entity))
	ATTRIB(Item, focused, float, 0)
	ATTRIB(Item, focusable, float, 0)
	ATTRIB(Item, parent, entity, NULL)
	ATTRIB(Item, preferredFocusPriority, float, 0)
	ATTRIB(Item, origin, vector, '0 0 0')
	ATTRIB(Item, size, vector, '0 0 0')
	ATTRIB(Item, tooltip, string, string_null)
ENDCLASS(Item)
#endif

#ifdef IMPLEMENTATION
void destroyItem(entity me)
{
	// free memory associated with me
}

void relinquishFocusItem(entity me)
{
	if(me.parent)
		if(me.parent.instanceOfContainer)
			me.parent.setFocus(me.parent, NULL);
}

void resizeNotifyItem(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	me.origin = absOrigin;
	me.size = absSize;
	// me.tooltip = "The quick brown fox jumped over the lazy sleeping dog's back then sat on a tack. Franz jagt im komplett verwahrlosten Taxi quer durch Bayern.";
}

void drawItem(entity me)
{
}

void showNotifyItem(entity me)
{
}

void hideNotifyItem(entity me)
{
}

float keyDownItem(entity me, float scan, float ascii, float shift)
{
	return 0; // unhandled
}

float keyUpItem(entity me, float scan, float ascii, float shift)
{
	return 0; // unhandled
}

float mouseMoveItem(entity me, vector pos)
{
	return 0; // unhandled
}

float mousePressItem(entity me, vector pos)
{
	return 0; // unhandled
}

float mouseDragItem(entity me, vector pos)
{
	return 0; // unhandled
}

float mouseReleaseItem(entity me, vector pos)
{
	return 0; // unhandled
}

void focusEnterItem(entity me)
{
}

void focusLeaveItem(entity me)
{
}

string toStringItem(entity me)
{
	return string_null;
}
#endif
