// spawner entity
// "classname" "target_spawn"
// "message" "fieldname value fieldname value ..."
// "spawnflags"
//   1 = call the spawn function
//   2 = trigger on map load

float target_spawn_initialized;
.void() target_spawn_spawnfunc;
float target_spawn_spawnfunc_field;
.entity target_spawn_activator;

void target_spawn_useon(entity e)
{
	float i, n, valuefieldpos, sPWNed;
	string key, value, valuefield, valueoffset, valueoffsetrandom;
	entity valueent;
	vector data, data2;
	entity oldself;
	entity oldactivator;

	n = tokenize_sane(self.message);

	sPWNed = FALSE;

	for(i = 0; i < n-1; i += 2)
	{
		key = argv(i);
		value = argv(i+1);
		data = stov(db_get(TemporaryDB, strcat("/target_spawn/field/", key)));
		if(data_y == 0) // undefined field, i.e., invalid type
		{
			print("target_spawn: invalid/unknown entity key ", key, " specified, ignored!\n");
			continue;
		}
		if(substring(value, 0, 1) == "$")
		{
			value = substring(value, 1, strlen(value) - 1);
			if(substring(value, 0, 1) == "$")
			{
				// deferred replacement
				// do nothing
				// useful for creating target_spawns with this!
			}
			else
			{
				// replace me!
				valuefieldpos = strstrofs(value, ".", 0);
				valuefield = "";
				if(valuefieldpos != -1)
				{
					valuefield = substring(value, valuefieldpos + 1, strlen(value) - valuefieldpos - 1);
					value = substring(value, 0, valuefieldpos);
				}

				valuefieldpos = strstrofs(value, "+", 0);
				valueoffset = "";
				if(valuefieldpos != -1)
				{
					valueoffset = substring(valuefield, valuefieldpos + 1, strlen(valueoffset) - valuefieldpos - 1);
					valuefield = substring(valuefield, 0, valuefieldpos);
				}

				valuefieldpos = strstrofs(valueoffset, "+", 0);
				valueoffsetrandom = "";
				if(valuefieldpos != -1)
				{
					valueoffsetrandom = substring(valueoffset, valuefieldpos + 1, strlen(valueoffset) - valuefieldpos - 1);
					valueoffset = substring(valueoffset, 0, valuefieldpos);
				}

				if(value == "self")
				{
					valueent = self;
					value = "";
				}
				else if(value == "activator")
				{
					valueent = activator;
					value = "";
				}
				else if(value == "pusher")
				{
					if(time < activator.pushltime)
						valueent = activator.pusher;
					else
						valueent = world;
					value = "";
				}
				else if(value == "time")
				{
					valueent = world;
					value = ftos(time);
				}
				else
				{
					print("target_spawn: invalid/unknown variable replacement ", value, " specified, ignored!\n");
					continue;
				}

				if(valuefield == "")
				{
					if(value == "")
						value = ftos(num_for_edict(valueent));
				}
				else
				{
					if(value != "")
					{
						print("target_spawn: try to get a field of a non-entity, ignored!\n");
						continue;
					}
					data2 = stov(db_get(TemporaryDB, strcat("/target_spawn/field/", valuefield)));
					if(data2_y == 0) // undefined field, i.e., invalid type
					{
						print("target_spawn: invalid/unknown entity key replacement ", value, " specified, ignored!\n");
						continue;
					}
					value = getentityfieldstring(data2_x, valueent);
				}

				if(valueoffset != "")
				{
					switch(data_y)
					{
						case FIELD_STRING:
							value = strcat(value, valueoffset);
							break;
						case FIELD_FLOAT:
							value = ftos(stof(value) + stof(valueoffset));
							break;
						case FIELD_VECTOR:
							value = vtos(stov(value) + stov(valueoffset));
							break;
						default:
							print("target_spawn: only string, float and vector fields can do calculations, calculation ignored!\n");
							break;
					}
				}

				if(valueoffsetrandom != "")
				{
					switch(data_y)
					{
						case FIELD_FLOAT:
							value = ftos(stof(value) + random() * stof(valueoffsetrandom));
							break;
						case FIELD_VECTOR:
							data2 = stov(valueoffsetrandom);
							value = vtos(stov(value) + random() * data2_x * '1 0 0' + random() * data2_y * '0 1 0' + random() * data2_z * '0 0 1');
							break;
						default:
							print("target_spawn: only float and vector fields can do random calculations, calculation ignored!\n");
							break;
					}
				}
			}
		}
		putentityfieldstring(data_x, e, value);

		if(key == "classname" && !sPWNed)
		{
			if(self.spawnflags & 1)
			{
				if(!e.target_spawn_spawnfunc)
					putentityfieldstring(target_spawn_spawnfunc_field, e, strcat("spawnfunc_", value));

				oldself = self;
				oldactivator = activator;

				self = e;
				activator = self.target_spawn_activator;

				self.target_spawn_spawnfunc();

				self = oldself;
				activator = oldactivator;
			}
			sPWNed = TRUE;
		}
	}
}

void target_spawn_use()
{
	entity e;

	if(self.target == "")
	{
		// spawn new entity
		e = spawn();
		target_spawn_useon(e);
	}
	else
	{
		// edit entity
		for(e = world; (e = find(e, targetname, self.target)); )
			target_spawn_useon(e);
	}
}

void target_spawn_spawnfirst()
{
	activator = self.target_spawn_activator;
	target_spawn_use();
}

void spawnfunc_target_spawn()
{
	if(!target_spawn_initialized)
	{
		float n, i;
		string fn;
		float ft;

		n = numentityfields();
		for(i = 0; i < n; ++i)
		{
			fn = entityfieldname(i);
			ft = entityfieldtype(i);
			db_put(TemporaryDB, strcat("/target_spawn/field/", fn), vtos(i * '1 0 0' + ft * '0 1 0' + '0 0 1'));
			if(fn == "target_spawn_spawnfunc")
				target_spawn_spawnfunc_field = i;
		}

		target_spawn_initialized = 1;
	}
	self.use = target_spawn_use;
	InitializeEntity(self, target_spawn_spawnfirst, INITPRIO_LAST);
}
