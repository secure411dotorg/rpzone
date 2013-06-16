#!/bin/bash
# PURPOSE: Accept an instruction, host and zonename
# and instruct an RPZ bind server to add or delete a rule
# 
# NAME: nsupdate_block.sh (part of rpzone helper scripts)
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
#

if [ -z "${1}"  ] || [ -z "${2}" ] || [ -z "${3}" ];then
    echo "instruction or host or zone named was not specified - Nothing was done"
    echo " "
    echo "USAGE: ./nsupdate_block.sh INSTRUCTION HOST ZONENAME"
    echo " " 
    echo "EXAMPLE: ./nsupdate_block.sh add example.com localblock"
    echo " " 
    echo "EXAMPLE: ./nsupdate_block.sh add *.example.com localblock"
    echo " " 
    echo "EXAMPLE: ./nsupdate_block.sh add *.example.com.rpz-nsdname localblock"

else

INSTRUCTION="${1}"
THEHOST="${2}"
ZONENAME="${3}"
ZONESERVER="localhost"
QCDIR="/opt/rpz-quality"

ZONETYPE=`echo "${THEHOST}"|rev|cut -d. -f2|rev`
x=1
while [ $x -le 1 ];do
        TSTAMP=`date +%s`
        echo "zone ${ZONENAME}"
        echo "update ${INSTRUCTION} ${THEHOST}.${ZONENAME} 60 A 127.0.0.2"
        echo "show"
        echo "send"
        echo "answer"
          x=$(( $x + 1 ))
          echo "${TSTAMP}|update ${INSTRUCTION} ${THEHOST}.${ZONENAME} 60 A 127.0.0.2" >> ${QCDIR}/audit_trail_manual.csv
done |sudo /usr/bin/nsupdate -l

fi

