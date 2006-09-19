#pragma interface
#ifndef BOLIBFS_H
#define BOLIBFS_H

#ifndef MISC_H
	#include <misc.h>
#endif

class BOLIBNODE: public ARRAY_OBJ{
public:
	SSTRING name;
	SSTRING uuid;
	SSTRING type;
	SSTRING modif;
	/*~PROTOBEG~ BOLIBNODE */
public:
	BOLIBNODE (const char *_name,
		 const char *_uuid,
		 const char *_type,
		 const char *_modif);
	/*~PROTOEND~ BOLIBNODE */
};

class BOLIBNODES: public ARRAY_OBJS<BOLIBNODE>{
	/*~PROTOBEG~ BOLIBNODES */
public:
	void add (BOLIBNODE *n);
	void add (const char *_name,
		 const char *_uuid,
		 const char *_type,
		 const char *_modif);
	void sort_by_name (void);
	/*~PROTOEND~ BOLIBNODES */
};

class BOLIBFS{
	class BOLIBFS_PRIVATE *priv;
	/*~PROTOBEG~ BOLIBFS */
public:
	BOLIBFS (const char *server,
		 const char *port,
		 const char *user,
		 const char *passwd,
		 const char *document);
	BOLIBFS (void);
	int connect (SSTRING&errmsg);
	int getfd (void);
	bool is_connected (void)const;
	int ls (const char *dir, BOLIBNODES&files);
	bool maycd (const char *dir);
	int read (const char *dir, SSTRING&data);
	int send (const char *command, const char *ctl, ...);
	void setdocument (const char *document);
	void setpasswd (const char *passwd);
	void setport (const char *port);
	void setserver (const char *server);
	void setuser (const char *user);
	~BOLIBFS (void);
	/*~PROTOEND~ BOLIBFS */
};


#endif

