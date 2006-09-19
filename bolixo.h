#pragma interface
#ifndef BOLIXO_H
#define BOLIXO_H

#ifndef MISC_H
	#include <misc.h>
#endif

class BOXMLENC{
	SSTRINGS tb;
	/*~PROTOBEG~ BOXMLENC */
public:
	const char *enc (const SSTRING&s);
	const char *enc (const char *s);
	const char *enc (int val);
	const char *encnq (const SSTRING&s);
	const char *encnq (const char *s);
	/*~PROTOEND~ BOXMLENC */
};

#include <parser.h>

class BOXML_READER{
	xmlParserCtxtPtr ctxt;
	/*~PROTOBEG~ BOXML_READER */
public:
	BOXML_READER (void);
	void append (const char *line);
	xmlDocPtr getxmldoc (void);
	bool reading (void)const;
	void reset (void);
	~BOXML_READER (void);
	/*~PROTOEND~ BOXML_READER */
};

#define _TLMP_boxml

struct _F_boxml{
	class _F_boxml_private *priv;
	#define _F_boxml_user(n) void n user(const char *owner, int ownerid, int documentid, const char *id, const char *name, const char *passw, bool &end, bool &skip)
	virtual _F_boxml_user( );
	#define _F_boxml_document(n) void n document(const char *owner, const char *name, const char *descr, bool &end, bool &skip, int &documentid, int &ownerid)
	virtual _F_boxml_document( );
	#define _F_boxml_node(n) void n node(int documentid, const char *name, const char *descr, const char *image, const char *modif, const char *uuid, const char *owner, const char *type, bool &end, bool &skip)
	virtual _F_boxml_node( );
	#define _F_boxml_relation(n) void n relation(int documentid, int docownerid, const char *owner, const char *uuid1, const char *uuid2, const char *relate, const char *descr, const char *modif, const char *type, const char *altname, char orderpol, unsigned int orderkey, bool &end, bool &skip)
	virtual _F_boxml_relation( );
	#define _F_boxml_delrelation(n) void n delrelation(int documentid, const char *uuid1, const char *uuid2, const char *relate, bool &end, bool &skip)
	virtual _F_boxml_delrelation( );
	#define _F_boxml_delnode(n) void n delnode(int documentid, const char *uuid, bool &end, bool &skip)
	virtual _F_boxml_delnode( );
	#define _F_boxml_oldnode(n) void n oldnode(int documentid, const char *name, const char *descr, const char *image, const char *modif, const char *uuid, const char *owner, const char *type, bool &end, bool &skip)
	virtual _F_boxml_oldnode( );
	#define _F_boxml_oldrelation(n) void n oldrelation(int documentid, int docownerid, const char *owner, const char *uuid1, const char *uuid2, const char *relate, const char *descr, const char *modif, const char *type, bool &end, bool &skip)
	virtual _F_boxml_oldrelation( );
};

#define _TLMP_bolibfs

struct _F_bolibfs{
	#define _F_bolibfs_node(n) void n node(const char *name, const char *descr, const char *image, const char *modif, const char *uuid, const char *owner, const char *type, bool &end)
	virtual _F_bolibfs_node( );
	#define _F_bolibfs_relation(n) void n relation(int docownerid, const char *owner, const char *uuid1, const char *uuid2, const char *relate, const char *descr, const char *modif, const char *type, const char *altname, char orderpol, unsigned int orderkey, bool &end)
	virtual _F_bolibfs_relation( );
};


extern const unsigned char K_BOLIXO[];
extern const unsigned char K_USER[];
extern const unsigned char K_PASSW[];
extern const unsigned char K_DOCUMENT[];
extern const unsigned char K_DOCUMENTID[];
extern const unsigned char K_NODE[];
extern const unsigned char K_NODEID[];
extern const unsigned char K_UUID1[];
extern const unsigned char K_UUID2[];
extern const unsigned char K_IMAGE[];
extern const unsigned char K_RELATE[];
extern const unsigned char K_RELATION[];
extern const unsigned char K_RELATIONID[];
extern const unsigned char K_ID[];
extern const unsigned char K_USERID[];
extern const unsigned char K_OWNERID[];
extern const unsigned char K_OWNER[];
extern const unsigned char K_NAME[];
extern const unsigned char K_ALTNAME[];
extern const unsigned char K_DESCRIPTION[];
extern const unsigned char K_MODIF[];
extern const unsigned char K_UUID[];
extern const unsigned char K_OLDNODE[];
extern const unsigned char K_DELNODE[];
extern const unsigned char K_OLDRELATION[];
extern const unsigned char K_DELRELATION[];
extern const unsigned char K_TYPE[];
extern const unsigned char K_ORDERPOL[];
extern const unsigned char K_ORDERKEY[];

// Commands for bolixo protocol
extern const char C_LOGIN[];
extern const char C_LISTDOC[];
extern const char C_SELDOC[];
extern const char C_LISTNODES[];
extern const char C_LISTRELS[];
extern const char C_GETNODE[];
extern const char C_GETREL[];
extern const char C_GETALL[];
extern const char C_DOCCHANGED[];
extern const char C_DELRELATION[];
extern const char C_DELNODE[];
extern const char C_GETROOT[];
extern const char C_GETCHILD[];
extern const char C_GETCHILDF[];
extern const char C_GETORPHAN[];
extern const char C_PING[];
extern const char C_XMLPING[];

// Defines to handle bolixo.conf
extern const char D_DEFAULT[];
extern const char D_SERVER[];
extern const char D_PORT[];
extern const char D_USER[];
extern const char D_PASSWORD[];


//

extern const char ROOTUUID[];
extern const char XMLINTRO[];
extern const char XMLEND[];
extern const char SIMPLE_HTML[];
extern const char DATA[];
extern const char REL_ATTRIBUT[];	// Relation for attributes
extern const char *version;
class BO_NODES;
class BO_RELS;
class _F_FRAMEWORK;
class TCPCONNECT;
class PRIVATE_MESSAGE;

struct _F_bomail_readfolder;
struct _F_bomail_readmsg;
class BOMAIL;

#include "bolixo.p"

#endif

