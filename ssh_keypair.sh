#!/bin/bash

SSH_KEYPAIR_SCRIPT_DIR=$(dirname $(readlink -f $0))
THIS_SH=$(basename $(readlink -f $0))
source ${SSH_KEYPAIR_SCRIPT_DIR}/ui/.ssh_keypair.sh

BACKTITLE="SSH key creation and remote transfer & pairing"

# Terminal helpers
#----------------------------------------------------------
# Useless but kept for reference. Intention was to be used for nested
# dialogs where previous are viable like this:
#			--keep-window \
#			--begin $(( $(mid_Y) - 15 )) $(( $(mid_X) - 15 )) \
#----------------------------------------------------------
function max_Y() {
	tput lines
}

function max_X() {
	tput cols
}

function mid_Y() {
	echo $(( $(max_Y) / 2 ))
}

function mid_X() {
	echo $(( $(max_X) / 2 ))
}
#----------------------------------------------------------
# Prints a time-stamp from a log-file in a format that the date utility
# understands
function fnconvert_2ts() {
	echo "$1" | \
		cut -f4-5 -d"_" | \
		sed -e's/\.log$//' | \
		sed -Ee 's/(..)(..)(..)_(..)(..)(..)\.(.*)/\1-\2-\3 \4:\5:\6.\7/'
}

function handle_rc_ui() {
	local RC=$1

	case $RC in
	2)
		manpage_ui
		;;
	1)
		$DIALOG --yesno "Are you sure?" 0 0 && exit 0
		RC=999
		;;
	0)
		;;
	*)
		echo "Internal error: RC=${RC}" 1>&2
		;;
	esac
	return $RC
}

function manpage_ui() {
	local TMPF=/tmp/ssh_keypair_${USER}_$(date +%y%m%d_%H%M%S.%N)
	$(readlink -f $0) -h >"${TMPF}"

	local HEIGHT=$(tput lines)

	$DIALOG \
			--backtitle "$BACKTITLE" \
			--no-collapse \
			--cr-wrap \
			--trim \
			--title "Manpage - ssh_keypair" \
			--textbox "${TMPF}" $(( HEIGHT - 5 )) 84
	rm $TMPF
}

function viewlog_ui() {
	local NAME="$1"
	local HEIGHT=$(tput lines)
	local TMPF=/tmp/ssh_keypair_${USER}_$(date +%y%m%d_%H%M%S.%N).flog
	fold -w 60 -s "${NAME}" | tr -cd '\11\12\15\40-\176' > "$TMPF"

	$DIALOG \
			--backtitle "$BACKTITLE" \
			--title "Showing log: $TMPF" \
			--textbox "${TMPF}" $(( HEIGHT - 5 )) 84

	#rm $TMPF
}

function password_ui() {
	local RC=1
	while [ $RC -ne 0 ] ; do
		exec 3>&1
		PASS=$($DIALOG \
			--help-button \
			--title "PASS" \
			--backtitle "$BACKTITLE" \
			--insecure \
			--passwordbox "\n${RUSER}@${FQDN} password:" 0 0 "$PASS" \
		2>&1 1>&3 )
		RC=$?
		exec 3>&-

		handle_rc_ui $RC
		RC=$?
	done
}

function fqdn_ui() {
	local RC=1
	while [ $RC -ne 0 ] ; do
		exec 3>&1
		FQDN=$($DIALOG \
			--help-button \
			--title "FQDN" \
			--backtitle "$BACKTITLE" \
			--inputbox "\nRemote host-name:" 0 0 "$FQDN" \
		2>&1 1>&3 )
		RC=$?
		exec 3>&-

		handle_rc_ui $RC
		RC=$?
	done
}

function ruser_ui() {
	local RC=1
	while [ $RC -ne 0 ] ; do
		exec 3>&1
		RUSER=$($DIALOG \
			--help-button \
			--title "RUSER" \
			--backtitle "$BACKTITLE" \
			--inputbox "\nRemote account @$FQDN:" 0 0 "$RUSER" \
		2>&1 1>&3 )
		RC=$?
		exec 3>&-

		handle_rc_ui $RC
		RC=$?
	done
}

function rport_ui() {
	local RC=1
	while [ $RC -ne 0 ] ; do
		exec 3>&1
		RPORT=$($DIALOG \
			--help-button \
			--title "RPORT" \
			--backtitle "$BACKTITLE" \
			--inputbox "\nRemote port:" 0 0 "$RPORT" \
		2>&1 1>&3 )
		RC=$?
		exec 3>&-

		handle_rc_ui $RC
		RC=$?
	done
}

function keytype_ui() {
	local RC=1
	while [ $RC -ne 0 ] ; do
		exec 3>&1
		KEY_TYPE=$($DIALOG \
			--default-item "$KEY_TYPE" \
			--item-help \
			--help-button \
			--backtitle "$BACKTITLE" \
			--title "KEY_TYPE" \
			--menu "\n\
			  Choose key-type:" 10 55 4 \
			"DSA" \
				"Digital Signature Algorithm" \
				"FIPS 186-4 2013" \
			"RSA" \
				"Ron Rivest, Adi Shamir and Leonard Adleman" \
				"U.S. Patent 4,405,829" \
		2>&1 1>&3 )
		RC=$?
		exec 3>&-

		handle_rc_ui $RC
		RC=$?
	done
}

#Run back-end interactively
function exec_backend() {
	local TS=$(date +%y%m%d_%H%M%S.%N)
	local TMPF=/tmp/ssh_keypair_${USER}_${TS}.log

	local EXPECT='
		spawn .s3..ssh_keypair.sh '"${FQDN}"' '"${RUSER}"' '"${RPORT}"' '"${KEY_TYPE}"'
		log_file -noappend -a '"${TMPF}"'

		set timeout 20
		expect {
			"(yes/no)" {
				send_user ">>>Sending \"yes\"<<<"
				send "yes\r"
				exp_continue
			}
			"id_dsa):" {
				send_user ">>>Sending <ENTER><<<"
				send "\r"
				exp_continue
			}
			"id_rsa):" {
				send_user ">>>Sending <ENTER><<<"
				send "\r"
				exp_continue
			}
			"passphrase):" {
				send_user ">>>Sending <ENTER><<<"
				send "\r"
				exp_continue
			}
			"passphrase again:" {
				send_user ">>>Sending <ENTER><<<"
				send "\r"
				exp_continue
			}
			"password:" {
				send_user ">>>Sending password<<<"
				send "'"$PASS"'\r"
				exp_continue
			}
			failed             abort
		}
	'
	screen -dmS exec_backend expect -c "${EXPECT}"
	echo ${TMPF}
}

# Run GUI.
function exec_gui() {
	local RC=1
	while [ $RC -ne 0 ] ; do
		exec 3>&1
		# Note the following Quirk:
		# RC-code will always be 0 if ITEM is declared local
		ITEM=$($DIALOG \
			--help-button \
			--item-help \
			--backtitle "$BACKTITLE" \
			--default-button "extra" \
			--extra-button \
			--extra-label "Run" \
			--ok-label "Select" \
			--cancel-label "Quit" \
			--title "Main menu - run/config" \
			--menu "\nConfirmation / change setting" \
			0 0 0 \
			"HOST" \
				"$FQDN" \
				"Hostname either as FQDN (pref), hostname (if local net) or IP" \
			"RUSER" \
				"$RUSER" \
				"User-account at the remote host" \
			"RPORT" \
				"$RPORT" \
				"SSH port-number at remote" \
			"KEY_TYPE" \
				"$KEY_TYPE" \
				"Key-type to use" \
			"View log" \
				"$LLOG_DATE" \
				"Last log: [$LLOG]" \
		2>&1 1>&3 )
		RC=$?
		exec 3>&-

		case $RC in
		2)
			# Help button
			manpage_ui
			;;
		1)
			# Quit button
			$DIALOG --yesno "Are you sure?" 0 0
			RC=$?
			;;
		0)
			# Change button (was OK)
			local RC=1
			case $ITEM in
			HOST)
				fqdn_ui
				;;
			RUSER)
				ruser_ui
				;;
			RPORT)
				rport_ui
				;;
			KEY_TYPE)
				keytype_ui
				;;
			"View log")
				if [ "X${LLOG}" != "X" ]; then
					viewlog_ui "${LLOG}"
				fi
				;;
			*)
				echo "Internal error: ITEM=${ITEM}" 1>&2
				exit 1
				;;
			esac
			;;
		3)
			# Run button (extra)
			if [ "X${LLOG}" != "X" ]; then
				rm -f ${LLOG}
			fi
			if [ "X${PASS}" == "X" ]; then
				password_ui
			fi
			local LLOG=$(exec_backend)
			local LLOG_DATE=$(date -d "$(fnconvert_2ts $(basename $LLOG))")
			if [ "${REUSE_PWD}" != "yes" ]; then
				PASS="";
			fi
			;;
		*)
			echo "Internal error: RC=${RC}" 1>&2
			exit 1
			;;
		esac

	done
}

if [ "X$TEXT_MODE" == "Xyes" ]; then
	exec .s3..ssh_keypair.sh "${FQDN}" "${RUSER}" "${RPORT}" "${KEY_TYPE}"
fi

if [ "X$(which "$DIALOG")" == "X" ]; then
	echo "Neither dialog nor xdialog installed."\
	     "Falling back to text-based back-end..." 1>&2
	exec .s3..ssh_keypair.sh "${@}"
fi

if [ "X$(which expect)" == "X" ]; then
	echo "Expect not installed."\
	     "Falling back to text-based back-end..." 1>&2
	exec .s3..ssh_keypair.sh "${@}"
fi

exec_gui "${@}"

