/*
	Does only a DNS request, used in lxc0-web to make sure the proper librairy are included
*/
#include <stdio.h>
#include <netdb.h>

int main ()
{
	gethostbyname("bolixo.org");
	return 0;
}
