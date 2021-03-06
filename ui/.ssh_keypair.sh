# Command-line UI part of all ssh_keypair tool
# This file contains command-line argument and options parsing, and man-page.

: ${KEY_TYPE="RSA"}
: ${FQDN="localhost"}
: ${RUSER="$USER"}
: ${RPORT=22}
: ${PASS=""}
: ${REUSE_PWD="no"}
: ${DIALOG=dialog}

function print_help() {
			cat <<EOF
NAME
    $THIS_SH - Exchange and if needed create ssh-keys

SYNOPSIS
    $THIS_SH [-dritn] [-h host] [-u user] [-s port]
                    [[user@]host[:port]] [host] [user] [port]

DESCRIPTION
    This simple script helps you create and exchange ssh key-pairs with a
    server which you have account and access to. It will handle cases both
    when you have ssh previously initialized or not, either on client- or
    server-side. It handles the nitty-gritty file-permission details that
    are such a common reason for why people tend to spend so much time
    setting up.

    Script can be used both in interactive and command-line mode with or
    without an GUI. GUI is default, but script will fall back to text if
    utilities which are needed for GUI operation are not installed.

    Interactive text-mode is the fall-back if neither arguments nor options
    are given or id -i flag is given.

EXECUTION

    Simplest case scenario:

    If you have initialized ssh on both sides before, all you will need to do
    when running the script is to enter your password 3-times (the script
    itself does not ask you for you password, it's the ssh client used by the
    script that asks you - i.e.  your password will never be eavesdropped or
    compromised in any way).

    Worst case scenario:

    If you haven't initialized ssh on either client or server side, this script
    will run the ssh init procedure for you. In such case, READ carefully what
    ssh is asking you to to. If it asks you for a pass-phrase, just press
    <enter>, if it asks you to answer “yes/no”, answer “yes” (you have to type
    in the answer, there's no default).

OPTIONS
    -d      Use DSA keys (default)

    -r      Use RSA keys

    -i      Interactive text-mode (-t is implicit)

    -n      Non-interactive text-mode (-t is implicit)

    -t      Force text mode. I.e. prevent trying to deploy GUI

    -r      Try to reuse password between iterations

    -H  host
            *host* is the remote machine to exchange keys with

    -U  user
            Remote username *user*. Default is the current localhost user

    -P  port
            Port-number *port*. Default is $DFTL_PORT

    -h      This help

ARGUMENTS
    All arguments to this script are just an alternative way of parsing
    options. Argument parsing precedes options if in conflict.

    Two methods exists:

    Non-interactive text-mode:
        Use *one* argument to express the remote side to not trigger
        interactive mode as follows:

            [user@]host[:port]

        Note that *user* and *port* are optional, but if neither is given
        script needs to be told to be non-interactive explicitly (-n).

    Interactive text-mode:
        This is the default fall-back if $THIS_SH is executed without
        arguments and GUI dependencies are not installed.

ENVIRONMENT
    Environment variables alter default settings. I.e. they are overloaded by
    either options or argument-parsing. They can also be used as a
    way to automate running $THIS_SH without arguments. Especially PASS
    which is not supported neither as option or argument for security
    reasons.

    KEY_TYPE
        Default key-type, "RSA" or "DSA" (see -d, -r)

    FQDN
        Fully Qualified Host Name, hostname or IP-number (see -H)

    RPORT
        Remote side port number (see -P)

    RUSER
        User-account on remote side to exchange keys with (see -R)

    PASS
        Password for remote-side user account

    DIALOG
        Name of dialog-utility. $THIS_SH supports dialog and xdialog.

DEPENDENCIES
    $THIS_SH is dependent of underlying utilities to achieve as high
    level of automation as possible. It will also aim to work even if
    the underlying utilities are not installed by falling back at simpler
    modes of operation. The following utilities are preferably installed,
    with importance from left to right, for full automation:

        expect dialog


AUTHOR
    Michael Ambrus <michael.ambrus at gmail.com>

EOF
}
    #"No" means it will try to use GUI if it can
	TEXT_MODE="no"

	while getopts hdritnH:U:P: OPTION; do
		case $OPTION in
		h)
			if [ -t 1 ]; then
				print_help $0 | less
			else
				print_help $0
			fi
			exit 0
			;;
		d)
			KEY_TYPE="DSA"
			;;
		r)
			KEY_TYPE="RSA"
			;;
		i)
			INTERACTIVE="yes"
			TEXT_MODE="yes"
			;;
		n)
			INTERACTIVE="no"
			TEXT_MODE="yes"
			;;
		t)
			TEXT_MODE="yes"
			;;
		r)
			REUSE_PWD="yes"
			;;
		H)
			FQDN="${OPTARG}"
			;;
		U)
			RUSER="${OPTARG}"
			;;
		P)
			RPORT="${OPTARG}"
			;;
		?)
			echo "Syntax error:" 1>&2
			print_help $0 1>&2
			exit 2
			;;

		esac
	done
	shift $(($OPTIND - 1))
