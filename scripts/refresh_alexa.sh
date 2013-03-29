#!/bin/bash
# PURPOSE: Update the dependencies with
# current Alexa 1 million and 5000 for whitelists
#
source /opt/process-locking/process-locking-header.sh

DEPENDENCIESDIR="/opt/rpz-dependencies"
DELIVERABLESDIR="/opt/rpz-deliverables"

/usr/bin/wget -O /tmp/alexa.zip http://s3.amazonaws.com/alexa-static/top-1m.csv.zip

/usr/bin/unzip -p /tmp/alexa.zip|cut -d"," -f2 > ${DEPENDENCIESDIR}/alexa.domains

head -n5000 ${DEPENDENCIESDIR}/alexa.domains|sort  > ${DEPENDENCIESDIR}/alexa5000.domains

cat ${DEPENDENCIESDIR}/alexa5000.domains|sed 's/$/\.rpz-nsdname/' > ${DEPENDENCIESDIR}/alexa5000.rpz-nsdname

touch ${DEPENDENCIESDIR}/alexa_rpz_new.flag

rm /tmp/alexa.zip

source /opt/process-locking/process-locking-footer.sh

