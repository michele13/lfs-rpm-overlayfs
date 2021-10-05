Name: rpm
Version: 4.17.0
Release: 1
Summary: Package manager
Group: Base
License: GPLv2
URL: http://rpm.org
Source0: http://ftp.rpm.org/releases/rpm-4.17.x/rpm-4.17.0.tar.bz2
BuildRequires: libarchive libgcrypt lua popt sqlite
%description
Package manager

%prep
%setup -q -n rpm-%{version}

%build

./autogen.sh --noconfigure
./configure \
--prefix=/usr \
--program-prefix= \
--sysconfdir=/etc \
--sharedstatedir=/var/lib \
--localstatedir=/var \
--with-crypto=libgcrypt \
--with-gnu-ld \
--with-archive \
--disable-openmp \
--without-selinux \
--enable-zstd=no \
--enable-python \
--enable-sqlite \
--disable-dependency-tracking \
--disable-silent-rules \
--disable-nls \
--disable-rpath \
--disable-inhibit-plugin \
--with-sysroot=/
%{make_build}

%install
directory=$(pwd)
%{make_install}
install -vdm 755 %{buildroot}/etc/rpm
# Create clean up list
cd ${directory}
[ -e %{buildroot}/usr/share/info/dir ] && rm
%{buildroot}/usr/share/info/dir find "%{buildroot}" -name '*.la' -delete
find '%{buildroot}' -ls -not -type d -print > filelist.rpm
sed -i 's|^%{buildroot}||' filelist.rpm
sed -i '/ /d' filelist.rpm
sed -i '/\/etc\/init.d/d' filelist.rpm

%files -f filelist.rpm
%defattr(-,root,root)

%changelog
* Mon Sep 27 2021 scott andrews <scott-andrews@columbus.rr.com>
4.17.0-1
- Initial build. First version