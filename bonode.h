#pragma interface
#ifndef BONODE_H
#define BONODE_H

#ifndef MISC_H
	#include <misc.h>
#endif

enum LINKTYPE{
	LINK_NONE=0,	// The node has no relation
	LINK_LEFT=1,	// The node relate to at least another node
	LINK_RIGHT=2,	// At least one node relate to this one
	LINK_BOTH=3,	// This is a or of the two previous
	LINK_ROOT=4		// This node is linked to the (pseudo) root node
};

class BO_NODEREL: public ARRAY_OBJ{
public:
	SSTRING modif;
	SSTRING format_modif;
	SSTRING type;
	/*~PROTOBEG~ BO_NODEREL */
public:
	const char *getmodif (void);
	/*~PROTOEND~ BO_NODEREL */
};

class BO_NODE: public BO_NODEREL{
public:
	bool selected;
	bool seen;
	SSTRING name;
	SSTRING image;
	SSTRING uuid;
	SSTRING owner;
	SSTRING descr;
	/*~PROTOBEG~ BO_NODE */
public:
	BO_NODE (void);
	/*~PROTOEND~ BO_NODE */
};


class BO_REL: public BO_NODEREL{
public:
	bool selected;
	SSTRING uuid1,uuid2,relate;
	SSTRING descr;
	char orderpol;
	unsigned int orderkey;
	SSTRING altname;
	/*~PROTOBEG~ BO_REL */
public:
	BO_REL (void);
	/*~PROTOEND~ BO_REL */
};

class BO_NODES: public ARRAY_OBJS<BO_NODE>{
	/*~PROTOBEG~ BO_NODES */
public:
	BO_NODE *locatebyname (const char *name)const;
	BO_NODE *locatebyuuid (const SSTRING&uuid)const;
	BO_NODE *locatebyuuid (const char *uuid)const;
	void resetseen (void);
	BO_NODE *set (const char *name,
		 const char *image,
		 const char *modif,
		 const char *uuid,
		 const char *owner,
		 const char *type,
		 const char *descr);
	void sort (void);
	/*~PROTOEND~ BO_NODES */
};
class BO_RELS: public ARRAY_OBJS<BO_REL>{
	/*~PROTOBEG~ BO_RELS */
public:
	int extract (const char *relate,
		 const char *uuid,
		 BO_RELS&tb)const;
	LINKTYPE islinked (const char *uuid);
	BO_REL *locate (const char *uuid1,
		 const char *uuid2,
		 const char *relate);
	BO_REL *set (const char *uuid1,
		 const char *uuid2,
		 const char *relate,
		 const char *modif,
		 const char *type,
		 const char *altname,
		 const char *descr,
		 const char orderpol,
		 unsigned int orderkey);
	/*~PROTOEND~ BO_RELS */
};

#endif
