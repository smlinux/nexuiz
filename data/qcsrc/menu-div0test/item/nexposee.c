#ifdef INTERFACE
CLASS(Nexposee) EXTENDS(Container)
	METHOD(Nexposee, draw, void(entity))
	METHOD(Nexposee, keyDown, float(entity, float, float, float))
	METHOD(Nexposee, keyUp, float(entity, float, float, float))
	METHOD(Nexposee, mousePress, float(entity, vector))
	METHOD(Nexposee, mouseMove, float(entity, vector))
	METHOD(Nexposee, mouseRelease, float(entity, vector))
	METHOD(Nexposee, mouseDrag, float(entity, vector))
	METHOD(Nexposee, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(Nexposee, focusEnter, void(entity))

	ATTRIB(Nexposee, animationState, float, -1)
	ATTRIB(Nexposee, animationFactor, float, 0)
	ATTRIB(Nexposee, selectedChild, entity, NULL)
	ATTRIB(Nexposee, mouseFocusedChild, entity, NULL)
	METHOD(Nexposee, addItem, void(entity, entity, vector, vector, float))
	METHOD(Nexposee, calc, void(entity))
	METHOD(Nexposee, setNexposee, void(entity, entity, vector, float, float))
	ATTRIB(Nexposee, mousePosition, vector, '0 0 0')
ENDCLASS(Nexposee)

void ExposeeCloseButton_Click(entity button, entity other); // un-exposees the current state
#endif

// animation states:
//   0 = thumbnails seen
//   1 = zooming in
//   2 = zoomed in
//   3 = zooming out
// animation factor: 0 = minimum theSize, 1 = maximum theSize

#ifdef IMPLEMENTATION

.vector Nexposee_initialSize;
.vector Nexposee_initialOrigin;
.float Nexposee_initialAlpha;

.vector Nexposee_smallSize;
.vector Nexposee_smallOrigin;
.float Nexposee_smallAlpha;
.float Nexposee_mediumAlpha;
.vector Nexposee_scaleCenter;

void ExposeeCloseButton_Click(entity button, entity other)
{
	other.selectedChild = other.focusedChild;
	other.setFocus(other, NULL);
	other.animationState = 3;
}

void resizeNotifyNexposee(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	me.resizeNotifyLie(me, relOrigin, relSize, absOrigin, absSize, Nexposee_initialOrigin, Nexposee_initialSize);
}

void calcNexposee(entity me)
{
	/*
	 * patented by Apple
	 * can't put that here ;)
	 */
	float scale;
	entity e, e2;
	vector emins, emaxs, e2mins, e2maxs;
	
	for(scale = 0.7;; scale *= 0.9)
	{
		for(e = me.firstChild; e; e = e.Container_nextSibling)
		{
			e.Nexposee_smallOrigin = (e.Nexposee_initialOrigin - e.Nexposee_scaleCenter) * scale + e.Nexposee_scaleCenter;
			e.Nexposee_smallSize = e.Nexposee_initialSize * scale;
		}

		for(e = me.firstChild; e; e = e.Container_nextSibling)
		{
			emins = e.Nexposee_smallOrigin;
			emaxs = emins + e.Nexposee_smallSize;
			for(e2 = e.Container_nextSibling; e2; e2 = e2.Container_nextSibling)
			{
				e2mins = e2.Nexposee_smallOrigin;
				e2maxs = e2mins + e2.Nexposee_smallSize;

				// two intervals [amins, amaxs] and [bmins, bmaxs] overlap if:
				//   amins < bmins < amaxs < bmaxs
				// for which suffices
				//   bmins < amaxs
				//   amins < bmaxs
				if((e2mins_x - emaxs_x) * (emins_x - e2maxs_x) > 0) // x overlap
					if((e2mins_y - emaxs_y) * (emins_y - e2maxs_y) > 0) // y overlap
					{
						goto have_overlap;
					}
			}
		}

		break;
:have_overlap
	}

	scale *= 0.9;
	for(e = me.firstChild; e; e = e.Container_nextSibling)
	{
		e.Nexposee_smallOrigin = (e.Nexposee_initialOrigin - e.Nexposee_scaleCenter) * scale + e.Nexposee_scaleCenter;
		e.Nexposee_smallSize = e.Nexposee_initialSize * scale;
	}
}

void setNexposeeNexposee(entity me, entity other, vector scalecenter, float a0, float a1)
{
	other.Nexposee_scaleCenter = scalecenter;
	other.Nexposee_smallAlpha = other.Container_alpha = a0;
	other.Nexposee_mediumAlpha = a1;
}

void drawNexposee(entity me)
{
	entity e;
	float f;

	if(me.animationState == -1)
	{
		me.animationState = 0;
		me.calc(me);
	}

	//print(ftos(me.animationState), "\n");

	f = min(1, frametime * 5);
	switch(me.animationState)
	{
		case 0:
			me.animationFactor = 0;
			break;
		case 1:
			me.animationFactor += f;
			if(me.animationFactor >= 1)
			{
				me.animationFactor = 1;
				me.animationState = 2;
				setFocusContainer(me, me.selectedChild);
			}
			break;
		case 2:
			me.animationFactor = 1;
			break;
		case 3:
			me.animationFactor -= f;
			me.mouseFocusedChild = me.itemFromPoint(me, me.mousePosition);
			if(me.animationFactor <= 0)
			{
				me.animationFactor = 0;
				me.animationState = 0;
				me.selectedChild = me.mouseFocusedChild;
			}
			break;
	}

	f = min(1, frametime * 10);
	for(e = me.firstChild; e; e = e.Container_nextSibling)
	{
		float a;
		float a0;
		if(e == me.selectedChild)
		{
			e.Container_origin = e.Nexposee_smallOrigin * (1 - me.animationFactor) + e.Nexposee_initialOrigin * me.animationFactor;
			e.Container_size = e.Nexposee_smallSize * (1 - me.animationFactor) + e.Nexposee_initialSize * me.animationFactor;
			a0 = e.Nexposee_mediumAlpha;
			if(me.animationState == 3)
				if(e != me.mouseFocusedChild)
					a0 = e.Nexposee_smallAlpha;
			a = a0 * (1 - me.animationFactor) + me.animationFactor;
		}
		else
		{
			// minimum theSize counts
			e.Container_origin = e.Nexposee_smallOrigin;
			e.Container_size = e.Nexposee_smallSize;
			a = e.Nexposee_smallAlpha * (1 - me.animationFactor);
		}
		e.Container_alpha = e.Container_alpha * (1 - f) + a * f;
	}

	drawContainer(me);
};

float mousePressNexposee(entity me, vector pos)
{
	if(me.animationState == 0)
	{
		me.mouseFocusedChild = NULL;
		mouseMoveNexposee(me, pos);
		if(me.selectedChild)
		{
			me.animationState = 1;
			setFocusContainer(me, NULL);
		}
		return 1;
	}
	else if(me.animationState == 2)
	{
		if(!mousePressContainer(me, pos))
		{
			me.animationState = 3;
			setFocusContainer(me, NULL);
		}
		return 1;
	}
	return 0;
}

float mouseReleaseNexposee(entity me, vector pos)
{
	if(me.animationState == 2)
		return mouseReleaseContainer(me, pos);
	return 0;
}

float mouseDragNexposee(entity me, vector pos)
{
	if(me.animationState == 2)
		return mouseDragContainer(me, pos);
	return 0;
}

float mouseMoveNexposee(entity me, vector pos)
{
	entity e;
	me.mousePosition = pos;
	e = me.mouseFocusedChild;
	me.mouseFocusedChild = me.itemFromPoint(me, pos);
	if(me.animationState == 2)
		return mouseMoveContainer(me, pos);
	if(me.animationState == 0)
	{
		if(me.mouseFocusedChild)
			if(me.mouseFocusedChild != e)
				me.selectedChild = me.mouseFocusedChild;
		return 1;
	}
	return 0;
}

float keyUpNexposee(entity me, float scan, float ascii, float shift)
{
	if(me.animationState == 2)
		return keyUpContainer(me, scan, ascii, shift);
	return 0;
}

float keyDownNexposee(entity me, float scan, float ascii, float shift)
{
	float nexposeeKey;
	if(me.animationState == 2)
		if(keyDownContainer(me, scan, ascii, shift))
			return 1;
	if(scan == K_TAB)
	{
		if(me.animationState == 0)
		{
			if(shift & S_SHIFT)
			{
				if(me.selectedChild)
					me.selectedChild = me.selectedChild.Container_prevSibling;
				if(!me.selectedChild)
					me.selectedChild = me.lastChild;
			}
			else
			{
				if(me.selectedChild)
					me.selectedChild = me.selectedChild.Container_nextSibling;
				if(!me.selectedChild)
					me.selectedChild = me.firstChild;
			}
		}
	}
	switch(me.animationState)
	{
		case 0:
		case 3:
			nexposeeKey = ((scan == K_SPACE) || (scan == K_ENTER));
			break;
		case 1:
		case 2:
			nexposeeKey = (scan == K_ESCAPE);
			break;
	}
	if(nexposeeKey)
	{
		switch(me.animationState)
		{
			case 0:
			case 3:
				me.animationState = 1;
				break;
			case 1:
			case 2:
				me.animationState = 3;
				break;
		}
		if(me.focusedChild)
			me.selectedChild = me.focusedChild;
		if(!me.selectedChild)
			me.animationState = 0;
		setFocusContainer(me, NULL);
		return 1;
	}
	return 0;
}

void addItemNexposee(entity me, entity other, vector theOrigin, vector theSize, float theAlpha)
{
	other.Nexposee_initialSize = theSize;
	other.Nexposee_initialOrigin = theOrigin;
	other.Nexposee_initialAlpha = theAlpha;
	addItemContainer(me, other, theOrigin, theSize, theAlpha);
}

void focusEnterNexposee(entity me)
{
	if(me.animationState == 2)
		setFocusContainer(me, me.selectedChild);
}
#endif
