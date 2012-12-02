#!/bin/bash
# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2011-01-22

if [ -z $UNINSTALL_ALL ]; then

UNINSTALL_ALL="uninstall_all.sh"

function uninstall_all() {
	cd $1
	local FILES=$( \
		ls -al ${1} | \
		egrep '^l' | \
		grep ${2} | \
		cut -f1 -d">" | \
		sed -e 's/ -$//' | \
		sed -e 's/.*[[:space:]]//'
	)

	for F in $FILES; do
		echo "Removing: ${1}/${F}"
		rm -f ${1}/${F}
	done


}

source s3.ebasename.sh

if [ "$UNINSTALL_ALL" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.
	set -e
	source s3.user_response.sh
	BINDIR=$(dirname $( which s3.install_all.sh ) )
    	S3DIR=$(dirname $( dirname $( ls -al $( which s3.install_all.sh ) | \
    		cut -d ">" -f2 ) ) )

	set +u
	ask_user_continue \
		"Brutally remove all links from [${BINDIR}] to [${S3DIR}]? (Y/n)" || exit $?

	set -u

	uninstall_all ${BINDIR} ${S3DIR}
	exit $?
fi

fi
