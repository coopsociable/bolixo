#ifndef DOCUMENTD_REQ_H
#define DOCUMENTD_REQ_H

// Request sent to documents
#define REQ_PRINT	"print"
#define REQ_GETFIELDS	"getfields"

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
#define DIALOG_WHITEBOARD_NEW	"newdoc"
#define DIALOG_IMBED		"imbed"
#define CHESS_ROBOT		"--robot--"
#endif
