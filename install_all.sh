#!/bin/bash
# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2011-02-18

if [ -z $INSTALL_ALL_SH ]; then

INSTALL_ALL_SH="install_all.sh"

# Installs files from the "script3" project
#
# It looks for the file files.s3 in each subdirectory from underneath it's
# executed recursively. Each files.s3 is listing the files to be installed from
# that directory. A simple way to create such a file:
#
# ls | grep -v README | grep -v files.s3 > files.s3
#
# This script is a core part of the 'script3' script library

set -e

if [ -z $INSTALL_S3_SH ]; then
	if [ ! -z $(which s3.install_s3.sh) ]; then
		source s3.install_s3.sh
	else
		#Try locally
		source $(dirname $0)/install_s3.sh
	fi
fi
if [ -z $USER_RESPONSE_SH ]; then
	if [ ! -z $(which s3.user_response.sh) ]; then
		source s3.user_response.sh
	else
		#Try locally
		source $(dirname $0)/user_response.sh
	fi
fi
if [ -z $FILES_S3_SH ]; then
	if [ ! -z $(which s3.files_s3.sh) ]; then
		source s3.files_s3.sh
	else
		#Try locally
		source $(dirname $0)/files_s3.sh
	fi
fi

function install_all() {
	local LFILES=$( find . -name files.s3 )
	local LF
	local F

	for LF in $LFILES;  do

		#Make LF_PATH escapable so it might pass sed expanded
		local LF_PATH=$( dirname $LF | sed -e 's/\//\\\//g' )

		IFILES=$( (
			cd $( dirname $LF)
			cat files.s3 | \
				sed -e "s/\(^\)\(.*\)/$LF_PATH\/\2/" | \
					sed -e 's/^\.\///'
		) )
		for F in $IFILES; do
			#echo $F
			install_s3 $F
		done
	done
}

if [ "$INSTALL_ALL_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.

	echo "This will install S3 in ~/bin." \
		 "Any previous installation will be overwritten/updated. Make sure you have"\
		 "write permissions both in the installation directory and in the source."
	ask_user_continue || exit 1

	#Create/update all files.s3 files
	files_s3

	install_all $@
	exit $?
fi

fi
