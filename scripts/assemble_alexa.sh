#!/bin/bash
# PURPOSE: bring together the data from multiple sources
# Update the header, update the serial, validate the resulting file
# Replace the existing zone and run rndc reload
#
# NOTE: other processes update or create the source data
# This script just checks for the existence of a new data flag file
#
source /opt/process-locking/process-locking-header.sh

DEPENDENCIESDIR="/opt/rpz-dependencies"
DELIVERABLESDIR="/opt/rpz-deliverables

cd ${DELIVERABLES}

THEPOCH=`date +%s`

# Check for new source file flags
if [ -f "${DEPENDENCIESDIR}/alexa_rpz_new.flag" ]; then

	# Use a header template file to an empty zone file.tmp with new serial
	sed "s/SERIAL/$THEPOCH/g" ${DEPENDENCIESDIR}/rpzone.header > ${DELIVERABLESDIR}/alexa5000.db.tmp

	# Append the rpz format files to the zone file.tmp with a POLICY appended to each line
	cat ${DEPENDENCIESDIR}/alexa5000.rpz-nsdname ${DEPENDENCIESDIR}/alexa5000.rpz ${DEPENDENCIESDIR}/dnb.rpz |\
	sort -u|sed '/^$/d'|sed 's/$/ CNAME \./' >> ${DELIVERABLES}/alexa5000.db.tmp

	# Validate the syntax of the zone - FIXME error handling for result of validation
	# /usr/sbin/named-checkconf -z ${DELIVERABLES}/alexa5000.db.tmp

	# if valid - Replace zone file with zone file.tmp - else log error FIXME
	cp ${DELIVERABLES}/alexa5000.db.tmp ${DELIVERABLES}/alexa5000.db
 
	# Run rndc reload zone
	/usr/sbin/rndc reload alexa5000

	sudo rm ${DEPENDENCIESDIR}/alexa_rpz_new.flag
else
        echo "no new source data files yet"
fi

source /opt/process-locking/process-locking-footer.sh

