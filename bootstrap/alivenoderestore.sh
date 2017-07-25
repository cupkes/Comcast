#!/bin/bash -e
#
# Script for changing a node to a core or read only member
# This script must be run as the neo4j user
# and must be run as super user
# Script tested on x/xx/2017 by Christopher Upkes
#################################################

#------------------------------------------------ 
# Script variables
#------------------------------------------------
# create a standard logging tag for all log entries
VERSION="3.2.0"
LOGTAG=NEO4J_SUPPORT
# specify the neo4j directory tree
NEOUSERHOME="/home/neo4j"
NEOBASE="/opt/neo4j"
NEOHOME="$NEOBASE/neo4j-enterprise-$VERSION"
NEOSUPP="$NEOBASE/support"
NEOBIN="$NEOSUPP/bin"
NEOETC="$NEOSUPP/etc"
NEOCONF="$NEOHOME/conf"
CMD="./bin/neo4j"
UNBIND_CMD"./bin/neo4j-admin unbind"
MSG="EXECUTING SCRIPT:"
NEOCONFIGFILE="$NEOCONF/neo4j.conf"
NEOFOCONFIGFILE="neo4j.conf.*"
RESTOREFILE="neo4jconfrestore"
CORENODELIST=xcorenodelist
NODETYPE=xnodetype
CLUSTERSIZe=xclustersize
DYNAMIC="NO"


CURRDIR=$( pwd )
CD $NEOHOME
if [ -e $NEOCONFIGFILE ]; then
	# restore neo4j.conf from neo4j.conf.timestamp
	logger -p local0.notice -t $LOGTAG "$NEOCONFIG file restored"
	# unbind server
	$UNBIND_CMD
	if [ $? -ne 0 ]; then
		echo "unbind command failed, aborting script"
		logger -p local0.notice -t $LOGTAG "neo4j restore script ERROR"
		exit 2
	fi
			
else
	echo "unable to locate neo4j configuration files, aborting script, $NEOCONF"
	logger -p local0.notice -t $LOGTAG "$(date) : Error: unable to locate files : $NEOCONFIGFILE and $NEOFOCONFIGFILE"
	exit 1
fi
cd $CURRDIR

			
			
