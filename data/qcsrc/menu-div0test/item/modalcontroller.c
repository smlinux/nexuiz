#ifdef INTERFACE
CLASS(ModalController) EXTENDS(Container)
	METHOD(ModalController, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(ModalController, draw, void(entity))
	METHOD(ModalController, addItem, void(entity, entity, vector, vector, float))
	METHOD(ModalController, setFocus, void(entity, entity))
	METHOD(ModalController, showChild, void(entity, entity, vector, vector, float))
	METHOD(ModalController, hideChild, void(entity, entity, float))
	METHOD(ModalController, hideAll, void(entity, float))
	METHOD(ModalController, addItem, void(entity, entity, vector, vector, float))
	METHOD(ModalController, addTab, void(entity, entity, entity))

	METHOD(ModalController, initializeDialog, void(entity, entity))

	METHOD(ModalController, switchState, void(entity, entity, float, float))
	ATTRIB(ModalController, origin, vector, '0 0 0')
	ATTRIB(ModalController, size, vector, '0 0 0')
	ATTRIB(ModalController, previousButton, entity, NULL)
	ATTRIB(ModalController, fadedAlpha, float, 0.3)
ENDCLASS(ModalController)

.vector origin;
.vector size;
void TabButton_Click(entity button, entity tab); // assumes a button has set the above fields to its own absolute origin, its size, and the tab to activate
void DialogOpenButton_Click(entity button, entity tab); // assumes a button has set the above fields to its own absolute origin, its size, and the tab to activate
void DialogCloseButton_Click(entity button, entity tab); // assumes a button has set the above fields to the tab to close
#endif

#ifdef IMPLEMENTATION

// modal dialog controller
// handles a stack of dialog elements
// each element can have one of the following states:
//   0: hidden (fading out)
//   1: visible (zooming in)
//   2: greyed out (inactive)
// While an animation is running, no item has focus. When an animation is done,
// the topmost item gets focus.
// The items are assumed to be added in overlapping order, that is, the lowest
// window must get added first.
//
// Possible uses:
// - to control a modal dialog:
//   - show modal dialog: me.showChild(me, childItem, buttonAbsOrigin, buttonAbsSize, 0) // childItem also gets focus
//   - dismiss modal dialog: me.hideChild(me, childItem, 0) // childItem fades out and relinquishes focus
//   - show first screen in m_show: me.hideAll(me, 1); me.showChild(me, me.firstChild, '0 0 0', '0 0 0', 1);
// - to show a temporary dialog instead of the menu (teamselect): me.hideAll(me, 1); me.showChild(me, teamSelectDialog, '0 0 0', '0 0 0', 1);
// - as a tabbed dialog control:
//   - to initialize: me.hideAll(me, 1); me.showChild(me, me.firstChild, '0 0 0', '0 0 0', 1);
//   - to show a tab: me.hideChild(me, currentTab, 0); me.showChild(me, newTab, buttonAbsOrigin, buttonAbsSize, 0);

.vector ModalController_initialSize;
.vector ModalController_initialOrigin;
.float ModalController_initialAlpha;
.vector ModalController_buttonSize;
.vector ModalController_buttonOrigin;
.float ModalController_state;
.float ModalController_factor;
.entity ModalController_controllingButton;

void initializeDialogModalController(entity me, entity root)
{
	me.hideAll(me, 1);
	me.showChild(me, root, '0 0 0', '0 0 0', 1); // someone else animates for us
}

void TabButton_Click(entity button, entity tab)
{
	if(tab.ModalController_state == 1)
		return;
	tab.parent.hideAll(tab.parent, 0);
	button.forcePressed = 1;
	tab.ModalController_controllingButton = button;
	tab.parent.showChild(tab.parent, tab, button.origin, button.size, 0);
}

void DialogOpenButton_Click(entity button, entity tab)
{
	if(tab.ModalController_state)
		return;
	button.forcePressed = 1;
	tab.ModalController_controllingButton = button;
	tab.parent.showChild(tab.parent, tab, button.origin, button.size, 0);
}

void DialogCloseButton_Click(entity button, entity tab)
{
	tab.parent.hideChild(tab.parent, tab, 0);
}

void resizeNotifyModalController(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	me.origin = absOrigin;
	me.size = absSize;
	me.resizeNotifyLie(me, relOrigin, relSize, absOrigin, absSize, ModalController_initialOrigin, ModalController_initialSize);
}

void switchStateModalController(entity me, entity other, float state, float skipAnimation)
{
	float previousState;
	previousState = other.ModalController_state;
	if(state == previousState)
		return;
	other.ModalController_state = state;
	switch(state)
	{
		case 0:
			other.ModalController_factor = 1 - other.Container_alpha / other.ModalController_initialAlpha;
			// fading out
			break;
		case 1:
			other.ModalController_factor = other.Container_alpha / other.ModalController_initialAlpha;
			if(previousState == 0 && !skipAnimation)
			{
				other.Container_origin = other.ModalController_buttonOrigin;
				other.Container_size = other.ModalController_buttonSize;
			}
			// zooming in
			break;
		case 2:
			other.ModalController_factor = bound(0, (1 - other.Container_alpha / other.ModalController_initialAlpha) / me.fadedAlpha, 1);
			// fading out halfway
			break;
	}
	if(skipAnimation)
		other.ModalController_factor = 1;
}

void drawModalController(entity me)
{
	// TODO set up alpha, sizes and focus
	entity e;
	entity front;
	float animating;
	float f0, f, fd;
	vector to, ts; float ta;
	animating = 0;

	for(e = me.firstChild; e; e = e.Container_nextSibling)
		if(e.ModalController_state)
		{
			if(front)
				me.switchState(me, front, 2, 0);
			front = e;
		}
	if(front)
		me.switchState(me, front, 1, 0);

	for(e = me.firstChild; e; e = e.Container_nextSibling)
	{
		f0 = e.ModalController_factor;
		f = e.ModalController_factor = min(1, f0 + frametime * 3);
		if(e.ModalController_state)
			if(f < 1)
				animating = 1;
		if(e.ModalController_state == 2)
		{
			// fading out partially
			to = e.Container_origin; // stay as is
			ts = e.Container_size; // stay as is
			ta = me.fadedAlpha * e.ModalController_initialAlpha;
		}
		else if(e.ModalController_state == 1)
		{
			// zooming in
			to = e.ModalController_initialOrigin;
			ts = e.ModalController_initialSize;
			ta = e.ModalController_initialAlpha;
		}
		else
		{
			// fading out
			if(f < 1)
				animating = 1;
			to = e.Container_origin; // stay as is
			ts = e.Container_size; // stay as is
			ta = 0;
		}

		if(f == 1)
		{
			e.Container_origin = to;
			e.Container_size = ts;
			e.Container_alpha = ta;
		}
		else
		{
			e.Container_origin = (e.Container_origin * (1 - f) + to * (f - f0)) * (1 / (1 - f0));
			e.Container_size = (e.Container_size * (1 - f) + ts * (f - f0)) * (1 / (1 - f0));
			e.Container_alpha = (e.Container_alpha * (1 - f) + ta * (f - f0)) * (1 / (1 - f0));
		}
		// assume: o == to * f0 + X * (1 - f0)
		// make:   o' = to * f  + X * (1 - f)
		// -->
		// X == (o - to * f0) / (1 - f0)
		// o' = to * f + (o - to * f0) / (1 - f0) * (1 - f)
	}
	if(animating)
		me.focusedChild = NULL;
	else
		me.focusedChild = front;
	drawContainer(me);
};

void addTabModalController(entity me, entity other, entity tabButton)
{
	me.addItem(me, other, '0 0 0', '1 1 1', 1);
	tabButton.onClick = TabButton_Click;
	tabButton.onClickEntity = other;
	if(other == me.firstChild)
	{
		tabButton.forcePressed = 1;
		other.ModalController_controllingButton = tabButton;
		me.showChild(me, other, '0 0 0', '0 0 0', 1);
	}
}

void addItemModalController(entity me, entity other, vector theOrigin, vector theSize, float theAlpha)
{
	other.ModalController_initialSize = theSize;
	other.ModalController_initialOrigin = theOrigin;
	other.ModalController_initialAlpha = theAlpha;
	addItemContainer(me, other, theOrigin, theSize, theAlpha);
	if(other != me.firstChild)
		other.Container_alpha = 0;
}

void setFocusModalController(entity me, entity other)
{
	error("Sorry, modal controllers can't handle setFocus");
}

void showChildModalController(entity me, entity other, vector theOrigin, vector theSize, float skipAnimation)
{
	if(other.ModalController_state == 0)
	{
		me.focusedChild = NULL;
		other.ModalController_buttonOrigin = globalToBox(theOrigin, me.origin, me.size);
		other.ModalController_buttonSize = globalToBoxSize(theSize, me.size);
		me.switchState(me, other, 1, skipAnimation);
	} // zoom in from button (factor increases)
}

void hideAllModalController(entity me, float skipAnimation)
{
	entity e;
	for(e = me.firstChild; e; e = e.Container_nextSibling)
		me.hideChild(me, e, skipAnimation);
}

void hideChildModalController(entity me, entity other, float skipAnimation)
{
	if(other.ModalController_state)
	{
		me.focusedChild = NULL;
		me.switchState(me, other, 0, skipAnimation);
		if(other.ModalController_controllingButton)
		{
			other.ModalController_controllingButton.forcePressed = 0;
			other.ModalController_controllingButton = NULL;
		}
	} // just alpha fade out (factor increases and decreases alpha)
}
#endif
