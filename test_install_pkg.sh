#!/bin/bash
# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2011-01-22

if [ -z $TEST_INSTALL_PKG_SH ]; then

TEST_INSTALL_PKG_SH="test_install_pkg.sh"

# Tests for a package, and if not installed then install it
function test_install_pkg() {
	local PACKV=$(\
	dpkg-query -l "${1}" | \
	grep "ii" | \
	sed -e 's/^[[:graph:]]\+[[:space:]]\+[[:graph:]]\+[[:space:]]\+//' | \
	cut -f1 -d" "\
	);
	#echo $PACKV

	if [ -z $PACKV ]; then
	set +e
	ask_user_continue \
		"Package [$1] not installed, install & continue? (Y/n)"\
		"Installing [$1]..."\
		"Can't continue without [$1]. Exiting..."
	RC=$?
	set -e
	if [ $RC -eq 0 ]; then
		sudo apt-get install $1
		RC=$?
	else
		return 1
	fi
	fi
	return $RC
}

source s3.ebasename.sh

if [ "$TEST_INSTALL_PKG_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.
	source user_response.sh

	test_install_pkg $@
	exit $?
fi

fi
