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
ANAME=bcd
BNAME=bgo

usage() {
	$ECHO "install_bcs.sh [options]"
	$ECHO ""
	$ECHO "Options:"
	$ECHO "-d        \tinstallation directory (required)"
	$ECHO "-f        \tlogon file to install alias (default = ${LOGONFILE})"
	$ECHO "-a        \talias name for cd + env (default = ${ANAME})"
	$ECHO "-b        \talias name for cd (default = ${BNAME})"
	$ECHO "-v        \tversion of bcs to install (default = master)"
	$ECHO "-s        \tshell (default = ${MYSHELL})"
	
	exit 1
}

# check arguments
while getopts "d:f:a:b:v:s:" opt; do
	case "$opt" in
		d) INSTALLDIR=$OPTARG
		;;
		f) LOGONFILE=$OPTARG
		;;
		a) ANAME=$OPTARG
		;;
		b) BNAME=$OPTARG
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

# ensure compatibility (w/ backup)
if [ -f ~/.breadcrumbs ]; then
	breadcrumbs/bcs update -b
fi

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
	$ECHO "alias ${ANAME} 'eval "'"`bcs cd \!$`"'"'" >> ${LOGONFILE}
	$ECHO "alias ${BNAME} 'eval "'"`bcs cd -g \!$`"'"'" >> ${LOGONFILE}
else
	$ECHO "" >> ${LOGONFILE}
	$ECHO "${ANAME}() { "'eval "$(bcs cd $1)"; }' >> ${LOGONFILE}
	$ECHO "${BNAME}() { "'eval "$(bcs cd -g $1)"; }' >> ${LOGONFILE}
fi
