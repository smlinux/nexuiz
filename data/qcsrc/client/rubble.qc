.float creationtime;

void RubbleDrop(entity list, void() deleteproc)
{
    float t;
    entity rub,old_rub;

    rub = findchainentity(owner,list);
    old_rub = rub;
    t = rub.creationtime;
    rub = rub.chain;
    while(rub)
    {
        if(t > rub.creationtime)
        {
            t = rub.creationtime;
            old_rub = rub;
        }
        rub = rub.chain;
    }

    if (old_rub == world)
        return;

    rub = self;
    self = old_rub;
    deleteproc();
    self = rub;
}

entity RubbleNew(entity list)
{
    entity rub;

    rub = spawn();
    rub.creationtime = time;
    rub.owner = list;

    return rub;
}
