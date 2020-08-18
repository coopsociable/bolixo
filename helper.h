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
template<typename T, typename T1>
bool is_eq(T t, T1 t1){
	return is_any_of(t,t1);
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

enum class NONEED_T{noneed};

#define NONEED NONEED_T::noneed
inline bool is_start_any_of (const char *a, const char *&pt, const char *b)
{
	bool ret = false;
	auto len = strlen(b);
	if (strncmp(a,b,len)==0){
		ret = true;
		pt = a+len;
	}
	return ret;
}
inline bool is_start_any_of (const char *a, NONEED_T, const char *b)
{
	bool ret = false;
	auto len = strlen(b);
	if (strncmp(a,b,len)==0){
		ret = true;
	}
	return ret;
}
template<typename T, typename T1, typename ... Ts>
bool is_start_any_of(T t, const char *&pt, T1 t1, Ts ... ts){
	return is_start_any_of(t,pt,t1) || is_start_any_of(t,pt,ts...);
}
template<typename T, typename T1, typename ... Ts>
bool is_start_any_of(T t, NONEED_T no, T1 t1, Ts ... ts){
	return is_start_any_of(t,no,t1) || is_start_any_of(t,no,ts...);
}
// Specialisation for std::string, optimisation
template<typename T1, typename ... Ts>
bool is_start_any_of(const std::string &t, const char *&pt, T1 t1, Ts ... ts){
	return is_start_any_of(t.c_str(),pt,t1,ts...);
}
template<typename T1, typename ... Ts>
bool is_start_any_of(const std::string &t, NONEED_T no, T1 t1, Ts ... ts){
	return is_start_any_of(t.c_str(),no,t1,ts...);
}
// Specialisation for char *
template<typename T1, typename ... Ts>
bool is_start_any_of(char *t, const char *&pt, T1 t1, Ts ... ts){
	return is_start_any_of((const char*)t,pt,t1,ts...);
}
template<typename T1, typename ... Ts>
bool is_start_any_of(char *t, NONEED_T no, T1 t1, Ts ... ts){
	return is_start_any_of((const char *)t,no,t1,ts...);
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
inline bool is_start_any_ofnc (const char *a, NONEED_T, const char *b)
{
	bool ret = false;
	auto len = strlen(b);
	if (strncasecmp(a,b,len)==0){
		ret = true;
	}
	return ret;
}
template<typename T, typename T1, typename ... Ts>
bool is_start_any_ofnc(T t, const char *&pt, T1 t1, Ts ... ts){
	return is_start_any_ofnc(t,pt,t1) || is_start_any_ofnc(t,pt,ts...);
}
template<typename T, typename T1, typename ... Ts>
bool is_start_any_ofnc(T t, NONEED_T no, T1 t1, Ts ... ts){
	return is_start_any_ofnc(t,no,t1) || is_start_any_ofnc(t,no,ts...);
}
// Specialisation for std::string, optimisation
template<typename T1, typename ... Ts>
bool is_start_any_ofnc(const std::string &t, const char *&pt, T1 t1, Ts ... ts){
	return is_start_any_ofnc(t.c_str(),pt,t1,ts...);
}
template<typename T1, typename ... Ts>
bool is_start_any_ofnc(const std::string &t, NONEED_T no, T1 t1, Ts ... ts){
	return is_start_any_ofnc(t.c_str(),no,t1,ts...);
}
// Specialisation for char *
template<typename T1, typename ... Ts>
bool is_start_any_ofnc(char *t, const char *&pt, T1 t1, Ts ... ts){
	return is_start_any_ofnc((const char *)t,pt,t1,ts...);
}
template<typename T1, typename ... Ts>
bool is_start_any_ofnc(char *t, NONEED_T no, T1 t1, Ts ... ts){
	return is_start_any_ofnc((const char *)t,no,t1,ts...);
}

#endif
