extern W_UNSIGNED w_robot;
extern W_UNSIGNED w_order;
extern W_UNSIGNED w_test;
extern W_SSTRING w_email;
extern W_SSTRING w_password;

extern W_SSTRING new_nickname;
extern W_SSTRING new_email;
extern W_SSTRING new_password1;
extern W_SSTRING new_password2;

extern W_SSTRING w_content;
extern W_SSTRING w_filename;
extern W_SSTRING w_confirm;

extern W_SSTRING w_list;
extern W_SSTRING w_group;
extern W_UNSIGNED w_add;
extern W_SSTRING w_desc;
extern W_SSTRING w_group1;
extern W_SSTRING w_group2;
extern W_SSTRING w_group3;
extern W_SSTRING w_group4;
extern W_SSTRING w_access1;
extern W_SSTRING w_access2;
extern W_SSTRING w_access3;
extern W_SSTRING w_access4;
extern W_UNSIGNED w_publish;
extern W_UNSIGNED w_bosite;
extern W_UNSIGNED w_photo;
extern W_UNSIGNED w_miniphoto;
extern W_SSTRING w_address1;
extern W_SSTRING w_address2;
extern W_SSTRING w_city;
extern W_SSTRING w_state;
extern W_SSTRING w_country;
extern W_SSTRING w_zipcode;
extern W_SSTRING w_phone;
extern W_SSTRING w_fax;
extern W_SSTRING w_website;
extern W_SSTRING w_interest;
extern W_SSTRING w_lang;
extern W_SSTRING w_public_dir;
extern W_UNSIGNED w_public_view;
extern W_SSTRING w_dateformat;
extern W_UNSIGNED w_anon_messages;
extern W_SSTRING w_timezone;

extern W_SSTRING w_recipients;
extern W_SSTRING w_upload;
extern W_SSTRING w_accept;
extern W_SSTRING w_user;
extern W_SSTRING w_name;
extern W_SSTRING w_image;

extern W_SSTRING w_action;

extern W_UNSIGNED w_notify_ui;
extern W_UNSIGNED w_notify_email;

extern string w_session;

const unsigned MENU_COPY=1;
const unsigned MENU_PASTE=2;
const unsigned MENU_DELETE=3;
const unsigned MENU_PREVIEW=4;
const unsigned MENU_HELPPREVIEW=5;
const unsigned MENU_UNDELETE=6;
const unsigned MENU_RENAME=7;
const unsigned MENU_REPLY=8;
const unsigned MENU_NOTIFICATIONS=9;
const unsigned MENU_OPENINTAB=10;
const unsigned MENU_OPENINBTAB=11;
const unsigned MENU_EDITITEM=12;
const unsigned MENU_QUOTEREPLY=13;
const unsigned MENU_DOWNLOAD=100;

// Special DIV class used to control the layout
#define TAB_FORM "tab_form"	// TAB_FORM are computed and the rest is allocated to webtable
#define TAB_SUBTABS "subtabs"	// The padding and margins are computed and inner webtable get the remainging spaces
extern USERLOGINFO userinfo;
extern map<string,unsigned> offsets;
extern map<string,unsigned> currents;
extern map<string,WEBTAB_CTRL> tabs;
