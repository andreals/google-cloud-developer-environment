#!/bin/bash
set -x

# Get command options
export project="$1"
export zone="$2"
export vm="$3"
echo "Launching instance $project/$zone/$vm ..."

# Alias with project/zone options
gcloud="gcloud --project=$project"

# Check current status first
export status="$($gcloud compute instances describe --zone=$zone --format="value(status)" $vm)"
echo "$project/$zone/$vm: $status"

# Launch if not running yet
if [ "$status" != "RUNNING" ]; then
    $gcloud compute instances start --zone=$zone $vm || true
fi

# Wait to boot
count=0
while ! $gcloud compute instances get-serial-port-output --zone=$zone $vm | grep 'Startup finished in' ; do
	sleep 1
	count=$(( count + 1 ))
	if [ $count -gt 30 ] ; then
		echo "Timed out after $count attempts"
		exit 1
	fi
done
echo "Instance launched."
