#!/bin/bash
#-----------------------------------------------------------------------------
# Title: mk-host-installer.sh
# Date: 2020-06-29
# Version: 1.0
# Author: scott-andrews@columbus.rr.com
# Options: none
#-----------------------------------------------------------------------------
# Copyright 2019 Scott Andrews
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
#set -o errexit # exit if error...insurance ;) 
set -o nounset # exit if variable not initalized
# disable hashall
set +h
#-----------------------------------------------------------------------------
# Master variables PRGNAME=${0##*/} # script name minus the path 
_red="\\033[1;31m" 
_normal="\\033[0;39m"
_green="\\033[1;32m"
#-----------------------------------------------------------------------------
# Mainline
#
# Process arguments
install=""
prefix=""
RELEASE="2021-08-31"
USAGE="Usage: ${0##*/} [ -h | -v | -p <prefix> | -i install rpms to
host directory]" VERSTR="${0##*/}, version ${RELEASE}"
OPTIND=1
while getopts vhi:p: opt; do
case "${opt}" in
h) printf "%s\n" "${USAGE}"
   printf "%s\n" "${0##*/} Setup Build system <directory> " 
   printf "\t%s\n" "-v version"
   printf "\t%s\n" "-h help"
   printf "\t%s\n" "-p <prefix>"
   printf "\t%s\n" "-i <directory containing rpms to install into host>"; exit 1; ;;
i) install=${OPTARG}; ;;
p) prefix=${OPTARG}; ;;
v) echo "${VERSTR}";exit 1; ;;
*) ;;
esac
done
shift $((OPTIND - 1))
printf "%s\n" "${0##*/} Setup Build system"
printf "%s\n" " Prefix: [${prefix}]"
printf "%s\n" " Install: [${install}]"
if [[ -z ${prefix} ]]; then printf "${_red}%s${_normal}\n" "Prefix Directory Name: missing"; exit 1; fi 
if [[ -d ${prefix} ]]; then printf "${_red}%s${_normal}\n" "Prefix Directory: [${prefix}]: exists, not overwritting"; exit 1; fi
if [[ -n ${install} ]]; then if [[ ! -d ${install} ]]; then
  printf "${_red}%s${_normal}\n" "Install Directory: missing"; exit 1; fi; fi 
# Create Parent directories 
install -vdm 755 ${prefix}-Chroot 
install -vdm 755 ${prefix}-Host
install -vdm 755 ${prefix}-Work
install -vdm 755 ${prefix}-WIP
