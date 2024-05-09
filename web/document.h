#ifndef EXTERN
#define EXTERN extern
#endif

EXTERN DOC_ID section_none;
EXTERN DOC_ID section_intro;
EXTERN DOC_ID section_main;
EXTERN DOC_ID section_talk;
EXTERN DOC_ID section_project;
EXTERN DOC_ID section_account;
EXTERN DOC_ID section_notifications;
EXTERN DOC_ID section_groups;
EXTERN DOC_ID section_projects;
EXTERN DOC_ID section_documents;
EXTERN DOC_ID section_tictacto;
EXTERN DOC_ID section_sudoku;
EXTERN DOC_ID section_checker;
EXTERN DOC_ID section_chess;
EXTERN DOC_ID section_wordproc;
EXTERN DOC_ID section_whiteboard;
EXTERN DOC_ID section_calc;
EXTERN DOC_ID section_whiteboard_operations;
EXTERN DOC_ID section_contacts;
EXTERN DOC_ID section_contact_req;
EXTERN DOC_ID section_mails;
EXTERN DOC_ID section_interests;
EXTERN DOC_ID section_preview;
EXTERN DOC_ID section_why;
EXTERN DOC_ID section_profile;
EXTERN DOC_ID section_started;
EXTERN DOC_ID section_ui;
EXTERN DOC_ID section_publish;
EXTERN DOC_ID section_photos;
EXTERN DOC_ID section_vidconf;
EXTERN DOC_ID section_msgformat;

#define SECTION_NONE 0
#define SECTION_TALK 1
#define SECTION_PROJECT 2
#define SECTION_ACCOUNT 3
#define SECTION_GROUPS 4
#define SECTION_PROJECTS 5
#define SECTION_CONTACTS 6
#define SECTION_MAILS 7
#define SECTION_INTERESTS 8
#define SECTION_CONTACT_REQ 9
#define SECTION_PREVIEW 10
#define SECTION_NOTIFICATIONS 11
#define SECTION_DOCUMENTS 12
#define SECTION_TECH 13
#define SECTION_NBSECTIONS 14

void jump2app (int step, PARAM_STRING webtab_add);
void jump2app (int step, int tab);
void jump_config_account();
void jump_config_notifications();
void jump_config_interests();
void jump_config_contacts();
void jump_config_contact_req();
void jump_config_projects();
void jump_config_groups();
void document_clickable_img (PARAM_STRING url, const char *image_width, unsigned border);
void document_clickable_link (PARAM_STRING url, PARAM_STRING txt);
extern bool document_button_display_only;
void document_draw_menu();
void button(const std::string &svg, const char *txt);
void buttons(const std::vector<const string*> &svgs, const char *txt);

