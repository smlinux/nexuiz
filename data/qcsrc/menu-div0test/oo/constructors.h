#ifndef INTERFACE
#define INTERFACE
#endif

#ifdef IMPLEMENTATION
#undef IMPLEMENTATION
#endif

#ifdef CLASS
#undef CLASS
#undef EXTENDS
#undef METHOD
#undef ATTRIB
#undef ENDCLASS
#endif

#define CLASS(cname)                 entity spawn##cname() { entity e;
#define EXTENDS(base)                e = spawn##base ();
#define METHOD(cname,name,prototype) e.name = name##cname;
#define ATTRIB(cname,name,type,val)  e.name = val;
#define ENDCLASS(cname)              e.instanceOf##cname = 1; e.classname = #cname; return e; }
