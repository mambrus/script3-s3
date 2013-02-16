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

	S3DIR=$(dirname $0)
	if [ ! -d $S3DIR ]; then
		echo "Fatal error: [$S3DIR] does not exist." 1>&2
		exit 1
	fi
	OPWD=$(pwd)
	cd ${S3DIR}
	cd ..
	S3DIR=$(pwd)
	cd ${OPWD}

	set +e
	ME4REAL=$(
		file $0 | \
		grep "symbolic link" | \
		sed -e 's/^.*symbolic link.*`//' | \
		sed -e "s/'"'.*$//')
	set -e
	if [ "X${ME4REAL}" != "X" ]; then
		S3DIR=$(dirname "${ME4REAL}")
		if [ ! -d $S3DIR ]; then
			echo "Fatal error: [$S3DIR] does not exist." 1>&2
			exit 1
		fi
		OPWD=$(pwd)
		cd ${S3DIR}
		cd ..
		S3DIR=$(pwd)
		cd ${OPWD}
	fi

	BINDIR=$(dirname $( which s3.install_all.sh ) )
	if [ "X${BINDIR}" == "X" ]; then
			echo "Error: S3 doesnt seem to have been previously installed,"\
			"or is allready uninstalled" 1>&2
			exit 1
	fi

	set +u
	ask_user_continue \
		"Remove all links from [${BINDIR}] to [${S3DIR}]? (Y/n)" || exit $?

	set -u

	uninstall_all ${BINDIR} ${S3DIR}
	exit $?
fi

fi
