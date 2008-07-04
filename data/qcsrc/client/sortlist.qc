

.float(entity,entity) sort_cmp;
.entity sort_next, sort_prev;

entity Sort_New(float(entity,entity) cmp)
{
	entity sort;
	sort = spawn();
	sort.sort_cmp = cmp;
	sort.sort_next = NULL;
	return sort;
}

void Sort_Remove(entity sort)
{
	entity next;
	while(sort.sort_next)
	{
		next = sort.sort_next;
		remove(sort);
		sort = next;
	}
	remove(sort);
}

void Sort_Add(entity sort, entity ent)
{
	entity next, parent;
	parent = sort;
	next = sort.sort_next;
	while(next && sort.sort_cmp(next, ent))
	{
		parent = next;
		next = next.sort_next;
	}
	ent.sort_next = next;
	ent.sort_prev = parent;
	parent.sort_next = ent;
	if(next)
		next.sort_prev = ent;
}

entity Sort_Get(entity sort, float i)
{
	for(; sort.sort_next && i > 0; --i)
		sort = sort.sort_next;
	return sort;
}

void Sort_DoSort(entity sort)
{
	entity newsort, next, tmp;
	newsort = Sort_New(sort.sort_cmp);
	next = sort.sort_next;
	while(next)
	{
		tmp = next.sort_next;
		Sort_Add(newsort, next);
		next = tmp;
	}
	sort.sort_next = newsort.sort_next;
}
