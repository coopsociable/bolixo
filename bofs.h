#ifndef BOFS_H
#define BOFS_H

struct CONTEXT{
	std::string email;
	std::string user;
	std::string password;
	std::string sessionid;	// Session ID for the internal protocol
	std::string hsessionid;	// Session ID for the https protocol
	std::string threshold;	// Date to filter in the history of a directory or files
	bool preset_session;	// We received the session id from the command line
				// so logout is not needed.
	CONNECT_INFO con;
	CONNECT_INFO con_sess;
	CONNECT_HTTP_INFO hcon;
	CONTEXT();
	~CONTEXT();
	int login();
	int hlogin();
	bool is_internal(){
		return con.port.size() > 0;
	}
};

int bofs_vidconf (CONTEXT &ctx, int argc, char *argv[]);

#endif

