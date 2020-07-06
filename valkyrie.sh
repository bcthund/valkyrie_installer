#!/bin/sh
grey='\033[1;30m'
red='\033[0;31m'
RED='\033[1;31m'
green='\033[0;32m'
GREEN='\033[1;32m'
yellow='\033[0;33m'
YELLOW='\033[1;33m'
purple='\033[0;35m'
PURPLE='\033[1;35m'
white='\033[0;37m'
WHITE='\033[1;37m'
blue='\033[0;34m'
BLUE='\033[1;34m'
cyan='\033[0;36m'
CYAN='\033[1;36m'
NC='\033[0m'

# Save the working directory of the script
working_dir=$PWD

# Setup command
DEBUG=false
VERBOSE=false
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
        -h|--help)
        echo "${WHITE}"
        echo "Usage: $0.sh <options>"
        echo
        echo "Options:"
        echo "  -h, --help            show this help message and exit"
        echo "  -v, --verbose         print commands being run before running them"
        echo "  -d, --debug           print commands to be run but do not execute them"
        echo "${NC}"
        exit
        shift # Remove from processing
        ;;
        *)
        OTHER_ARGUMENTS="$OTHER_ARGUMENTS$1 "
        echo "${RED}Unknown argument: $1${NC}"
        exit
        shift # Remove generic argument from processing
        ;;
    esac
done

cmd(){
    if [ "$VERBOSE" = true ] || [ "$DEBUG" = true ]; then echo ">> ${WHITE}$1${NC}"; fi;
    if [ "$DEBUG" = false ]; then eval $1; fi;
}

# trap ctrl-c and call ctrl_c()
ctrl_c() { echo; echo; exit 0; }
trap ctrl_c INT

echo
echo -n "${PURPLE}Install Valkyrie ${GREEN}(y/n)? ${NC}"
read answer
echo
if [ "$answer" != "${answer#[Yy]}" ] ;then

    # PPAs
        printf "${PURPLE}Source [Valkyrie]: ${BLUE}Add Additional PPAs${NC}"
         echo -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "sudo add-apt-repository -y ppa:rock-core/qt4"
         fi

    # Dependencies
         echo
         printf "${PURPLE}Source [Valkyrie]: ${BLUE}Install Dependencies${NC}"
         echo -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            #libqtcore4 - might be needed to actually run if it compiles
            cmd "sudo apt install libqt4-dev"
         fi

    # Create Directories
         echo
         printf "${PURPLE}Source [Valkyrie]: ${BLUE}Create Temp Directories${NC}\n"
         if [ -d "./src/valkyrie_tmp" ] ;then
            printf "${BLUE}Build directory already exists, remove first? ${NC}\n"
            printf "${YELLOW}If you leave the directoy, it will be used as-is for building.${NC}\n"
            printf "${BLUE}Remove Directory? ${GREEN}(y/n)? ${NC}"
            read answer
            if [ "$answer" != "${answer#[Yy]}" ] ;then
                cmd "sudo rm -rf ./src/valkyrie_tmp"
            fi
        fi

    # Grab Source - If directory exists, use it without change
        if [ ! -d "./src/valkyrie_tmp" ] ;then
            echo
            
            printf "${PURPLE}Source [Valkyrie]: ${BLUE}Use provided source snapshot${NC}"
            if [ "$answer" != "${answer#[Yy]}" ] ;then printf " ${GREEN}(y/n)? ${NC} "; read answer2; else echo; fi
            
            #printf "${PURPLE}Source [Valkyrie]: ${BLUE}Pull current Valkyrie source (will install subservsion)${NC}\n"
            #printf "${YELLOW}Warning! Modifications were made to source files for missing includes for compile to succeed. Using the subversion copy will likely need manual source edits to work.${NC}\n"
            #echo -n "${BLUE}Use current source ${GREEN} (y/n)? ${NC}"; read answer;
            cmd "mkdir -pv ./src/valkyrie_tmp/build"
            if [ "$answer" != "${answer#[Yy]}" ] ;then
                cmd "rsync -a ./src/valkyrie-src/valkyrie/ ./src/valkyrie_tmp/build/"
            else
                cmd "sudo apt install subversion"
                cmd "svn co svn://svn.valgrind.org/valkyrie/trunk ./src/valkyrie_tmp/build/"
            fi
        fi

    # Build and install
        echo
        printf "${PURPLE}Source [Valkyrie]: ${BLUE}Entering './src/valkyrie_tmp/build'${NC}\n"
        cmd "cd ./src/valkyrie_tmp/build"
        cmd "echo $PWD"
        cmd "ls -al"
        ctrl_c() {
            echo;
            cmd "cd '${working_dir}'";
            cmd "sudo rm -rf ./src/valkyrie_tmp";
            echo;
            exit 0;
        }

        echo
        printf "${PURPLE}Source [Valkyrie]: ${BLUE}Run 'qmake-qt4'${NC}"
        echo -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "qmake-qt4"
        fi
        
        echo
        printf "${PURPLE}Source [Valkyrie]: ${BLUE}Run 'make'${NC}"
        echo -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "make"
        fi
        
        echo
        printf "${PURPLE}Source [Valkyrie]: ${BLUE}Run 'make install'${NC}"
        echo -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "sudo make install"
        fi
        
        echo
        printf "${PURPLE}Source [Valkyrie]: ${BLUE}Leaving './src/valkyrie_tmp/build'${NC}\n"
        cmd "cd '${working_dir}'";
        ctrl_c() { echo; echo; exit 0; }
        
    # Removing build files
        echo
        printf "${PURPLE}Source [Valkyrie]: ${BLUE}Remove './src/valkyrie_tmp'${NC}"
        echo -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "sudo rm -rf ./src/valkyrie_tmp";
        fi
fi
