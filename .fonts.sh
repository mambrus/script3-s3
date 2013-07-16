#! /bin/bash

# These are a couple of lines to make it easier to modify fonts in
# output. Especially useful in ui/.file.sh, i.e. for man-pages/help. Note
# that the following line should end all scripts manipulating the terminal:

# tput sgr0

# Note that escape sequence can be written in several different (valid) 
# ways:
# \e[
# \033[
# \x1b[


# If pipe is open and is stdout (=1), only then
if [ -t 1 ] ; then
# Color (foreground):
	BLACK='\e[30m'
	BLUE='\e[34m'
	GREEN='\e[32m'
	CYAN='\e[36m'
	RED='\e[31m'
	PURPLE='\e[35m'
	BROWN='\e[33m'
	LIGHT_GRAY='\e[37m'
	DARK_GRAY='\e[1;30m'
	LIGHT_BLUE='\e[1;34m'
	LIGHT_GREEN='\e[1;32m'
	LIGHT_CYAN='\e[1;36m'
	LIGHT_RED='\e[1;31m'
	LIGHT_PURPLE='\e[1;35m'
	YELLOW='\e[1;33m'
	WHITE='\e[1;37m'

# Color (explicit foreground):
	FG_BLACK=$BLACK
	FG_BLUE=$BLUE
	FG_GREEN=$GREEN
	FG_CYAN=$CYAN
	FG_RED=$RED
	FG_PURPLE=$PURPLE
	FG_BROWN=$BROWN
	FG_LIGHT_GRAY=$LIGHT_GRAY
	FG_DARK_GRAY=$DARK_GRAY
	FG_LIGHT_BLUE=$LIGHT_BLUE
	FG_LIGHT_GREEN=$LIGHT_GREEN
	FG_LIGHT_CYAN=$LIGHT_CYAN
	FG_LIGHT_RED=$LIGHT_RED
	FG_LIGHT_PURPLE=$LIGHT_PURPLE
	FG_YELLOW=$YELLOW
	FG_WHITE=$WHITE

	BG_BLACK='\e[40m'
	BG_RED='\e[41m'
	BG_GREEN='\e[42m'
	BG_BROWN='\e[43m'
	BG_BLUE='\e[44m'
	BG_PURPLE='\e[45m'
	BG_CYAN='\e[46m'
	BG_LIGHT_GRAY='\e[47m'

# Style:
	FONT_NONE='\e[0m'
	FONT_BOLD='\e[1m'
	FONT_NORMAL='\e[2m'

	FONT_UNDERLINE='\e[4m'
	FONT_BLINK='\e[5m'
	FONT_INVERT='\e[7m'

fi
