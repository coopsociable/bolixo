#ifndef EXTERN
#define EXTERN extern
#endif

EXTERN DOC_ID section_lxc0;
EXTERN DOC_ID section_protocheck;
EXTERN DOC_ID section_keysd;
EXTERN DOC_ID section_remote_accounts;
EXTERN DOC_ID section_bosqlduser;
EXTERN DOC_ID section_bosqlddata;

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
