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
ANAME=bcsgo

usage() {
	$ECHO "install_bcs.sh [options]"
	$ECHO ""
	$ECHO "Options:"
	$ECHO "-d        \tinstallation directory (required)"
	$ECHO "-f        \tlogon file to install alias (default = ${LOGONFILE})"
	$ECHO "-a        \talias name (default = ${ANAME})"
	$ECHO "-v        \tversion of bcs to install (default = master)"
	$ECHO "-s        \tshell (default = ${MYSHELL})"
	
	exit 1
}

# check arguments
while getopts "d:f:a:v:s:" opt; do
	case "$opt" in
		d) INSTALLDIR=$OPTARG
		;;
		f) LOGONFILE=$OPTARG
		;;
		a) ANAME=$OPTARG
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
if grep ${ANAME} ${LOGONFILE} > /dev/null 2>&1; then
	exit 0
fi

# setup alias/function
if [[ $MYSHELL == *csh ]]; then
	$ECHO "" >> ${LOGONFILE}
	$ECHO "alias ${ANAME} 'cd "'"`bcs list \!$`"'"'" >> ${LOGONFILE}
else
	$ECHO "" >> ${LOGONFILE}
	$ECHO "${ANAME}() { "'cd "$(bcs list $1)"; }' >> ${LOGONFILE}
fi