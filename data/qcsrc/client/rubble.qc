.float creationtime;

void RubbleDrop(entity list, void() deleteproc)
{
    float t,tt;
    entity rub,old_rub;

    rub = findchainentity(owner,list);
    while(rub)
    {
        if(rub.creationtime > t)
        {
            old_rub = rub;
            tt = t;
        }
        rub = rub.chain;
    }

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
