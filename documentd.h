#ifndef DOCUMENTD_H
#define DOCUMENTD_H

#include <set>

#define CLASS_CHESS	"CHES"
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

struct GAMENOTE{
	std::string script;
	unsigned sequence=0;
	GAMENOTE(PARAM_STRING _script, unsigned _sequence)
		: script(_script.ptr), sequence(_sequence){
	}
};

struct SUBPROGRAM_REQUEST{
	std::string gameid;
	std::string line;
	SUBPROGRAM_REQUEST(PARAM_STRING _gameid, PARAM_STRING _line)
		:gameid(_gameid.ptr), line(_line.ptr){
	}
};

class SUBPROGRAM{
	std::vector<SUBPROGRAM_REQUEST> tosend;
	std::string command;	// shell command to start the program
	std::string gameclass;	// This engine is suitable when gameclass==GAME::getclass()
	pid_t pid=(pid_t)-1;
	int fdin=-1;		// handle to send command
	int fdout=-1;		// Output of the command
	int fderr=-1;		// Errors from the command
	std::string gameid;	// gameid associated with this subprogram
public:
	~SUBPROGRAM();
	SUBPROGRAM(PARAM_STRING _gameclass, PARAM_STRING _command);
	SUBPROGRAM(const SUBPROGRAM &n) = delete;
	SUBPROGRAM(SUBPROGRAM &&n);
	SUBPROGRAM &operator =(const SUBPROGRAM &n) = delete;
	void send(PARAM_STRING gameid, PARAM_STRING line);
	int sendmore ();
	const char *get_gameid() const {
		return gameid.c_str();
	}
	void reset_gameid(){
		gameid.clear();
	}
	bool is_fdout(int no) const {
		return no == fdout;
	}
	bool is_fderr(int no) const {
		return no == fderr;
	}
	int get_fdout() const {
		return fdout;
	}
	int get_fderr() const {
		return fderr;
	}
	const char *getclass() const {
		return gameclass.c_str();
	}
	bool is_class (PARAM_STRING cls){
		return gameclass == cls.ptr;
	}
};

class GAME{
	unsigned sequence=0;	// For notifications
	time_t modified = (time_t)0;
	time_t last_activity = time(nullptr);
	std::string modified_by;
	std::vector<GAMENOTE> notifications;	// Script to send to all active users (users with the game opened and displayed)
	std::set<int> notification_fds;		// Handles waiting for notifications
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
	inline void js_find_loop_set(std::string &lines, const char *prefix, const char *tag, PARAM_STRING id, const char *feature1,
		const char *val1, const char *feature2, const char *val2, const char *feature3, const char *val3){
		lines += string_f ("var elm = document.getElementById('%s-%s');\n",prefix,gameid.c_str());
		lines += "if (elm != null){\n";
		lines += string_f("\tvar elms = elm.getElementsByTagName('%s');\n",tag);
		lines += "\tfor (var i=0; i<elms.length; i++){\n";
		lines += "\t\tvar e = elms[i];\n";
		lines += string_f("\t\tif (e.id == '%s'){\n",id.ptr);
		lines += string_f("\t\t\te.%s='%s';\n",feature1,val1);
		lines += string_f("\t\t\te.%s='%s';\n",feature2,val2);
		lines += string_f("\t\t\te.%s='%s';\n",feature3,val3);
		lines += "\t\t\tbreak;\n";
		lines += "\t\t}\n";
		lines += "\t}\n";
		lines += "}\n";
	}
	inline void js_find_loop_start(std::string &lines, const char *prefix, const char *tag){
		lines += string_f ("var elm = document.getElementById('%s-%s');\n",prefix,gameid.c_str());
		lines += "if (elm != null){\n";
		lines += string_f("\tvar elms = elm.getElementsByTagName('%s');\n",tag);
		lines += "\tif (elms.length > 0){\n";
	}
	inline void js_find_loop_start_class(std::string &lines, const char *prefix, const char *cls){
		lines += string_f ("var elm = document.getElementById('%s-%s');\n",prefix,gameid.c_str());
		lines += "if (elm != null){\n";
		lines += string_f("\tvar elms = elm.getElementsByClassName('%s');\n",cls);
		lines += "\tif (elms.length > 0){\n";
	}
	inline void js_find_loop_end(std::string &lines){
		lines += "\t}\n";
		lines += "}\n";
	}
public:
	unsigned get_nbwait() const {
		return notification_fds.size();
	}
	unsigned get_sequence() const {
		return sequence;
	}
	void add_notification (PARAM_STRING script);
	void add_notification_fd(int fd);
	int del_notification_fd(int fd);
	const char *locate_event (unsigned &sequence);
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
	virtual void manyexec (const std::vector<VARVAL_receive> &steps, const char *session, const char *username, bool maywrite, const DOC_UI_SPECS_receive &sp, std::vector<VARVAL> &res);
	virtual void engine_reply (const char *line, std::string &notify, bool &done);
	virtual ~GAME(){};
};

class TICTACTO: public GAME{
	bool x_is_player;
	unsigned char grid[3][3];
	void update_msg (bool to_all, PARAM_STRING msg, const char *color, std::vector<VARVAL> &res);
public:
	void save(DOC_WRITER &w, bool);
	void load(DOC_READER &r, std::string &msg);
	void resetgame();
	TICTACTO();
	const char *getclass() const;
	void testwin(std::vector<VARVAL> &res);
	void draw_x(unsigned cellx, unsigned celly, std::string &lines, unsigned x, unsigned y, unsigned len, bool visible);
	void draw_o(unsigned cellx, unsigned celly, std::string &lines, unsigned x, unsigned y, unsigned len, bool visible);
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

struct WORD_EFFECTS_STATE{
	bool bold = false;
	bool italic = false;
	bool underline = false;
	bool sup = false;
	bool sub = false;
	bool font1 = false;
};
struct WORD_DOCPOS{
	unsigned line=0;
	unsigned column=0;
	void reset(){
		line = column = 0;
	}
};
// WORDPROC user preference
struct WORD_USERPREF{
	bool maywrite=false;
	unsigned offset=0;	// First line displayed
	WORD_DOCPOS cursor;
	bool insertmode = true;
	WORD_DOCPOS mark1,mark2;	// Cut & Paste
	bool states_valid = false;	// Tell if the UI is in sync with the states variable below
	WORD_EFFECTS_STATE states;
};

enum WORDPROC_LISTTYPE { LIST_NONE, LIST_BULLET,LIST_NUM,LIST_CENTER};

class WORDPROC_LINE{	// Well, a line is a paragraph...
	unsigned char title_level=0;
	unsigned char line_spec=0;	// Used for tables and images
public:
	unsigned char tab_level=0;
	WORDPROC_LISTTYPE listtype=LIST_NONE;
	std::string line;
public:
	WORDPROC_LINE(){}
	WORDPROC_LINE(const std::string &l):line(l){}
	WORDPROC_LINE(const char *l):line(l){}
	bool is_image() const {
		return title_level == 10;
	}
	void set_paragraph_type(unsigned type){
		title_level = type;
	}
	unsigned get_paragraph_type() const{
		return title_level;
	}
	void set_paragraph_spec(unsigned spec){
		line_spec = spec;
	}
	unsigned get_paragraph_spec() const{
		return line_spec;
	}
	void increase_title_level(){
		if (title_level < 4) title_level++;
	}
	void decrease_title_level(){
		if (title_level > 0 && title_level < 5) title_level--;
	}
	void set_image(bool on){
		if (on){
			if (title_level == 0){
				title_level = 10;
				if (line_spec == 0) line_spec = 30;
			}
		}else if (title_level == 10){
			title_level = 0;
		}
	}
	void increase_image_width(){
		if (is_image() && line_spec < 100) line_spec++;
	}
	void decrease_image_width(){
		if (is_image() && line_spec > 0) line_spec--;
	}
	unsigned get_image_width() const {
		return is_image() ? line_spec : 0;
	}
	void set_table(bool on){
		if (on){
			if (title_level == 0){
				title_level = 11;
			}
		}else if (title_level == 11){
			title_level = 0;
		}
	}
	bool is_table() const {
		return title_level == 11;
	}
	bool is_title() const {
		return title_level > 0 && title_level < 4;
	}
	bool std_paragraph() const {
		return title_level == 0;
	}
	unsigned get_title_level() const {
		return title_level < 5 ? title_level : 0;
	}
};

class WORDPROC: public GAME{
	std::vector<WORDPROC_LINE> lines;
	std::map<std::string,WORD_USERPREF> prefs;
	void deletechar(std::set<unsigned> &updlines, WORD_USERPREF &pref);
	void vmove (int move, unsigned visible_lines, unsigned lastline, WORD_USERPREF &pref, const DOC_UI_SPECS_receive &sp, VARVAL &script_var, std::set<unsigned> &updlines);
	void page_up_down(int new_offset, unsigned visible_lines, unsigned lastline, WORD_USERPREF &pref, VARVAL &script_var,
		std::set<unsigned> &script_lines, std::set<unsigned> &notify_lines);
	void update_lines (std::string &line, std::set<unsigned> &updlines);
	std::string formatline (unsigned noline);
	void execstep (const char *var,	const char *val, const char *session, const char *username, bool maywrite, const DOC_UI_SPECS_receive &sp,
		VARVAL &script_var, std::set<unsigned> &script_lines, VARVAL &notify_var, std::set<unsigned> &notify_lines,
		std::vector<VARVAL> &res);
	void set_para_spec(class PARAGRAPH &para, unsigned noline, unsigned column, const DOC_UI_SPECS_receive &sp, unsigned &para_noline);
	void set_para_spec(class PARAGRAPH &para, unsigned noline, const DOC_UI_SPECS_receive &sp);
public:
	const char *getclass() const{
		return "WORD";
	}
	void save(DOC_WRITER &w, bool save_session_info);
	void load(DOC_READER &r, std::string &msg);
	void resetgame();
	void testwin(std::vector<VARVAL> &res);
	void exec (const char *var, const char *val, const char *session, const char *username, bool maywrite, const DOC_UI_SPECS_receive &sp, std::vector<VARVAL> &res);
	void manyexec (const std::vector<VARVAL_receive> &steps, const char *session, const char *username, bool maywrite, const DOC_UI_SPECS_receive &sp, std::vector<VARVAL> &res);
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
struct CHESS_PLAYER{
	unsigned robot_level=0;
	unsigned col=11;
	unsigned line=11;
	std::string name;
	bool king_moved = false;
	bool left_rook_moved = false;
	bool right_rook_moved = false;
	struct{
		unsigned line=10;
		unsigned col=10;
	}lastmove;
	struct{
		unsigned line=10;
		unsigned col=10;
	}en_passant;
	void reset(){
		king_moved = left_rook_moved = right_rook_moved = false;
		reset_sel();
		reset_en_passant();
		reset_lastmove();
	}
	void reset_sel(){
		col = line = 11;
	}
	void reset_en_passant(){
		en_passant.line = en_passant.col = 10;
	}
	bool has_en_passant() const {
		return en_passant.line != 10;
	}
	bool has_lastmove() const {
		return lastmove.line != 10;
	}
	void reset_lastmove(){
		lastmove.line = lastmove.col = 10;
	}
	bool has_selected(){	// Has the player select the piece he wants to move
		return col < 8 && line < 8;
	}
	std::string dump() const;
	bool is_robot() const {
		return robot_level > 0;
	}
};

class CHESSMOVE_EFFECTS;

struct CHESS_COOR{
	unsigned line;
	unsigned col;
	CHESS_COOR(unsigned _line, unsigned _col){
		line = _line;
		col = _col;
	}
};

enum CHESS_UNDO_TYPE {
	CHESS_UNDO_MOVE, CHESS_UNDO_KING_MOVED, CHESS_UNDO_LEFT_ROOK_MOVED, CHESS_UNDO_RIGHT_ROOK_MOVED,
	CHESS_UNDO_EN_PASSANT,CHESS_UNDO_LASTMOVE
};
struct CHESS_UNDO{
	bool player1_playing = false;
	unsigned line=10;
	unsigned col=10;
	char cell=' ';
	CHESS_UNDO_TYPE type;
};
class CHESS: public GAME{
	char grid[8][8];
	CHESS_PLAYER player1,player2;
	bool player1_playing = true;
	std::string message;
	std::vector<CHESS_UNDO> undos;
	std::vector<CHESS_COOR> marked_pieces;
	std::map<std::string,bool> sessions; // Display mode (reverse) per session
	void update_msg (bool to_all, PARAM_STRING msg, const char *color, std::vector<VARVAL> &res);
	bool checkmove (CHESS_PLAYER *player, unsigned to_line, unsigned to_col, CHESS_PLAYER *other_player, CHESSMOVE_EFFECTS &, std::string &error);
	void save_lastmove (CHESS_PLAYER *player);
	void execmove (CHESS_PLAYER *player, CHESS_PLAYER *other_player, unsigned to_line, unsigned to_col, const CHESSMOVE_EFFECTS &);
	bool check_expose(unsigned line, unsigned col, bool king_is_white, std::vector<CHESS_COOR> &pieces);
	bool check_expose(bool king_is_white, std::vector<CHESS_COOR> &pieces);
	void undoone(VARVAL &notify_var);
	void show_marked_pieces (VARVAL &notify_var, const char *color);
	std::string format_fen();
	void robot_request (std::vector<VARVAL> &res);
public:
	const char *getclass() const{
		return CLASS_CHESS;
	}
	void save(DOC_WRITER &w, bool save_session_info);
	void load(DOC_READER &r, std::string &msg);
	void resetgame();
	void testwin(std::vector<VARVAL> &res);
	void exec (const char *var, const char *val, const char *session, const char *username, bool maywrite, const DOC_UI_SPECS_receive &sp, std::vector<VARVAL> &res);
	void engine_reply(const char *line, std::string &notify, bool &done);
};

#define VAR_CONTENT	"content"	// HTML content to display
#define VAR_ERROR	"error"
#define VAR_RESULT	"result"
#define VAR_NOTIFY	"notify"	// Javascript applied to all users
#define VAR_REFRESH	"refresh"	// Trigger a screen refresh
#define VAR_SCRIPT	"script"	// Javascript for this user only
#define VAR_CHANGES	"changes"	// A change was done in the game or document worth telling everyone
#define VAR_ENGINE	"engine"	// A message must be sent to an engine (gnuchess for now) for this game

std::string documentd_escape(PARAM_STRING msg);
void documentd_error (std::vector<VARVAL> &res, PARAM_STRING s);
void documentd_button_start (std::string &line, const std::string &gameid);
void documentd_button_end (std::string &line);
void documentd_button_label (std::string &line, PARAM_STRING txt);
void documentd_button (std::string &lines, unsigned command, PARAM_STRING txt, bool highlit);
struct DOC_BUTTON_SPECS{
	unsigned width = 20;
	unsigned radius = 4;
	unsigned margin_left = 5;
	unsigned margin_top = 2;
	unsigned margin_bottom = 2;
};
void documentd_button (std::string &lines, unsigned command, PARAM_STRING txt, const DOC_BUTTON_SPECS &specs, bool highlit);
void documentd_forcerefresh (std::vector<VARVAL> &res);
void documentd_setchanges (std::vector<VARVAL> &res);
unsigned documentd_displaylen (const char *line, unsigned fontsize, float size);
void fflush (DOC_WRITER *);
char *fgets(char *s, int size, DOC_READER *r);
#endif
