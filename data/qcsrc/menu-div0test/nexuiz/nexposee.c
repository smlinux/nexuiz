#ifdef INTERFACE
CLASS(NexuizNexposee) EXTENDS(Nexposee)
	METHOD(NexuizNexposee, configureNexuizNexposee, void(entity))
	METHOD(NexuizNexposee, close, void(entity))
ENDCLASS(NexuizNexposee)
entity makeNexuizNexposee();
#endif

#ifdef IMPLEMENTATION
entity makeNexuizNexposee()
{
	entity me;
	me = spawnNexuizNexposee();
	me.configureNexuizNexposee(me);
	return me;
}

void configureNexuizNexposeeNexuizNexposee(entity me)
{
}

void closeNexuizNexposee(entity me)
{
	m_goto(string_null); // hide
}
#endif
