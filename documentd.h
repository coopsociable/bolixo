#ifndef DOCUMENTD_H
#define DOCUMENTD_H

class DOC_UI_SPECS_receive;

class DOC_WRITER{
	FILE *fout = nullptr;
	std::vector<std::string> lines;
public:
	DOC_WRITER(){}
	DOC_WRITER(FILE *_fout);
	int write (const char *buf, unsigned len);
	int write (const std::string &l);
	BOB_TYPE getcontent () const;
};

class DOC_READER{
public:
	FILE *fin = nullptr;
	const char *bufptr = nullptr;
	DOC_READER(FILE *_fin) : fin(_fin){}
	DOC_READER(const char *ptr) : bufptr(ptr){}
	DOC_READER(){}
};	

class GAME{
	time_t modified = (time_t)0;
	time_t last_activity = time(nullptr);
	std::string modified_by;
protected:
	unsigned revision = 0;
	std::string gameid;
	inline void js_find_set(std::string &lines, const char *prefix, const char *feature, const char *val){
		lines += string_f ("var elm = document.getElementById('%s-%s');\n",prefix,gameid.c_str());
		lines += "if (elm != null){\n";
		lines += string_f("\telm.%s='%s';\n",feature,val);
		lines += "}\n";
	}
	inline void js_find_set(std::string &lines, const char *prefix, const char *feature1, const char *val1, const char *feature2, const char *val2){
		lines += string_f ("var elm = document.getElementById('%s-%s');\n",prefix,gameid.c_str());
		lines += "if (elm != null){\n";
		lines += string_f("\telm.%s='%s';\n",feature1,val1);
		lines += string_f("\telm.%s='%s';\n",feature2,val2);
		lines += "}\n";
	}
	inline void js_find_loop_set(std::string &lines, const char *prefix, const char *tag, PARAM_STRING id, const char *feature, const char *val){
		lines += string_f ("var elm = document.getElementById('%s-%s');\n",prefix,gameid.c_str());
		lines += "if (elm != null){\n";
		lines += string_f("\tvar elms = elm.getElementsByTagName('%s');\n",tag);
		//lines += string_f("\tconsole.log('%s.length='+elms.length);\n",tag);
		lines += "\tfor (var i=0; i<elms.length; i++){\n";
		lines += "\t\tvar e = elms[i];\n";
		lines += string_f("\t\tif (e.id == '%s'){\n",id.ptr);
		lines += string_f("\t\t\te.%s='%s';\n",feature,val);
		lines += "\t\t\tbreak;\n";
		lines += "\t\t}\n";
		lines += "\t}\n";
		lines += "}\n";
	}
	inline void js_find_loop_set(std::string &lines, const char *prefix, const char *tag, PARAM_STRING id, const char *feature1, const char *val1, const char *feature2, const char *val2){
		lines += string_f ("var elm = document.getElementById('%s-%s');\n",prefix,gameid.c_str());
		lines += "if (elm != null){\n";
		lines += string_f("\tvar elms = elm.getElementsByTagName('%s');\n",tag);
		lines += "\tfor (var i=0; i<elms.length; i++){\n";
		lines += "\t\tvar e = elms[i];\n";
		lines += string_f("\t\tif (e.id == '%s'){\n",id.ptr);
		lines += string_f("\t\t\te.%s='%s';\n",feature1,val1);
		lines += string_f("\t\t\te.%s='%s';\n",feature2,val2);
		lines += "\t\t\tbreak;\n";
		lines += "\t\t}\n";
		lines += "\t}\n";
		lines += "}\n";
	}
public:
	void setgameid(const char *_gameid){
		gameid = _gameid;
	}
	void set_revision(unsigned _revision){
		revision = _revision;
	}
	unsigned get_revision() const {
		return revision;
	}
	void setactivity(){
		last_activity = time(nullptr);
	}
	void setactivity(time_t act){
		last_activity = act;
	}
	void setmodified(const char *_modified_by){
		modified = time(nullptr);
		modified_by = _modified_by;
		revision++;
	}
	void setmodified(time_t mod, const char *_modified_by){
		modified = mod;
		modified_by = _modified_by;
	}
	void resetmodified(){
		modified = (time_t)0;
		modified_by.clear();
	}
	bool is_modified() const{
		return modified != (time_t)0;
	}
	time_t get_modified() const {
		return modified;
	}
	const char *get_modified_by() const {
		return modified_by.c_str();
	}
	time_t get_last_activity() const {
		return last_activity;
	}
	virtual const char *getclass() const =0;
	virtual void save(DOC_WRITER &writer, bool save_session_info)=0;
	virtual void load(DOC_READER &reader, std::string &msg)=0;
	virtual void resetgame() = 0;
	virtual void testwin(std::vector<VARVAL> &res) = 0;
	virtual void exec (const char *var, const char *val, const char *session, const char *username, bool maywrite, const DOC_UI_SPECS_receive &sp, std::vector<VARVAL> &res) = 0;
	virtual ~GAME(){};
};

class TICTACTO: public GAME{
	bool x_is_player;
	unsigned char grid[3][3];
public:
	void save(DOC_WRITER &w, bool);
	void load(DOC_READER &r, std::string &msg);
	void resetgame();
	TICTACTO();
	const char *getclass() const;
	void testwin(std::vector<VARVAL> &res);
	void draw_x(std::string &lines, unsigned x, unsigned y, unsigned len);
	void draw_o(std::string &lines, unsigned x, unsigned y, unsigned len);
	void exec (const char *var, const char *val, const char *session, const char *username, bool maywrite, const DOC_UI_SPECS_receive &sp, std::vector<VARVAL> &res);
};

struct SUDOKU_CELL{
	unsigned char visible;		// This cell is visible
	unsigned char value;		// Value of the cell. If visible, this value is shown in gray
	unsigned char user_value;	// Value entered by the user, if user_value == value, user is right.
	std::string username;		// User who solved this cell.
	unsigned char user_guess;	// When trying to solve complex puzzle, a user
					// may enter a guess in a cell to help his memory
	unsigned char guess_color;	
	void reset(){
		visible = value = user_value = 0;
		username.clear();
		user_guess = guess_color = 0;
	}
	SUDOKU_CELL(){
		reset();
	}
};
struct SUDO_USERPREF{
	unsigned color = 0;
	unsigned last_column = 10;	// Last solve cell coordinate
	unsigned last_line = 10;
};
class SUDOKU: public GAME{
	SUDOKU_CELL grid[9][9];	
	std::map<std::string,unsigned> seldigs; // Selected digit used when setting a value
	std::map<std::string,SUDO_USERPREF> prefs;	// Preferences associated with a user
	unsigned difficulty=0;	// What difficulty was used to initialize the game
	bool grid_full[9];	// The grid is now complete for a given digit.
	void compute_grid_full();
	void redraw_notify(std::vector<VARVAL> &res);
	void update_msg(bool to_all, PARAM_STRING msg, const char *color, std::vector<VARVAL> &res);
public:
	const char *getclass() const{
		return "SUDO";
	}
	SUDOKU(){
		resetgame();
	}
	void save(DOC_WRITER &fout, bool save_session_info);
	void load(DOC_READER &r, std::string &msg);
	void resetgame();
	void testwin(std::vector<VARVAL> &res);
	void exec (const char *var, const char *val, const char *session, const char *username, bool maywrite, const DOC_UI_SPECS_receive &sp, std::vector<VARVAL> &res);
};

struct WORD_USERPREF{
	unsigned offset=0;	// First line displayed
	unsigned line=0;
	unsigned column=0;
	bool insertmode = true;
};

class WORDPROC: public GAME{
	std::vector<std::string> lines;
	std::map<std::string,WORD_USERPREF> prefs;
public:
	const char *getclass() const{
		return "WORD";
	}
	void save(DOC_WRITER &w, bool save_session_info);
	void load(DOC_READER &r, std::string &msg);
	void resetgame();
	void testwin(std::vector<VARVAL> &res);
	void exec (const char *var, const char *val, const char *session, const char *username, bool maywrite, const DOC_UI_SPECS_receive &sp, std::vector<VARVAL> &res);
};

struct CHECKER_PLAYER{
	unsigned col=11;
	unsigned line=11;
	bool onemove=false;	// The player has done one move over another player coin
				// and may stop there or not.
	std::string name;
	void reset(){
		onemove = false;
		col = line = 11;
		name.clear();
	}
	bool has_selected(){	// Has the player select the piece he wants to move
		return col < 10 && line < 10;
	}
};

class CHECKERS: public GAME{
	unsigned nbcol=8;
	static const unsigned MAX_GRID_SIZE = 10;
	unsigned char grid[MAX_GRID_SIZE][MAX_GRID_SIZE];
	CHECKER_PLAYER player1,player2;
	bool player1_playing = true;
	std::string message;
	std::map<std::string,bool> sessions; // Display mode (reverse) per session
	void update_msg (bool to_all, PARAM_STRING msg, const char *color, std::vector<VARVAL> &res);
public:
	const char *getclass() const{
		return "CHEC";
	}
	void save(DOC_WRITER &w, bool save_session_info);
	void load(DOC_READER &r, std::string &msg);
	void resetgame();
	void testwin(std::vector<VARVAL> &res);
	void exec (const char *var, const char *val, const char *session, const char *username, bool maywrite, const DOC_UI_SPECS_receive &sp, std::vector<VARVAL> &res);
};

#define VAR_CONTENT	"content"	// HTML content to display
#define VAR_ERROR	"error"
#define VAR_RESULT	"result"
#define VAR_NOTIFY	"notify"	// Javascript applied to all users
#define VAR_REFRESH	"refresh"	// Trigger a screen refresh
#define VAR_SCRIPT	"script"	// Javascript for this user only

std::string documentd_escape(PARAM_STRING msg);
void documentd_error (std::vector<VARVAL> &res, PARAM_STRING s);
void documentd_button (std::string &lines, unsigned command, const char *txt, bool highlit);
void documentd_forcerefresh (std::vector<VARVAL> &res);
void fflush (DOC_WRITER *);
char *fgets(char *s, int size, DOC_READER *r);
#endif
