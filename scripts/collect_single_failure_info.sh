#!/usr/bin/bash
#
#  Copyright (c) 2017, 2018, MariaDB
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

# From environment:
# Mandatory:
# - BASEDIR
# - LOGDIR
# Optional:
# - TRIAL
# - SERVER
# - REVISION
# - TEST_BRANCH
# - TEST_REVISION
# - CMAKE_OPTIONS

function soft_exit {
  return $res
}

set -x

if [ -z "$LOGDIR" ] ; then
  echo "ERROR: Logdir is not defined, cannot process logs"
  res=1
  soft_exit
fi

if [ -z "$BASEDIR" ] ; then
  echo "ERROR: Basedir is not defined, cannot process logs"
  res=1
  soft_exit
fi

if [ -e "$BASEDIR/bin/mysql" ] ; then
  MYSQL=$BASEDIR/bin/mysql
elif [ -e "$BASEDIR/client/mysql" ] ; then
  MYSQL=$BASEDIR/client/mysql
else
  echo "ERROR: MySQL client not found, cannot process logs"
  res=1
  soft_exit
fi

ARCHDIR=$LOGDIR/logs_$TRAVIS_JOB_NUMBER
res=0
TRIAL="${TRIAL:-0}"
TRIAL=$((TRIAL+1))
TRAVIS_JOB=`echo $TRAVIS_JOB_NUMBER | sed -e 's/.*\.//'`

TRIAL_CMD=""
TRIAL_RESULT=""
TRIAL_STATUS=""

function insert_result
{
  $MYSQL --host=$DB_HOST --port=$DB_PORT -u$DB_USER -p$DBP -e "INSERT INTO travis.result (build_id, job_id, trial_id, travis_branch, result, status, command_line, server_branch, server_revision, cmake_options, test_branch, test_revision, data) VALUES ($TRAVIS_BUILD_NUMBER, $TRAVIS_JOB, $TRIAL, \"$TRAVIS_BRANCH\", \"$TRIAL_RESULT\", \"$TRIAL_STATUS\", \"TRIAL_CMD\", \"$SERVER\", \"$REVISION\", \"$CMAKE_OPTIONS\", \"$TEST_BRANCH\", \"$TEST_REVISION\", LOAD_FILE(\"$LOGDIR/$ARCHDIR.tar.gz\"))"
  if [ "$?" != "0" ] ; then
    echo "ERROR: Failed to insert the result"
  fi
}

rm -rf $ARCHDIR && mkdir $ARCHDIR

if [ -e $LOGDIR/trial.log ] ; then
  TRIAL_STATUS=`grep 'will exit with exit status' $LOGDIR/trial.log | sed -e 's/.*will exit with exit status STATUS_\([A-Z_]*\).*/\1/'`
  TRIAL_CMD=`grep -A 1 'Final command line:' $LOGDIR/trial.log`
  mv $LOGDIR/trial.log $ARCHDIR/
else
  echo "$triallog does not exist"
fi

echo "=================== Trial $TRIAL ==================="
echo
echo "Status: $STATUS"
echo

if [[ "$status" == "OK" ]] ; then
  TRIAL_RESULT=PASS
  insert_result
  soft_exit
fi

perl $HOME/mariadb-tests/scripts/check_for_known_bugs.pl $LOGDIR/vardir*/mysql.err $LOGDIR/trial${trial}.log

echo
echo Server: $SERVER $REVISION
echo Tests: $TEST_BRANCH $TEST_REVISION
echo $cmd
echo

res=1

for dname in $LOGDIR/vardir*
do
  echo "Processing dirname $dname"
  # Quoting bootstrap log all existing error logs
  for fname in $dname/mysql.err* $dname/boot.log
  do
    if [ -e $fname ] ; then
      mkdir -p $ARCHDIR/$dname
      cp $fname $ARCHDIR/$dname/
      echo "------------------- $fname -----------------------------"
      echo
      cat $fname | grep -v "\[Note\]" | grep -v "\[Warning\]" | grep -v "^$" | cut -c 1-4096
      echo "-------------------"
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
    echo "------------------- $coredump --------------------------"
    echo "------------------- Generated by $binary"
    echo
    gdb --batch --eval-command="thread apply 1 bt" $binary $coredump
    echo
    echo "-------------------"
    echo

    gdb --batch --eval-command="thread apply all bt" $binary $coredump > $dname/data_orig/threads
    mkdir -p $ARCHDIR/$dname
    mv $dname/data_orig $ARCHDIR/$dname/
    cp $binary $ARCHDIR/$dname/data_orig/
    
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
    echo "------------------- $coredump --------------------------"
    echo "------------------- Generated by $binary"
    echo
    gdb --batch --eval-command="thread apply 1 bt" $binary $coredump
    echo
    echo "-------------------"
    echo

    gdb --batch --eval-command="thread apply all bt" $binary $coredump > $dname/data/threads
    mkdir -p $ARCHDIR/$dname
    mv $dname/data $ARCHDIR/$dname/
    cp $binary $ARCHDIR/$dname/data/

  fi
  
  cd $LOGDIR
  tar zcf $ARCHDIR.tar.gz $ARCHDIR
  ls -l $ARCHDIR.tar.gz
  insert_result
  rm -rf ${ARCHDIR}*
  
done

soft_exit
