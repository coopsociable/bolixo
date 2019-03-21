#ifndef HELPER_H
#define HELPER_H

// Replace a sequence of if (a==b || a==c || a==d ...
// with is_any_of (a,b,c,d,...)
inline bool is_any_of (const char *t, const char *t1)
{
	return strcmp(t,t1)==0;
}
template<typename T, typename T1>
bool is_any_of(T t, T1 t1){
	return t == t1;
}
template<typename T, typename T1, typename ... Ts>
bool is_any_of(T t, T1 t1, Ts ... ts){
	return is_any_of(t,t1) || is_any_of(t,ts...);
}
// Replace a sequence of if (a!=b && a!=c && a==d ...
// with is_not_in (a,b,c,d,...)
inline bool is_not_in (const char *t, const char *t1)
{
	return strcmp(t,t1)!=0;
}
template<typename T, typename T1>
bool is_not_in(T t, T1 t1){
	return t != t1;
}
template<typename T, typename T1, typename ... Ts>
bool is_not_in(T t, T1 t1, Ts ... ts){
	return is_not_in(t,t1) && is_not_in(t,ts...);
}

static const char *NONEED="";
inline bool is_start_any_of (const char *a, const char *&pt, const char *b)
{
	bool ret = false;
	auto len = strlen(b);
	if (strncmp(a,b,len)==0){
		ret = true;
		if (&pt != &NONEED) pt = a+len;
	}
	return ret;
}
inline bool is_start_any_of (const std::string &a, const char *&pt, const char *b)
{
	return is_start_any_of(a.c_str(),pt,b);
}
template<typename T, typename T1, typename ... Ts>
bool is_start_any_of(T t, const char *&pt, T1 t1, Ts ... ts){
	return is_start_any_of(t,pt,t1) || is_start_any_of(t,pt,ts...);
}

// Case insensitive
inline bool is_start_any_ofnc (const char *a, const char *&pt, const char *b)
{
	bool ret = false;
	auto len = strlen(b);
	if (strncasecmp(a,b,len)==0){
		ret = true;
		pt = a+len;
	}
	return ret;
}
inline bool is_start_any_ofnc (const std::string &a, const char *&pt, const char *b)
{
	return is_start_any_ofnc(a.c_str(),pt,b);
}
template<typename T, typename T1, typename ... Ts>
bool is_start_any_ofnc(T t, const char *&pt, T1 t1, Ts ... ts){
	return is_start_any_ofnc(t,pt,t1) || is_start_any_ofnc(t,pt,ts...);
}

#endif
