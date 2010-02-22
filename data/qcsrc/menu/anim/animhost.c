#ifdef INTERFACE
CLASS(AnimHost) EXTENDS(Object)
	METHOD(AnimHost, addAnim, void(entity, entity))
	METHOD(AnimHost, removeAnim, void(entity, entity))
	METHOD(AnimHost, stopAllAnim, void(entity))
	METHOD(AnimHost, finishAllAnim, void(entity))
	METHOD(AnimHost, tickAll, void(entity))
	ATTRIB(AnimHost, firstChild, entity, NULL)
	ATTRIB(AnimHost, lastChild, entity, NULL)
ENDCLASS(AnimHost)
.entity nextSibling;
.entity prevSibling;
#endif

#ifdef IMPLEMENTATION
void addAnimAnimHost(entity me, entity other)
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
		me.firstChild = other;

	other.prevSibling = l;
	other.nextSibling = NULL;
	me.lastChild = other;
}

void removeAnimAnimHost(entity me, entity other)
{
	if(other.parent != me)
		error("Can't remove from wrong AnimHost!");

	other.parent = NULL;

	entity n, p, f, l;
	f = me.firstChild;
	l = me.lastChild;
	n = other.nextSibling;
	p = other.prevSibling;

	if(p)
		p.nextSibling = n;
	else
		me.firstChild = n;

	if(n)
		n.prevSibling = p;
	else
		me.lastChild = p;
}

void stopAllAnimAnimHost(entity me)
{
	entity e;
	for(e = me.firstChild; e; e = e.nextSibling)
	{
		e.stopAnim(e);
	}
}

void finishAllAnimAnimHost(entity me)
{
	entity e, tmp;
	for(e = me.firstChild; e; e = e.nextSibling)
	{
		tmp = e;
		e = tmp.prevSibling;
		me.removeAnim(me, tmp);
		e.finishAnim(tmp);
	}
}

void tickAllAnimHost(entity me)
{
	entity e, tmp;
	for(e = me.firstChild; e; e = e.nextSibling)
	{
		e.tick(e, time);
	}
	for(e = me.firstChild; e; e = e.nextSibling)
	{
		if (e.isFinished(e))
		{
			tmp = e;
			e = tmp.prevSibling;
			me.removeAnim(me, tmp);
			remove(tmp);
		}
	}
}
#endif
