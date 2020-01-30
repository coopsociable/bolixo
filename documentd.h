#ifndef DOCUMENTD_H
#define DOCUMENTD_H

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
	virtual void exec (const char *var, const char *val, const char *session, const char *username, bool maywrite,
		unsigned width, unsigned height, bool mobile, std::vector<VARVAL> &res) = 0;
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
	void exec (const char *var, const char *val, const char *session, const char *username, bool maywrite,
		unsigned win_width, unsigned win_height, bool mobile, std::vector<VARVAL> &res);
};

struct SUDOKU_CELL{
	unsigned char visible;
	unsigned char value;
	unsigned char user_value;
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
	//unsigned line,column;	// Currently selected 3x3 area
	std::map<std::string,unsigned> seldigs; // Selected digit used when setting a value
	std::map<std::string,SUDO_USERPREF> prefs;	// Preferences associated with a user
	unsigned difficulty=0;	// What difficulty was used to initialize the game
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
	void exec (const char *var, const char *val, const char *session, const char *username, bool maywrite,
		unsigned width, unsigned height, bool mobile, std::vector<VARVAL> &res);
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
	void exec (const char *var, const char *val, const char *session, const char *username, bool maywrite,
		unsigned width, unsigned height, bool mobile, std::vector<VARVAL> &res);
};

struct CHECKER_PLAYER{
	unsigned col=10;
	unsigned line=10;
	std::string name;
	void reset(){
		col = line = 10;
		name.clear();
	}
	bool has_selected(){	// Has the player select the piece he wants to move
		return col < 8 && line < 8;
	}
};

class CHECKERS: public GAME{
	unsigned char grid[8][8];
	CHECKER_PLAYER player1,player2;
	bool player1_playing = true;
	void update_msg (PARAM_STRING msg, const char *color, std::vector<VARVAL> &res);
public:
	const char *getclass() const{
		return "CHEC";
	}
	void save(DOC_WRITER &w, bool save_session_info);
	void load(DOC_READER &r, std::string &msg);
	void resetgame();
	void testwin(std::vector<VARVAL> &res);
	void exec (const char *var, const char *val, const char *session, const char *username, bool maywrite,
		unsigned width, unsigned height, bool mobile, std::vector<VARVAL> &res);
};

#define VAR_CONTENT	"content"	// HTML content to display
#define VAR_ERROR	"error"
#define VAR_RESULT	"result"
#define VAR_NOTIFY	"notify"	// Javascript applied to all users
#define VAR_REFRESH	"refresh"	// Trigger a screen refresh
#define VAR_SCRIPT	"script"	// Javascript for this user only

void documentd_error (std::vector<VARVAL> &res, PARAM_STRING s);
void documentd_button (std::string &lines, unsigned command, const char *txt, bool highlit);
void documentd_forcerefresh (std::vector<VARVAL> &res);
void fflush (DOC_WRITER *);
char *fgets(char *s, int size, DOC_READER *r);
#endif
