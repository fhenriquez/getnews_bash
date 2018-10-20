#########################################################################
# Name: Franklin Henriquez                                              #
# Author: Franklin Henriquez (franklin.a.henriquez@gmail.com)           #
# Creation Date: 19Oct2018                                              #
# Last Modified: 20Oct2018                                              #
# Description:	Gets news from https://newsapi.org/                     #
#               Accepts a valid news-id and returns the top headlines.  #
#                                                                       #   
# Version: 1.0.0                                                        #
#                                                                       #   
#########################################################################

#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

set -o errexit
#set -o pipefail
set -o nounset
# set -o xtrace

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app

# DESC: Handler for unexpected errors
# ARGS: $1 (optional): Exit code (defaults to 1)
function script_trap_err() {
    # Disable the error trap handler to prevent potential recursion
    trap - ERR

    # Consider any further errors non-fatal to ensure we run to completion
    set +o errexit
    set +o pipefail

    # Exit with failure status
    if [[ $# -eq 1 && $1 =~ ^[0-9]+$ ]]; then
        exit "$1"
    else
        exit 1
    fi
}


# DESC: Handler for exiting the script
# ARGS: None
function script_trap_exit() {
    cd "$orig_cwd"

    # Restore terminal colours
    printf '%b' "$ta_none"
}


# DESC: Exit script with the given message
# ARGS: $1 (required): Message to print on exit
#       $2 (optional): Exit code (defaults to 0)
function script_exit() {
    if [[ $# -eq 1 ]]; then
        printf '%s\n' "$1"
        exit 0
    fi

    if [[ $# -eq 2 && $2 =~ ^[0-9]+$ ]]; then
        printf '%b\n' "$1"
        # If we've been provided a non-zero exit code run the error trap
        if [[ $2 -ne 0 ]]; then
            script_trap_err "$2"
        else
            exit 0
        fi
    fi

    script_exit "Invalid arguments passed to script_exit()!" 2
}

# DESC: Generic script initialisation
# ARGS: None
function script_init() {
    # Useful paths
    readonly orig_cwd="$PWD"
    readonly script_path="${BASH_SOURCE[0]}"
    readonly script_dir="$(dirname "$script_path")"
    readonly script_name="$(basename "$script_path")"

    # Important to always set as we use it in the exit handler
    readonly ta_none="$(tput sgr0 || true)"
}

# DESC: Initialise colour variables
# ARGS: None
function colour_init() {
    if [[ -z ${no_colour-} ]]; then
        # Text attributes
        readonly ta_bold="$(tput bold || true)"
        printf '%b' "$ta_none"
        readonly ta_uscore="$(tput smul || true)"
        printf '%b' "$ta_none"
        readonly ta_blink="$(tput blink || true)"
        printf '%b' "$ta_none"
        readonly ta_reverse="$(tput rev || true)"
        printf '%b' "$ta_none"
        readonly ta_conceal="$(tput invis || true)"
        printf '%b' "$ta_none"

        # Foreground codes
        readonly fg_black="$(tput setaf 0 || true)"
        printf '%b' "$ta_none"
        readonly fg_blue="$(tput setaf 4 || true)"
        printf '%b' "$ta_none"
        readonly fg_cyan="$(tput setaf 6 || true)"
        printf '%b' "$ta_none"
        readonly fg_green="$(tput setaf 2 || true)"
        printf '%b' "$ta_none"
        readonly fg_magenta="$(tput setaf 5 || true)"
        printf '%b' "$ta_none"
        readonly fg_red="$(tput setaf 1 || true)"
        printf '%b' "$ta_none"
        readonly fg_white="$(tput setaf 7 || true)"
        printf '%b' "$ta_none"
        readonly fg_yellow="$(tput setaf 3 || true)"
        printf '%b' "$ta_none"

        # Background codes
        readonly bg_black="$(tput setab 0 || true)"
        printf '%b' "$ta_none"
        readonly bg_blue="$(tput setab 4 || true)"
        printf '%b' "$ta_none"
        readonly bg_cyan="$(tput setab 6 || true)"
        printf '%b' "$ta_none"
        readonly bg_green="$(tput setab 2 || true)"
        printf '%b' "$ta_none"
        readonly bg_magenta="$(tput setab 5 || true)"
        printf '%b' "$ta_none"
        readonly bg_red="$(tput setab 1 || true)"
        printf '%b' "$ta_none"
        readonly bg_white="$(tput setab 7 || true)"
        printf '%b' "$ta_none"
        readonly bg_yellow="$(tput setab 3 || true)"
        printf '%b' "$ta_none"
    else
        # Text attributes
        readonly ta_bold=''
        readonly ta_uscore=''
        readonly ta_blink=''
        readonly ta_reverse=''
        readonly ta_conceal=''

        # Foreground codes
        readonly fg_black=''
        readonly fg_blue=''
        readonly fg_cyan=''
        readonly fg_green=''
        readonly fg_magenta=''
        readonly fg_red=''
        readonly fg_white=''
        readonly fg_yellow=''

        # Background codes
        readonly bg_black=''
        readonly bg_blue=''
        readonly bg_cyan=''
        readonly bg_green=''
        readonly bg_magenta=''
        readonly bg_red=''
        readonly bg_white=''
        readonly bg_yellow=''
    fi
}

# DESC: Usage help
# ARGS: None
function usage() {
    echo -e "
    \rUsage: ${__base} <news-id> [options]
    \rDescription:\tThe script will gather the top headlines for a giving news source.
    
    \rrequired arguments:
    \r<news-id>\tNews id.

    \roptional arguments:
    \r-a|--all\tList all sources.
    \r-d|--desc\t<news-id> Get descriptor.
    \r-l|--list\tList all English speaking news sources.
    \r-h|--help\tShow this help message and exit.
    \r-i|--id\t\tList all English speaking news sources id.
    \r-s|--source\t<news-id> List all articles of the news source.
    \r-t|--top\t<news-id> List the top headlines of the news source.
    \r-u|--url\tPrint URL of news articles from source.
    "
}

# DESC: Parameter parser
# ARGS: $@ (optional): Arguments provided to the script
function parse_params() {
    local param
    while [[ $# -gt 0 ]]; do
        #param="${1}"
        params=$(echo ${1})
        
        # Getting the last parameter which should be the news_id.
        news_id=$(echo $params | awk 'NF>1{print $NF}')
        shift
        # Iterate through all the parameters.
        for param in $(echo ${params})
        do
            case $param in
                -a|--all)
                    news_sources_list "all"
                    exit 0
                    ;;
                -d|--desc)
                    #news_desc "$1"
                    news_desc "${news_id}"
                    exit 0
                    ;;
                -l|--list)
                    news_sources_list "en"
                    exit 0
                    ;;
                -i|--id)
                    news_sources_id "en"
                    exit 0
                    ;;
                -h|--help)
                    usage
                    exit 0
                    ;;
                -r|--random)
                    news_random
                    exit 0
                    ;;
                -s|--sources)
                    news_get "${news_id}" "everything"
                    exit 0
                    ;;
                -t|--top)
                    #news_get "$1" "top-headlines"
                    news_get "${news_id}" "top-headlines"
                    exit 0
                    ;;
                -u|--url)
                    #news_get "$1" "top-headlines"
                    url=1
                    ;;
                *)
                    news_get "${param}" "top-headlines"
                    exit 0
                    ;;
                esac
        done
    done
}

#######################
# Custom Variables    #
#######################

news_apiKey=""
news_api_url="https://newsapi.org/v2/"
news_sources=$(curl ${news_api_url}sources -s -G -d apiKey=$news_apiKey)

# Reset
Color_Off='\033[0m'       # Text Reset
NC='\e[m'                 # Color Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# High Intensity
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White

######################
# Custom Functions    #
#######################

# DESC: Gets if API key is set. 
# ARGS: $@ (required): API key regex varible.
function check_api_key(){

    api_key="${1}"
    
    # Validate API key regex.
    if [[ $news_apiKey =~ ^[0-f]{32}$ ]]
    then
        return 0    
    else
        # Print line number to check variable.
        variable_line_num=$(grep -n "news_apiKey=" ${__file} | cut -d ':' -f 1 | head -n 1)
        echo -e "Please validate ${Red}API Key${Color_Off}: ${api_key}
                \rReview ${__file} ${IYellow}line number${Color_Off}: ${variable_line_num}"

        exit 0
    fi
}
# DESC: Retrieves the description of a news_id.
# ARGS: $@ (required): Valid news id. 
function news_desc()
{
    news_id="${1}"
    news_desc=$(echo ${news_sources} | jq .[] | grep -w -A 6 -F "${news_id}" | head -n 7)
    if [ -z "${news_id}" ]
    then
        echo -e "${IYellow}Please select a news-id.${Color_Off}"
        exit 0
    elif [ -z "${news_desc}" ]
    then
        echo -e "News ID: ${Red}${news_id}${Color_Off} does not exist."
        exit 0
    else

    # Setup template to print
    ID=`echo "${news_desc}" | sed -e $'s/", "/\\\n/g' | sed 's/"//g' | sed -n '1p' \
        | cut -d ':' -f 2 | sed 's/,$//'`
    Name=`echo "${news_desc}" | sed -e $'s/", "/\\\n/g' | sed 's/"//g' | sed -n '2p' \
        | cut -d ':' -f 2 | sed 's/,$//'`
    Description=`echo "${news_desc}" | sed -e $'s/", "/\\\n/g' | sed 's/"//g' \
        | sed -n '3p' | cut -d ':' -f 2 | sed 's/,$//'`
    URL=`echo "${news_desc}" | sed -e $'s/", "/\\\n/g' | sed 's/"//g' | sed -n '4p' \
        | cut -d ',' -f 1 | awk '{print $2}'`
    Category=`echo "${news_desc}" | sed -e $'s/", "/\\\n/g' | sed 's/"//g' | sed -n '5p' \
        | cut -d ':' -f 2 | sed 's/,$//'`
    Language=`echo "${news_desc}" | sed -e $'s/", "/\\\n/g' | sed 's/"//g' | sed -n '6p' \
        | cut -d ':' -f 2 | sed 's/,$//'`
    Country=`echo "${news_desc}" | sed -e $'s/", "/\\\n/g' | sed 's/"//g' | sed -n '7p' \
        | cut -d ':' -f 2 | sed 's/,$//'`


    # Print Template
    echo -e "
    \r${ICyan}ID:${Color_Off}${ID}
    \r${ICyan}Name:${Color_Off}${Name}
    \r${ICyan}Description:${Color_Off}${Description}
    \r${ICyan}URL: ${Color_Off}${URL}
    \r${ICyan}Category:${Color_Off}${Category}
    \r${ICyan}Language:${Color_Off}${Language}
    \r${ICyan}Country:${Color_Off}${Country}
    "
    fi
}

# DESC: Retrieves news from specific news_id.
# ARGS: $@ (required): news_id. 
function news_get(){
    
    news_id="${1}"
    url_get="${2}"
    url_links="${url}"
   
    # Validate news_id. 
    resp=$(curl ${news_api_url}\\${url_get} -s -G -d sources=${news_id} -d apiKey=$news_apiKey | jq -r '.status')

    news_name=$(news_desc "${news_id}" | grep Name | cut -d ":" -f 2 )


    if [ "${resp}" = "error" ];
    then
        echo -e "News ID: ${Red}${news_id}${Color_Off} does not exist."
        exit 0
    elif [ "${url_links}" -eq 1 ]
    then
        echo -e "\n${ICyan}News from the ${news_name/ /${BRed}}${Color_Off}:"
        curl ${news_api_url}\\${url_get} -s -G -d sources=${news_id} -d apiKey=$news_apiKey | jq -r '.articles[] | .title, .url'
    else
        echo -e "\n${ICyan}News from the ${news_name/ /${BRed}}${Color_Off}:"
        curl ${news_api_url}\\${url_get} -s -G -d sources=${news_id} -d apiKey=$news_apiKey | jq -r '.articles[] | .title'
    fi

}

# DESC: Retrieves the top news from random english speaking news_id.
# ARGS: $@ (optional): Add URL links. 
function news_random(){
    
    url_links=${url}

    en_news_id=$(news_sources_id "en" | tail -n +4 )
    start_id=1
    total_ids=$(echo $en_news_id | wc -w)

    # Get random number between 1 and total news sources.
    random_news_id=$(jot -r 1 $start_id $total_ids 2>/dev/null)
    if [ -z "$random_news_id" ]
    then
        random_news_id=$(shuf -i $start_id-$total_ids -n 1)
    fi

    news_id=$(echo $en_news_id | cut -d " " -f "$random_news_id")
    #news_name=$(news_desc "$news_id" | grep Name | cut -d ":" -f 2 )

    #echo -e "\n${ICyan}News from the ${IRed}${news_name}${Color_Off}:"

    if [ "${url_links}" -eq 1 ]
    then
        #news_get -t "$news_id" -u
        news_get ${news_id} "top-headlines"
    else
        news_get "${news_id}" "top-headlines"
    fi    
}

# DESC: List all sources name along with id.
# ARGS: $@ (opitional): Language abbreviation. 
function news_sources_list() {
    language="${1}"
    
    echo -e "${ICyan}#-----------------#
            \r#${Color_Off} Name    ID${ICyan}      #
            \r#-----------------#${Color_Off}"
    
    if [ "${language}" = "all" ];
    then
        echo ${news_sources} | jq '.sources[] | .name, .id' | sed 's/"//g' | awk 'NR%2{printf "%s ",$0;next;}1' 
    else
        echo ${news_sources} | jq ".sources[] | select(.language==\"${language}\") | .name, .id" | sed 's/"//g' \
        | awk 'NR%2{printf "%s ",$0;next;}1' 
    fi
}

# DESC: List all sources id.
# ARGS: $@ (opitional): Language abbreviation. 
function news_sources_id() {
    language="${1}"
    
     echo -e "${ICyan}#-----------------#
            \r#${Color_Off} ID${ICyan}              #
            \r#-----------------#${Color_Off}"

    # If statement will always be false; just in case I want to change this later.
    if [ "${language}" = "all" ];
    then
        echo ${news_sources} | jq '.sources[] | .id' | sed 's/"//g'
    else
        echo ${news_sources} | jq ".sources[] | select(.language==\"${language}\") | .id" | sed 's/"//g'
    fi
}

# DESC: Main control flow
# ARGS: $@ (optional): Arguments provided to the script
function main() {
    # shellcheck source=source.sh
    #source "$(dirname "${BASH_SOURCE[0]}")/bash_color_codes"

    trap "script_trap_err" ERR
    trap "script_trap_exit" EXIT

    script_init
    colour_init
    
    # Print usage if no parameters are entered.
    if [ $# -eq 0 ]
    then
        usage
        exit 2
    fi
    
    # Check API key.
    check_api_key "${news_apiKey}"
    # Check to see if url is enabled in the parameters.
    if [[ "$@" == *"-u"* ]] 
    then
        url=1
    else
        url=0
    fi
    
    get_params="$@"
    sorted_params=$( echo ${get_params} | tr ' ' '\n' | sort | tr '\n' ' ' | sed 's/ *$//')
    parse_params "${sorted_params}"
    
}

# Make it rain
main "$@"
