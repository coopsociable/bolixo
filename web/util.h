struct USERINFO{
	std::string name;
	bool is_admin;
	std::string lang;
	void reset(){
		name.clear();
		lang = "eng";
		is_admin = false;
	}
	USERINFO(){
		reset();
	}
};
extern USERINFO userinfo;

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
void print_date (PARAM_STRING date);
void util_formanchor();
void button_preview(int step);

#define _TLMP_button_row
struct _F_button_row{
	void split();
	#define _F_button_row_draw(x) void x draw()
	virtual _F_button_row_draw( )=0;
};

void button_row(_F_button_row &c, int border, const char *bgcolor, bool alignleft);
void button_row(_F_button_row &c, int border, const char *bgcolor);
void button_row(_F_button_row &c, int border);
void button_row(_F_button_row &c);

void trli_subjects (int step_statistics, int subject_selected, bool stat_selected, bool blog_selected, W_UNSIGNED &_w_tosubject);

