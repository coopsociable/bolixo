struct ENTRY {
	unsigned userid;
	bool is_admin;
	std::string basename;
	int dirid;
	int entryid;
	unsigned ownerid;
	unsigned group_list_id;
	char type;
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
		type = '_';
		listmode = ' ';
	}
};

#define END_OF_TIME	"3000/01/01 00:00:00"
#define ALL_MAY_READ	"#allread"

int fs_findentry (const char *name, ENTRY &entry, bool expect_exist, const char *threshold);
FILE *fs_alloc_file_handle (int fileid, PARAM_STRING modified, const char *mode, std::string &handle, const char *sessionid);
long fs_get_filesize (int fileid, PARAM_STRING modified);
FILE *fs_get_file (const std::string &handle, const char *sessionid);
void fs_delete_handle (PARAM_STRING handle);
std::string fs_makeid (int noproc);
unsigned fs_getnbhandle();
void fs_list_inboxes (unsigned userid, std::vector<std::string> &managers, std::vector<std::string> &projects, std::vector<std::string> &roles, std::vector<unsigned> &listids);
unsigned fs_find_inbox (unsigned ownerid, const char *name, int noproc, std::string &msg);
unsigned fs_find_project_inbox (unsigned ownerid, unsigned listid, const char *name, const char *project, const char *role, int noproc, std::string &msg);
void fs_set_now (char now[20]);
int fs_newid (unsigned userid, unsigned listid, char listmode, int noproc, std::string &msg, std::string &uuid);
int fs_newid (unsigned userid, int noproc, std::string &msg, std::string &uuid);
int fs_newid (unsigned userid, int noproc, std::string &msg);
