#!/bin/sh

LOG_PATH="$1"

# TODO: shorter time intervals at the start of the script and gradually longer time intervals in later stages

beginTime=`date +%s%3N`

while true; do
	# store the time for timestamping in the logs
	currentTime=`date +%s%3N`
	elapsedTime=$((currentTime - beginTime))

	# load files first
	memoryStats=`cat '/sys/fs/cgroup/memory/memory.stat'`
	memoryUsage=`cat '/sys/fs/cgroup/memory/memory.usage_in_bytes'`
	cpuStats=`cat '/sys/fs/cgroup/cpuacct/cpuacct.stat'`

	# gather metrics
	activeAnon=`echo "$memoryStats" | grep '^total_active_anon ' | cut -d ' ' -f 2`
	inactiveAnon=`echo "$memoryStats" | grep '^total_inactive_anon ' | cut -d ' ' -f 2`

	userTime=`echo "$cpuStats" | grep '^user ' | cut -d ' ' -f 2`
	systemTime=`echo "$cpuStats" | grep '^system ' | cut -d ' ' -f 2`

	anonymousMemory=$(($activeAnon + $inactiveAnon))

	# write to logs
	printf "%s\t%s\n" "$elapsedTime" "$memoryUsage" >> "$LOG_PATH/memory_usage.logs"
	printf "%s\t%s\n" "$elapsedTime" "$activeAnon" >> "$LOG_PATH/anonymous_memory.logs"
	printf "%s\t%s\n" "$elapsedTime" "$anonymousMemory" >> "$LOG_PATH/total_anonymous_memory.logs"
	printf "%s\t%s\n" "$elapsedTime" "$userTime" >> "$LOG_PATH/user_time.logs"
	printf "%s\t%s\n" "$elapsedTime" "$systemTime" >> "$LOG_PATH/system_time.logs"

	# wait a bit
	sleep 0.05
done
