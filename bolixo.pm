/* bolibfs.tlcc 13/12/2005 12.34.22 */
PUBLIC BOLIBNODE::BOLIBNODE (const char *_name,
	 const char *_uuid,
	 const char *_type,
	 const char *_modif);
PUBLIC void BOLIBNODES::add (BOLIBNODE *n);
PUBLIC void BOLIBNODES::add (const char *_name,
	 const char *_uuid,
	 const char *_type,
	 const char *_modif);
PUBLIC void BOLIBNODES::sort_by_name (void);
PUBLIC BOLIBFS::BOLIBFS (const char *server,
	 const char *port,
	 const char *user,
	 const char *passwd,
	 const char *document);
PUBLIC BOLIBFS::BOLIBFS (void);
PUBLIC void BOLIBFS::setserver (const char *server);
PUBLIC void BOLIBFS::setport (const char *port);
PUBLIC void BOLIBFS::setuser (const char *user);
PUBLIC void BOLIBFS::setpasswd (const char *passwd);
PUBLIC void BOLIBFS::setdocument (const char *document);
PUBLIC BOLIBFS::~BOLIBFS (void);
PUBLIC bool BOLIBFS::is_connected (void)const;
PUBLIC int BOLIBFS::send (const char *command, const char *ctl, ...);
PUBLIC int BOLIBFS::getfd (void);
PUBLIC int BOLIBFS::connect (SSTRING&errmsg);
PUBLIC bool BOLIBFS::maycd (const char *dir);
PUBLIC int BOLIBFS::ls (const char *dir, BOLIBNODES&files);
PUBLIC int BOLIBFS::read (const char *dir, SSTRING&data);
/* bolixod.tlcc 13/12/2005 12.34.22 */
PUBLIC BO_CLIENT::BO_CLIENT (void);
/* bolixogui.tlcc 13/12/2005 12.34.22 */
PRIVATE bool DOCDATA::same (const FRAMEWORK_DOCUMENT&d);
PUBLIC BO_MAP::BO_MAP (BO_REL *_relate, BO_NODE *_node);
PUBLIC bool BO_MAPS::seen (BO_NODE *node);
PUBLIC int BO_MAPS::extract (const char *relate,
	 const char *uuid,
	 const BO_RELS&rels,
	 const BO_NODES&nodes);
PUBLIC void BO_MAPS::sort (void);
PUBLIC DOCDATA::DOCDATA (void);
PUBLIC int DOCDATA::seldocument (void);
void _F_bo_drawtree::enddir (void);
/* bomail.tlcc 13/12/2005 12.34.22 */
PUBLIC BOMAIL::BOMAIL (const char *document,
	 const char *_user,
	 const char *pass);
PUBLIC bool BOMAIL::isok (void);
PUBLIC BOMAIL::~BOMAIL (void);
PUBLIC int BOMAIL::send (const char *line);
PUBLIC int BOMAIL::sendf (const char *ctl, ...);
PUBLIC int BOMAIL::getfd (void)const;
PUBLIC int BOMAIL::save (const char *from,
	 const char *msgid,
	 const char *header,
	 const char *text,
	 const SSTRING&folder_uuid,
	 SSTRING&uuid);
PUBLIC int BOMAIL::attach (const SSTRING&msg_uuid,
	 const char *title,
	 const char *type,
	 const char *attach,
	 int length,
	 SSTRING&att_uuid);
PUBLIC int BOMAIL::find (SSTRING&uuid);
PUBLIC bool BOMAIL::folder_exist (const char *folder, SSTRING&uuid);
PUBLIC int BOMAIL::link (const SSTRING&mailuuid,
	 const SSTRING&folderuuid);
PUBLIC int BOMAIL::unlink (const SSTRING&mailuuid,
	 const SSTRING&folderuuid);
PUBLIC int BOMAIL::saveflags (const SSTRING&mailuuid,
	 bool deleted,
	 bool viewed,
	 bool replied,
	 bool marked,
	 DICTIONARY&vars);
PUBLIC int BOMAIL::savecomment (const SSTRING&mailuuid,
	 const SSTRING&comment);
PUBLIC int BOMAIL::create_folder (const char *folder, SSTRING&uuid);
PUBLIC bool BOMAIL::msg_exist (const SSTRING&folder_uuid,
	 const char *msgid,
	 SSTRING&msg_uuid);
PUBLIC int BOMAIL::list_folders (SSTRINGS&tb);
PUBLIC int BOMAIL::getrevision (const SSTRING&uuid);
PUBLIC int BOMAIL::incrrevision (const SSTRING&uuid);
/* bomisc.tlcc 13/12/2005 12.34.22 */
/* bonode.tlcc 13/12/2005 12.34.22 */
PUBLIC const char *BO_NODEREL::getmodif (void);
PUBLIC BO_REL::BO_REL (void);
PUBLIC BO_NODE::BO_NODE (void);
PUBLIC BO_NODE *BO_NODES::set (const char *name,
	 const char *image,
	 const char *modif,
	 const char *uuid,
	 const char *owner,
	 const char *type,
	 const char *descr);
PUBLIC BO_NODE *BO_NODES::locatebyuuid (const char *uuid)const;
PUBLIC BO_NODE *BO_NODES::locatebyuuid (const SSTRING&uuid)const;
PUBLIC BO_NODE *BO_NODES::locatebyname (const char *name)const;
PUBLIC void BO_NODES::sort (void);
PUBLIC BO_REL *BO_RELS::locate (const char *uuid1,
	 const char *uuid2,
	 const char *relate);
PUBLIC int BO_RELS::extract (const char *relate,
	 const char *uuid,
	 BO_RELS&tb)const;
PUBLIC BO_REL *BO_RELS::set (const char *uuid1,
	 const char *uuid2,
	 const char *relate,
	 const char *modif,
	 const char *type,
	 const char *altname,
	 const char *descr,
	 const char orderpol,
	 unsigned int orderkey);
PUBLIC LINKTYPE BO_RELS::islinked (const char *uuid);
PUBLIC void BO_NODES::resetseen (void);
/* boshell.tlcc 13/12/2005 12.34.22 */
PUBLIC BOFSPATH::BOFSPATH (const SSTRING&cwd, const SSTRING&sub);
/* boxml.tlcc 13/12/2005 12.34.22 */
void _F_boxml::user (const char *owner,
	 int ownerid,
	 int documentid,
	 const char *id,
	 const char *name,
	 const char *passw,
	 bool&end,
	 bool&skip);
void _F_boxml::document (const char *owner,
	 const char *name,
	 const char *descr,
	 bool&end,
	 bool&skip,
	 int &documentid,
	 int &ownerid);
void _F_boxml::node (int documentid,
	 const char *name,
	 const char *descr,
	 const char *image,
	 const char *modif,
	 const char *uuid,
	 const char *owner,
	 const char *type,
	 bool&end,
	 bool&skip);
void _F_boxml::oldnode (int documentid,
	 const char *name,
	 const char *descr,
	 const char *image,
	 const char *modif,
	 const char *uuid,
	 const char *owner,
	 const char *type,
	 bool&end,
	 bool&skip);
void _F_boxml::delnode (int documentid,
	 const char *uuid,
	 bool&end,
	 bool&skip);
void _F_boxml::relation (int documentid,
	 int docownerid,
	 const char *owner,
	 const char *uuid1,
	 const char *uuid2,
	 const char *relate,
	 const char *descr,
	 const char *modif,
	 const char *type,
	 const char *altname,
	 char orderpol,
	 unsigned int orderkey,
	 bool&end,
	 bool&skip);
void _F_boxml::oldrelation (int documentid,
	 int docownerid,
	 const char *owner,
	 const char *uuid1,
	 const char *uuid2,
	 const char *relate,
	 const char *descr,
	 const char *modif,
	 const char *type,
	 bool&end,
	 bool&skip);
void _F_boxml::delrelation (int documentid,
	 const char *uuid1,
	 const char *uuid2,
	 const char *relate,
	 bool&end,
	 bool&skip);
PUBLIC BOXML_READER::BOXML_READER (void);
PUBLIC void BOXML_READER::append (const char *line);
PUBLIC xmlDocPtr BOXML_READER::getxmldoc (void);
PUBLIC void BOXML_READER::reset (void);
PUBLIC bool BOXML_READER::reading (void)const;
PUBLIC BOXML_READER::~BOXML_READER (void);
PUBLIC const char *BOXMLENC::enc (const char *s);
PUBLIC const char *BOXMLENC::enc (const SSTRING&s);
PUBLIC const char *BOXMLENC::enc (int val);
PUBLIC const char *BOXMLENC::encnq (const char *s);
PUBLIC const char *BOXMLENC::encnq (const SSTRING&s);
