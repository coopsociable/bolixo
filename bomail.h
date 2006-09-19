#pragma interface
#ifndef BOMAIL_H
#define BOMAIL_H


#ifndef MISC_H
	#include <misc.h>
#endif

class DICTIONARY;

class BOMAIL{
	int fd;		// Connection to the bolixod server
	FILE *fout;	// FILE for fd
	SSTRING document;
	SSTRING user;
	/*~PROTOBEG~ BOMAIL */
public:
	BOMAIL (const char *document,
		 const char *_user,
		 const char *pass);
	int attach (const SSTRING&msg_uuid,
		 const char *title,
		 const char *type,
		 const char *attach,
		 int length,
		 SSTRING&att_uuid);
	int create_folder (const char *folder, SSTRING&uuid);
	int find (SSTRING&uuid);
	bool folder_exist (const char *folder, SSTRING&uuid);
	int getfd (void)const;
	int getrevision (const SSTRING&uuid);
	int incrrevision (const SSTRING&uuid);
	bool isok (void);
	int link (const SSTRING&mailuuid,
		 const SSTRING&folderuuid);
	int list_folders (SSTRINGS&tb);
	bool msg_exist (const SSTRING&folder_uuid,
		 const char *msgid,
		 SSTRING&msg_uuid);
	int save (const char *from,
		 const char *msgid,
		 const char *header,
		 const char *text,
		 const SSTRING&folder_uuid,
		 SSTRING&uuid);
	int savecomment (const SSTRING&mailuuid,
		 const SSTRING&comment);
	int saveflags (const SSTRING&mailuuid,
		 bool deleted,
		 bool viewed,
		 bool replied,
		 bool marked,
		 DICTIONARY&vars);
	int send (const char *line);
	int sendf (const char *ctl, ...);
	int unlink (const SSTRING&mailuuid,
		 const SSTRING&folderuuid);
	~BOMAIL (void);
	/*~PROTOEND~ BOMAIL */
};


#define _TLMP_bomail_readfolder

struct _F_bomail_readfolder{
	#define _F_bomail_readfolder_message(n) void n message (const char *uuid, const char *header, bool &end)
	virtual _F_bomail_readfolder_message( )=0;
};

#define _TLMP_bomail_readmsg

struct _F_bomail_readmsg{
	#define _F_bomail_readmsg_header(n) void n header (const char *text)
	virtual _F_bomail_readmsg_header( );
	#define _F_bomail_readmsg_body(n) void n body (const char *uuid, const char *text, bool &end)
	virtual _F_bomail_readmsg_body( );
	#define _F_bomail_readmsg_attach(n) void n attach (int no, const char *uuid, const char *attach, bool &end)
	virtual _F_bomail_readmsg_attach( );
	#define _F_bomail_readmsg_comment(n) void n comment (const char *uuid, const char *text, bool &end)
	virtual _F_bomail_readmsg_comment( );
	#define _F_bomail_readmsg_flags(n) void n flags (const char *uuid, bool deleted, bool viewed, bool replied, bool marked, const DICTIONARY &dict, const char *text, bool &end)
	virtual _F_bomail_readmsg_flags( );
};

#define BOMAIL_READHEAD		1
#define BOMAIL_READBODY		2
#define BOMAIL_READATTACH	4
#define BOMAIL_READFLAGS	8
#define BOMAIL_READCOMMENT	16
#define BOMAIL_READALL		0xff

int bomail_readfolder (
	_F_bomail_readfolder &c,
	BOMAIL *bo,
	const SSTRING &uuid);

int bomail_readmsg (
	_F_bomail_readmsg &c,
	BOMAIL *bo,
	const SSTRING &uuid,
	int flags);

#endif

