#!/bin/bash -e
#
# Script for initializing NEO4J Server Config
# This script must be run as the neo4j user
# and must be run as super user
# Script tested on x/xx/2017 by Christopher Upkes
#################################################

#------------------------------------------------ 
# Script variables
#------------------------------------------------
LOGTAG=NEO4J_SUPPORT
GITREPO="https://github.com/cupkes/CSS.git"
GITCLONECMD="git clone $GITREPO"
NEOUSERHOME="/home/neo4j"
REPODIR="$NEOUSERHOME/repo"
REPO="CSS"
VERSION="3.2.0"
#  SUPPORT_TGZ_FILE=neo4j_support.tar.gz - depracated
NEO4J_SERVER_TGZ=neo4j-enterprise-$VERSION-unix.tar.gz
INITSCRIPT=neo4j_init.sh
HOSTINITSCRIPT=neo4j_host_init.sh

# make sure the neo4j home directory exists
logger -p local0.notice -t $LOGTAG "neo4j bootstrap script called"

if [ -d $NEOUSERHOME ]; then
	echo "located neo4j home directory"
	mkdir $REPODIR
		if [ $? -ne 0 ]; then
			echo "unable to create directory $REPODIR"
			logger -p local0.notice -t $LOGTAG "neo4j bootstrap ERROR"
			exit 2
		else
			cd $REPODIR
		fi
else
	echo "could not locate neo4j home directory, aborting script"
	exit 1
fi

GITTEST=$(yum list installed git |& grep Error | awk '{ print $1 }' | sed s/://) 

# if there is no git package installed, install the git package

if [ -z $GITTEST ]; then
	echo "GIT already installed"
else
	if [ $GITTEST = "Error" ]; then
		echo "GIT not installed, installing" && logger -p local0.notice -t $LOGTAG "installing GIT"
		yum install -y git
	fi
fi

$GITCLONECMD
if [ $? -ne 0 ]; then
		echo "unable to call git clone"
		logger -p local0.notice -t $LOGTAG "neo4j bootstrap ERROR"
		exit 3
else
	cd $REPO/bootstrap
	if [[ ! -f $NEO4J_SERVER_TGZ  || ! -f $INITSCRIPT  ]]; then
		echo "unable to locate all required files"
		logger -p local0.notice -t $LOGTAG "neo4j bootstrap script ERROR"
		exit 4
	else
		chmod +x $INITSCRIPT
	fi
	cd $REPODIR/$REPO/install/Server
	if [ !  -f $HOSTINITSCRIPT  ]; then
		echo "unable to locate all required files"
		logger -p local0.notice -t $LOGTAG "neo4j bootstrap script ERROR"
		exit 5
	fi
fi
echo "Bootstrap complete.  Ready to initialize host"
logger -p local0.notice -t $LOGTAG "neo4j bootstrap script completed"
# call the initialization script
# chmod +x $INITSCRIPT
# ./$INITSCRIPT


	

	