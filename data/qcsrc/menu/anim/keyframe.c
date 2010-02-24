#ifdef INTERFACE
CLASS(Keyframe) EXTENDS(Animation)
	METHOD(Keyframe, addAnim, void(entity, entity))
	METHOD(Keyframe, calcValue, float(entity, float, float, float, float))
	ATTRIB(Keyframe, currentChild, entity, NULL)
	ATTRIB(Keyframe, firstChild, entity, NULL)
	ATTRIB(Keyframe, lastChild, entity, NULL)
ENDCLASS(Animation)
entity makeHostedKeyframe(entity, void(entity, float), float, float, float);
entity makeKeyframe(entity, void(entity, float), float, float, float);
#endif

#ifdef IMPLEMENTATION
entity makeHostedKeyframe(entity obj, void(entity, float) setter, float duration, float start, float end)
{
	entity me;
	me = makeKeyframe(obj, setter, duration, start, end);
	anim.addAnim(anim, me);
	return me;
}

entity makeKeyframe(entity obj, void(entity, float) setter, float duration, float start, float end)
{
	entity me;
	me = spawnKeyframe();
	me.configureAnimation(me, obj, setter, time, duration, start, end);
	return me;
}

void addAnimKeyframe(entity me, entity other)
{
	if(other.parent)
		error("Can't add already added anim!");

	if(other.isFinished(other))
		error("Can't add finished anim!");

	other.parent = me;

	entity f, l;
	f = me.firstChild;
	l = me.lastChild;

	if(l)
		l.nextSibling = other;
	else
	{
		me.currentChild = other;
		me.firstChild = other;
	}

	other.prevSibling = l;
	other.nextSibling = NULL;
	me.lastChild = other;
}

float calcValueKeyframe(entity me, float time, float duration, float startValue, float delta)
{
	if (me.currentChild)
		if (me.currentChild.isFinished(me.currentChild))
			me.currentChild = me.currentChild.nextSibling;

	if (me.currentChild)
	{
		me.currentChild.tick(me.currentChild, time);
		return me.currentChild.value;
	}

	return startValue + delta;
}
#endif
