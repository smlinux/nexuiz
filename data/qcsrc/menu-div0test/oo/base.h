.string classname;
entity spawnObject()
{
	entity e;
	e = spawn();
	e.classname = "Object";
	return e;
}
