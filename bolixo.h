enum ENTRY_TYPE{
	ENTRY_NONE,
	ENTRY_DELETED,
	ENTRY_DIR,
	ENTRY_FILE,
	ENTRY_MSG
};

inline bool bolixo_isfile (ENTRY_TYPE type)
{
	return type == ENTRY_FILE || type == ENTRY_MSG;
}
inline bool bolixo_isdir (ENTRY_TYPE type)
{
	return type == ENTRY_DIR;
}
inline bool bolixo_isdeleted(ENTRY_TYPE type)
{
	return type == ENTRY_DELETED;
}

enum FILE_TYPE {
	FILE_UNKNOWN,
	FILE_TEXT,
	FILE_SOUND,
	FILE_IMAGE,
	FILE_VIDEO,
};
