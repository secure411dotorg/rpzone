#!/bin/bash
# PURPOSE: bring together the data from multiple sources
# Update the header, update the serial, validate the resulting file
# Replace the existing zone and run rndc reload
#
# NAME: assemble_cidr_zone.sh (part of rpzone helper scripts)
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

# NOTE: other processes update or create the source data
# This script just checks for the existence of a new data flag file
#
source /opt/process-locking/process-locking-header.sh

if [ -z "${1}"  ];then
	echo "No zone specified - Nothing done"
	echo " " 
	echo "USAGE: ./assemble_cidr_zone.sh ZONENAME"
else

#FIXME most of the rest of the file needs indenting another level
# FIXME needs more error checking for file existence

ZONENAME="${1}"
DEPENDENCIESDIR="/opt/rpz-dependencies"
DELIVERABLESDIR="/opt/rpz-deliverables"

cd ${DELIVERABLESDIR}

THEPOCH=`date +%s`

# Check for new source file flags
if [ -f "${DEPENDENCIESDIR}/${ZONENAME}_rpz_new.flag" ]; then

	# Use a header template file to an empty zone file.tmp with new serial
	sed "s/ZONENAME/$ZONENAME/g;s/SERIAL/$THEPOCH/g" ${DEPENDENCIESDIR}/rpzone.header > ${DELIVERABLESDIR}/${ZONENAME}.db.tmp

	# Append the rpz format files to the zone file.tmp with a POLICY appended to each line
	cat ${DEPENDENCIESDIR}/${ZONENAME}.rpz-*ip |\
	sort -u|sed '/^$/d'|sed 's/$/ CNAME \./' >> ${DELIVERABLESDIR}/${ZONENAME}.db.tmp

	echo "zone ${ZONENAME} { type master; file \"${DELIVERABLESDIR}/${ZONENAME}.db.tmp\"; };" > ${DEPENDENCIESDIR}/${ZONENAME}.validator

	# Validate the syntax of the zone
	/usr/sbin/named-checkconf -z ${DEPENDENCIESDIR}/${ZONENAME}.validator

	# if valid - Replace zone file with zone file.tmp - else log error FIXME
	if [ ${?} -eq "0" ];then 
		cp ${DELIVERABLESDIR}/${ZONENAME}.db.tmp ${DELIVERABLESDIR}/${ZONENAME}.db
		# Run rndc reload zone
		sudo /usr/sbin/rndc reload ${ZONENAME}
		sudo rm ${DEPENDENCIESDIR}/${ZONENAME}_rpz_new.flag
	else
		/usr/bin/logger "WARN: rpzone ${ZONENAME}.db.tmp has a syntax error"
	fi
else
        echo "no new source data files yet"
fi

fi

source /opt/process-locking/process-locking-footer.sh

