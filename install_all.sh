#!/bin/bash
# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2011-02-18

INSTALL_ALL_SH="install_all.sh"

# Installs files from the "stript3" project
# 
# It looks for the file files.s3 in each subdirectory from underneeth it's
# executed recursivly. Each files.s3 is listing the files to be installed from
# that directory. A simple way to create such a file:
# 
# ls | grep -v README > files.s3 
#
# Or recursivly:
#
# DIRS=$( find . -type d | grep -v .git ); for D in $DIRS; \
#   do (cd $D; ls | grep -v README > files.s3) ;  done
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


function install_all() {
	local DIRS=$( find . -name files.s3 ) 
	for D in $DIRS;  do 
		(cd $D; cat files.s3 );  
	done
}

if [ "$INSTALL_ALL_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.
	install_all $@
	exit $?
fi
