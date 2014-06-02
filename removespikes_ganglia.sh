#!/bin/bash

# This script can be used to remove traffic spikes in ganglia.
# But only remove spikes of summary rrds for grid and clusters, reserve spikes of hosts.

RRDUSER=nobody
#DIR=$(cd $(dirname $0) && pwd)
DIR=/usr/local/bin
REMOVESPIKE=$DIR/removespikes.pl
RRDDIR=/var/lib/ganglia/rrds
METRICS="
bytes_in
bytes_out
pkts_in
pkts_out
"
CONDITION="-t 1.0e+12"

if [ $USER != 'root' ]; then
    echo you should execute this shell with sudo
    exit 1
fi

cd $RRDDIR
for METRIC in $METRICS; do
    # use s/ /MMMM/g to deal with directory name which contains space.
    RRDFILES=$(find ./ -type f | grep __SummaryInfo__ | grep ${METRIC}.rrd$ | sed -e "s/ /MMMM/g")
    for RRDFILE in $RRDFILES; do
        RRDFILE=$(echo $RRDFILE | sed -e "s/MMMM/ /g")
        su $RRDUSER -c "[ -e $REMOVESPIKE ] &&$REMOVESPIKE -d $CONDITION \"$RRDFILE\" "
        EXITCODE=$?
        if [ $EXITCODE -ne 0 ]; then
            echo EXIT CODE: $EXITCODE, please check
            exit $EXITCODE
        fi
    done
done

