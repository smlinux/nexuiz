/// Some default stacks.
.entity verbs_idle;
.entity verbs_attack;
.entity verbs_move;

/// This global gets set to the verb in question each time the stack manager calls verb_call
entity verb;

/// Execure this verb
#define VCM_DO     0
/// Return teh value of this verb. Return VS_CALL_REMOVE to delete it.
#define VCM_EVAL   1
/// This verb is beeing removed NOW (not sent when verb_call returns VS_CALL_REMOVE)
#define VCM_REMOVE 2

/// Verb callback
.float(float message) verb_call;

/// Points to this verb's stack.
.entity  verbstack;

/// Static value of this verb
.float verb_static_value;

/// verb_call returns this when a verb in not doable
#define VS_CALL_NO        0
/// verb_call(VCM_DO) returns this when a verb is executing
#define VS_CALL_YES_DOING -1
/// verb_call(VCM_DO) returns this when a verb did execure and is done
#define VS_CALL_YES_DONE  -2
/// verb_call(VCM_DO) returns this when a verb should be deleted by the stack manager
#define VS_CALL_REMOVE    -3

/**
    Push a new verb onto the specified stack. Set vrb_life to make it time-limited.
**/
entity verbstack_push(entity stack, float(float eval) vrb_call, float val_static, float vrb_life)
{
    entity vrb;

    if not(stack)
        return world;

    if not(vrb_call)
        return world;

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

/**
    Find the best verb in this stack and execurte it.
    ALso remove any verbs returning VS_CALL_REMOVE on VCM_EVAL or VCM_DO
**/
float verbstack_pop(entity stack)
{
    entity vrb, bestverb, oldself;
    float  value, bestvalue;

    oldself = self;

    vrb = findchainentity(verbstack,stack);
    while(vrb)
    {
        verb  = vrb;
        vrb   = vrb.chain;
        self  = verb.owner;
        value = verb.verb_call(VCM_EVAL);

        if(value < 0)
        {
            if(value == VS_CALL_REMOVE)
                remove(verb);
        }
        else
        {
            if(value > bestvalue)
            {
                bestverb  = verb;
                bestvalue = value;
            }
        }
    }

    if(bestverb)
    {
        verb  = bestverb;
        self  = verb.owner;
        value = verb.verb_call(VCM_DO);

        if(value == VS_CALL_REMOVE)
            remove(bestverb);
    }

    self = oldself;

    return value;
}

/**
    Find the best verb in this stack and return it.
    ALso remove any verbs returning VS_CALL_REMOVE on VCM_EVAL.
**/
entity verbstack_pull(entity stack)
{
    entity vrb;
    entity bestverb, oldself;
    float  value, bestvalue;

    oldself = self;

    vrb = findchainentity(verbstack,stack);
    while(vrb)
    {
        self = vrb.owner;

        verb  = vrb;
        vrb   = vrb.chain;
        value = verb.verb_call(VCM_EVAL);

        if(value > 0)
        {
            if(value == VS_CALL_REMOVE)
                remove(verb);
        }
        else
        {
            if(value > bestvalue)
            {
                bestverb = verb;
                bestvalue = value;
            }
        }
    }

    self = oldself;

    return bestverb;
}

/**
    Delete every verb on this stack, signaling them with VCM_REMOVE first.
**/
void verbstack_flush(entity stack)
{
    entity vrb, oldself;

    oldself = self;

    vrb = findchainentity(verbstack,stack);
    while(vrb)
    {
        self = vrb.owner;

        verb = vrb;
        vrb  = vrb.chain;
        verb.verb_call(VCM_REMOVE);
        remove(verb);
    }

    self = oldself;
}
