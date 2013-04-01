#!/bin/bash
# PURPOSE: Update the dependencies with
# current Alexa 1 million and 5000 for whitelists
#
source /opt/process-locking/process-locking-header.sh

DEPENDENCIESDIR="/opt/rpz-dependencies"
DELIVERABLESDIR="/opt/rpz-deliverables"

/usr/bin/wget -O /tmp/alexa.zip http://s3.amazonaws.com/alexa-static/top-1m.csv.zip

/usr/bin/unzip -p /tmp/alexa.zip|cut -d"," -f2 > ${DEPENDENCIESDIR}/alexa.domains

# Preserve existing copy of our source data to facilitate diffing
mv ${DEPENDENCIESDIR}/alexa5000.domains ${DEPENDENCIESDIR}/alexa5000.domains.prev

# Create files with every record which can be used to initialize or recreate a zone
head -n5000 ${DEPENDENCIESDIR}/alexa.domains|sort  > ${DEPENDENCIESDIR}/alexa5000.domains
cat ${DEPENDENCIESDIR}/alexa5000.domains|sed 's/$/\.rpz-nsdname/;s/^/*\./g' > ${DEPENDENCIESDIR}/alexa5000.rpz-nsdname
cat ${DEPENDENCIESDIR}/alexa5000.domains|sed 's/^/*\./g' > ${DEPENDENCIESDIR}/alexa5000.wildcarddomains

# Diff the old and new list of domains
/usr/bin/comm -23 ${DEPENDENCIESDIR}/alexa5000.domains.prev ${DEPENDENCIESDIR}/alexa5000.domains >> ${DEPENDENCIESDIR}/alexa5000.domains.add
/usr/bin/comm -23 ${DEPENDENCIESDIR}/alexa5000.domains ${DEPENDENCIESDIR}/alexa5000.domains.prev >> ${DEPENDENCIESDIR}/alexa5000.domains.del

# FIXME optimze speed of nsupdate, verify adds and removes
# nsupdate the zone with added domains
while read DNAME;do
	/opt/rpzone/scripts/nsupdate_zone.sh add ${DNAME} alexa5000
	/opt/rpzone/scripts/nsupdate_zone.sh add *.${DNAME} alexa5000
	/opt/rpzone/scripts/nsupdate_zone.sh add *.${DNAME}.rpz-nsdname alexa5000
done < ${DEPENDENCIESDIR}/alexa5000.domains.add
rm ${DEPENDENCIESDIR}/alexa5000.domains.add
# nsupdate the zone with removed domains
while read DNAME;do
	/opt/rpzone/scripts/nsupdate_zone.sh delete ${DNAME} alexa5000
	/opt/rpzone/scripts/nsupdate_zone.sh delete *.${DNAME} alexa5000
	/opt/rpzone/scripts/nsupdate_zone.sh delete *.${DNAME}.rpz-nsdname alexa5000
done < ${DEPENDENCIESDIR}/alexa5000.domains.del
rm ${DEPENDENCIESDIR}/alexa5000.domains.del

touch ${DEPENDENCIESDIR}/alexa5000_rpz_new.flag

rm /tmp/alexa.zip

source /opt/process-locking/process-locking-footer.sh

