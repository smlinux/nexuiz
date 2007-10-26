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

#define CLASS(cname)                 entity spawn##cname();
#define EXTENDS(base)                
#define METHOD(cname,name,prototype) prototype name##cname; .prototype name;
#define ATTRIB(cname,name,type,val)  .type name;
#define ENDCLASS(cname)              .float instanceOf##cname;
