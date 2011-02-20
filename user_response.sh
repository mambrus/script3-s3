#!/bin/bash
#Author: Michael Ambrus (michael.ambrus@sonyericsson.com)
# 2010-03-01

if [ -z $USER_RESPONSE_SH ]; then

USER_RESPONSE_SH="user_response.sh"

#Example of various ways to use this function:
# 1)
#	ask_user_continue || exit $?
#
# 2)
#	set +e
#	ask_s3.user_continue \
#		"Continue with patching project [$PROJ]? (Y/n)"\
#		"Patching..."\
#		"Skipping..."
#	RC=$?
#	:
# 	set -e
#	if [ $RC -eq 0 ]; then
#		do_first_choice
#	else
#		do_second_choice
#	done

function ask_user_continue() {
	local INIT_QUESTION=$1
	local Y_STRING=$2
	local N_STRING=$3
	local DEFAULT_ANSWER=$4

	#set defaults
	if [ "X${INIT_QUESTION}" == "X" ]; then
		INIT_QUESTION="Would you like to continue? (Y/n)"
	fi
	if [ "X${Y_STRING}" == "X" ]; then
		Y_STRING="Continuing..."
	fi
	if [ "X${N_STRING}" == "X" ]; then
		N_STRING="Aborting..."
	fi
	if [ "X${DEFAULT_ANSWER}" == "X" ]; then
		DEFAULT_ANSWER="Y"
	fi

	local ANSWER
	while [ "x$ANSWER" != "xY" -a "x$ANSWER" != "xy" ]
	do
		echo "$INIT_QUESTION"
		local DEFAUask_user_continueLT_ANSWER="Y"
		read ANSWER
		if [ -z "$ANSWER" ] ; then
			ANSWER=$DEFAULT_ANSWER
		fi
		case $ANSWER in
		"")
			ANSWER=$DEFAULT_ANSWER
			;;
		Y)
			echo "$Y_STRING"
			;;
		y)
			echo "$Y_STRING"
			;;
		N)
			echo "$N_STRING"
			return 2
			;;
		n)
			echo "$N_STRING"
			return 2
			;;
		*)
			echo
			echo "I didn't understand your response.  Please try again."
			echo
			;;
		esac
    done
    return 0
}

if [ "$USER_RESPONSE_SH" == $( basename $0 ) ]; then
  #Not sourced, do something with this.
  ask_user_continue "$@"
  exit $?
fi

fi
