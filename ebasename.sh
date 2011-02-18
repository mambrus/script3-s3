#!/bin/bash
# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2011-02-18

EBASENAME_SH="ebasename.sh"

# This script works as the basename command, except that it also
# ripps away everything in the name before the next but last '.'
# I.e. usage like:
# $ ebasename /some/path/pre.fix.myshell.sh
#   myshell.sh
#
# The script is a core part of the 'script3' script library

function ebasename() {
	basename $1 | sed -e \
		's/\(.*\)\(\..\+\)\(\..\+$\)/\2\3/;s/^\.//'
}

if [ "$EBASENAME_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.
	ebasename $@
	exit $?
fi
