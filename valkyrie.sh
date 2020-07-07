#!/bin/bash
grey='\e[37;0m'
GREY='\e[37;1m'
red='\e[31;0m'
RED='\e[31;1m'
green='\e[32;0m'
GREEN='\e[32;1m'
yellow='\e[33;0m'
YELLOW='\e[33;1m'
purple='\e[35;0m'
PURPLE='\e[35;1m'
white='\e[37;0m'
WHITE='\e[37;1m'
blue='\e[34;0m'
BLUE='\e[34;1m'
cyan='\e[36;0m'
CYAN='\e[36;1m'
NC='\e[39;0m'

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
        echo -e "${WHITE}"
        echo -e "Usage: $0 <options>"
        echo -e
        echo -e "Options:"
        echo -e "  -h, --help            show this help message and exit"
        echo -e "  -v, --verbose         print commands being run before running them"
        echo -e "  -d, --debug           print commands to be run but do not execute them"
        echo -e "${NC}"
        exit
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
if [ "$answer" != "${answer#[Yy]}" ] ;then
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
            cmd "sudo apt install libqt4-dev"
        fi

    # Create Directories
        echo -e
        printf "${PURPLE}Source [Valkyrie]: ${BLUE}Create Temp Directories${NC}\n"
        if [ -d "./src/valkyrie_tmp" ] ;then
            printf "${BLUE}Build directory already exists, remove first${NC}\n"
            if [ "$answer" != "${answer#[Yy]}" ] ;then printf " ${GREEN}(y/n)? ${NC} "; read answer2; else echo; fi
            if [ "$answer2" != "${answer2#[Yy]}" ] ;then
                cmd "sudo rm -rf ./src/valkyrie_tmp"
            fi
        fi

    # Grab Source - If directory exists, use it without change
        if [ ! -d "./src/valkyrie_tmp" ] ;then
            echo -e
            
            printf "${PURPLE}Source [Valkyrie]: ${BLUE}Use provided source snapshot${NC}"
            if [ "$answer" != "${answer#[Yy]}" ] ;then printf " ${GREEN}(y/n)? ${NC} "; read answer2; else echo; fi
            cmd "mkdir -pv ./src/valkyrie_tmp/build"
            if [ "$answer2" != "${answer2#[Yy]}" ] ;then
                cmd "rsync -a ./src/valkyrie-src/valkyrie/ ./src/valkyrie_tmp/build/"
            else
                cmd "sudo apt install subversion"
                cmd "svn co svn://svn.valgrind.org/valkyrie/trunk ./src/valkyrie_tmp/build/"
            fi
        fi

    # Build and install
        echo -e
        printf "${PURPLE}Source [Valkyrie]: ${BLUE}Entering './src/valkyrie_tmp/build'${NC}\n"
        cmd "cd ./src/valkyrie_tmp/build"
        cmd "echo -e $PWD"
        cmd "ls -al"
        ctrl_c() {
            echo -e;
            cmd "cd '${working_dir}'";
            cmd "sudo rm -rf ./src/valkyrie_tmp";
            echo -e;
            exit 0;
        }

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
        printf "${PURPLE}Source [Valkyrie]: ${BLUE}Leaving './src/valkyrie_tmp/build'${NC}\n"
        cmd "cd '${working_dir}'";
        ctrl_c() { echo -e; echo -e; exit 0; }
        
    # Removing build files
        echo -e
        printf "${PURPLE}Source [Valkyrie]: ${BLUE}Remove './src/valkyrie_tmp'${NC}"
        if [ "$answer" != "${answer#[Yy]}" ] ;then printf " ${GREEN}(y/n)? ${NC} "; read answer2; else echo; fi
        if [ "$answer2" != "${answer2#[Yy]}" ] ;then
            cmd "sudo rm -rf ./src/valkyrie_tmp";
        fi
fi
