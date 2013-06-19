#!/bin/bash

# From: https://github.com/secure411dotorg/rpzone/blob/master/scripts/nsupdate_hits.sh

# PURPOSE: Update a zone that is only used to pass a record of hits
# between RPZ servers using IXFR
#
# Intended to run on crontab periodically such as hourly
#
# Set response-policy for zone "hits" to DISABLED

# 
# NAME: nsupdate_hits_alternative.sh (part of rpzone helper scripts)

# Alternative re-write by Hugo Connery

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
# FIXME test if any response-policy is even needed for this zone
# FIXME add protection from running multiple copies of script

TODAY=`date +%d-%b-%Y`

# Source data
SOURCE="/var/named/data/named.log.rpz"

# Auditing
QCDIR="/var/named/rpz-quality"
QCLOG="audit_trail_hits.txt"
QC_LOG="$QCDIR/$QCLOG"

# RPZ / Zone interaction
INSTRUCTION="add"
ZONENAME="dc-feedback"

function update()
{
  local tstamp=$1
	local the_host=$2
	local hit=$3
	local hit_zone=$4
	echo "zone ${ZONENAME}"
	echo -n "update ${INSTRUCTION} ${the_host}.${ZONENAME} "
	echo "60 CNAME ${hit}.${hit_zone}"
	echo -e "show\nsend\nanswer"
	# Report to our log
	echo "${tstamp}|update ${INSTRUCTION} ${the_host}.${ZONENAME} 60 CNAME ${hit}.${hit_zone}" >> ${QC_LOG}
}

# More full approach using white listing ...
# grep -F "${TODAY}" $SOURCE |awk '{print $12,$NF}'|sort -u|grep -v alexa5000|grep -v white |\

grep -F "${TODAY}" $SOURCE |awk '{print $12,$NF}'|sort -u| \
while read HIT RULE;do
	# Pull values
	THEHOST=`echo "${RULE}"|rev|cut -d"." -f2-10|rev`
	HITZONE=`echo "${RULE}"|rev|cut -d"." -f1|rev`
	TSTAMP=`date +%s`
	# process, audit log, and update
	update $TSTAMP $THEHOST $HIT $HITZONE | sudo /usr/bin/nsupdate -l
done

exit 0
