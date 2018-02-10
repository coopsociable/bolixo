struct ENTRY {
	unsigned userid;
	std::string basename;
	int dirid;
	int entryid;
	unsigned ownerid;
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

int fs_findentry (const char *name, ENTRY &entry, bool expect_exist);
std::string fs_alloc_file_handle (int fileid, PARAM_STRING modified);
FILE *fs_open_handle (PARAM_STRING handle, const char *mode);
void fs_delete_handle (PARAM_STRING handle);
std::string fs_makeid (int noproc);
unsigned fs_getnbhandle();
