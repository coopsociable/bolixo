#include "../bolixo.h"

#ifdef DEFINE_USERINFO
struct USERLOGINFO{
	std::string name;
	bool is_admin;
	unsigned dateformat;
	std::string lang;
	bool talk_notify = false;
	bool mail_notify = false;
	bool main_notify = false;
	bool menu_notify = false;
	std::set<std::string> notifies;
	unsigned notify_sequence = 0;
	void reset(){
		name.clear();
		lang = "eng";
		is_admin = false;
		dateformat = 0;
		notifies.clear();
	}
	USERLOGINFO(){
		reset();
	}
};
#endif

struct DOTMENU{
	const char *menu;
	unsigned step;
	DOTMENU(const char *_menu, unsigned _step){
		menu = _menu;
		step = _step;
	}
};
void util_dotmenu(const std::vector<DOTMENU> &menu, bool is_active, bool notify);
int util_getsessioninfo (CONNECT_INFO &con, CONNECT_INFO &con_sess, std::string &session, const char *varname, unsigned &varval);
void print_href (const char *id_suffix, const char *title, PARAM_STRING href, bool notify);
void print_aref (const char *id_suffix, const char *title, int step, bool notify);
void print_aref_selected (const char *id_suffix, const char *title, int step);


const char *format_line (const char *s);
const char *format_url(const char *s);
void format_href(const char *s);
void format_content (const char *s);
void format_content (const char *s, int nbline, bool &more);
void formatting_tips();
void util_google_code();
void util_setmobilespecs (unsigned body_font_size, unsigned input_font_size);
void util_defstyles();
void printhref(const char *url, const char *text);
void printhref(const char *url, const char *text, bool largewindow);
void printhref_raw(const char *url, const char *text, bool largewindow);
std::string format_date (unsigned format, PARAM_STRING date);
std::string format_time (unsigned format, PARAM_STRING time);
void util_formanchor();
unsigned draw_tab (const char *id_suffix, unsigned width, const char *fill, const char *fill_in, bool close, const char *title, bool drawx, PARAM_STRING href, PARAM_STRING xref);
unsigned draw_tab (const char *id_suffix, unsigned width, const char *fill, const char *fill_in, bool close, const char *title, PARAM_STRING href);

#define _TLMP_button_row
struct _F_button_row{
	const char *align;
	bool spliton;
	string href_arrow_left;
	bool arrow_left_visible;
	string href_arrow_right;
	bool arrow_right_visible;
	bool endline;
	unsigned endline_width;
	_F_button_row(){
		align = "left";
		spliton = false;
		arrow_left_visible = arrow_right_visible = false;
		endline = false;
		endline_width = 0;
	}
	void split();
	void reset();
	void drawendline(unsigned width);
	void drawleftarrow(PARAM_STRING href, bool visible);
	void drawrightarrow(PARAM_STRING href, bool visible);
	#define _F_button_row_draw(x) void x draw()
	virtual _F_button_row_draw( )=0;
	#define _F_button_row_draw_right(x) void x draw_right()
	virtual _F_button_row_draw_right( );
};

void button_row(_F_button_row &c, int border, const char *bgcolor, bool alignleft);
void button_row(_F_button_row &c, int border, const char *bgcolor);
void button_row(_F_button_row &c, int border);
void button_row(_F_button_row &c);

void trli_subjects (int step_statistics, int subject_selected, bool stat_selected, bool blog_selected, W_UNSIGNED &_w_tosubject);
int util_sendfile (CONNECT_INFO &con, PARAM_STRING session, PARAM_STRING filename);
int util_sendpublicfile (CONNECT_INFO &con, PARAM_STRING filename);
std::string util_flipspaces(PARAM_STRING s);

class FILEINFO;
class SHORTMSG;

#define _TLMP_public_page
struct _F_public_page{
	void sendhtml (const BOB_TYPE &content);
	#define _F_public_page_listdir(x) int x listdir(PARAM_STRING path, unsigned offset, unsigned nb, std::vector<FILEINFO> &files)
	virtual _F_public_page_listdir( )=0;
	#define _F_public_page_list_talk(x) int x list_talk(unsigned offset, unsigned nb, std::vector<SHORTMSG> &msgs)
	virtual _F_public_page_list_talk( )=0;
	#define _F_public_page_readfile(x) int x readfile(PARAM_STRING path, BOB_TYPE &content)
	virtual _F_public_page_readfile( )=0;
	#define _F_public_page_process(x) void x process()
	virtual _F_public_page_process( )=0;
	#define _F_public_page_projecturl(x) std::string x projecturl(PARAM_STRING name, PARAM_STRING modified, bool is_image)
	virtual _F_public_page_projecturl( )=0;
	#define _F_public_page_msgurl(x) std::string x msgurl(PARAM_STRING name, PARAM_STRING modified)
	virtual _F_public_page_msgurl( )=0;
	#define _F_public_page_sendfile(x) void x sendfile(PARAM_STRING name)
	virtual _F_public_page_sendfile( )=0;
};

void public_page (_F_public_page &c);
void public_display (_F_public_page &c, CONNECT_INFO &con, PARAM_STRING user, bool pubdir, PARAM_STRING website, PARAM_STRING interest);
std::string util_format_shortmsg (PARAM_STRING txt, unsigned nblines, size_t size, unsigned image_width);
std::string util_format_shortmsg (PARAM_STRING txt, unsigned image_width);
std::string util_readsecret();
void util_setnodeurl(PARAM_STRING name);
const char *util_getnodename();
const char *util_getnodeurl();
void util_setdirserver(PARAM_STRING dir);
const char *util_getdirserver();
string toupper (PARAM_STRING s);
class MESSAGE_receive;
string index_format_mail_fname(const MESSAGE_receive &m, PARAM_STRING username);
void util_delnotify(CONNECT_INFO &con_sess, PARAM_STRING id);
void util_delnotify(CONNECT_INFO &con_sess, PARAM_STRING prefix, PARAM_STRING id);
void util_endscript(PARAM_STRING urlparam);
string util_clickable_img (PARAM_STRING url, unsigned image_width);
void util_clickable_img (PARAM_STRING url, const char *image_width, unsigned border);
void util_print_span(PARAM_STRING url);
ENTRY_TYPE util_entrytype(CONNECT_INFO &con,PARAM_STRING path, FILEINFO &info);
ENTRY_TYPE util_entrytype(CONNECT_INFO &con,PARAM_STRING path);

struct _F_sendfile_common {
	string handle;
	bool success;
	void sethandle (PARAM_STRING handle);
	void setresult (bool success, PARAM_STRING msg);
};

#define _TLMP_sendfile
struct _F_sendfile: public _F_sendfile_common {
	#define _F_sendfile_start(x) void x start(const char *filepath, const BOB_TYPE &content, bool more)
	virtual _F_sendfile_start( )=0;
	#define _F_sendfile_rest(x) void x rest(const string &handle, const BOB_TYPE &content, bool more)
	virtual _F_sendfile_rest( )=0;
};
void sendfile(_F_sendfile &c, PARAM_STRING filepath, PARAM_STRING localfile, bool &fail);

#define _TLMP_sendfile_var
struct _F_sendfile_var: public _F_sendfile_common {
	#define _F_sendfile_var_start(x) void x start(const char *filepath, const BOB_TYPE &content, bool more)
	virtual _F_sendfile_var_start( )=0;
	#define _F_sendfile_var_rest(x) void x rest(const string &handle, const BOB_TYPE &content, bool more)
	virtual _F_sendfile_var_rest( )=0;
};
void sendfile_var(_F_sendfile_var &c, PARAM_STRING filepath, PARAM_STRING var_content, bool &fail);
std::string util_mini_img(unsigned step, unsigned width, PARAM_STRING dirpath, PARAM_STRING filename, PARAM_STRING date);
std::string util_img(unsigned step, unsigned width, PARAM_STRING dirpath, PARAM_STRING filename, PARAM_STRING date);
std::string util_img(unsigned step, const char *style, PARAM_STRING filepath, PARAM_STRING date);
void util_popup (CONNECT_INFO &con, int step, const char *content, FILE_TYPE file_type, PARAM_STRING modified, PARAM_STRING from, PARAM_STRING filepath);
void util_popup (CONNECT_INFO &con, const char *content, FILE_TYPE file_type, PARAM_STRING modified, PARAM_STRING from, PARAM_STRING filepath);
void util_markview (CONNECT_INFO &con, PARAM_STRING fname);
