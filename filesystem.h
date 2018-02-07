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
