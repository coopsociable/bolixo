#pragma implementation
#include "bolixo.h"

// Keys for boxml

const unsigned char K_BOLIXO[]="bolixo";
const unsigned char K_USER[]="user";
const unsigned char K_PASSW[]="passw";
const unsigned char K_DOCUMENT[]="document";
const unsigned char K_DOCUMENTID[]="documentid";
const unsigned char K_NODE[]="node";
const unsigned char K_NODEID[]="nodeid";
const unsigned char K_IMAGE[]="image";
const unsigned char K_RELATE[]="relate";
const unsigned char K_RELATION[]="relation";
const unsigned char K_RELATIONID[]="relationid";
const unsigned char K_NAME[]="name";
const unsigned char K_ALTNAME[]="altname";
const unsigned char K_ID[]="id";
const unsigned char K_USERID[]="userid";
const unsigned char K_OWNERID[]="ownerid";
const unsigned char K_OWNER[]="owner";
const unsigned char K_DESCRIPTION[]="description";
const unsigned char K_MODIF[]="modif";
const unsigned char K_UUID[]="uuid";
const unsigned char K_UUID1[]="uuid1";
const unsigned char K_UUID2[]="uuid2";
const unsigned char K_OLDNODE[]="oldnode";
const unsigned char K_DELNODE[]="delnode";
const unsigned char K_OLDRELATION[]="oldrelation";
const unsigned char K_DELRELATION[]="delrelation";
const unsigned char K_TYPE[]="type";
const unsigned char K_ORDERPOL[]="orderpol";
const unsigned char K_ORDERKEY[]="orderkey";

// Commands for bolixo protocol
const char C_LOGIN[]="login";
const char C_LISTDOC[]="listdoc";
const char C_SELDOC[]="seldoc";
const char C_LISTNODES[]="listnodes";
const char C_LISTRELS[]="listrels";
const char C_GETNODE[]="getnode";
const char C_GETREL[]="getrel";
const char C_GETALL[]="getall";
const char C_DOCCHANGED[]="docchanged";
const char C_DELRELATION[]="delrelation";
const char C_DELNODE[]="delnode";
const char C_GETROOT[]="getroot";
const char C_GETCHILD[]="getchild";
const char C_GETCHILDF[]="getchildf";
const char C_GETORPHAN[]="getorphan";
const char C_PING[]="ping";
const char C_XMLPING[]="xmlping";

const char ROOTUUID[]="root";
const char XMLINTRO[]="<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n<bolixo>\n";
const char XMLEND[]="</bolixo>\n";
const char SIMPLE_HTML[]="text/shtml";
const char DATA[]="data";
const char REL_ATTRIBUT[]="attribut";


// Constant for bolixo.conf
const char D_DEFAULT[]="default";
const char D_SERVER[]="server";
const char D_PORT[]="port";
const char D_USER[]="user";
const char D_PASSWORD[]="password";



