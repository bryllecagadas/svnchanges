#!/bin/bash
#
# Filename: svnchanges.sh
# Author: Brylle Cagadas
# Description:
# Tries to list all files changed with the provided revision number(s) in a way that
# the changed files appears only once. Used for prepping files to be updated to a remote server.
#
# Usage:
# script -r [revision_number]:[revision_number] -c
#
# Options:
# -r [revision_number]:[revision_number]	Specifies the revision numbers to use.
# -c						Displays comments associated with the file.

# Get the options given to the script
SHOW_COMMENT=false;
while getopts ":r:c" opt; do
  case $opt in
  r)
    if [[ $OPTARG =~ [0-9]+:[0-9]+ ]]
    then
      REVISION=$OPTARG;
    else
      echo "Revision numbers required" >&2
      exit 2
    fi
    ;;
  c)
    SHOW_COMMENT=true;
    ;;
  ?)
    echo "Invalid option: -$OPTARG" >&2
    exit 2
    ;;
  esac
done
STATUS_CHAR="^   (A|B|C|D|I|K|L|M|O|R|S|T|X|\?|!|~|\+|\*)";
RESULT="$(svn log -v -r $REVISION)";
echo "$RESULT" | grep "$STATUS_CHAR" -P | while read LINE;
do
  SKIP=false;
  CLEAN=$(echo "${LINE:2}");
  if [[ -z "$COUNTER" ]]
  then
    COUNTER=0;
  fi
  if [[ -z "$FILES" ]]
  then
    FILES=( );
  fi
  for F in "${FILES[@]}"
  do
    if [ "$CLEAN" == "$F" ];
    then
      SKIP=true;
      break
    fi
  done
  if $SKIP;
  then
    continue
  fi
  FILES[$COUNTER]=$CLEAN;
  echo $CLEAN;
  COUNTER=$[COUNTER+1];
done