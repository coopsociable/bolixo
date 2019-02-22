#ifndef XMLFLAT_H
#define XMLFLAT_H

#include <libxml/parser.h>


#define _TLMP_xmlflat

struct _F_xmlflat {
	#define _F_xmlflat_start(x) void x start(const char *parent, const char *name, const char *path, xmlNodePtr node)
	virtual _F_xmlflat_start( );
	#define _F_xmlflat_tag(x) void x tag(const char *parent, const char *name, const char *path, xmlNodePtr node)
	virtual _F_xmlflat_tag( );
	#define _F_xmlflat_text(x) void x text(const char *parent, const char *name, const char *path, xmlNodePtr node)
	virtual _F_xmlflat_text( );
	#define _F_xmlflat_end(x) void x end(const char *parent, const char *name, const char *path, xmlNodePtr node)
	virtual _F_xmlflat_end( );
};

void xmlflat (_F_xmlflat&c, xmlNodePtr node, const char *basepath);

#endif

