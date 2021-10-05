Name: gcc
Version: 11.2.0
Release: 0
Summary: The GNU Compiler Collection
Group: Tools
License: GPL
URL: https://gcc.gnu.org
Source0: https://ftp.gnu.org/gnu/gcc/gcc-11.2.0/gcc-11.2.0.tar.xz
Source1: https://ftp.gnu.org/gnu/gmp/gmp-6.2.1.tar.xz
Source2: https://ftp.gnu.org/gnu/mpc/mpc-1.2.1.tar.gz
Source3: https://www.mpfr.org/mpfr-4.1.0/mpfr-4.1.0.tar.xz
%description
The GNU Compiler Collection

%prep
%setup -q -n %{name}-%{version}
tar -xf %{_sourcedir}/mpfr-4.1.0.tar.xz
tar -xf %{_sourcedir}/gmp-6.2.1.tar.xz
tar -xf %{_sourcedir}/mpc-1.2.1.tar.gz
mv -v mpfr-4.1.0 mpfr
mv -v gmp-6.2.1 gmp
mv -v mpc-1.2.1 mpc

%build
mkdir build
pushd build
../configure \
--target=%{HBL_TGT} \
--prefix=/tools \
--with-glibc-version=2.11 \
--with-sysroot=/mnt \
--with-newlib \
--without-headers \
--enable-initfini-array \
--disable-nls \
--disable-shared \
--disable-multilib \
--disable-decimal-float \
--disable-threads \
--disable-libatomic \
--disable-libgomp \
--disable-libquadmath \
--disable-libssp \
--disable-libvtv \
--disable-libstdcxx \
--enable-languages=c,c++ \
--disable-werror\
%CONFIGARM
%{make_build}
popd

%install
directory=$(pwd)
pushd build
%{make_install}
popd
cat gcc/limitx.h gcc/glimits.h gcc/limity.h >
%{buildroot}/tools/lib/gcc/%{HBL_TGT}/%{version}/install-tools/include/limits.h
rm -r %{buildroot}/tools/share/{doc,info,man} || true
# Create clean up list
cd ${directory}
[ -e %{buildroot}/usr/share/info/dir ] && rm %{buildroot}/usr/share/info/dir
find "%{buildroot}" -name '*.la' -delete
find '%{buildroot}' -ls -not -type d -print > filelist.rpm
sed -i 's|^%{buildroot}||' filelist.rpm
sed -i '/ /d' filelist.rpm
sed -i '/\/etc\/init.d/d' filelist.rpm

%files -f filelist.rpm
%defattr(-,root,root)

%changelog
* Fri Sep 24 2021 scott andrews <scott-andrews@columbus.rr.com> 11.2.0-0
- Initial build. First version