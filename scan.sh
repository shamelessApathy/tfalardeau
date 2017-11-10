#!/bin/bash
USAGE="$0 usage: -d debug; -f filename; -v verbose"
LOGDIR="$(pwd)/SCANLOGS"

#Time stamp function YYYYMMDD:HHMMSS
timestamp () {
  unset STAMP;unset DATE;unset DATETIME
  TIME="$(date +%H%M%S)"
  DATE="$(date +%Y%m%d)"
  DATETIME="$DATE:$TIME"
}


#Validate or create log file
timestamp
if [ ! -d ./SCANLOGS ]; then
  mkdir $LOGDIR
  if [ $? != 0 ]; then
    echo "Couldn't create log directory"
    exit 1
  fi

  touch $LOGDIR/$DATE
  if [ $? != 0 ]; then
    echo "Couldn't create logfile \"$LOGDIR/$DATE\""
    exit 1
  else
    LOGFILE="$LOGDIR/$DATE"
    echo "Logfile \"$LOGFILE\" created at $TIME on $DATE" >> $LOGFILE
  fi
fi

LOGFILE="$LOGDIR/$DATE"

log () {
  echo $1 >> $LOGFILE
}

#Get options script was called with
while getopts "f:dv" OPT; do
  case $OPT in
    f)
      USEFILE="yes"
      FILE=$OPTARG
      ;;
    d)
      set -x
      ;;
    v)
      VERBOSE="yes"
      ;;
    \?)
      echo "$USAGE"
      exit 1
      ;;
  esac
done

quit () {
  #Quit rutine $1=Exit Code, $2=Error Msg
  timestamp
  EXITCODE=$1
  MSG="$2"
  LINE="($EXITCODE) --> \"$MSG\""

  if [ "$VERBOSE" = "yes" ]; then
    if [ ${#ESSID[@]} -gt 0 ]; then
      for (( x=0; x<${#ESSID[@]}; x++ )); do
        echo "${ESSID[$x]}"
      done
    else
     echo "No ESSIDs found"
    fi
  fi

  if [ $EXITCODE -ge 1 ]; then
    LINE="ERROR $LINE"
  fi

  log $LINE
  exit $EXITCODE
}

#function to scan and parse ESSIDs
get.essids () {
  #Change the IFS but maintain the old one
  OLDIFS="$IFS"
  IFS=$'\n\r'

  #Parse output to an array
  if [ "$USEFILE" = "yes" ]; then
    ESSID=($(cat $FILE | grep ESSID | cut -d \" -f 2))
  else
    ESSID=($(iwlist wlan0 scan | grep ESSID | cut -d \" -f 2))
  fi

  timestamp

  if [ ${#ESSID[@]} = 0 ]; then
    quit 0 "No ESSIDs found @ $TIME on $DATE"
  else
    for x in ${ESSID[@]}; do
      log "ESSID \"$x\" found at $TIME on $DATE"
    done 
    quit 0 "Found ${#ESSID[@]} ESSID(s) at $TIME on $DATE"
  fi
}

get.strongest ()
{
#iwconfig wlan0 | grep Signal | cut -d "=" -f 3 | cut -d " " -f 1 | \
#  cut -d "-" -f 2

}
get.essids

exit 0
