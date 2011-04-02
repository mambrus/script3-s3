#!/bin/bash
# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2011-04-02

if [ -z $FILES_S3_SH ]; then

FILES_S3_SH="files_s3.sh"

# Creates/updates the set of files.s3 in the structure
#
# The script is a core part of the 'script3' script library

function files_s3() {
	local DIRS=$( find . -type d | egrep -v '\.git' ); for D in $DIRS; 
	do ( 								\
		cd $D; ls -F |					\
		grep -v README |				\
		grep -v 'files\.s3' |			\
		egrep '\*$' |					\
		sed -e 's/\*$//' > files.s3		\
	);  done
}

source s3.ebasename.sh

if [ "$FILES_S3_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.
	files_s3 $@
	exit $?
fi

fi
