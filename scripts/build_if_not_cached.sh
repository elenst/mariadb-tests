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

# The script gets from the environment:
# $HOME
# $BASEDIR
# $CMAKE_OPTIONS

set -x

if [ -e $BASEDIR/revno ] ; then
  CACHED_REVISION=`cat $BASEDIR/revno`
fi

cd $HOME/src
REVISION=`git log -1 | head -1 | sed -e 's/^commit \([a-f0-9]*\)/\1/'`

if [ "$REVISION" != "$CACHED_REVISION" ] ; then 
  echo "Cached revision $CACHED_REVISION, new revision $REVISION, build is required"
  rm -rf $BASEDIR && mkdir $BASEDIR
  rm -rf $HOME/out-of-source && mkdir $HOME/out-of-source && cd $HOME/out-of-source
  cmake $HOME/src $CMAKE_OPTIONS -DCMAKE_INSTALL_PREFIX=$BASEDIR
  make -j6
  make install > /dev/null
  echo $REVISION > $BASEDIR/revno
  rm -rf $HOME/out-of-source
elif [ -z "$RERUN_OLD_SERVER" ] && [ -e $BASEDIR/test_result ] ; then
  echo "Test result for revision $REVISION has already been cached, tests will be skipped"
  echo "For details of the test run, check logs of previous releases"
  exit `cat $BASEDIR/test_result`
elif [ -n "$RERUN_OLD_SERVER" ]
  echo "Revision $REVISION has already been cached, build is not needed, tests will be re-run as requested"
else
  echo "Revision $REVISION has already been cached, build is not needed, but there is no stored test result, so tests will be run"
fi
