#!/bin/bash
# PURPOSE: Update the dependencies with
# current SH Do Not Route or Peer (DROP) as a blocklist
# 
# NAME: refresh_drop.sh (part of rpzone helper scripts)
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

source /opt/process-locking/process-locking-header.sh

DEPENDENCIESDIR="/opt/rpz-dependencies"
DELIVERABLESDIR="/opt/rpz-deliverables"

/usr/bin/wget -O /tmp/edrop.txt http://www.spamhaus.org/drop/edrop.txt
/usr/bin/wget -O /tmp/drop.txt http://www.spamhaus.org/drop/drop.txt

# Preserve existing copy of our source data to facilitate diffing
mv ${DEPENDENCIESDIR}/shdrop.rCIDR ${DEPENDENCIESDIR}/shdrop.rCIDR.prev

cat /tmp/drop.txt /tmp/edrop.txt|grep -v "^;"|cut -d" " -f1|sed 's/\//\./' |\
awk -F"." '{print $5"."$4"."$3"."$2"."$1}' > ${DEPENDENCIESDIR}/shdrop.rCIDR

cat /tmp/drop.txt /tmp/edrop.txt|grep -v "^;"|cut -d" " -f1|sed 's/\//\./' |\
awk -F"." '{print $5"."$4"."$3"."$2"."$1".rpz-ip"}' > ${DEPENDENCIESDIR}/shdrop.rpz-ip

cat /tmp/drop.txt /tmp/edrop.txt|grep -v "^;"|cut -d" " -f1|sed 's/\//\./' |\
awk -F"." '{print $5"."$4"."$3"."$2"."$1".rpz-nsip"}' > ${DEPENDENCIESDIR}/shdrop.rpz-nsip

# Diff the old and new list of domains
/usr/bin/comm -23 ${DEPENDENCIESDIR}/shdrop.rCIDR.prev ${DEPENDENCIESDIR}/shdrop.rCIDR >> ${DEPENDENCIESDIR}/shdrop.rCIDR.add
/usr/bin/comm -23 ${DEPENDENCIESDIR}/shdrop.rCIDR ${DEPENDENCIESDIR}/shdrop.rCIDR.prev >> ${DEPENDENCIESDIR}/shdrop.rCIDR.del

# FIXME optimze speed of nsupdate, verify adds and removes
# nsupdate the zone with added domains
while read RCIDR;do
	/opt/rpzone/scripts/nsupdate_zone.sh add ${RCIDR}.rpz-ip shdrop
	/opt/rpzone/scripts/nsupdate_zone.sh add ${RCIDR}.rpz-nsip shdrop
done < ${DEPENDENCIESDIR}/shdrop.rCIDR.add
rm ${DEPENDENCIESDIR}/shdrop.rCIDR.add
# nsupdate the zone with removed domains
while read RCIDR;do
	/opt/rpzone/scripts/nsupdate_zone.sh delete ${RCIDR}.rpz-ip shdrop
	/opt/rpzone/scripts/nsupdate_zone.sh delete ${RCIDR}.rpz-nsip shdrop
done < ${DEPENDENCIESDIR}/shdrop.rCIDR.del
rm ${DEPENDENCIESDIR}/shdrop.rCIDR.del


touch ${DEPENDENCIESDIR}/shdrop_rpz_new.flag

rm /tmp/edrop.txt
rm /tmp/drop.txt

source /opt/process-locking/process-locking-footer.sh

