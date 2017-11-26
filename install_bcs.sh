#!/bin/bash -e

ECHO="echo -e"

# vars and default values
INSTALLDIR=""
MYSHELL=$SHELL
LOGONFILE=~/.bashrc
if [[ $MYSHELL == *csh ]]; then
	LOGONFILE=~/.cshrc
fi
VERSION=""

usage() {
	$ECHO "install_bcs.sh [options]"
	$ECHO ""
	$ECHO "Options:"
	$ECHO "-d        \tinstallation directory (required)"
	$ECHO "-f        \tlogon file to install alias (default = $LOGONFILE)"
	$ECHO "-v        \tversion of bcs to install (default = master)"
	$ECHO "-s        \tshell (default = $MYSHELL)"
	
	exit 1
}

# check arguments
while getopts "d:f:v:s:" opt; do
	case "$opt" in
		d) INSTALLDIR=$OPTARG
		;;
		f) LOGONFILE=$OPTARG
		;;
		v) VERSION="-b $OPTARG"
		;;
		s) MYSHELL=$OPTARG
		;;
	esac
done

# check required args
if [ -z "$INSTALLDIR" ]; then
	usage
fi

# temp area
mkdir bcstmp
cd bcstmp

# download program
git clone https://github.com/kpedro88/breadcrumbs.git $VERSION

# install program
mv breadcrumbs/bcs $INSTALLDIR
cd ..
rm -rf bcstmp

# check if already set up
if grep "bcsgo" $LOGONFILE > /dev/null 2>&1; then
	exit 0
fi

# setup alias/function
if [[ $MYSHELL == *csh ]]; then
	$ECHO "" >> $LOGONFILE
	$ECHO "alias bcsgo 'cd "'"`bcs list \!$`"'"'" >> $LOGONFILE
else
	$ECHO "" >> $LOGONFILE
	$ECHO "bcsgo() {" >> $LOGONFILE
	$ECHO '\tcd "$(bcs list $1)"' >> $LOGONFILE
	$ECHO "}" >> $LOGONFILE
fi
