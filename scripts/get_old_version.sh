#!/usr/bin/bash
#
#  Copyright (c) 2017, MariaDB
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; version 2 of the License.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA */

OLD=$1

cd $HOME
if [ -n "$OLD" ] ; then
  case $OLD in
    mysql-*)
      ver=`echo $OLD | sed -e 's/mysql-//'`
      if [[ $ver =~ ^[0-9]\.[0-9]\.[0-9] ]] ; then
        major_ver=`echo $ver | sed -e 's/\([0-9]*\.[0-9]*\)\.*/\1/'`
      elif [[ $ver =~ ^[0-9]\.[0-9]$ ]] ; then
        major_ver=$ver
        wget https://dev.mysql.com/doc/relnotes/mysql/$major_ver/en/
        ver=`grep 'General Availability' index.html  | grep -v 'Not yet released' | grep section | head -1 | sed -e 's/.*Changes in MySQL \([0-9]*\.[0-9]*\.[0-9]*\).*/\1/'`
      fi
      echo "MySQL version $ver"
      fname=mysql-${ver}-linux-glibc2.12-x86_64
      wget -nv https://dev.mysql.com/get/Downloads/MySQL-${major_ver}/${fname}.tar.gz
    ;;
    10.*)
      wget https://downloads.mariadb.com/MariaDB/mariadb-${OLD}/bintar-linux-glibc_214-x86_64/
      fname=`grep "\"mariadb-.*tar.gz\"" index.html | sed -e 's/.*\(mariadb-.*\)\.tar\.gz.*/\1/'`
      wget -nv https://downloads.mariadb.com/MariaDB/mariadb-${OLD}/bintar-linux-glibc_214-x86_64/${fname}.tar.gz
    ;;
    *)
    ;;
  esac
  rm -rf old
  mkdir old
  cd old
  tar zxf ../${fname}.tar.gz
  dname=`ls`
  mv $dname/* ./
  rmdir $dname
  cd $HOME
else
  echo "Old and new versions are the same"
  ln -s $BASEDIR $HOME/old
fi
