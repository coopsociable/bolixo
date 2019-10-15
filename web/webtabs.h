#ifndef WEBTABS_H
#define WEBTABS_H

#include <misc.h>
#include <tuple>

#define WEBTAB_MARK '*'

enum WEBTAB_TYPE{
	WEBTAB_TYPE1, WEBTAB_TYPE2, WEBTAB_TYPE3, WEBTAB_TYPE4
};
struct WEBTAB{
	WEBTAB_TYPE type;
	string tab;	// Name of this tab in the webtab
	string title;
	int selorder;
	bool locked;	// Can't be deleted
	string state;	// It is a string set by the application and preserved
			// in the session manager. The state is passed back to the application
	bool notify;	// Use a different color to show there is content to review
	void setargs(PARAM_STRING args){
		vector<string> tb;
		str_splitline(args.ptr,',',tb);
		for (auto &v:tb){
			const char *vs = v.c_str();
			const char *vs2 = vs+2;
			if (strncmp(vs,"f=",2)==0){
				selorder = atoi(vs2);
			}else if (strncmp(vs,"s=",2)==0){
				state = vs2;
			}else if (strncmp(vs,"t=",2)==0){
				title = vs2;
			}else if (strncmp(vs,"l=",2)==0){
				locked = atoi(vs2);
			}
		}
	}
	WEBTAB(){
		type = WEBTAB_TYPE1;
		selorder = 0;
		locked = false;
		notify = false;
	}
	WEBTAB(WEBTAB_TYPE _type, PARAM_STRING _tab, PARAM_STRING _title, PARAM_STRING args){
		selorder = 0;
		type = _type;
		tab = _tab.ptr;
		title = _title.ptr;
		locked = false;
		notify = false;
		setargs(args);
	}
	WEBTAB(PARAM_STRING _tab, PARAM_STRING args){
		selorder = 0;
		if (isdigit(_tab.ptr[0]) && _tab.ptr[1] == ':'){
			type = (WEBTAB_TYPE)(_tab.ptr[0] - '1');
			tab = _tab.ptr+2;
		}else{
			type = WEBTAB_TYPE1;
			tab  = _tab.ptr;
		}
		title.clear();
		locked = false;
		notify = false;
		setargs(args);
	}
	bool operator < (const WEBTAB &n) const {
		return tie(type,tab) < tie(n.type,n.tab);
	}
};
struct WEBTAB_CTRL{
	vector<WEBTAB> tabs;
	unsigned offsets[4];
	WEBTAB_CTRL(){
		for (auto &v:offsets) v=0;
	}
};

#define _TLMP_webtabs
struct _F_webtabs {
	bool redo;
	WEBTAB *curtab;
	string selected_id;
	string help_id;
	string help_title;
	vector<WEBTAB> *tabs;
	int maxsel;
	bool changed;
	int added_tab;
	_F_webtabs(){
		maxsel = 0;
		tabs = NULL;
		redo = false;
		curtab = NULL;
		changed = false;
		added_tab = -1;
	}
	void setid (PARAM_STRING id);	// Change the ID of the active TAB
	void sethelp();			// Set the context help button
	void sethelp(PARAM_STRING id, PARAM_STRING title);
	void settitle (PARAM_STRING title);	// Change the title of the active TAB
	void setstate (PARAM_STRING val);// Record some value for the active TAB
	const char *getstate() const;	// Return the state previously stored for the active TAB
	void redotab ();		// Ask webtabs to redraw the current TAB
	bool selected(PARAM_STRING id);
	void addtab (PARAM_STRING id, PARAM_STRING txt);
	#define _F_webtabs_documents(x) void x documents()
	virtual _F_webtabs_documents( );
	#define _F_webtabs_docmain(x) void x docmain(const char *id, const char *formid, const char *state)
	virtual _F_webtabs_docmain( )=0;
	#define _F_webtabs_doctype2(x) void x doctype2(const char *id, const char *formid, const char *state, const char *title)
	virtual _F_webtabs_doctype2( );
	#define _F_webtabs_doctype3(x) void x doctype3(const char *id, const char *formid, const char *state)
	virtual _F_webtabs_doctype3( );
	#define _F_webtabs_doctype4(x) void x doctype4(const char *id, const char *formid, const char *state)
	virtual _F_webtabs_doctype4( );
	#define _F_webtabs_init(x) void x init()
	virtual _F_webtabs_init( );
};

void webtabs(_F_webtabs &c,
	const char *name,
	map<string,WEBTAB_CTRL> &tabs,
	unsigned size[5]);
void webtabs(_F_webtabs &c,
	const char *name,
	const vector<string> &starttabs,
	map<string,WEBTAB_CTRL> &alltabs,
	unsigned size[5]);

unsigned webtabs_getsubtab();
void webtabs_forcevar(PARAM_STRING val);
#endif
