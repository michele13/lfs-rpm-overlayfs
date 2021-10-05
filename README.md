# lfs-rpm-overlayfs
Notes about scripting a Linux From Scratch build using RPM and OverlayFS

## How to use the scripts

**DISCLAIMER**
These informations are taken from [This Conversation](https://lists.linuxfromscratch.org/sympa/arc/lfs-support/2021-09/msg00248.html)

So if you `mk-setup.sh -p LFS` it will make LFS-Chroot, LFS-WIP, LFS-Work
and LFS-Host. You can populate LFS-Host with what ever host you would
like.

Then `sudo ./mk-chroot.sh -p LFS -r LFS-Host`
or
`sudo ./mk-chroot.sh -p LFS -r /`

The latter uses the currently booted system as the host.

I copy the "build system" into LFS-/WIP/home/\<user\>.

After I chroot into LFS-Chroot I `su - <user>`

The <user> is setup with:
.bash_profile: copied to LFS-WIP/home/\<user\>

```
exec env -i HOME=$HOME TERM=$TERM PS1="\u:\w\$ " /bin/bash
```
.bashrc: copied to LFS-WIP/home/\<user\> env setup goes here

```
set +h
umask 022
LC_ALL=POSIX
PATH=/tools/bin:/bin:/usr/bin <-- this changes when building chapter 8-9
HOST=rpi.example.org
HOSTNAME=rpi.example.org
export LC_ALL PATH HOST
NORMAL="\[\e[0m\]"
RED="\[\e[1;31m\]"
GREEN="\[\e[1;32m\]"
CYAN="\[\e[1;36m\]"
if [[ $EUID == 0 ]] ; then
PS1="$RED\u$NORMAL@$HOST$RED [ $NORMAL\w$RED ]# $NORMAL"
else
PS1="\u$GREEN@$CYAN$HOST$GREEN [ $NORMAL\w$GREEN ]$ $NORMAL"
fi
```
Then I run my building scripts.....

I have sudo installed in the build system so I can build the rpm as
<user> then sudo `rpm -Uvh --nodeps RPMS/armv7hnl/<rpm-fliepsec>` to
install.

I have developed this "system" over many years.

All the changes to the chrooted system are in LFS-WIP, after you exit
the chroot you can simply have a look at them (`ls -R LFS-WIP/`).

If you are using LFS-Host you can/could `rsync -var LFS-WIP/* LFS-Host` if
you want the changes to be part of the host. I wouldn't do that if / is
LFS-Host as it would over write your host system.

All the "changes" to the chrooted system is in LFS-WIP, the LFS-Host is
never changed unless you do the rsync above (really not necessary).

You can copy in or change things in the chrooted system by
using another terminal(from another desktop) by cd
LFS-Chroot/home/\<user\> while the chroot is active. All of those changes
land in LFS-WIP automatically.

## How do I build an RPM Package without rpmdev-setuptree on Debian/Ubuntu?

Source: https://stackoverflow.com/a/65007648


`rpmdev` is mostly optional. `rpm` is enough. The following describes the minimum steps to package a script program into a RPM file on Debian.

Install rpmbuild:

```
apt-get install rpm
```

Create a helloworld program:

```
cat > helloworld <<EOF
#! /bin/bash
printf "Hello World!\n"
EOF
chmod +x helloworld
```

Create a minimal specification helloworld.spec:

```
Name:       helloworld
Version:    1.0
Release:    1%{?dist}
Summary:    Hello World
License:    GPLv3+
BuildArch:  noarch

%description
Hello World!

%prep

%build

%install
mkdir -p %{buildroot}/%{_bindir}
install -m 0755 %{name} %{buildroot}/%{_bindir}/%{name}

%files
%{_bindir}/%{name}

%changelog
```

Build the RPMs:


```
rpmbuild -ba --build-in-place --define "_topdir $(pwd)/rpm" helloworld.spec
mv rpm/SRPMS/*.rpm .
mv rpm/RPMS/*/*.rpm .
rm -rf rpm
```

But you will not be able to install it on Debian or Ubuntu. The installation requires Fedora or Red Hat.

## Other Infos about Building RPM

* [RPM Packaging guide](https://rpm-packaging-guide.github.io/)
* [Maximum RPM](http://ftp.rpm.org/max-rpm/)
* [RPM Documentation from official website](http://rpm.org/documentation.html)

