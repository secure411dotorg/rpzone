#!/bin/bash
# PURPOSE: Accept an instruction, host and zonename
# and instruct an RPZ bind server to add or delete a rule
#

if [ -z "${1}"  ] || [ -z "${2}" ] || [ -z "${3}" ];then
    echo "instruction or host or zone named was not specified - Nothing was done"
    echo " "
    echo "USAGE: ./nsupdate_white.sh INSTRUCTION HOST ZONENAME"
    echo " " 
    echo "EXAMPLE: ./nsupdate_white.sh add example.com localwhite"
    echo " " 
    echo "EXAMPLE: ./nsupdate_white.sh delete example.com localwhite"
    echo " " 

else

INSTRUCTION="${1}"
THEHOST="${2}"
ZONENAME="${3}"
ZONESERVER="localhost"
QCDIR="/etc/bind/rpz-quality"

ZONETYPE=`echo "${THEHOST}"|rev|cut -d. -f2|rev`
x=1
while [ $x -le 1 ];do
        TSTAMP=`date +%s`
        echo "zone ${ZONENAME}"
        echo "update ${INSTRUCTION} ${THEHOST}.${ZONENAME} 60 CNAME ." 
        echo "show"
        echo "send"
        echo "answer"
          x=$(( $x + 1 ))
          echo "${TSTAMP}|update ${INSTRUCTION} ${THEHOST}.${ZONENAME} 60 CNAME ." >> ${QCDIR}/audit_trail_manual.csv
done |sudo /usr/bin/nsupdate -l

fi

