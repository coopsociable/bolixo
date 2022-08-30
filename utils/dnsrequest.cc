/*
	Does only a DNS request, used in lxc0-web to make sure the proper librairy are included
*/
#include <stdio.h>
#include <netdb.h>
#include <time.h>

int main ()
{
	// Generate a random name to make sure it does the full protocol each time
	// it is used (goes through cache).
	char name[1000];
	snprintf (name,sizeof(name)-1,"%lu.org",time(nullptr));
	//printf ("name=%s\n",name);
	gethostbyname(name);
	return 0;
}
