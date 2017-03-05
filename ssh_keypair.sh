#!/bin/bash

SSH_KEYPAIR_SCRIPT_DIR=$(dirname $(readlink -f $0))
THIS_SH=$(basename $(readlink -f $0))
source ${SSH_KEYPAIR_SCRIPT_DIR}/ui/.ssh_keypair.sh

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

BACKTITLE="SSH key creation and remote transfer & pairing"

function print_help() {
	sed -ne /EOF/,/EOF/P ${SSH_KEYPAIR_SCRIPT_DIR}/ui/.ssh_keypair.sh | \
		tail -n +2 | head -n -1
}

function handle_rc_ui() {
	local RC=$1

	case $RC in
	2)
		help_ui
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

function password_ui() {
	local RC=1
	while [ $RC -ne 0 ] ; do
		exec 3>&1
		PASS=$($DIALOG \
        	    --clear \
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
	            --clear \
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
	            --clear \
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
	            --clear \
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
			--clear \
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
				"Ron Rivest, Adi Shamir, and Leonard Adleman" \
				"U.S. Patent 4,405,829" \
		2>&1 1>&3 )
		RC=$?
		exec 3>&-

		handle_rc_ui $RC
		RC=$?
	done
}

function help_ui() {
	TMPF=/tmp/ssh_keypair_${USER}_$(date +%y%m%d_%H%M%S.%N)
	print_help>"${TMPF}"

	$DIALOG \
            --backtitle "$BACKTITLE" \
            --keep-window \
            --no-collapse \
            --cr-wrap \
            --trim \
            --title "Manpage - ssh_keypair" \
            --textbox "${TMPF}" 20 80
}

function syntax_ui() {
	#Not sure why the following is needed. yesno box wont work without it.
	params="${@}"

	$DIALOG \
            --clear \
            --backtitle "$BACKTITLE" \
			--no-label "Manpage" \
			--yes-label "Syntax" \
			--title "Syntax error:" \
            --yesno "$(basename $0) ${params}" 0 0
            case $? in
            0)
				$DIALOG \
					--title "Syntax:" \
					--msgbox "$(basename $0) [<FQDN>] [<user>]" 5 45
				echo "Syntax error: $(basename $0) ${@}" 1>&2
				echo "Usage: $(basename $0) [<FQDN>] [<user>]" 1>&2
				echo "Please try again..." 1>&2
				exit 1
                break
            	;;
			esac
	help_ui
}

case $# in
0)
	fqdn_ui     || exit 1
	ruser_ui    || exit 1
	rport_ui    || exit 1
	keytype_ui  || exit 1
	password_ui || exit 1
	;;
1)
	FQDN=$1
	ruser_ui    || exit 1
	rport_ui    || exit 1
	keytype_ui  || exit 1
	password_ui || exit 1
	;;
2)
	FQDN=$1
	RUSER=$2
	rport_ui    || exit 1
	keytype_ui  || exit 1
	password_ui || exit 1
	;;
3)
	FQDN=$1
	RUSER=$2
	RPORT=$3
	keytype_ui  || exit 1
	password_ui || exit 1
	;;
4)
	FQDN=$1
	RUSER=$2
	RPORT=$3
	KEY_TYPE=$4
	password_ui || exit 1
	;;
*)
	syntax_ui
	exit 1
	;;
esac

clear


EXPECT='
	spawn .s3..ssh_keypair.sh '"${FQDN}"' '"${RUSER}"' '"${RPORT}"' '"${KEY_TYPE}"'

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
expect -c "${EXPECT}"
