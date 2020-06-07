#ifndef BOLIXO_H
#define BOLIXO_H

#include "helper.h"

enum ENTRY_TYPE{
	ENTRY_NONE,
	ENTRY_DELETED,
	ENTRY_DIR,
	ENTRY_FILE,
	ENTRY_MSG,
	ENTRY_DOCUMENT
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

// Do not forget to edit the table tbftype below and tbhttptype in web/util.hcc
enum FILE_TYPE {
	FILE_UNKNOWN,
	FILE_TEXT,
	FILE_SOUND_MP3,
	FILE_SOUND_OGG,
	FILE_IMAGE_JPG,
	FILE_IMAGE_PNG,
	FILE_IMAGE_GIF,
	FILE_VIDEO,
	FILE_DOC_SUDOKU,
	FILE_DOC_CHECKER,
	FILE_DOC_CHESS,
	FILE_DOC_TICTACTO,
	FILE_ZIP,
	FILE_TGZ,
	FILE_DOC_WORDPROC,
	FILE_DOC_WHITEBOARD,
	FILE_WEBM,
	FILE_IMAGE_TIFF,
	FILE_PDF,
	FILE_DOC_CALC,
	// Do not forget to edit the table tbftype below and tbhttptype in web/util.hcc
	FILE_TYPE_LAST
};

enum VIEWED_STATUS{
	VIEWED_NEW,	// This is new for you
	VIEWED_OK,	// Ok you have seen it
	VIEWED_MODIFIED	// You have seen it, but the document changed
};

inline bool file_is_text (FILE_TYPE type){
	return type == FILE_TEXT;
}
inline bool file_is_sound (FILE_TYPE type){
	return is_any_of(type,FILE_SOUND_MP3,FILE_SOUND_OGG);
}
inline bool file_is_image (FILE_TYPE type){
	return is_any_of (type,FILE_IMAGE_JPG,FILE_IMAGE_GIF,FILE_IMAGE_PNG,FILE_IMAGE_TIFF);
}
inline bool file_is_video (FILE_TYPE type){
	return is_any_of(type,FILE_VIDEO,FILE_WEBM);
}
// is_doc contains documents and games
inline bool file_is_game (FILE_TYPE type){
	return is_any_of(type,FILE_DOC_SUDOKU,FILE_DOC_CHECKER,FILE_DOC_CHESS,FILE_DOC_TICTACTO);
}
inline bool file_is_doc (FILE_TYPE type){
	return is_any_of(type,FILE_DOC_SUDOKU,FILE_DOC_CHECKER,FILE_DOC_CHESS,FILE_DOC_TICTACTO,FILE_DOC_WORDPROC,FILE_DOC_WHITEBOARD,FILE_DOC_CALC);
}
inline bool file_is_data (FILE_TYPE type){
	return is_any_of(type,FILE_ZIP,FILE_TGZ,FILE_PDF);
}
#ifdef DEFINE_TBTYPE
static char tbtype[]={' ','_','D','F','M','C'};
#endif
#ifdef DEFINE_TBFTYPE
const char *tbftype[]={
	"?",	//FILE_UNKNOWN,
	"txt",	//FILE_TEXT,
	"mp3",	//FILE_SOUND_MP3,
	"ogg",	//FILE_SOUND_OGG,
	"jpg",	//FILE_IMAGE_JPG,
	"png",	//FILE_IMAGE_PNG,
	"gif",	//FILE_IMAGE_GIF,
	"vid",	//FILE_VIDEO,
	"sud",	//FILE_DOC_SUDOKU
	"chk",	//FILE_DOC_CHECK
	"chs",	//FILE_DOC_CHESS
	"tic",	//FILE_DOC_TICTACTO
	"zip",	//FILE_ZIP
	"tgz",	//FILE_TGZ
	"wrd",	//FILE_DOC_WORDPROC
	"whi",	//FILE_DOC_WHITEBOARD
	"wbm",	//FILE_WEBM
	"tiff", //FILE_IMAGE_TIFF
	"pdf",	//FILE_PDF
	"clc",	//FILE_DOC_CALC
};
#else
extern const char *tbftype[];
#endif


enum ERR_CODE{
	ERR_CODE_NONE,
	ERR_CODE_WARNING,
	ERR_CODE_FAIL,
	ERR_CODE_INVALID,
	ERR_CODE_NOPASSPHRASE,
	ERR_CODE_IVLDACCOUNT,
	ERR_CODE_CANTSIGN,
	ERR_CODE_NOSIGFOUND,
	ERR_CODE_VERIFYFAILED,
	ERR_CODE_CANTVERIFY
};

enum CONTACT_STATUS{
	CONTACT_WAITING,
	CONTACT_ACCEPTED,
	CONTACT_REJECTED
};

#define NOTIFY_PROFILE_CONTACTS "profile:Contacts"
#define NOTIFY_PROFILE_CONTACT_REQ "profile:Contact-req"

#endif

