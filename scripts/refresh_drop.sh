#!/bin/bash
# PURPOSE: Update the dependencies with
# current SH Do Not Route or Peer (DROP) as a blocklist
#
source /opt/process-locking/process-locking-header.sh

DEPENDENCIESDIR="/opt/rpz-dependencies"
DELIVERABLESDIR="/opt/rpz-deliverables"

/usr/bin/wget -O /tmp/edrop.txt http://www.spamhaus.org/drop/edrop.txt
/usr/bin/wget -O /tmp/drop.txt http://www.spamhaus.org/drop/drop.txt

cat /tmp/drop.txt /tmp/edrop.txt|grep -v "^;"|cut -d" " -f1|sed 's/\//\./' |\
awk -F"." '{print $5"."$4"."$3"."$2"."$1".rpz-ip"}' > ${DEPENDENCIESDIR}/shdrop.rpz-ip

cat /tmp/drop.txt /tmp/edrop.txt|grep -v "^;"|cut -d" " -f1|sed 's/\//\./' |\
awk -F"." '{print $5"."$4"."$3"."$2"."$1".rpz-nsip"}' > ${DEPENDENCIESDIR}/shdrop.rpz-nsip

touch ${DEPENDENCIESDIR}/shdrop_rpz_new.flag

rm /tmp/edrop.txt
rm /tmp/drop.txt

source /opt/process-locking/process-locking-footer.sh

