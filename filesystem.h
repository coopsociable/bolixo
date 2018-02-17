struct ENTRY {
	unsigned userid;
	bool is_admin;
	std::string basename;
	int dirid;
	int entryid;
	unsigned ownerid;
	unsigned group_list_id;
	char type;
	std::string modified;
	std::string msg;
	ENTRY(){
		userid = 0;
		dirid = -1;
		entryid = -1;
		ownerid = (unsigned)-1;
		type = '_';
	}
};

int fs_findentry (const char *name, ENTRY &entry, bool expect_exist, const char *threshold);
FILE *fs_alloc_file_handle (int fileid, PARAM_STRING modified, const char *mode, std::string &handle, const char *sessionid);
long fs_get_filesize (int fileid, PARAM_STRING modified);
FILE *fs_get_file (const std::string &handle, const char *sessionid);
void fs_delete_handle (PARAM_STRING handle);
std::string fs_makeid (int noproc);
unsigned fs_getnbhandle();
