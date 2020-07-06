#ifndef DOC_CALC_H
#define DOC_CALC_H

enum CALC_TOK{
	TOK_NUMBER,
	TOK_CELL,
	TOK_OPNPAR,
	TOK_CLSPAR,
	TOK_PLUS,
	TOK_MINUS,
	TOK_MULT,
	TOK_DIV,
	TOK_MODULO,
	TOK_COMMA,
	TOK_COLON,
	TOK_SEMICOL,
	TOK_EQUAL,
	TOK_NOTEQUAL,
	TOK_STRING,
	TOK_SMALLER,
	TOK_SMALLEREQ,
	TOK_GREATER,
	TOK_GREATEREQ,
	TOK_KEYWORD,
	TOK_FUNCTION,
	TOK_IF,
	TOK_ERROR,
	TOK_EOL,
};

enum CALC_OPER{
	CALC_OPER_NONE,
	CALC_FUNC_SUM,
	CALC_FUNC_AVG,
	CALC_FUNC_MAX,
	CALC_FUNC_MIN,
};

struct CELL_COOR{
	unsigned short line=0;
	unsigned short col=0;
	CELL_COOR(){}
	CELL_COOR(const CELL_COOR &c) = default;
	CELL_COOR(unsigned short _line, unsigned short _col)
		:line(_line), col(_col){}
	bool operator < (const CELL_COOR &c) const {
		return std::tie(line,col) < std::tie(c.line,c.col);
	}
	bool operator == (const CELL_COOR &c) const {
		return std::tie(line,col) == std::tie(c.line,c.col);
	}
	bool operator != (const CELL_COOR &c) const {
		return std::tie(line,col) != std::tie(c.line,c.col);
	}
	std::string tostring() const;
};
enum EVAL_TYPE {EVAL_VAL, EVAL_SEMI, EVAL_BEGIN, EVAL_RANGE};
struct EVALELM{
	EVAL_TYPE type;
	double val=0;
	CELL_COOR coor;
	EVALELM(EVAL_TYPE _type, double _val): type(_type), val(_val){}
	EVALELM(EVAL_TYPE _type, double _val, const CELL_COOR &_coor): type(_type), val(_val),coor(_coor){}
};
struct CALC_TOKEN {
	CALC_TOK token;
	CALC_OPER oper = CALC_OPER_NONE;
	CELL_COOR coor;		// Translation of a TOK_CELL
	std::string text;
};

enum CELL_STATE {
	CELL_STATE_UNKNOWN,
	CELL_STATE_NUM,
	CELL_STATE_TEXT,
	CELL_STATE_FORMULAERR,	// The cell contains an invalid formula (syntax error)
	CELL_STATE_FORMULA,	// The cell contains a formula, not evaluated
	CELL_STATE_COMPUTING,	// formula evaluation in progress. This is used to trigger loops in formula 
	CELL_STATE_EVALED,	// The formula has been evaluated
	CELL_STATE_LAST		// Not a state, just to size a table in dump
};
struct CALC_CELL{
	std::string text;
	CELL_STATE state = CELL_STATE_UNKNOWN;
	double value=nan("");		// The result of the formula evaluation or simply the translation of 'text'.
	std::vector<CALC_TOKEN> steps;	// Steps to evaluate a formula
	CALC_CELL(){};
	CALC_CELL(PARAM_STRING _text)
		:text(_text.ptr){}
	CALC_CELL(const CALC_CELL &n) = default;
	void eval0();
	std::string gettext(unsigned precision) const;
	const char *getcolor() const;	// Return the text color
	const char *getalign() const;	// Return the textAlign value
	void reformat();		//  Use the steps to rebuild the text formula (generally use after applyoffset());
	void applyoffset (CELL_COOR &coor, int offset_line, int offset_col);
};

enum COL_ALIGN{
	COL_DEFAULT,	// Alignment controled by type
	COL_LEFT,
	COL_CENTER,
	COL_RIGHT
};
struct CALC_COL_FORMAT{
	unsigned short width=100;
	unsigned char precision=2;	// Precision for numbers
	COL_ALIGN align=COL_DEFAULT;
	bool is_default() const {
		return width == 100 && precision == 2 && align == COL_DEFAULT;
	}
};

struct CALC_PREF{
	unsigned offset_line=0;
	unsigned offset_col=0;
	MOD_KBD mod;
	CELL_COOR cursor = CELL_COOR((unsigned short)-1,(unsigned short)-1);
	bool is_modified() const {
		return offset_line != 0 || offset_col != 0 || cursor.line != (unsigned short)-1 || cursor.col != (unsigned short)-1;
	}
	void reset(){
		offset_line = offset_col = 0;
		cursor.line = cursor.col = 0;
	}
};

class CALC: public GAME{
	// Spreadsheet are often sparse. So we store only cells with some content.
	std::map<CELL_COOR,CALC_CELL> grid;
	std::map<unsigned,CALC_COL_FORMAT> col_formats;		// Most columns use standard format
	void execstep (const char *var, const char *val, const DOC_CONTEXT &ctx, const DOC_UI_SPECS_receive &sp,
		VARVAL &script_var, VARVAL &notify_var, std::set<CELL_COOR> &notify_ids, std::vector<VARVAL> &res,
		std::string &error, std::string &status);
	std::string draw_board (const DOC_CONTEXT &ctx, CALC_PREF &pref, 
		unsigned board_width, unsigned board_height, unsigned fontsize, unsigned docnum, bool editmode, const CELL_COOR &area, std::string &script);
	std::string define_functions(const DOC_CONTEXT &ctx, const CALC_PREF &pref, unsigned board_width, unsigned board_height);
	std::string define_styles(const DOC_CONTEXT &ctx, const DOC_UI_SPECS_receive &sp);
	void update_msg (bool to_all, PARAM_STRING msg, const char *color, std::vector<VARVAL> &res);
	std::map<std::string,CALC_PREF> prefs;	// Per session state
	void setfocus(VARVAL &var);
	void update_cells(std::set<CELL_COOR> &cells, VARVAL &var, bool optim);
	void update_cellname(CALC_PREF &pref, VARVAL &var);
	void update_celledit(CALC_PREF &pref, VARVAL &var);
	void update_lines_cols(CALC_PREF &pref, const CELL_COOR &old, const CELL_COOR &new_pos, VARVAL &var);
	void update_onecell (CALC_PREF &pref, PARAM_STRING buf);
	void reset_eval();
	double evalformula(const std::vector<CALC_TOKEN> &steps, std::string &error);
	void eval (std::set<CELL_COOR> &cells, std::string &error);
	void walkrange(const CELL_COOR &from, const CELL_COOR &to, std::string &error, std::function<void(const CALC_CELL &)> f);
	void evalfinal (CALC_CELL &cell, std::string &error);
	void walkstack (std::stack<EVALELM> &st, std::string &error, std::function<void(double value)> f);
	void dump() const;
	void update_col_width(VARVAL &var, unsigned col);
	void update_offsets(VARVAL &var, const DOC_CONTEXT &ctx, CALC_PREF &pref);
	void insert_line_col(unsigned line, unsigned col, int offline, int offcol);
	void insert_line(VARVAL &var, unsigned line);
	void insert_col(VARVAL &var, unsigned col);
	void delete_line_col(unsigned line, unsigned col, int offline, int offcol);
	void delete_line(VARVAL &var, unsigned line);
	void delete_col(VARVAL &var, unsigned col);
	void vscroll (VARVAL &var, CALC_PREF &pref, int move);
	void hscroll (VARVAL &var, CALC_PREF &pref, int move);
public:
	void save(DOC_WRITER &w, bool);
	void load(DOC_READER &r, std::string &msg);
	void resetgame();
	CALC();
	const char *getclass() const;
	void testwin(std::vector<VARVAL> &res);
	void exec (const char *var, const char *val, const DOC_CONTEXT &ctx, const DOC_UI_SPECS_receive &sp, std::vector<VARVAL> &res);
	void manyexec (const std::vector<VARVAL_receive> &steps, const DOC_CONTEXT &ctx, const DOC_UI_SPECS_receive &sp, std::vector<VARVAL> &res);
	void remove_session(const char *session);
	friend void calc_eval(int argc, char *argv[]);
};

bool calc_parserange (PARAM_STRING line, CELL_COOR &start, CELL_COOR &end);
#endif
