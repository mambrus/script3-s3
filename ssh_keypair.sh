#!/bin/bash

: ${DIALOG=dialog}

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

backtitle="SSH key creation and remote transfer & pairing"
FQDN="localhost"
RUSER="$USER"
PASS=""

function print_help() {
	cat $(which .s3..ssh_keypair.sh) | \
	sed -ne "2,/SSH_KEYPAIR_SH/P" | \
	grep '^#' | sed -e 's/^#//'
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
            	--backtitle "$backtitle" \
            	--insecure \
            	--passwordbox "${RUSER}@${FQDN} password:" 0 0 "$PASS" \
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
	            --backtitle "$backtitle" \
	            --inputbox "Remote host-name:" 0 0 "$FQDN" \
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
	            --backtitle "$backtitle" \
	            --inputbox "Remote account @$FQDN:" 0 0 "$RUSER" \
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
            --backtitle "$backtitle" \
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
            --backtitle "$backtitle" \
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
	password_ui || exit 1
	;;
1)
	FQDN=$1
	ruser_ui    || exit 1
	password_ui || exit 1
	;;
2)
	FQDN=$1
	RUSER=$2
	password_ui || exit 1
	;;
*)
	syntax_ui
	exit 1
	;;
esac

clear


EXPECT='
	spawn .s3..ssh_keypair.sh '"${FQDN}"' '"${RUSER}"'

	set timeout 20
	expect {
		"(yes/no)" {
			send "yes\r"
			exp_continue
		}
		"id_dsa):" {
			send "\r"
			exp_continue
		}
		"passphrase):" {
			send "\r"
			exp_continue
		}
		"passphrase again:" {
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
