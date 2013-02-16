#!/bin/bash
# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2011-04-02

if [ -z $FILES_S3_SH ]; then

FILES_S3_SH="files_s3.sh"

# Creates/updates the set of files.s3 in the current subdirectory
# recursivly.
#
# The script is a core part of the 'script3' script library

function files_s3() {
	local DIRS=$( find . -type d | egrep -v '\.git' | egrep -v '\.repo' )
	for D in $DIRS
	do ( 								\
		cd $D; ls -aF |					\
		grep -v README |				\
		grep -v 'files\.s3' |			\
		#Include only executable files, or files starting with '.' \
		egrep '\*$|^\.[[:alpha:]]' |	\
		sed -e 's/\*$//' |				\
		#Avoid special files lingering around (vim swap-files e.t.a.) \
		egrep -v '\.swp$|^.git/$|^.repo/$' | \
		cat -- > files.s3
	);  done
}

#Need to handle cases where s3 isn't installed yet
if [ ! -z $(which s3.ebasename.sh) ]; then
	source s3.ebasename.sh
else
	#Try locally
	source $(dirname $0)/ebasename.sh
fi

if [ "$FILES_S3_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.
	files_s3 $@
	exit $?
fi

fi
