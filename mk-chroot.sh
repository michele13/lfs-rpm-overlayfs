#!/bin/bash
#-----------------------------------------------------------------------------
# Title: mk-chroot.sh
# Date: 2020-08-14
# Version: 1.0
# Author: scott-andrews@columbus.rr.com
# Options: none
#-----------------------------------------------------------------------------
# Copyright 2020 Scott Andrews
#-----------------------------------------------------------------------------
# This program is free software: you can redistribute it and/or modify 
# it under the terms of the GNU General Public License as published by 
# the Free Software Foundation, either version 3 of the License, or 
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License 
# along with this program. If not, see <https://www.gnu.org/licenses/>.
#-----------------------------------------------------------------------------
# Dedicated to Elizabeth my cat of 20 years, Euthanasia on 2019-05-16
#-----------------------------------------------------------------------------
set -o errexit # exit if error...insurance ;) 
set -o nounset # exit if variable not initalized 
set +h # disable hashall
#-----------------------------------------------------------------------------
# Master variables PRGNAME=${0##*/} # script name minus the path 
_red="\\033[1;31m"
_normal="\\033[0;39m"
_green="\\033[1;32m"
#-----------------------------------------------------------------------------
_unmount() {
local _filespec="${1}-Chroot"
mountpoint -q "${PWD}/${_filespec}/run" && umount "${PWD}/${_filespec}/run" 
mountpoint -q "${PWD}/${_filespec}/sys" && umount "${PWD}/${_filespec}/sys"
mountpoint -q "${PWD}/${_filespec}/proc" && umount "${PWD}/${_filespec}/proc"
mountpoint -q "${PWD}/${_filespec}/dev/pts" && umount "${PWD}/${_filespec}/dev/pts"
mountpoint -q "${PWD}/${_filespec}/dev" && umount "${PWD}/${_filespec}/dev" 
mountpoint -q "${PWD}/${_filespec}" && umount "${PWD}/${_filespec}"
return 0; }

_chroot() {
local _prefix=${1}
local _host=${2}
mount -t overlay overlay -o "lowerdir=${_host},upperdir=${_prefix}-WIP,workdir=${_prefix}-Work" "${_prefix}-Chroot"
mount --bind /dev "${_prefix}-Chroot/dev"
mount -t devpts devpts "${_prefix}-Chroot/dev/pts" -o gid=5,mode=620
mount -t proc proc "${_prefix}-Chroot/proc"
mount -t sysfs sysfs "${_prefix}-Chroot/sys"
mount -t tmpfs tmpfs "${_prefix}-Chroot/run"
/usr/sbin/chroot "${_prefix}-Chroot" /usr/bin/env -i HOME="${HOME}" TERM="${TERM}" PATH=/bin:/usr/bin:/sbin:/usr/sbin PS1='(Overlay) \u:\w\$ ' /bin/bash --noprofile --norc --login +h 
return 0; } 

_mk-dev() {
local _prefix=${1}
local _host=${2}
mkdir -pv ${_host}/{dev,proc,sys,run}
if [[ ! -d ${_host}/dev ]]; then install -vdm 755 ${_host}/dev; fi
if [[ ! -d ${_host}/proc ]]; then install -vdm 755 ${_host}/proc; fi
if [[ ! -d ${_host}/sys ]]; then install -vdm 755 ${_host}/sys; fi
if [[ ! -d ${_host}/run ]];then install -vdm 755 ${_host}/run; fi
if [[ ! -e ${_host}/dev/console ]];then mknod -m 600 ${_host}/dev/console c 5 1; fi
if [[ ! -e ${_host}/dev/null ]]; then mknod -m 666 ${_host}/dev/null c 1 3; fi
return 0; }

#-----------------------------------------------------------------------------
# Mainline
#
# Process arguments
host=""
prefix=""
RELEASE="2021-09-09"
USAGE="Usage: ${0##*/} [ -h | -v | -p <prefix> ]"
VERSTR="${0##*/}, version ${RELEASE}"
OPTIND=1
while getopts hp:vr: opt; do
case "${opt}" in
h) printf "%s\n" "${USAGE}"
   printf "%s\n" "${0##*/} Chroot into build  system <prefix> " 
   printf "\t%s\n" "-v version"
   printf "\t%s\n" "-h help"
   printf "\t%s\n" "-p <prefix> - name of overlay filesystem"
   printf "\t%s\n" "-r <directory> - host for build"
exit 1; ;;
p) prefix=${OPTARG}; ;;
r) host=${OPTARG}; ;;
v) echo "${VERSTR}"; exit 1; ;;
*) ;;
esac
done
shift $((OPTIND - 1))
if [[ -z ${host} ]]; then
printf "${_red}%s${_normal}\n" "Host: [${host}]: Directory not found"; exit 1; fi

if [[ -z ${prefix} ]]; then
printf "${_red}%s${_normal}\n" "Prefix: [${prefix}]: Directory not found"; exit 1; fi
_unmount "${prefix}" 
_mk-dev "${prefix}" "${host}" || true
_chroot "${prefix}" "${host}" || true
_unmount "${prefix}"
printf "${_green}%s${_normal}\n" "${PRGNAME}: Run Complete"

