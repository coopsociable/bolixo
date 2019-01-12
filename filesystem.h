#include "bolixo.h"
#include "proto/bod_client.protodef"

struct ENTRY {
	unsigned userid;
	bool is_admin;
	std::string basename;
	int dirid;
	int entryid;
	unsigned ownerid;
	unsigned group_list_id;
	ENTRY_TYPE type;
	char listmode;
	bool may_add;		// May add an entry in the directory
	bool may_modify;	// May update the entry
	std::string modified;
	std::string msg;
	ENTRY(){
		may_add = false;
		may_modify = false;
		userid = 0;
		dirid = -1;
		entryid = -1;
		ownerid = (unsigned)-1;
		type = ENTRY_NONE;
		listmode = ' ';
	}
};

#define END_OF_TIME	"3000/01/01 00:00:00"
#define ALL_MAY_READ	"#all"

void fs_set_noproc (int noproc);
int fs_findentry (PARAM_STRING name, ENTRY &entry, bool expect_exist, const char *threshold);
std::string fs_createpath (int fileid, PARAM_STRING modified);
FILE *fs_alloc_file_handle (int fileid, PARAM_STRING modified, const char *mode, std::string &handle, const char *sessionid);
long fs_get_filesize (int fileid, PARAM_STRING modified);
FILE *fs_get_file (const std::string &handle, const char *sessionid);
void fs_delete_handle (PARAM_STRING handle);
void fs_file_handle_addextra (PARAM_STRING handle, int ownerid, int dirid);
int fs_file_handle_getextra (PARAM_STRING handle, int &ownerid, int &dirid, int &fileid, std::string &modified);
std::string fs_makeid ();
unsigned fs_getnbhandle();
void fs_list_inboxes (unsigned userid, std::vector<INBOX> &inboxes, std::vector<unsigned> &listids, bool showroles);
unsigned fs_find_inbox (unsigned ownerid, PARAM_STRING name, bool create, std::string &msg);
//unsigned fs_find_short_inbox (unsigned ownerid, PARAM_STRING username, std::string &msg, bool create, bool &created);
unsigned fs_find_short_inbox (unsigned ownerid, PARAM_STRING username, PARAM_STRING groupname, std::string &msg, bool create, bool &created);
unsigned fs_find_short_inbox (unsigned ownerid, PARAM_STRING username, PARAM_STRING groupname, std::string &msg);
unsigned fs_find_outbox (unsigned ownerid, PARAM_STRING name, std::string &msg);
unsigned fs_find_project_inbox (unsigned ownerid, unsigned listid, const char *name, const char *project, const char *role, bool create, std::string &msg);
void fs_set_now (DATEASC &now);
int fs_newid (unsigned userid, unsigned listid, char listmode, std::string &msg, std::string &uuid);
int fs_newid (unsigned userid, unsigned listid, char listmode, std::string &msg);
int fs_newid (unsigned userid, std::string &msg, std::string &uuid);
int fs_newid (unsigned userid, std::string &msg);
int fs_insert_dir (int parentid,int dirid,PARAM_STRING modified,PARAM_STRING name);
int fs_insert_dir (int parentid,int dirid,PARAM_STRING name);
int fs_insert_entry (int parentid,int id,PARAM_STRING modified,PARAM_STRING name, ENTRY_TYPE type, unsigned copiedby);
int fs_insert_entry (int parentid,int id,PARAM_STRING modified,PARAM_STRING name, ENTRY_TYPE type);
int fs_insert_file (int parentid,int fileid,PARAM_STRING modified,PARAM_STRING name);
int fs_insert_file (int parentid,int fileid,PARAM_STRING name);
int fs_insert_deleted (int parentid,int id,PARAM_STRING name, PARAM_STRING modified);
__attribute__((format(printf, 1, 2))) int fs_rec_getid(const char *query, ...);
int fs_locate_dir (
	const std::vector<std::string> &tb,
	unsigned userid,	// Check access for this userid
	bool is_admin,
	std::string &msg,
	const char *threshold,
	bool &may_add,
	bool create_missing,
	const std::vector<unsigned> *listids,
	const std::vector<char> *listmodes);

int fs_verify(const BOB_TYPE &msg, EVP_PKEY *key, PARAM_STRING sig64);
int fs_verify(PARAM_STRING msg, EVP_PKEY *key, PARAM_STRING sig64);
EVP_PKEY *fs_load_public (PARAM_STRING p);
void fs_free_public (EVP_PKEY *p);
int fs_valid_pubkey(const char *pubkey);

