#!/bin/bash
# PURPOSE: Update a zone that is only used to pass a record of hits
# between RPZ servers using IXFR
#
# Intended to run on crontab periodically such as hourly
#
# Set response-policy for zone "hits" to DISABLED

# 
# NAME: nsupdate_hits.sh (part of rpzone helper scripts)
# Copyright (C) 2012 April Lorenzen
#
# Paper mail contact: April Lorenzen, PO Box 293, Jamestown RI 02835
# Electronic contact: https://github.com/secure411dotorg/rpzone/issues
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>


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
        echo "update ${INSTRUCTION} ${THEHOST}.${ZONENAME} ${TSTAMP} CNAME ${HIT}.${HITZONE}"
        echo "show"
        echo "send"
        echo "answer"
          x=$(( $x + 1 ))
          echo "${TSTAMP}|update ${INSTRUCTION} ${THEHOST}.${ZONENAME} ${TSTAMP} CNAME ${HIT}.${HITZONE}" >> ${QCDIR}/audit_trail_hits.csv
    done |sudo /usr/bin/nsupdate -l

done

