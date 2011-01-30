#!/bin/bash

INSTALL_BIN_SH="install_bin.sh"

if [ "x${BINDIR}" == "x" ]; then
  BINDIR=$HOME/bin
fi

if [ -z $USER_RESPONSE_SH ]; then
  source user_response.sh
fi

#Installs arg #1 from where is at, to $BINDIR
function install_bin() {
  local SRC_FILE=$(pwd)/$1

  if [ ! -f $SRC_FILE ]; then
        echo "Error: Trying to install [$SRC_FILE] which doesnt exist."
        ask_user_continue || exit $?
        return 1
  fi
  echo "Installing [$1]..."
  rm -f "${BINDIR}/$1"
  ln -s "$SRC_FILE"     "${BINDIR}/$1"
  chmod a+x "${BINDIR}/$1"
}

if [ "$INSTALL_BIN_SH" == $( basename $0 ) ]; then
  #Not sourced, do something with this.
  install_bin $1
fi

