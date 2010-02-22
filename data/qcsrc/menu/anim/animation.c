#ifdef INTERFACE
CLASS(Animation) EXTENDS(Object)
	METHOD(Animation, setTimeStartEnd, void(entity, float, float))
	METHOD(Animation, setTimeStartDuration, void(entity, float, float))
	METHOD(Animation, setValueStartEnd, void(entity, float, float))
	METHOD(Animation, setValueStartDelta, void(entity, float, float))
	METHOD(Animation, setObjectSetter, void(entity, entity, void(entity, float)))
	METHOD(Animation, tick, void(entity, float))
	METHOD(Animation, isFinished, float(entity))
	METHOD(Animation, stopAnim, void(entity))
	METHOD(Animation, finishAnim, void(entity))
	ATTRIB(Animation, object, entity, NULL)
	ATTRIB(Animation, setter, void(entity, float), setterDummy)
	ATTRIB(Animation, math, float(float, float, float, float), linear)
	ATTRIB(Animation, value, float, 0)
	ATTRIB(Animation, startTime, float, 0)
	ATTRIB(Animation, duration, float, 0)
	ATTRIB(Animation, startValue, float, 0)
	ATTRIB(Animation, delta, float, 0)
	ATTRIB(Animation, finished, float, FALSE)
ENDCLASS(Animation)
entity makeHostedAnimation(entity, void(entity, float), float, float, float);
entity makeAnimation(entity, void(entity, float), float, float, float);
float linear(float, float, float, float);
void setterDummy(entity, float);
#endif

#ifdef IMPLEMENTATION
entity makeHostedAnimation(entity obj, void(entity, float) setter, float duration, float start, float end)
{
	entity me;
	me = makeAnimation(obj, setter, duration, start, end);
	anim.addAnim(anim, me);
	return me;
}

entity makeAnimation(entity obj, void(entity, float) setter, float duration, float start, float end)
{
	entity me;
	me = spawnAnimation();
	me.setObjectSetter(me, obj, setter);
	me.setTimeStartDuration(me, time, duration);
	me.setValueStartEnd(me, start, end);
	return me;
}

void setTimeStartEndAnimation(entity me, float s, float e)
{
	me.startTime = s;
	me.duration = e - s;
}

void setTimeStartDurationAnimation(entity me, float s, float d)
{
	me.startTime = s;
	me.duration = d;
}

void setValueStartEndAnimation(entity me, float s, float e)
{
	me.startValue = s;
	me.delta = e - s;
}

void setValueStartDeltaAnimation(entity me, float s, float d)
{
	me.startValue = s;
	me.delta = d;
}

void setObjectSetterAnimation(entity me, entity o, void(entity, float) s)
{
	me.object = o;
	me.setter = s;
}

void tickAnimation(entity me, float time)
{
	me.value = me.math((time - me.startTime), me.duration, me.startValue, me.delta);
	me.setter(me.object, me.value);
	if (time > (me.startTime + me.duration))
		me.finishAnim(me);
}

float isFinishedAnimation(entity me)
{
	return me.finished;
}

void stopAnimAnimation(entity me)
{
}

void finishAnimAnimation(entity me)
{
	me.finished = TRUE;
}

float linear(float time, float duration, float start, float delta)
{
	if (time > duration)
		return delta + start;
	return (delta * (time / duration)) + start;
}

void setterDummy(entity object, float value)
{
}

#endif
