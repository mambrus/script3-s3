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

	#This one is tricky. There exist 4 cases, we need to cover 3.
	local OPWD=$(pwd)

	cd $( dirname $0 )
	#Whe use the script itself to figure out which s3 it belongs to
	if  [ -h $( basename $0 ) ]; then
		#Case 2.
		#We're executing the link. Follow it to get the s3 directory
		cd $( dirname $( ls -al $( basename $0 ) | cut -f2 -d">" ) )
		cd ..
		local S3_PATH=$(pwd)
	else
		#Case 1.
		#This is the case when no previous s3 has been installed
		#I.e Installing by cd mypath/source3; s3/install_all
		cd ..
		local S3_PATH=$(pwd)
	fi
	cd $OPWD

	#Case 3.
	#S3_PATH must be a part of SRC_FILE (the one we're installing), or it's
	#*not* part of this s3 (but we want to install it anyway). Installing
	#without this case will also work, but the names in ~/bin are too long as
	#the become full path's, hence worthless.

	#In this case it's is assumed that the installer wants to give the link
	#a name relative to where he stands. Allow that by detecting the case.
	#NOTE: these installs will nu be un-installable by uninstall_all.sh and
	#need to be un-installed manually.
	BELONGS_TO_THIS_S3=$(echo -n "${S3_PATH};${OPWD}" | awk -F";" '{
		rc=index($2,$1);
		if (rc == 0)
			printf("no\n");
		else
			printf("yes\n");
	}')

	if [ "X${BELONGS_TO_THIS_S3}" == "Xyes" ]; then
		echo "All OK" > /dev/null
	elif [ "X${BELONGS_TO_THIS_S3}" == "Xno" ]; then
		echo "Warning: [${1}] does not belong to S3 in [${S3_PATH}]" 1>&2
		set +e
		ask_user_continue \
		   "Install anyway (fake S3_DIR)?"\
" NOTE: Any uninstallations bust be done manually (Y/n)" \
		   "Installing..." \
		   "Skipping..." \
		   "Y"
		RC=$?
		set -e

		if [ $RC -eq 0 ]; then
			#Fake S3_DIR path
			S3_PATH="${OPWD}"
		else
			return 1
		fi
	else
		echo "Internal Error: Can't install [${1}->${S3_PATH}]" 1>&2
		exit 0
	fi

	#Make S3_PATH escapable so it might pass sed expanded
	local DS3_PATH=$( echo $S3_PATH | sed -e 's/\//\\\//g' )

	#Subtract the absolute path part to S3 itself and convert
	#slashes to dots in the rest so to be usable as filenames.
	local DST_FILE=$( \
		echo $SRC_FILE | 			\
		sed -e "s/$DS3_PATH//" | 	\
		sed -e 's/^\///' | 			\
		sed -e 's/\//./g' )

	echo "${1}" | egrep '^\.|\/\.' >/dev/null && \
		DST_FILE=".${DST_FILE}"

	#echo $DST_FILE

	if [ ! -f $SRC_FILE ]; then
		echo "Error: Trying to install [$SRC_FILE] which doesn't exist."
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
