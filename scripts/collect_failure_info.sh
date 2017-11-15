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


LOGDIR=$1

for dname in $LOGDIR/vardir1_*
do
  if [ -e $dname ] ; then
    # Found the vardir, hence there was a failure

    trial=`echo $dname | sed -e 's/.*vardir1_\([0-9]*\).*/\1/'`
    echo
    echo "=============================================================="
    echo "Failed trial: $trial"
    echo

    # Quoting bootstrap log and error logs before and after upgrade (if exist)
    for fname in $dname/mysql.err_orig* $dname/mysql.err $dname/boot.log
    do
      if [ -e $fname ] ; then
        echo
        echo "------------------------- $fname -----------------------------"
        echo
        cat $fname | grep -v "\[Note\]" | grep -v "^$" | cut -c 1-4096
        echo "--------------------------------------------------------------"
      fi
    done

    # Checking for coredump in the _orig datadir
    if [ -e $dname/data_orig/core ] ; then
      coredump=$dname/data_orig/core
      # Since it's in the _orig dir, it is definitely from the old server
      bname=$HOME/old
      if [ -e $bname/bin/mysqld ] ; then
        binary=$bname/bin/mysqld
      elif [ -e $bname/sql/mysqld ] ; then
        binary=$bname/sql/mysqld
      fi
      echo
      echo "------------------------- $coredump --------------------------"
      echo "------------------------- Generated by $binary"
      echo
      gdb --batch --eval-command="thread apply all bt" $binary $coredump
      echo
      echo "--------------------------------------------------------------"
      echo
    fi

    # Checking for coredump in the datadir
    if [ -e $dname/data/core ] ; then
      coredump=$dname/data/core
      
      # It can be both from the old and the new server, depending on
      # whether it is an upgrade test, and if it is, on when
      # the test failed. If there is also 'data_orig', then 'data'
      # belongs to the new server; if there is no 'data_orig' and 'old'
      # server exists, then it's an upgrade test and the core belongs to
      # the old server; otherwise it belongs to the new server
      
      if [ -e $dname/data_orig ] ; then
        bname=$BASEDIR
      elif [ -e $HOME/old ] ; then
        bname=$HOME/old
      else
        bname=$BASEDIR
      fi
      
      if [ -e $bname/bin/mysqld ] ; then
        binary=$bname/bin/mysqld
      elif [ -e $bname/sql/mysqld ] ; then
        binary=$bname/sql/mysqld
      fi

      echo
      echo "------------------------- $coredump --------------------------"
      echo "------------------------- Generated by $binary"
      echo
      gdb --batch --eval-command="thread apply all bt" $binary $coredump
      echo
      echo "--------------------------------------------------------------"
      echo
    else
      triallog=$LOGDIR/trial${trial}.log
      if [ -e $triallog ] ; then
        echo "------------------------- $triallog --------------------------"
        echo
        cat $triallog | cut -c 1-4096
        echo
        echo "--------------------------------------------------------------"
        echo
      fi
    fi
  fi
done
