#ifndef DOC_CALC_H
#define DOC_CALC_H

struct CALC_CELL{
	std::string text;
	bool value_valid = false;
	double value;
	CALC_CELL(){};
	CALC_CELL(PARAM_STRING _text)
		:text(_text.ptr){}
};


struct CELL_COOR{
	unsigned short line=0;
	unsigned short col=0;
	CELL_COOR(){}
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
struct CALC_PREF{
	unsigned offset_x=0;
	unsigned offset_y=0;
	MOD_KBD mod;
	CELL_COOR cursor;
};

class CALC: public GAME{
	// Spreadsheet are often sparse. So we store only cells with some content.
	std::map<CELL_COOR,CALC_CELL> grid;
	void execstep (const char *var, const char *val, const DOC_CONTEXT &ctx, const DOC_UI_SPECS_receive &sp,
		VARVAL &script_var, VARVAL &notify_var, std::set<CELL_COOR> &notify_ids, std::vector<VARVAL> &res);
	std::string draw_board (const DOC_CONTEXT &ctx, unsigned vx, unsigned vy, 
		unsigned board_width, unsigned board_height, unsigned fontsize, unsigned docnum, bool editmode, std::string &script);
	std::string define_functions(const DOC_CONTEXT &ctx, const CALC_PREF &pref, unsigned board_width, unsigned board_height);
	std::string define_styles(const DOC_CONTEXT &ctx, const DOC_UI_SPECS_receive &sp);
	void update_msg (bool to_all, PARAM_STRING msg, const char *color, std::vector<VARVAL> &res);
	std::map<std::string,CALC_PREF> prefs;	// Per session state
	void setfocus(VARVAL &var);
	void update_cells(std::set<CELL_COOR> &cells, VARVAL &var);
	void update_cellname(CALC_PREF &pref, VARVAL &var);
public:
	void save(DOC_WRITER &w, bool);
	void load(DOC_READER &r, std::string &msg);
	void resetgame();
	CALC();
	const char *getclass() const;
	void testwin(std::vector<VARVAL> &res);
	void exec (const char *var, const char *val, const DOC_CONTEXT &ctx, const DOC_UI_SPECS_receive &sp, std::vector<VARVAL> &res);
	void manyexec (const std::vector<VARVAL_receive> &steps, const DOC_CONTEXT &ctx, const DOC_UI_SPECS_receive &sp, std::vector<VARVAL> &res);
};

#endif
