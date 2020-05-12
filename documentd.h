#ifndef DOCUMENTD_H
#define DOCUMENTD_H

#include <set>
#include <memory>

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
	unsigned nbsend=0;	// Number of request sent to the engine
	unsigned nbrec=0;	// Number of lines received from the engine
	void subswap(SUBPROGRAM &&n);
public:
	~SUBPROGRAM();
	SUBPROGRAM(PARAM_STRING _gameclass, PARAM_STRING _command);
	SUBPROGRAM(const SUBPROGRAM &n) = delete;
	SUBPROGRAM(SUBPROGRAM &&n);
	SUBPROGRAM &operator =(const SUBPROGRAM &n) = delete;
	SUBPROGRAM &operator =(SUBPROGRAM &&n);
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
	const char *getcommand() const {
		return command.c_str();
	}
	const char *getgameid() const {
		return gameid.c_str();
	}
	unsigned getnbrec() const {
		return nbrec;
	}
	unsigned getnbsend() const {
		return nbsend;
	}
	void inc_nbrec(){
		nbrec++;
	}
	bool is_class (PARAM_STRING cls){
		return gameclass == cls.ptr;
	}
};

struct CHATLINE{
	time_t time;
	std::string line;
	CHATLINE(time_t _time, PARAM_STRING _line)
		:time(_time),line(_line.ptr){
	}
};
template<typename T> void documentd_copychat(std::vector<T> &dst, const std::vector<CHATLINE> &src)
{
	for (auto &c:src){
		T t;
		t.time = c.time;
		t.line = c.line;
		dst.emplace_back(std::move(t));
	}
}
class GAME{
	unsigned sequence=1;	// For notifications
	time_t modified = (time_t)0;
	time_t last_activity = time(nullptr);
	std::string modified_by;
	std::vector<GAMENOTE> notifications;	// Script to send to all active users (users with the game opened and displayed)
	std::map<int,std::string> notification_fds;	// Handles waiting for notifications (with username)
	bool has_waiting_users = false;		// Does this game display the list of waiting/connected users
	std::set<std::string> last_waitings;	// Last set of connected users sent.
protected:
	std::vector<CHATLINE> chat;
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
	// Used when declaring an update function. The function has an argument called id
	// and must perform updates on a variable named 'e'
	// if tag is "tag", it is taken as a javascript variable named tag.
	// if tag is not "tag", it is an SVG type.
	inline void js_find_loop_set_META(std::string &lines, const char *prefix, const char *tag){
		lines += string_f ("\tvar elm = document.getElementById('%s-%s');\n",prefix,gameid.c_str());
		lines += "\tif (elm != null){\n";
		const char *quote = strcmp(tag,"tag")==0 ? "" : "\"";
		lines += string_f("\t\tvar elms = elm.getElementsByTagName(%s%s%s);\n",quote,tag,quote);
		//lines += string_f("\t\tconsole.log('%s.length='+elms.length);\n",tag);
		lines += "\t\tfor (var i=0; i<elms.length; i++){\n";
		lines += "\t\t\tvar e = elms[i];\n";
		lines += "\t\t\tif (e.id == id){\n";
	}
	inline void js_find_loop_set_end_META(std::string &lines){
		lines += "\t\t\t\tbreak;\n";
		lines += "\t\t\t}\n";
		lines += "\t\t}\n";
		lines += "\t}\n";
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
	void appendchat(PARAM_STRING line, std::string &notify);
	void appendchat(PARAM_STRING line, std::string &notify, std::vector<VARVAL> &res);
	std::string format_draw_waiting (const std::set<std::string> &waitings);
	void draw_waiting_users(std::string &lines, unsigned width, unsigned height, const char *style);
public:
	unsigned get_nbwait() const {
		return notification_fds.size();
	}
	unsigned get_sequence() const {
		return sequence;
	}
	void add_notification (PARAM_STRING script);
	void add_notification_fd(int fd, const char *username);
	std::set<std::string> get_waiting_users();
	void update_waiting_users(std::string &lines);
	int del_notification_fd(int fd);
	const char *locate_event (unsigned &sequence);
	void setgameid(PARAM_STRING _gameid){
		gameid = _gameid.ptr;
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
	virtual ~GAME();
};

using GAME_P = std::shared_ptr<GAME>;

GAME_P make_TICTACTO();
GAME_P make_SUDOKU();
GAME_P make_WORDPROC();
GAME_P make_WHITEBOARD();
GAME_P make_CHECKERS();
GAME_P make_CHESS();



#include "documentd_req.h"

std::string documentd_escape(PARAM_STRING msg);
void documentd_error (std::vector<VARVAL> &res, PARAM_STRING s);
void documentd_button_start (std::string &line, const std::string &gameid);
void documentd_button_end (std::string &line);
void documentd_button_space (std::string &line);
void documentd_button_label (std::string &line, PARAM_STRING txt);
void documentd_button (std::string &lines, unsigned command, PARAM_STRING txt, bool highlit);
struct DOC_BUTTON_SPECS{
	unsigned width = 25;
	unsigned radius = 4;
	unsigned margin_left = 5;
	unsigned margin_top = 2;
	unsigned margin_bottom = 2;
};
void documentd_button (std::string &lines, unsigned command, PARAM_STRING txt, const DOC_BUTTON_SPECS &specs, bool highlit);
void documentd_bar_button (std::string &lines, unsigned command, PARAM_STRING txt, const DOC_BUTTON_SPECS &specs, bool highlit);
void documentd_forcerefresh (std::vector<VARVAL> &res);
void documentd_setchanges (std::vector<VARVAL> &res);
void documentd_chat(std::string &lines, PARAM_STRING username, const std::vector<CHATLINE> &content, unsigned width, unsigned height);
void documentd_parsefields (const char *val, std::vector<VARVAL> &fields);
unsigned documentd_displaylen (const char *line, unsigned fontsize, float size);
const char *documentd_getflag(const char *flag);
void fflush (DOC_WRITER *);
char *fgets(char *s, int size, DOC_READER *r);
unsigned chess_getmaxskill();
void chess_setmaxskill(unsigned maxskill);
void wordproc_set_gamepress(std::string &lines);
struct MOD_KBD{
	bool ctrl = false;
	bool shift = false;
	bool alt = false;
};
void wordproc_kbd (const char *val, MOD_KBD &mod, std::string &var, std::string &newval, unsigned &lastline);
size_t utf8_codepoint_size(uint8_t text);
#endif
