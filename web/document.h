#ifndef EXTERN
#define EXTERN extern
#endif

EXTERN DOC_ID section_none;
EXTERN DOC_ID section_talk;
EXTERN DOC_ID section_project;
EXTERN DOC_ID section_account;
EXTERN DOC_ID section_groups;
EXTERN DOC_ID section_projects;
EXTERN DOC_ID section_contacts;
EXTERN DOC_ID section_contact_req;
EXTERN DOC_ID section_mails;
EXTERN DOC_ID section_interests;
EXTERN DOC_ID section_preview;
EXTERN DOC_ID section_why;

void jump2app (int step, const char *webtab_add);
void jump2app (int step, int tab);
