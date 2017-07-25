#!/bin/bash -e
#
# Script for starting a node
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
CMD="./bin/neo4j"
MSG="EXECUTING SCRIPT:"

# run $CMD status and AWK for running, etc...
# if then else to see if return value is running or notice
# handle case where node already started
#
# starting node$
CURRDIR=$(pwd)
cd $NEOHOME
RUNNING=$($CMD status | awk '{ print $3 }')
if [ $? -ne 0 ]; then
	echo "cypher-shell command failed, aborting script"
	logger -p local0.notice -t $LOGTAG "neo4j reconfig script ERROR"
	exit 2
fi
if [[ ! -z $RUNNING && $RUNNING == "not" ]]; then

	$CMD start
	if [ $? -ne 0 ];then
		logger -p local0.notice -t $LOGTAG "neo4j shutdownscript ERROR"
		exit 1
	else
		sleep 15
	fi
else
	echo "No4j not in a stopped state"
	logger -p local0.notice -t $LOGTAG "neo4j shutdownscript ERROR"
fi
cd $CURRDIR