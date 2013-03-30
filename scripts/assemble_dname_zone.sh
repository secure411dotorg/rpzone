#!/bin/bash
# PURPOSE: bring together the data from multiple sources
# Update the header, update the serial, validate the resulting file
# Replace the existing zone and run rndc reload
#
# NOTE: other processes update or create the source data
# This script just checks for the existence of a new data flag file
#
source /opt/process-locking/process-locking-header.sh

if [ -z "${1}"  ];then
	echo "No zone specified - Nothing done"
	echo " " 
	echo "USAGE: ./assemble_dname_zone.sh ZONENAME"
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
	cat ${DEPENDENCIESDIR}/${ZONENAME}.rpz-nsdname ${DEPENDENCIESDIR}/${ZONENAME}.domains |\
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

