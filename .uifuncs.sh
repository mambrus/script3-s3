#! /bin/bash
# script3 ui helper-functions
# File to be sourced. Contains bare-bone functions only.

function print_man_header() {
	local CMD_STR="$(basename ${0})(7)"
	local STR_LEN=$(expr length ${CMD_STR})
	local N_WHITES=$(( 80 - STR_LEN - STR_LEN ))

	echo -n $CMD_STR | tr '[:lower:]' '[:upper:]'
	for (( I=0; I<$N_WHITES; I++ )); do
		echo -n " "
	done
	echo $CMD_STR | tr '[:lower:]' '[:upper:]'
}
