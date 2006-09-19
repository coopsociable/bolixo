/* bolibfs.tlcc 13/12/2005 12.34.22 */
int bolibfs (_F_bolibfs&c, int fd);
/* bolixod.tlcc 13/12/2005 12.34.22 */
/* bolixogui.tlcc 13/12/2005 12.34.22 */
/* bomail.tlcc 13/12/2005 12.34.22 */
int bomail_readfolder (_F_bomail_readfolder&c,
	 BOMAIL *bo,
	 const SSTRING&uuid);
int bomail_readmsg (_F_bomail_readmsg&c,
	 BOMAIL *bo,
	 const SSTRING&uuid,
	 int flags);
/* bomisc.tlcc 13/12/2005 12.34.22 */
int bomisc_connect (const char *server,
	 const char *port,
	 const char *user,
	 const char *passwd,
	 const char *document,
	 SSTRING&errmsg);
/* bonode.tlcc 13/12/2005 12.34.22 */
void node_edit (_F_FRAMEWORK *framework,
	 TCPCONNECT *con,
	 PRIVATE_MESSAGE&docevent,
	 BO_NODES&nodes,
	 BO_RELS&rels,
	 const char *uuid);
/* boshell.tlcc 13/12/2005 12.34.22 */
/* boxml.tlcc 13/12/2005 12.34.22 */
int boxml (_F_boxml&c, const char *fname);
int boxml (_F_boxml&c, BOXML_READER&reader, int documentid);
int boxml (_F_boxml&c, BOXML_READER&reader);
int bo_makeuuid (char buf[30]);
int bo_makeuuid (SSTRING&uuid);
void bo_getnow (SSTRING&now);
