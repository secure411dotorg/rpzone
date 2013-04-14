#!/bin/bash
# PURPOSE: Update a zone that is only used to pass a record of hits
# between RPZ servers using IXFR
#
# Intended to run on crontab periodically such as hourly
#
# Set response-policy for zone "hits" to DISABLED
# FIXME test if any response-policy is even needed for this zone
# FIXME add protection from running multiple copies of script

TODAY=`date +%d-%b-%Y`

QCDIR="/etc/bind/rpz-quality"
INSTRUCTION="add"
ZONENAME="hits"
ZONESERVER="localhost"

grep -F "${TODAY}" /var/log/named/rpz.log |awk '{print $12,$NF}'|sort -u|grep -v alexa5000|grep -v white |\
while read HIT RULE;do

    THEHOST=`echo "${RULE}"|rev|cut -d"." -f2-10|rev`
    HITZONE=`echo "${RULE}"|rev|cut -d"." -f1|rev`

    x=1
    while [ $x -le 1 ];do
        TSTAMP=`date +%s`
        echo "zone ${ZONENAME}"
        echo "update ${INSTRUCTION} ${THEHOST}.${ZONENAME} 60 CNAME ${HIT}.${HITZONE}"
        echo "show"
        echo "send"
        echo "answer"
          x=$(( $x + 1 ))
          echo "${TSTAMP}|update ${INSTRUCTION} ${THEHOST}.${ZONENAME} 60 CNAME ${HIT}.${HITZONE}" >> ${QCDIR}/audit_trail_hits.csv
    done |sudo /usr/bin/nsupdate -l

done

