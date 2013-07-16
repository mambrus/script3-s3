#! /bin/bash

# These are a couple of lines to make it easier to modify fonts in
# output. Especially useful in ui/.file.sh, i.e. for man-pages/help. Note
# that the following line should end all scripts manipulating the terminal:

# tput sgr0

# Note that escape can be written in different ways:
# \033[
# \e[
# \x1b[

# In some examples "01;" is inserted between the escpae and the code. I don't
# know why and it doesn't seem to matter so it is skipped here (KISS).

# Colors:
FONT_RED='\033[01;31m'
FONT_GREEN='\033[01;32m'
FONT_YELLOW='\033[01;33m'
FONT_PURPLE='\033[01;35m'
FONT_CYAN='\033[01;36m'
FONT_WHITE='\033[01;37m'

     echo -e "\x1b[30m black"
     echo -e "\x1b[31m red"
     echo -e "\x1b[32m green"
     echo -e "\x1b[33m yellow"
     echo -e "\x1b[34m blue"
     echo -e "\x1b[35m mag"
     echo -e "\x1b[36m cyan"
     echo -e "\x1b[37m white"

# Style:
FONT_BOLD='\033[1m'
FONT_UNDERLINE='\033[4m'

# Other:
FONT_NONE='\033[00m'
