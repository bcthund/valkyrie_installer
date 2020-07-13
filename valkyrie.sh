#!/bin/bash
grey='\e[0m\e[37m'
GREY='\e[1m\e[90m'
red='\e[0m\e[91m'
RED='\e[1m\e[31m'
green='\e[0m\e[92m'
GREEN='\e[1m\e[32m'
yellow='\e[0m\e[93m'
YELLOW='\e[1m\e[33m'
purple='\e[0m\e[95m'
PURPLE='\e[1m\e[35m'
white='\e[0m\e[37m'
WHITE='\e[1m\e[37m'
blue='\e[0m\e[94m'
BLUE='\e[1m\e[34m'
cyan='\e[0m\e[96m'
CYAN='\e[1m\e[36m'
NC='\e[0m\e[39m'

# Save the working directory of the script
working_dir=$PWD

# Setup command
DEBUG=false
VERBOSE=false
IN_TESTING=false
EXTRACT=true
TMP_DIR=""
SRC_DIR=""
FLAGS=""
OTHER_ARGUMENTS=""

for arg in "$@"
do
    case $arg in
        -d|--debug)
        DEBUG=true
        FLAGS="$FLAGS-d "
        shift # Remove --debug from processing
        ;;
        -v|--verbose)
        VERBOSE=true
        FLAGS="$FLAGS-v "
        shift # Remove --verbose from processing
        ;;
        --in-testing)
        IN_TESTING=true
        FLAGS="$FLAGS--in-testing "
        shift # Remove from processing
        ;;
        -h|--help)
        echo -e "${WHITE}"
        echo -e "Usage: $0 <options>"
        echo -e
        echo -e "Options:"
        echo -e "  -h, --help            show this help message and exit"
        echo -e "  -v, --verbose         print commands being run before running them"
        echo -e "  -d, --debug           print commands to be run but do not execute them"
        echo -e "  --in-testing          Enable use of in-testing features"
        #echo -e "  --tmp=DIRECTORY       not used, passed from fresh_install script"
        echo -e "${NC}"
        exit
        shift # Remove from processing
        ;;
        --tmp=*)
        EXTRACT=false
        TMP_DIR="$(echo ${arg#*=} | sed 's:/*$::')"
        FLAGS="$FLAGS--tmp=${TMP_DIR} "
        shift # Remove from processing
        ;;
        *)
        OTHER_ARGUMENTS="$OTHER_ARGUMENTS$1 "
        echo -e "${RED}Unknown argument: $1${NC}"
        exit
        shift # Remove generic argument from processing
        ;;
    esac
done

cmd(){
    if [ "$VERBOSE" = true ] || [ "$DEBUG" = true ]; then echo -e ">> ${WHITE}$1${NC}"; fi;
    if [ "$DEBUG" = false ]; then eval $1; fi;
}

# trap ctrl-c and call ctrl_c()
ctrl_c() { echo -e; echo -e; exit 0; }
trap ctrl_c INT

echo -e
echo -e -n "${PURPLE}Install Valkyrie ${GREEN}(y/n/a)? ${NC}"
read answer
echo -e
if [ "$answer" != "${answer#[YyAa]}" ] ;then
    if [ "$answer" != "${answer#[Aa]}" ] ;then answer2="y"; else answer2=""; fi

    # PPAs
        printf "${PURPLE}Source [Valkyrie]: ${BLUE}Add Additional PPAs${NC}"
        if [ "$answer" != "${answer#[Yy]}" ] ;then printf " ${GREEN}(y/n)? ${NC} "; read answer2; else echo; fi
        if [ "$answer2" != "${answer2#[Yy]}" ] ;then
            cmd "sudo add-apt-repository -y ppa:rock-core/qt4"
        fi

    # Dependencies
        echo -e
        printf "${PURPLE}Source [Valkyrie]: ${BLUE}Install Dependencies${NC}"
        if [ "$answer" != "${answer#[Yy]}" ] ;then printf " ${GREEN}(y/n)? ${NC} "; read answer2; else echo; fi
        if [ "$answer2" != "${answer2#[Yy]}" ] ;then
            #libqtcore4 - might be needed to actually run if it compiles
            cmd "printf '%s\n' y | sudo apt install libqt4-dev"
        fi


    # Create Directories
        echo -e
        printf "${BLUE}Create Temp Directory${NC}\n"
        SRC_DIR=$(mktemp -d -t valkyrie-XXXXXX)
        ctrl_c() {
            cmd "cd '${working_dir}'"
            echo -e;
            echo -e -n "${BLUE}Do you want to remove temporary files in '${SRC_DIR}' ${GREEN}(y/n)? ${NC}"; read -e -i "y" answer; echo;
            if [ "$answer" != "${answer#[Yy]}" ] ;then
                eval "sudo rm -rf ${SRC_DIR}";
            fi
            echo -e;
            echo -e;
            exit 0;
        }
        echo -e "${YELLOW}Temp directory: '${SRC_DIR}'${NC}"
        

    # Grab Source - If directory exists, use it without change
        echo -e           
        printf "${PURPLE}Source [Valkyrie]: ${BLUE}Use provided source snapshot${NC}"
        if [ "$answer" != "${answer#[Yy]}" ] ;then printf " ${GREEN}(y/n)? ${NC} "; read answer2; else echo; fi
        cmd "mkdir -pv ${SRC_DIR}/build"
        if [ "$answer2" != "${answer2#[Yy]}" ] ;then
            cmd "rsync -a ./src/valkyrie-src/valkyrie/ ${SRC_DIR}/build/"
        else
            if ! command -v svn &> /dev/null; then cmd "sudo apt -qy install subversion"; fi
            #cmd "sudo apt install subversion"
            cmd "svn co svn://svn.valgrind.org/valkyrie/trunk ${SRC_DIR}/build/"
        fi

    # Build and install
        echo -e
        printf "${PURPLE}Source [Valkyrie]: ${BLUE}Entering '${SRC_DIR}/build'${NC}\n"
        cmd "cd ${SRC_DIR}/build"
        cmd "echo -e $PWD"
        cmd "ls -al"

        echo -e
        printf "${PURPLE}Source [Valkyrie]: ${BLUE}Run 'qmake-qt4'${NC}"
        if [ "$answer" != "${answer#[Yy]}" ] ;then printf " ${GREEN}(y/n)? ${NC} "; read answer2; else echo; fi
        if [ "$answer2" != "${answer2#[Yy]}" ] ;then
            cmd "qmake-qt4"
        fi
        
        echo -e
        printf "${PURPLE}Source [Valkyrie]: ${BLUE}Run 'make'${NC}"
        if [ "$answer" != "${answer#[Yy]}" ] ;then printf " ${GREEN}(y/n)? ${NC} "; read answer2; else echo; fi
        if [ "$answer2" != "${answer2#[Yy]}" ] ;then
            cmd "make"
        fi
        
        echo -e
        printf "${PURPLE}Source [Valkyrie]: ${BLUE}Run 'make install'${NC}"
        if [ "$answer" != "${answer#[Yy]}" ] ;then printf " ${GREEN}(y/n)? ${NC} "; read answer2; else echo; fi
        if [ "$answer2" != "${answer2#[Yy]}" ] ;then
            cmd "sudo make install"
        fi
        
        echo -e
        printf "${PURPLE}Source [Valkyrie]: ${BLUE}Leaving '${SRC_DIR}/build'${NC}\n"
        cmd "cd '${working_dir}'";
        
    # Removing build files
        echo -e
        printf "${PURPLE}Source [Valkyrie]: ${BLUE}Remove '${SRC_DIR}'${NC}"
        if [ "$answer" != "${answer#[Yy]}" ] ;then printf " ${GREEN}(y/n)? ${NC} "; read answer2; else echo; fi
        if [ "$answer2" != "${answer2#[Yy]}" ] ;then
            cmd "sudo rm -rf ${SRC_DIR}";
        fi
fi
