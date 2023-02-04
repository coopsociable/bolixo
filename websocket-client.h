#ifndef WEBSOCKET_CLIENT_H
#define WEBSOCKET_CLIENT_H

enum WSS_STATE { WSS_IN_HEADER, WSS_RUNNING};
class HANDLE_WSS{
	CONNECT_HTTP_INFO con;
	std::string challenge;
	std::string session;
	std::vector<std::string> initmsgs;
	WSS_STATE state = WSS_IN_HEADER;
	STREAMP_BUF sbuf;
	void process(bool &endclient, bool &now_running, int clientfd, std::string *msg);
public:
	~HANDLE_WSS();
	void moveconnectinfo(CONNECT_HTTP_INFO &con);
	void setsession(PARAM_STRING sessionid);
	void process(bool &endclient, bool &now_running, int clientfd);
	void process(bool &endclient, bool &now_running, std::string &msg);
	void sendheader(PARAM_STRING hostname);
	void write (const void *buf, size_t size);
	void send (PARAM_STRING line);
	void addinitmsg (PARAM_STRING msg);
};

#endif
