#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include <string>
#include <vector>

using namespace std;

int main (int argc, char *argv[])
{
	int ret = -1;
	static const char *datafile = "/tmp/eximrm.data";
	FILE *fin = fopen (datafile,"r");
	if (fin == NULL){
		fprintf (stderr,"Can't open file %s (%s)\n",datafile,strerror(errno));
	}else{
		vector<string> tb;
		char line[1000];
		while (fgets(line,sizeof(line)-1,fin)!=NULL){
			tb.push_back(line);
		}
		fclose (fin);
		char *args[tb.size()+1];
		for (unsigned i=0; i<tb.size(); i++){
			string &arg = tb[i];
			while (arg.size() > 0 && isspace(arg[arg.size()-1])) arg.resize(arg.size()-1);
			args[i] = (char*)arg.c_str();
			printf ("arg[%u]=:%s:\n",i,args[i]);
		}
		args[tb.size()] = NULL;
		execv (args[0],args);

	}
	return ret;
}
