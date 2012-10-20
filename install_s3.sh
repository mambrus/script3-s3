#!/bin/bash
# Installs a file from the "script3" project

# NOTE: This is not a good example to use as a template
# use ebasename.sh instead for that.

if [ -z $INSTALL_S3_SH ]; then

INSTALL_S3_SH="install_s3.sh"

if [ "x${BINDIR}" == "x" ]; then
	BINDIR=$HOME/bin
fi

set -e

if [ -z $USER_RESPONSE_SH ]; then
	if [ ! -z $(which s3.user_response.sh) ]; then
		source s3.user_response.sh
	else
		#Try locally
		source $(dirname $0)/user_response.sh
	fi
fi

if [ -z $EBASENAME_SH ]; then
	if [ ! -z $(which s3.ebasename.sh) ]; then
		source s3.ebasename.sh
	else
		#Try locally
		source $(dirname $0)/ebasename.sh
	fi
fi

#Installs arg #1 from where is at, to $BINDIR
function install_s3() {
	local SRC_FILE=$(pwd)/$1

	#This one is tricky, it needs to cover two cases
	local OPWD=$(pwd)
	cd $( dirname $0 )
	if  [ -h $( basename $0 ) ]; then
		#We're executing the link. Follow it to get the s3 directory
		cd $( dirname $( ls -al $( basename $0 ) | cut -f2 -d">" ) )
		#exit 0
		cd ..
		local S3_PATH=$(pwd)
	else
		cd ..
		local S3_PATH=$(pwd)
	fi
	cd $OPWD

	#Make S3_PATH escapabele so it might pass sed expanded
	local DS3_PATH=$( echo $S3_PATH | sed -e 's/\//\\\//g' )

	local DST_FILE=$( \
		echo $SRC_FILE | 			\
		sed -e "s/$DS3_PATH//" | 	\
		sed -e 's/^\///' | 			\
		sed -e 's/\//./g' )

	#echo $DST_FILE

	if [ ! -f $SRC_FILE ]; then
		echo "Error: Trying to install [$SRC_FILE] which doesnt exist."
		ask_user_continue || exit $?
		return 1
	fi
	echo "Installing [$1] as [${BINDIR}/${DST_FILE}]..."

	rm -f "${BINDIR}/${DST_FILE}"
	ln -s "$SRC_FILE"     "${BINDIR}/${DST_FILE}"
}

if [ "$INSTALL_S3_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.
	install_s3 $1
fi

fi
