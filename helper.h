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

#endif
