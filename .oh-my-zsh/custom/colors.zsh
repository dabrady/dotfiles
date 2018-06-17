### Colors for shell text ###
# Reset
COLOR_OFF='\001\e[0m\002'       # Text Reset

# tput colors
TRED="$(tput setaf 1)"
TGREEN="$(tput setaf 2)"
TYELLOW="$(tput setaf 3)"
TBLUE="$(tput setaf 4)"
TPURPLE="$(tput setaf 5)"
TCYAN="$(tput setaf 6)"
TWHITE="$(tput setaf 7)"
TCOLOR_BOLD="$(tput bold)"
TCOLOR_UNDR="$(tput sgr 0 1)"
TCOLOR_RESET="$(tput sgr0)"

# Regular Colors
BLACK='\001\e[0;30m\002'        # Black
RED='\001\e[0;31m\002'          # Red
GREEN='\001\e[0;32m\002'        # Green
YELLOW='\001\e[0;33m\002'       # Yellow
BLUE='\001\e[0;34m\002'         # Blue
PURPLE='\001\e[0;35m\002'       # Purple
CYAN='\001\e[0;36m\002'         # Cyan
WHITE='\001\e[0;37m\002'        # White
DARKGREY='\001\e[0;90m\002'       # Dark Grey

# Bold
B_BLACK='\001\e[1;30m\002'       # Black
B_RED='\001\e[1;31m\002'         # Red
B_GREEN='\001\e[1;32m\002'       # Green
B_YELLOW='\001\e[1;33m\002'      # Yellow
B_BLUE='\001\e[1;34m\002'        # Blue
B_PURPLE='\001\e[1;35m\002'      # Purple
B_CYAN='\001\e[1;36m\002'        # Cyan
B_WHITE='\001\e[1;37m\002'       # White
B_DARKGREY='\001\e[1;90m\002'    # Dark Grey

# Underline
U_BLACK='\001\e[4;30m\002'       # Black
U_RED='\001\e[4;31m\002'         # Red
U_GREEN='\001\e[4;32m\002'       # Green
U_YELLOW='\001\e[4;33m\002'      # Yellow
U_BLUE='\001\e[4;34m\002'        # Blue
U_PURPLE='\001\e[4;35m\002'      # Purple
U_CYAN='\001\e[4;36m\002'        # Cyan
U_WHITE='\001\e[4;37m\002'       # White
U_DARKGREY='\001\e[4;90m\002'    # Dark Grey

# Background
ON_BLACK='\001\e[40m\002'       # Black
ON_RED='\001\e[41m\002'         # Red
ON_GREEN='\001\e[42m\002'       # Green
ON_YELLOW='\001\e[43m\002'      # Yellow
ON_BLUE='\001\e[44m\002'        # Blue
ON_PURPLE='\001\e[45m\002'      # Purple
ON_CYAN='\001\e[46m\002'        # Cyan
ON_WHITE='\001\e[47m\002'       # White

# High Intensity
I_BLACK='\001\e[0;90m\002'       # Black
I_RED='\001\e[0;91m\002'         # Red
I_GREEN='\001\e[0;92m\002'       # Green
I_YELLOW='\001\e[0;93m\002'      # Yellow
I_BLUE='\001\e[0;94m\002'        # Blue
I_PURPLE='\001\e[0;95m\002'      # Purple
I_CYAN='\001\e[0;96m\002'        # Cyan
I_WHITE='\001\e[0;97m\002'       # White

# Bold High Intensity
BI_BLACK='\001\e[1;90m\002'      # Black
BI_RED='\001\e[1;91m\002'        # Red
BI_GREEN='\001\e[1;92m\002'      # Green
BI_YELLOW='\001\e[1;93m\002'     # Yellow
BI_BLUE='\001\e[1;94m\002'       # Blue
BI_PURPLE='\001\e[1;95m\002'     # Purple
BI_CYAN='\001\e[1;96m\002'       # Cyan
BI_WHITE='\001\e[1;97m\002'      # White

# High Intensity backgrounds
ON_I_BLACK='\001\e[0;100m\002'   # Black
ON_I_RED='\001\e[0;101m\002'     # Red
ON_I_GREEN='\001\e[0;102m\002'   # Green
ON_I_YELLOW='\001\e[0;103m\002'  # Yellow
ON_I_BLUE='\001\e[0;104m\002'    # Blue
ON_I_PURPLE='\001\e[0;105m\002'  # Purple
ON_I_CYAN='\001\e[0;106m\002'    # Cyan

# ALL THE COLORS
_STDCOLORS=($BLACK $RED $GREEN $YELLOW $BLUE $PURPLE $CYAN $WHITE $DARKGREY)
_BLDCOLORS=($B_BLACK $B_RED $B_GREEN $B_YELLOW $B_BLUE $B_PURPLE $B_CYAN $B_WHITE $B_DARKGREY)
_UNDCOLORS=($U_BLACK $U_RED $U_GREEN $U_YELLOW $U_BLUE $U_PURPLE $U_CYAN $U_WHITE $U_DARKGREY)
_ALLCOLORS=(${_STDCOLORS[*]} ${_BLDCOLORS[*]} ${_UNDCOLORS[*]})
