#ifdef INTERFACE
CLASS(Animation) EXTENDS(Object)
	METHOD(Animation, configureAnimation, void(entity, entity, void(entity, float), float, float, float, float))
	METHOD(Animation, setTimeStartEnd, void(entity, float, float))
	METHOD(Animation, setTimeStartDuration, void(entity, float, float))
	METHOD(Animation, setValueStartEnd, void(entity, float, float))
	METHOD(Animation, setValueStartDelta, void(entity, float, float))
	METHOD(Animation, setObjectSetter, void(entity, entity, void(entity, float)))
	METHOD(Animation, tick, void(entity, float))
	METHOD(Animation, calcValue, float(entity, float, float, float, float))
	METHOD(Animation, isStopped, float(entity))
	METHOD(Animation, stopAnim, void(entity))
	METHOD(Animation, resumeAnim, void(entity))
	METHOD(Animation, isFinished, float(entity))
	METHOD(Animation, finishAnim, void(entity))
	ATTRIB(Animation, object, entity, NULL)
	ATTRIB(Animation, setter, void(entity, float), setterDummy)
	ATTRIB(Animation, value, float, 0)
	ATTRIB(Animation, startTime, float, 0)
	ATTRIB(Animation, duration, float, 0)
	ATTRIB(Animation, startValue, float, 0)
	ATTRIB(Animation, delta, float, 0)
	ATTRIB(Animation, stopped, float, FALSE)
	ATTRIB(Animation, finished, float, FALSE)
ENDCLASS(Animation)
void setterDummy(entity, float);
#endif

#ifdef IMPLEMENTATION
void configureAnimationAnimation(entity me, entity obj, void(entity, float) setter, float startTime, float duration, float startValue, float end)
{
	me.setObjectSetter(me, obj, setter);
	me.setTimeStartDuration(me, startTime, duration);
	me.setValueStartEnd(me, startValue, end);
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
	if (me.isStopped(me) || me.isFinished(me) || (time < me.startTime))
		return;

	if (time >= (me.startTime + me.duration))
		me.finishAnim(me);
	else
		me.value = me.calcValue(me, (time - me.startTime), me.duration, me.startValue, me.delta);

	me.setter(me.object, me.value);
}

float calcValueAnimation(entity me, float time, float duration, float startValue, float delta)
{
	return startValue;
}

float isStoppedAnimation(entity me)
{
	return me.stopped;
}

void stopAnimAnimation(entity me)
{
	me.stopped = TRUE;
}

void resumeAnimAnimation(entity me)
{
	me.stopped = FALSE;
}

float isFinishedAnimation(entity me)
{
	return me.finished;
}

void finishAnimAnimation(entity me)
{
	me.value = me.delta + me.startValue;
	me.finished = TRUE;
}

void setterDummy(entity object, float value)
{
}

#endif
