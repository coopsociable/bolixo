Summary: bolixo
Name: bolixo
Version: REV
Release: 1
license: GPL
Vendor: Solucorp
Group: Networking/util
Source0: bolixo-REV.src.tar.gz
BuildRoot: /var/tmp/bolixo
BuildRequires: tlmp-devel mariadb-devel trlitool tlmpsql tlmpweb
Requires: mariadb-libs tlmp tlmpsql trlitool tlmpweb

%description
Bolixo is a distributed social media. This package includes everything
to run a node.

%prep
%setup 

%build
make BUILD_SVNVER=REV compile

%install
if [ "$RPM_BUILD_ROOT" != "" ] ; then
	rm -rf $RPM_BUILD_ROOT
fi
mkdir -p $RPM_BUILD_ROOT/usr/sbin
export RPM_BUILD_ROOT
make install

%files
%defattr(-,root,root)
/usr/share/bolixo/secrets.admin
/usr/share/bolixo/secrets.client
/usr/sbin/bod
/usr/sbin/bod-control
/usr/sbin/bod-client
/usr/sbin/bo-writed
/usr/sbin/bo-writed-control
/usr/sbin/bo-sessiond
/usr/sbin/bo-sessiond-control
/usr/sbin/bolixod
/usr/sbin/bolixod-control
/usr/sbin/bo-keysd
/usr/sbin/bo-keysd-control
/usr/sbin/bo-manager
/usr/bin/bofs
/usr/lib/tlmp/help.eng/bolixo.eng
/usr/lib/tlmp/help.fr/bolixo.fr
/var/www/html/index.hc
/var/www/html/public.hc
/var/www/html/bolixo.hc
/var/www/html/webapi.hc
/var/www/html/bolixoapi.hc
/var/www/html/.tlmplibs
/var/www/html/private.png
/usr/lib/bolixo-test.sh
/usr/sbin/bolixo-production
/etc/bolixo/http_check.conf
/etc/init.d/bolixoserv
/var/www/html/about.html
/var/www/html/favicon.ico
/var/www/html/robots.txt
/var/log/bolixo
%attr(-,bolixo,bolixo)/var/lib/bolixo

%clean
if [ "$RPM_BUILD_ROOT" != "" ] ; then
	rm -rf $RPM_BUILD_ROOT
fi

%post

id bolixo >/dev/null 2>/dev/null || useradd -r bolixo
chkconfig --add bolixoserv

%postun

%pre

%preun



