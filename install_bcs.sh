#!/bin/bash -e

ECHO="echo -e"

# vars and default values
INSTALLDIR=""
LOGONFILE=~/.bashrc
VERSION=""
ANAME=bcd
BNAME=bgo
ENAME=benv
CHANGED_ENAME=""

usage() {
	EXIT=$1

	$ECHO "install_bcs.sh [options]"
	$ECHO ""
	$ECHO "Options:"
	$ECHO "-d        \tinstallation directory (required)"
	$ECHO "-f        \tlogon file to install functions (default = ${LOGONFILE})"
	$ECHO "-a        \tfunction name for cd + env (default = ${ANAME})"
	$ECHO "-b        \tfunction name for cd (default = ${BNAME})"
	$ECHO "-e        \tscript name for CMSSW singularity env (default = ${ENAME})"
	$ECHO "-v        \tversion of bcs to install (default = master)"
	$ECHO "-h        \tdisplay this message and exit"
	
	exit $EXIT
}

# check arguments
while getopts "d:f:a:b:e:v:h" opt; do
	case "$opt" in
		d) INSTALLDIR=$OPTARG
		;;
		f) LOGONFILE=$OPTARG
		;;
		a) ANAME=$OPTARG
		;;
		b) BNAME=$OPTARG
		;;
		e) ENAME=$OPTARG
		   CHANGED_ENAME=true
		;;
		v) VERSION="-b $OPTARG"
		;;
		h) usage 0
		;;
	esac
done

# check required args
if [ -z "$INSTALLDIR" ]; then
	usage 1
fi

# check shell
if [[ $SHELL == *csh ]]; then
	$ECHO "csh is not supported"
	exit 1
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

# setup functions if not already set up
checkname() { grep $1 $2 > /dev/null 2>&1; }
if ! checkname ${ANAME} ${LOGONFILE}; then
	$ECHO "${ANAME}() { "'eval "$(bcs cd $1)"; }' >> ${LOGONFILE}
fi
if ! checkname ${BNAME} ${LOGONFILE}; then
	$ECHO "${BNAME}() { "'eval "$(bcs cd -g $1)"; }' >> ${LOGONFILE}
fi

# setup singularity env script
if ! type ${ENAME}; then
	cat << EOF > ${INSTALLDIR}/${ENAME}
#!/bin/bash
/bin/bash && eval `scramv1 runtime -sh`
EOF
	chmod +x ${INSTALLDIR}/${ENAME}
fi
if [ -n "$CHANGED_ENAME" ]; then
	sed -i 's/benv/'$ENAME'/' $INSTALLDIR/bcs
fi
