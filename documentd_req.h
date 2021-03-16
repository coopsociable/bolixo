#ifndef DOCUMENTD_REQ_H
#define DOCUMENTD_REQ_H

// Request sent to documents
#define REQ_PRINT	"print"
#define REQ_FOCUS	"focus"
#define REQ_GETFIELDS	"getfields"
#define REQ_FUNCTIONS	"functions"
#define REQ_STYLES	"styles"
#define REQ_REGION	"region"
#define REQ_LISTREGION	"listregion"
#define REQ_CHAT	"chat"

// Results produced by documents
#define VAR_CONTENT	"content"	// HTML content to display
#define VAR_ERROR	"error"
#define VAR_RESULT	"result"
#define VAR_NOTIFY	"notify"	// Javascript applied to all users
#define VAR_REFRESH	"refresh"	// Trigger a screen refresh
#define VAR_SCRIPT	"script"	// Javascript for this user only
#define VAR_CHANGES	"changes"	// A change was done in the game or document worth telling everyone
#define VAR_ENGINE	"engine"	// A message must be sent to an engine (gnuchess for now) for this game
#define VAR_DIALOG	"dialog"	// A dialog must be presented by the UI
#define VAR_FIELDS	"fields"	// Content for a dialog
#define VAR_STYLES	"styles"	// Used to retrieve the styles for a document (uses for embedding)
#define VAR_DEFSCRIPT	"defscript"	// Used to retrieve all js functions for support a document (used for embedding)

// Various per document dialog
#define DIALOG_CHESS_CONFIG	"config"
#define DIALOG_CHESS_NEWGAME	"newgame"
#define DIALOG_WHITEBOARD_NEW	"newwhite"
#define DIALOG_CALC_NEW		"newcalc"
#define DIALOG_CALC_INSCOLLINE	"inscolline"
#define DIALOG_CALC_FORMATCELL	"formatcell"
#define DIALOG_IMBED		"imbed"
#define DIALOG_IMAGE		"image"
#define CHESS_ROBOT		"--robot--"
#define DIALOG_PHOTOS_CONFIG	"photoconfig"
#define DIALOG_PHOTOS_TXTEDIT	"phototxtedit"
#define DIALOG_VIDCONF_CONFIG	"vidconfconfig"
#endif
