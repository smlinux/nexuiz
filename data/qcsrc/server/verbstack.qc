entity verb;
.entity verbs_idle;
.entity verbs_attack;
.entity verbs_move;

.float(float eval) verb_call;
.entity  verbstack;
.float verb_static_value;

#define VS_CALL_NO        0
#define VS_CALL_YES_DOING -1
#define VS_CALL_YES_DONE  -2
#define VS_CALL_REMOVE    -3

entity verbstack_push(entity stack, float(float eval) vrb_call, float val_static, float vrb_life)
{
    entity vrb;

    vrb                   = spawn();
    vrb.owner             = self;
    vrb.verbstack         = stack;
    vrb.verb_call         = vrb_call;
    vrb.verb_static_value = val_static;

    if(vrb_life)
    {
        vrb.think     = SUB_Remove;
        vrb.nextthink = time + vrb_life;
    }

    return vrb;
}

float verbstack_pop(entity stack)
{
    entity vrb;
    entity bestverb,oldself;
    float value,bestvalue;

    oldself = self;

    vrb = findchainentity(verbstack,stack);
    while(vrb)
    {
        verb = vrb;
        self = vrb.owner;
        value = vrb.verb_call(TRUE);
        if(value < 0)
        {
            if(value == VS_CALL_REMOVE)
                remove(vrb);
        }
        else
        {
            if(value > bestvalue)
            {
                bestverb = vrb;
                bestvalue = value;
            }
        }
        vrb = vrb.chain;
    }

    if(bestverb)
    {
        verb = bestverb;
        self = verb.owner;
        value = bestverb.verb_call(FALSE);
            if(value == VS_CALL_REMOVE)
                remove(bestverb);
    }

    self = oldself;

    return value;
}

entity verbstack_pull(entity stack)
{
    entity vrb;
    entity bestverb,oldself;
    float value,bestvalue;

    oldself = self;

    vrb = findchainentity(verbstack,stack);
    while(vrb)
    {
        self = vrb.owner;
        verb = vrb;
        value = vrb.verb_call(TRUE);
        if(value > 0)
        {
            if(value == VS_CALL_REMOVE)
                remove(vrb);
        }
        else
        {
            if(value > bestvalue)
            {
                bestverb = vrb;
                bestvalue = value;
            }
        }
        vrb =vrb.chain;
    }

    self = oldself;

    return bestverb;
}
