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
UNBIND_CMD="./bin/neo4j-admin unbind"
MSG="EXECUTING SCRIPT:"
NEOCONFIGFILE="$NEOCONF/neo4j.conf"
NEOFOCONFIGFILE="$NEOCONF/neo4j.conf.fo.*"
RESTOREFILE="neo4jconfrestore"
CORENODELIST=xcorenodelist
NODETYPE=xnodetype
CLUSTERSIZE=xclustersize
DYNAMIC="NO"
LEADERFILE="$NEOETC/promote"
CLUSTERSTATE="$NEOHOME/data/cluster-state"
GRAPHDBFILE="$NEOHOME/data/databases/graph.db"
FOFILES=$(ls -l $NEOCONF/neo4j.conf.fo.* | grep -v ^d | wc -l)

CURRDIR=$( pwd )
cd $NEOCONF
if [[ $FOFILES -gt 0 ]]; then
	echo "found the failover file"
	if [ -e $NEOCONFIGFILE ]; then
		# restore neo4j.conf from neo4j.conf.timestamp 
		echo "finding the latest config"
		LATEST_FOCONFIG=$( ls -t $NEOFOCONFIGFILE | head -1 )
		if [ $? -ne 0 ]; then
			echo "script routine returned error code, aborting script"
			logger -p local0.notice -t $LOGTAG "neo4j restore script ERROR"
			exit 1
		fi
		mv $NEOCONFIGFILE $NEOCONFIGFILE.$(date +"%Y%m%d_%H%M%S")
		mv $LATEST_FOCONFIG $NEOCONFIGFILE
		logger -p local0.notice -t $LOGTAG "$NEOCONFIG file restored"
		# unbind server
		echo "restoring config file"
		
					
	else
		echo "unable to locate neo4j configuration files, aborting script, $NEOCONF"
		logger -p local0.notice -t $LOGTAG "$(date) : Error: unable to locate files : $NEOCONFIGFILE and $NEOFOCONFIGFILE"
		exit 1
	fi
fi
cd $NEOHOME

if [ -d $CLUSTERSTATE ]; then
	$UNBIND_CMD
	if [ $? -ne 0 ]; then
		echo "unbind command failed, aborting script"
		logger -p local0.notice -t $LOGTAG "neo4j restore script ERROR"
		exit 2
	fi
else
	echo "no cluster-state directory, not calling unbind"
fi

if [[ ! -e $LEADERFILE && -e $GRAPHDBFILE ]]; then
	mv $GRAPHDBFILE $GRAPHDBFILE.$(date +"%Y%m%d_%H%M%S")
	logger -p local0.notice -t $LOGTAG "$GRAPHDBFILE backed up"
else
	echo "unable to locate $GRAPHDBFILE file or $LEADERFILE exists"
	logger -p local0.notice -t $LOGTAG "$(date) : Error: unable to locate file : $GRAPHDBFILE"
	
fi


cd $CURRDIR


			
			
