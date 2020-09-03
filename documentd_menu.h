#include <string>
struct DOC_BUTTON_SPECS{
	unsigned width = 25;
	unsigned radius = 4;
	unsigned margin_left = 5;
	unsigned margin_top = 2;
	unsigned margin_bottom = 2;
};
struct WHITEBOARD_MENU{
	std::string svg_clear;
	std::string svg_text;
	std::string svg_ellipse;
	std::string svg_rect;
	std::string svg_line;
	std::string svg_handline;
	std::string svg_select;
	std::string svg_star;
	std::string svg_parent;
	std::string svg_dashrect;
	std::string svg_linetype;
	std::string svg_textpos;
	std::string svg_image;
	std::string svg_imbed;
	std::string svg_inctextsize;
	std::string svg_dectextsize;
	std::string svg_delitems;
	std::string svg_undo;
	WHITEBOARD_MENU(DOC_BUTTON_SPECS &specs);
};
struct WORDPROC_MENU{
	std::string svg_image;
	std::string svg_imbed;
	WORDPROC_MENU(DOC_BUTTON_SPECS &specs);
};
struct CALC_MENU{
	std::string svg_clear;
	CALC_MENU(DOC_BUTTON_SPECS &specs);
};
