#!/bin/bash
# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2011-01-22

if [ -z $TEST_INSTALL_BIN_SH ]; then

TEST_INSTALL_BIN_SH="test_install_bin.sh"

# Tests for an executable, and if not found in path then install it
function test_install_bin() {
	if [ -z $(which $1) ]; then
	set +e
	ask_user_continue \
		"No [$1] found, install & continue? (Y/n)"\
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

if [ "$TEST_INSTALL_BIN_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.
	source user_response.sh

	test_install_pkg "$@"
	exit $?
fi

fi
