#ifdef INTERFACE
CLASS(Easing) EXTENDS(Animation)
	METHOD(Easing, calcValue, float(entity, float, float, float, float))
	METHOD(Easing, setMath, void(entity, float(float, float, float, float)))
	ATTRIB(Easing, math, float(float, float, float, float), easingLinear)
ENDCLASS(Easing)
entity makeHostedEasing(entity, void(entity, float), float(float, float, float, float), float, float, float);
entity makeEasing(entity, void(entity, float), float(float, float, float, float), float, float, float, float);
float easingLinear(float, float, float, float);
float easingQuadIn(float, float, float, float);
float easingQuadOut(float, float, float, float);
float easingQuadInOut(float, float, float, float);
#endif

#ifdef IMPLEMENTATION
entity makeHostedEasing(entity obj, void(entity, float) setter, float(float, float, float, float) func, float duration, float startValue, float end)
{
	entity me;
	me = makeEasing(obj, setter, func, time, duration, startValue, end);
	anim.addAnim(anim, me);
	return me;
}

entity makeEasing(entity obj, void(entity, float) setter, float(float, float, float, float) func, float startTime, float duration, float startValue, float end)
{
	entity me;
	me = spawnEasing();
	me.configureAnimation(me, obj, setter, startTime, duration, startValue, end);
	me.setMath(me, func);
	return me;
}

float calcValueEasing(entity me, float time, float duration, float start, float delta)
{
	return me.math(time, duration, start, delta);
}

void setMathEasing(entity me, float(float, float, float, float) func)
{
	me.math = func;
}

float easingLinear(float time, float duration, float start, float delta)
{
	return (delta * (time / duration)) + start;
}

float easingQuadIn(float time, float duration, float start, float delta)
{
	float frac = time / duration;
	return (delta * frac * frac) + start;
}

float easingQuadOut(float time, float duration, float start, float delta)
{
	float frac = time / duration;
	return (-delta * frac * (frac - 2)) + start;
}

float easingQuadInOut(float time, float duration, float start, float delta)
{
	if (time < (duration / 2))
	{
 		return easingQuadIn(time, (duration / 2), start, (delta / 2));
	}
	else
	{
 		return easingQuadOut((time - (duration / 2)), (duration / 2), (start + (delta / 2)), (delta / 2));
	}
}

#endif
