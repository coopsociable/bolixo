#ifndef JSON_H
#define JSON_H

#define _TLMP_json_parse
struct _F_json_parse {
	#define _F_json_parse_item(x) void x item(const char *parent, const char *name, const char *value)
	virtual _F_json_parse_item( )=0;
};

void json_parse (_F_json_parse &c, const char *line);

#endif
