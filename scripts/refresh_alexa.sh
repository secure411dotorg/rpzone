#!/bin/bash
# PURPOSE: Update the dependencies with
# current Alexa 1 million and 5000 for whitelists
#
source /opt/process-locking/process-locking-header.sh

DEPENDENCIESDIR="/opt/rpz-dependencies"
DELIVERABLESDIR="/opt/rpz-deliverables"

/usr/bin/wget -O /tmp/alexa.zip http://s3.amazonaws.com/alexa-static/top-1m.csv.zip

/usr/bin/unzip -p /tmp/alexa.zip|cut -d"," -f2 > ${DEPENDENCIESDIR}/alexa.domains

head -n5000 ${DEPENDENCIESDIR}/alexa.domains|sort  > ${DEPENDENCIESDIR}/alexa_5000.domains

rm /tmp/alexa.zip

source /opt/process-locking/process-locking-footer.sh

