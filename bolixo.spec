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
Requires: mariadb-connector-c, tlmp >= TLMPVERSION, tlmpsql >= TLMPSQLVERSION, trlitool >= TRLITOOLVERSION, tlmpweb >= TLMPWEBVERSION
Requires: dejavu-serif-fonts

%description
Bolixo is a distributed social media. This package includes everything
to run a node.

%package install
Summary: Script to help install the bolixo packages
Group: Networking/util
%description install
This package installs the script bolixo-production to let you easily installed
the required packages for Bolixo. After installing this package, just run

bolixo-production install-required

%package utils
Summary: Client command line utility to access Bolixo
Group: Networking/util
Requires: tlmp >= TLMPVERSION
%description utils
Provide the bofs command line tool. This tool allows you to access and maintain
Bolixo.

%prep
%setup 

%build
make BUILD_SVNVER=REV BUILDOPTIONS compile

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
/usr/share/bolixo/update-script
/usr/lib/bolixo-update
/usr/lib/dnsrequest
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
/usr/sbin/bo-websocket
/usr/sbin/bo-websocket-control
/usr/sbin/publishd
/usr/sbin/publishd-control
/usr/sbin/documentd
/usr/sbin/documentd-control
/usr/sbin/bo-keysd
/usr/sbin/bo-keysd-control
/usr/sbin/bo-manager
/usr/sbin/bo-mon
/usr/sbin/bo-mon-control
/usr/sbin/rssd
/usr/sbin/rssd-control
/usr/sbin/rss-scan
/usr/sbin/summary
/usr/sbin/listusers
/usr/sbin/deleteoldmsgs
/usr/sbin/nbusers
/usr/sbin/pendingusers
/usr/sbin/logssl
/usr/sbin/logweb
/usr/sbin/logexim
/usr/sbin/eximrm
/usr/sbin/deleteitems
/usr/sbin/create-rss-accounts
/usr/lib/eximexec
/usr/lib/cacheurl
/usr/lib/email-log
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
/var/www/html/zip.png
/var/www/html/pdf.png
/var/www/html/new.png
/var/www/html/modified.png
/var/www/html/seen.png
/var/www/html/back.png
/var/www/html/bolixo.png
/var/www/html/background.png
/var/www/html/no-mini-photo.jpg
/var/www/html/no-photo.jpg
/var/www/html/admin.jpg
/var/www/html/admin-photo.jpg
/var/www/html/conditions-d-utilisation.html
/var/www/html/terms-of-use.html
/var/www/html/email-open-outline.svg
/var/www/html/email-outline.svg
/var/www/html/images-doc/*
/usr/lib/bolixo-test.sh
/usr/sbin/bolixo-production
/usr/sbin/bo
/etc/bolixo/http_check.conf
%config(noreplace) /etc/bolixo/default_interests.lst
%config(noreplace) /etc/bolixo/greetings.lst
/usr/share/bolixo/greetings/*
/etc/init.d/bolixoserv
/var/www/html/about.html
/var/www/html/favicon.ico
/var/www/html/favicon.jpg
/var/www/html/icon.png
/var/www/html/dev-photo.jpg
/var/www/html/news-photo.jpg
/var/www/html/robots.txt
/var/log/bolixo
/etc/bash_completion.d/bolixo
/usr/lib/bo-complete
/etc/cron.hourly/erase-oldsesssions
/etc/cron.hourly/document-save
%attr(-,bolixo,bolixo)/var/lib/bolixo
%attr(-,bolixo,bolixo)/var/lib/bolixod
%doc utils/rss-scan.hourly
%doc utils/convert_db_utf8

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


%files install
/etc/bash_completion.d/bolixo
/usr/lib/bo-complete
/usr/sbin/bolixo-production
/usr/sbin/bo
/usr/share/bolixo/bolixo.conf

%files utils
/usr/bin/bofs
/usr/share/bolixo/whiteboard-help.sh
