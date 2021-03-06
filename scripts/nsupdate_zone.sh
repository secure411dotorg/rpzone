#!/bin/bash
# PURPOSE: Accept an instruction, host and zonename
# and instruct an RPZ bind server to add or delete a rule
# 
# NAME: nsupdate_zone.sh (part of rpzone helper scripts)
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
INSTRUCTION="${1}"
THEHOST="${2}"
ZONENAME="${3}"
ZONESERVER="localhost"
QCDIR="/opt/rpz-quality"

ZONETYPE=`echo "${THEHOST}"|rev|cut -d. -f2|rev`

# EXAMPLE: If you also need to add to a database
#if [ "${ZONETYPE}" = "rpz-nsip" ];then
	#IPADDR=`echo "${THEHOST}"|awk -F"." '{print $5"."$4"."$3"."$2}'`
	#NETMASK=`echo "${THEHOST}"|cut -d. -f1`
	#echo "IPADDR is $IPADDR and NETMASK is $NETMASK"

	#if [ "${INSTRUCTION}" = "delete" ];then
	#	SQLRESULT=`psql -h pg.example.com rz -U postgres -At -c "DELETE FROM mytable WHERE address <<= '${IPADDR}/${NETMASK}';"`
	#	echo "${ZONETYPE} ${IPADDR} ${NETMASK} ${SQLRESULT}" >> ${QCDIR}/reviewcandidates.sql
	#else
	#	SQLRESULT=`psql -h pg.example.com rz -U postgres -At -c "INSERT INTO mytable (address,my,other,columns) VALUES ('${IPADDR}/${NETMASK}',my,other,values);"`
	#fi
	#TSTAMP=`date +%s`
	#echo "${TSTAMP} ${ZONETYPE} ${IPADDR} ${NETMASK} ${SQLRESULT}" >> ${QCDIR}/sql.audit_trail
	#echo "${ZONETYPE} ${IPADDR} ${NETMASK} ${SQLRESULT}"
	#echo " " 
#fi
#if [ "${ZONETYPE}" = "rpz-nsdname" ];then
	#NSWILD=`echo "${THEHOST}"|rev|cut -d. -f3-10|rev|sed 's/^*/\%/'`
	#if [ "${INSTRUCTION}" = "delete" ];then
	#	SQLRESULT=`echo "DELETE FROM mytable WHERE pattern ilike '${NSWILD}';"|psql -h pg.example.com rz -U postgres`
	#	echo "${ZONETYPE} ${NSWILD} ${SQLRESULT}" >> ${QCDIR}/reviewcandidates.sql
	#else
	#	NSHOST=`echo "${NSWILD}"|sed 's/^\%\.//'`
	#	D8S=`dig +short txt @MYASSIGNEDHOST.d8s.us ${NSHOST}`
	#	echo "${D8S}"
	#	echo "${D8S}" >> ${QCDIR}/${ZONENAME}.d8s
	#	CTIME=`echo "${D8S}"|grep -o "c:.*"|cut -d, -f1|sed 's/c://'`
	#	if [ -n "${CTIME}" ];then
	#		SQLVALS="'${NSWILD}','${CTIME}'"
	#		SQLRESULT=`echo "INSERT INTO mytable (my,various,columns) VALUES (${SQLVALS});"|psql -h pg.example.com rz -U postgres`
	#	else
	#		echo "${NSWILD} ${D8S}" >> ${QCDIR}/rpz-nsdname.prune
	#	fi
	#fi
	#TSTAMP=`date +%s`
	#echo "${TSTAMP} ${ZONETYPE} ${NSWILD} ${SQLRESULT}" >> ${QCDIR}/sql.audit_trail
	#echo "${ZONETYPE} ${NSWILD} ${SQLRESULT}"
	#echo " " 
#fi
x=1
while [ $x -le 1 ]
do
TSTAMP=`date +%s`
#echo "server ${ZONESERVER}"
echo "zone ${ZONENAME}"
echo "update ${INSTRUCTION} ${THEHOST}.${ZONENAME} 60 A 127.0.0.2"
echo "show"
echo "send"
echo "answer"
  x=$(( $x + 1 ))
echo "${TSTAMP}|update ${INSTRUCTION} ${THEHOST}.${ZONENAME} 60 A 127.0.0.2" >> ${QCDIR}/audit_trail_manual.csv
done |sudo /usr/bin/nsupdate -l

