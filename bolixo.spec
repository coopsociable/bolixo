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
Requires: mariadb-connector-c tlmp tlmpsql trlitool tlmpweb

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
/usr/share/bolixo/COPYING
/usr/share/bolixo/README
/usr/share/bolixo/secrets.admin
/usr/share/bolixo/secrets.client
/usr/share/bolixo/manager.conf
/usr/share/bolixo/bolixo.conf
/usr/share/bolixo/bofs.conf
/usr/sbin/bo-webtest
/usr/sbin/bod
/usr/sbin/bod-control
/usr/sbin/bod-client
/usr/sbin/bo-writed
/usr/sbin/bo-writed-control
/usr/sbin/bo-sessiond
/usr/sbin/bo-sessiond-control
/usr/sbin/bolixod
/usr/sbin/bolixod-control
/usr/sbin/publishd
/usr/sbin/publishd-control
/usr/sbin/bo-keysd
/usr/sbin/bo-keysd-control
/usr/sbin/bo-manager
/usr/sbin/bo-mon
/usr/sbin/bo-mon-control
/usr/sbin/rssd
/usr/sbin/rssd-control
/usr/sbin/summary
/usr/sbin/listusers
/usr/sbin/nbusers
/usr/sbin/pendingusers
/usr/sbin/logssl
/usr/sbin/logweb
/usr/sbin/logexim
/usr/sbin/eximrm
/usr/sbin/create-rss-accounts
/usr/lib/eximexec
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
/var/www/html/new.png
/var/www/html/modified.png
/var/www/html/seen.png
/var/www/html/back.png
/var/www/html/bolixo.png
/var/www/html/background.png
/var/www/html/admin.jpg
/var/www/html/admin-photo.jpg
/var/www/html/conditions-d-utilisation.html
/var/www/html/terms-of-use.html
/var/www/html/dot3-fr.jpg
/var/www/html/dot3.jpg
/var/www/html/main-fr.jpg
/var/www/html/main.jpg
/var/www/html/project-fr.jpg
/var/www/html/project.jpg
/var/www/html/talk1-fr.jpg
/var/www/html/talk1.jpg
/var/www/html/talk2-fr.jpg
/var/www/html/talk2.jpg
/var/www/html/talk3-fr.jpg
/var/www/html/talk3.jpg
/var/www/html/talk-fr.jpg
/var/www/html/talk.jpg
/var/www/html/narrowscreen.jpg
/usr/lib/bolixo-test.sh
/usr/sbin/bolixo-production
/usr/sbin/bo
/etc/bolixo/http_check.conf
/etc/init.d/bolixoserv
/var/www/html/about.html
/var/www/html/favicon.ico
/var/www/html/favicon.jpg
/var/www/html/dev-photo.jpg
/var/www/html/news-photo.jpg
/var/www/html/robots.txt
/var/log/bolixo
/etc/bash_completion.d/bolixo
/usr/lib/bo-complete
%attr(-,bolixo,bolixo)/var/lib/bolixo
%attr(-,bolixo,bolixo)/var/lib/bolixod

%clean
if [ "$RPM_BUILD_ROOT" != "" ] ; then
	rm -rf $RPM_BUILD_ROOT
fi

%post

chkconfig --add bolixoserv

%postun

%pre
id bolixo >/dev/null 2>/dev/null || useradd -r bolixo

%preun



