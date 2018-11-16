struct USERINFO{
	std::string name;
	bool is_admin;
	unsigned dateformat;
	std::string lang;
	void reset(){
		name.clear();
		lang = "eng";
		is_admin = false;
		dateformat = 0;
	}
	USERINFO(){
		reset();
	}
};

int util_getsessioninfo (CONNECT_INFO &con, CONNECT_INFO &con_sess, std::string &session, const char *varname, unsigned &varval);
void print_href (const char *title, PARAM_STRING href);
void print_aref (const char *title, int step);
void print_aref (const char *title, int step, W_VAR &var);
void print_aref_selected (const char *title, int step);
void print_aref_selected (const char *title, int step, W_VAR &var);
void print_aref (const char *title, int step, W_VAR &var1, W_VAR &var2);
void print_aref (const char *title, int step, W_VAR &var1, const char *varname2, const char *val2);
void print_aref (const char *title, int step, W_VAR &var1, W_VAR &var2, W_VAR &var3);

const char *format_line (const char *s);
const char *format_url(const char *s);
void format_href(const char *s);
void format_content (const char *s);
void format_content (const char *s, int nbline, bool &more);
void formatting_tips();
void util_google_code();
void util_defstyles();
void printhref(const char *url, const char *text);
void printhref(const char *url, const char *text, bool largewindow);
void printhref_raw(const char *url, const char *text, bool largewindow);
std::string format_date (unsigned format, PARAM_STRING date);
std::string format_time (unsigned format, PARAM_STRING time);
void util_formanchor();
unsigned draw_tab (unsigned width, unsigned height, const char *fill, const char *fill_in, bool close, const char *title, bool drawx, PARAM_STRING href, PARAM_STRING xref);
unsigned draw_tab (unsigned width, unsigned height, const char *fill, const char *fill_in, bool close, const char *title, PARAM_STRING href);

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
void util_sendfile (CONNECT_INFO &con, PARAM_STRING session, PARAM_STRING filename);
int util_sendpublicfile (CONNECT_INFO &con, PARAM_STRING filename);
std::string util_flipspaces(PARAM_STRING s);


