#!/bin/bash
#
# Note that this script can be sourced, i.e. you can use it as a “script
# library” for your own higher abstraction scripting. i.e. you could add a
# nice GUI on top of it..
#
# Author: michael.ambrus(-at-)gmail.com 2010-01-23

if [ -z $SSH_KEYPAIR_SH ]; then

SSH_KEYPAIR_SH="ssh_keypair.sh"

# Creates a script that will go on the server-side
function create_srvscript() {
	echo "#! /bin/bash"									 	 >"$1"
	echo "set -e"											>>"$1"
	echo "TS=$2"											>>"$1"
	echo -n 'echo "Auto-generated script '					>>"$1"
	echo -n "$TS"											>>"$1"
	echo '. Please remove if not in use"'					>>"$1"
	echo "set -u"											>>"$1"
	echo 'echo; echo'										>>"$1"
	echo "if [ ! -d ~/.ssh ]; then"							>>"$1"
	echo '	echo "~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~'\
				 '~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~"'	>>"$1"

	echo '	echo "Remote side [~/.ssh] directory missing."'	>>"$1"
	echo '	echo "Initializing..."'							>>"$1"
	echo '	echo "~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~'\
				 '~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~"'	>>"$1"
	echo "	ssh-keygen -t dsa"								>>"$1"
	echo 'echo; echo'										>>"$1"
	echo "fi;"												>>"$1"
	echo 'echo "~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~'\
				'~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~"'	>>"$1"
	echo 'echo Adding transferred key id_dsa_${TS}.pub to authorized_keys2'	>>"$1"
	echo "cd ~/.ssh"										>>"$1"
	echo 'cat "/tmp/id_dsa_${TS}.pub" >> authorized_keys2'	>>"$1"
	echo "chmod 640 authorized_keys2"						>>"$1"
	echo 'echo; echo'										>>"$1"
	echo 'echo Removing temporary transferred key "/tmp/id_dsa_${TS}.pub"'	>>"$1"
	echo 'rm "/tmp/id_dsa_${TS}.pub"'										>>"$1"
	echo 'echo Server is removing script "/tmp/ssh_server_$TS.sh"'		>>"$1"
	echo 'echo "~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~'\
				'~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~"'	>>"$1"
	echo 'rm "/tmp/ssh_server_$TS.sh"'						>>"$1"
	echo 'cd $OLDPWD'										>>"$1"
	chmod 0777 "$1"
}

# If necessary, Creates a local public key. Then transfers it to the
# the server side
function local_key_copy() {
	local USER="$1"
	local REMOTE="$2"
	local PORT="$3"
	local TS="$4"

	echo; echo
	if [ ! -d ~/.ssh ]; then
		echo 	"~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~"\
				"~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~"
		echo "[~/.ssh] directory missing. Initializing..."
		echo 	"~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~"\
				"~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~"
		ssh-keygen -t dsa
		echo; echo
	fi;
	if [ ! -f ~/.ssh/id_dsa.pub ]; then
		echo 	"~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~"\
				"~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~"
		echo "Public keyfile [~/.ssh/id_dsa.pub] missing. Creating one..."
		echo 	"~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~"\
				"~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~"
		ssh-keygen -t dsa -f ~/.ssh/id_dsa
		echo; echo
	fi;

	echo 	"~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~"\
			"~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~"
	echo "Transfering your public key to the server using the following command:"
	echo "scp -P${PORT} ~/.ssh/id_dsa.pub ${USER}@${REMOTE}:/tmp/id_dsa_${TS}.pub"
	echo "(You will need to enter password)"
	echo 	"~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~"\
			"~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~"
	echo; echo
	scp -P${PORT} ~/.ssh/id_dsa.pub ${USER}@${REMOTE}:/tmp/id_dsa_${TS}.pub
	echo; echo
}

# Wrapper to the script itself. I.e. you can use this function as it would
# be the script itself if you source it.
function ssh_keypair() {
	set -e

	local SRV_SCRIPT
	local REMOTE_SERVER="$1"
	local REMOTE_USER="$2"
	local REMOTE_PORT="$3"

	if [ -z "$TS" ]; then
		local TS=$(date "+%y%m%d_%H%M%S")
	fi

	SRV_SCRIPT=ssh_server_"$TS".sh
	if [ -z "$REMOTE_SERVER" ]; then
		echo -n "Enter the remote server name (FQDN): "
		read REMOTE_SERVER
	fi;
	if [ -z "$REMOTE_USER" ]; then
		echo -n "Enter the account to use at the server: "
		read REMOTE_USER
	fi;
	if [ -z "$REMOTE_PORT" ]; then
		echo -n "Enter remote port (empty = use default port 22): "
		read REMOTE_PORT
	fi;
	set -u

	if [ "X${REMOTE_PORT}" == "X" ]; then
		local REMOTE_PORT=22
	fi

	create_srvscript "/tmp/local_${SRV_SCRIPT}" "$TS"
	local_key_copy "$REMOTE_USER" "$REMOTE_SERVER" "$REMOTE_PORT" "$TS"

	echo 	"~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~"\
			"~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~"
	echo "Transferring server-side script using the following command:"
	echo	"scp \"/tmp/local_${SRV_SCRIPT}"\
			"${REMOTE_USER}@${REMOTE_SERVER}:/tmp/${SRV_SCRIPT}\""
	echo "(You will need to enter password)"
	echo 	"~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~"\
			"~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~"
	echo; echo
	scp -P"${REMOTE_PORT}" "/tmp/local_${SRV_SCRIPT}" \
		"${REMOTE_USER}@${REMOTE_SERVER}:/tmp/${SRV_SCRIPT}"
	echo; echo

	echo 	"~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~"\
			"~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~"
	echo "Running server-side script using the following command:"
	echo "ssh -p${REMOTE_PORT} \"${REMOTE_USER}@${REMOTE_SERVER}\" \"/tmp/${SRV_SCRIPT}\""
	echo "(You will need to enter password)"
	echo 	"~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~"\
			"~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~"
	ssh -p${REMOTE_PORT} "${REMOTE_USER}@${REMOTE_SERVER}" "/tmp/${SRV_SCRIPT}"
	echo; echo
	echo 	"~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~"\
			"~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~"
	echo "Key-pair binding with ${REMOTE_USER}@${REMOTE_SERVER} is done"
	echo "You should now be able to log in without a password"
	echo "If not, consider the workaround at this link:"
	echo " https://bugs.launchpad.net/ubuntu/+source/openssh/+bug/201786"
	echo 	"~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~"\
			"~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~ ~-~"
	sleep 2
	#Done with it, remove local copy
	echo "[$HOSTNAME] is removing script /tmp/local_${SRV_SCRIPT}"
	rm -f "/tmp/local_${SRV_SCRIPT}"
}

source s3.ebasename.sh
if [ "$SSH_KEYPAIR_SH" == $( ebasename $0 ) ]; then
	#The script is not sourced. I.e. it's actually supposed do something"
	ssh_keypair $@
fi

fi
