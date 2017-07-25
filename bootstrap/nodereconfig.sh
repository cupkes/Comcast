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
CYPHERSHELL_CMD="./bin/cypher-shell -u neo4j -p password"
CLUSTERINFOCYPHER="CALL dbms.cluster.role"
MSG="EXECUTING SCRIPT:"
NEOCONFIGFILE="$NEOCONF/neo4j.conf"
NEOFOCONFIGFILE="neo4j.conf.failover"
GRAPHDBFILE="$NEOHOME/data/databases/graph.db"
CLUSTERSTATE="$NEOHOME/data/cluster-state"
CORENODELIST=xcorenodelist
NODETYPE=xnodetype
CLUSTERSIZE=xclustersize
DYNAMIC="NO"
ROLEFILE="$NEOETC/role.conf"
LEADERFILE="$NEOETC/promote"

CURRDIR=$( pwd )
cd $NEOHOME
if [ -e $ROLEFILE ]; then
	ROLE=$( cat $ROLEFILE )
	if [ $? -ne 0 ]; then
		echo "cypher-shell command failed, aborting script"
		logger -p local0.notice -t $LOGTAG "neo4j reconfig script ERROR"
		exit 2
	fi
fi
if [[ ! -z $ROLE && $ROLE != "READ_REPLICA" && -d $CLUSTERSTATE ]]; then
	echo "this node is not a READ_REPLICA and requires unbinding "
	$UNBIND_CMD
	if [ $? -ne 0 ]; then
		echo "unbind command failed, aborting script"
		logger -p local0.notice -t $LOGTAG "neo4j restore script ERROR"
		exit 2
	fi
	# rename the clsuter state directory
	#mv $CLUSTERSTATE $CLUSTERSTATE.$(date +"%Y%m%d_%H%M%S")
	logger -p local0.notice -t $LOGTAG "$CLUSTERSTATE backed up"
	
	
fi


# unbind the node from the cluster





cd $NEOCONF

# updating conf file
if [ $DYNAMIC == "YES" ]; then
	if [ -e $NEOCONFIGFILE ]; then
		sed -i s/dbms.mode=.*/$NODETYPE/g $NEOCONFIGFILE
		sed -i s/causal_clustering.expected_core_cluster_size=.*/$CLUSTERSIZE/g $NEOCONFIGFILE
		sed -i s/causal_clustering.initial_discovery_members=.*/$CORENODELIST/g $NEOCONFIGFILE
		logger -p local0.notice -t $LOGTAG "$NEOCONFIGFILE updated"
	else
		echo "unable to locate neo4j configuration file, aborting script, $NEOCONFIGFILE"
		logger -p local0.notice -t $LOGTAG "$(date) : Error: unable to locate file : $NEOCONFIGFILE"
		exit 1
	fi
else
	if [ -e $NEOCONFIGFILE ]; then
		# backup neo4j.conf and copy neo4j.conf.failover 
		mv $NEOCONFIGFILE $NEOCONFIGFILE.fo.$(date +"%Y%m%d_%H%M%S")
		logger -p local0.notice -t $LOGTAG "$NEOCONF backed up"
		if [ -e $NEOETC/$NEOFOCONFIGFILE ]; then
			cp $NEOETC/$NEOFOCONFIGFILE $NEOCONFIGFILE && echo "copied failover config file"
			logger -p local0.notice -t $LOGTAG "$NEOCONFIGFILE updated"
		else
			echo "unable to locate failover config file"
			logger -p local0.notice -t $LOGTAG "$(date) : Error: unable to locate file : $NEOFOCONFIGFILE"
			exit 2
		fi
			
	else
		echo "unable to locate neo4j configuration file, aborting script, $NEOCONF"
		logger -p local0.notice -t $LOGTAG "$(date) : Error: unable to locate file : $NEOCONFIGFILE"
		exit 1
	fi
fi
# determine role of node

# rename graph.db file if node is not the leader 
if [ -e $LEADERFILE ]; then
	echo "$LEADERFILE found.  Promoting node to leader"
	echo "LEADER" > $ROLEFILE
	logger -p local0.notice -t $LOGTAG "$LEADERFILE backed up"
elif [[ ! -z $ROLE && $ROLE != "LEADER" ]]; then
	if [ -d $GRAPHDBFILE ]; then
		mv $GRAPHDBFILE $GRAPHDBFILE.$(date +"%Y%m%d_%H%M%S")
		logger -p local0.notice -t $LOGTAG "$GRAPHDBFILE backed up"
	else
		echo "unable to locate $GRAPHDBFILE file"
		logger -p local0.notice -t $LOGTAG "$(date) : Error: unable to locate file : $GRAPHDBFILE"
		exit 3
	fi
fi




			
			
