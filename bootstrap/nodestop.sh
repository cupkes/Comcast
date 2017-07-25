#!/bin/bash -e
#
# Script for stopping a running node
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
ROLEFILE="$NEOETC/role.conf"
CYPHERSHELL_CMD="./bin/cypher-shell"
CLUSTERINFOCYPHER="CALL dbms.cluster.role"

# run $CMD status and AWK for running, etc...
# if then else to see if return value is running or notice
# handle case where node already shut down
#
# shutting down node
CURRDIR=$(pwd) 
cd $NEOHOME
RUNNING=$($CMD status | awk '{ print $5 }')
if [ $? -ne 0 ]; then
	echo "cypher-shell command failed, aborting script"
	logger -p local0.notice -t $LOGTAG "neo4j reconfig script ERROR"
	exit 2
fi
if [[ ! -z $RUNNING && $RUNNING == "pid" ]]; then
	ROLE=$( $CYPHERSHELL_CMD "$CLUSTERINFOCYPHER" | awk 'FNR == 2 { print $1}' | sed "s/\"//g" )
	echo "role for node is $ROLE"
	if [ $? -ne 0 ]; then
		echo "cypher-shell command failed, aborting script"
		logger -p local0.notice -t $LOGTAG "neo4j reconfig script ERROR"
		exit 2
	fi
	echo $ROLE > $ROLEFILE
	$CMD stop
	if [ $? -ne 0 ]; then
		logger -p local0.notice -t $LOGTAG "neo4j shutdownscript ERROR"
		exit 2
	else
		echo "waiting for halt"
		sleep 15
	fi
else
	echo "Neo4j is not in a normal running state"
fi
cd $CURRDIR