
void SUB_Null (void)
{
	
}

void SUB_Remove (void)
{
	remove (self);
}

void main (void)
{
	
}

void PointSound (vector org, string snd, float vol, float attn)
{
	entity	speaker;
	
	speaker = spawn ();
	setorigin (speaker, org);
	sound (speaker, CHAN_BODY, snd, vol, attn);
	remove (speaker);
}