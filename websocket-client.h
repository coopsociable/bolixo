#ifndef WEBSOCKET_CLIENT_H
#define WEBSOCKET_CLIENT_H

enum WSS_STATE { WSS_IN_HEADER, WSS_RUNNING};
struct HANDLE_WSS{
	CONNECT_HTTP_INFO con;
	std::string challenge;
	std::string session;
	std::vector<std::string> initmsgs;
	WSS_STATE state = WSS_IN_HEADER;
	STREAMP_BUF sbuf;
	~HANDLE_WSS();
	void process(bool &endclient, bool &now_running, int clientfd);
	void sendheader(PARAM_STRING hostname);
	void send (PARAM_STRING line);
	void addinitmsg (PARAM_STRING msg);
};

#endif
