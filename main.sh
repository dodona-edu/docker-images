#!/bin/bash

# process arguments
RUNNER_SCRIPT=$1

# kill all child processes on exit
trap "pkill -P $$" EXIT

# switch to user "runner" and start the script
su runner -c "PATH='$PATH' ${RUNNER_SCRIPT}"
