// NG Menu
// util/nfunction.qc

void() Util_NullFunction 	= {};
bool() Util_TrueFunction 	= { return true; 	};
bool() Util_FalseFunction	= { return false; 	};
string() Util_StringFuntion	= { return "";		};
vector() Util_VectorFunction	= { return '0 0 0';	};
entity() Util_EntityFunction	= { return null_entity;	};
