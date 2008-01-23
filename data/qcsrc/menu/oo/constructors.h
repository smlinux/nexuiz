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
#undef ATTRIBARRAY
#undef ENDCLASS
#endif

#define CLASS(cname)                       entity spawn##cname() { entity me;
#define EXTENDS(base)                      me = spawn##base ();
#define METHOD(cname,name,prototype)       me.name = name##cname;
#define ATTRIB(cname,name,type,val)        me.name = val;
#define ATTRIBARRAY(cname,name,type,cnt)   me.name = me.name;
#define ENDCLASS(cname)                    me.instanceOf##cname = 1; me.classname = #cname; return me; }
