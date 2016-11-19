#!/usr/bin/env bash
# Created by zeqi
# @description
# @module
# @version 1.0.0
# @author Xijun Zhu <zhuzeqi2010@163.com>
# @File init
# @Date 16-11-18
# @Wechat zhuzeqi2010
# @QQ 304566647
# @Office-email zhuxijun@b2cf.cn

mongod=$(pwd)"/bin/mongod"
mongo=$(pwd)"/bin/mongo"
mongos=$(pwd)"/bin/mongos"

bindIp="127.0.0.1"
mongosPort=27017
clusterPort=27018
clusterRootName="cluster_0"

clusterRootDir="$(pwd)/"$clusterRootName
shardDir=$clusterRootDir"/shard"
configsvrDir=$clusterRootDir"/configsvr"
mongosDir=$clusterRootDir"/mongos"
genJsDri="initConfig"
initConfigDir=$clusterRootDir"/"$genJsDri
mongosSettingsFile=$initConfigDir"/mongosSettings.js"

startServerShell=$clusterRootDir"/startServer.sh"
startMongosSettingsShell=$clusterRootDir"/startMongosSettingsShell.sh"
startShardSettingsShell=$clusterRootDir"/startShardSettingsShell.sh"


shard_names=("shard_1" "shard_2" "shard_3")
configsvr_names=('svr_1' 'svr_2' 'svr_3')
shard_cluster_names=('master' 'slaver' 'arbiter')

configServers=()
shardServers=()

if [ -d "$initConfigDir" ]; then
    echo "The directory already exists: $initConfigDir"
    exec 0
else
    echo "Not found:$initConfigDir"
    mkdir -p "$initConfigDir"
fi

if [ ! -d "$shardDir" ]; then
    echo "Not found:$shardDir"
    mkdir -p "$shardDir"
fi

if [ ! -d "$configsvrDir" ]; then
    echo "Not found:$configsvrDir"
    mkdir -p "$configsvrDir"
fi

if [ ! -d "$mongosDir" ]; then
    echo "Not found:$mongosDir"
    mkdir -p "$mongosDir"
fi

#Mongodb shard settings start
for i in ${shard_names[@]}
do
    shardPath="$shardDir/$i"
    echo "$shardPath"
    if [ ! -d "$shardPath" ]; then
        echo "Not found:$shardPath"
        mkdir "$shardPath"
    fi
    clusterShardServers=()
    echo "#shard server: "$i >> $startServerShell
    materCluster=$mongo" $bindIp:$clusterPort/admin"
    genJsPath=$initConfigDir"/"$i".js"
    echo $materCluster" "$genJsPath >> $startShardSettingsShell
    addshardShell="db.runCommand({addshard:\"$i/"
    addclusterShell="var cfg = {
    \"_id\": \"$i\",
    \"members\": ["

    for cluster_index in `seq 0 $((${#shard_cluster_names[*]}-1))`
    do
        cluster_name=${shard_cluster_names[$cluster_index]}
        clusterPath="$shardPath/"$cluster_name
        echo "$clusterPath"
        if [ ! -d "$clusterPath" ]; then
            echo "Not found:$clusterPath"
            mkdir "$clusterPath"
        fi
        clusterDataPath="$clusterPath/data"
        if [ ! -d "$clusterDataPath" ]; then
            echo "Not found:$clusterDataPath"
            mkdir "$clusterDataPath"
        fi
        clusterLogsPath="$clusterPath/logs"
        if [ ! -d "$clusterLogsPath" ]; then
            echo "Not found:$clusterLogsPath"
            mkdir "$clusterLogsPath"
        fi
        clusterConfigFile="$clusterPath/mongodb.conf"
        if [ ! -f "$clusterConfigFile" ]; then
            echo "Not found:$clusterConfigFile"
            echo "net:
    bindIp: \"$bindIp\"
    port: $clusterPort
processManagement:
    fork: true
    pidFilePath: \"$clusterPath/mongodb.pid\"
replication:
    oplogSizeMB: 10000
    replSetName: \"$i\"
storage:
    dbPath: \"$clusterDataPath\"
    directoryPerDB: true
systemLog:
    destination: \"file\"
    logAppend: true
    path: \"$clusterLogsPath/mongodb.log\"
sharding:
    clusterRole: shardsvr " > $clusterConfigFile
        fi

        clusterItemConfig="        {
            \"_id\": $cluster_index,
            \"host\": \"$bindIp:$clusterPort\"
        }"
        if [ $cluster_index = 0 ]; then
            addshardShell=${addshardShell}"$bindIp:$clusterPort"
            addclusterShell=$addclusterShell$clusterItemConfig
        else
            addshardShell=${addshardShell}",$bindIp:$clusterPort"
            addclusterShell=$addclusterShell"        ,"$clusterItemConfig
        fi

        clusterShardServers[${#clusterShardServers[@]}]="$bindIp:$clusterPort"
        echo "$mongod -f "$clusterConfigFile >> $startServerShell
        let clusterPort=clusterPort+1

    done

    addshardShell=$addshardShell"\",name:\"_$i\"})"

    addclusterShell=$addclusterShell"    ]
};"
    echo $addshardShell >> $mongosSettingsFile

    echo $addclusterShell >> $genJsPath
    echo "rs.initiate(cfg);" >> $genJsPath
    #echo "exit" >> $genJsPath

    echo "" >> $startServerShell
    #echo "$i members: "${clusterShardServers[*]} >> $startServerShell
done

echo "sh.enableSharding(\"test\")" >> $mongosSettingsFile
echo "sh.shardCollection(\"test.user\", {name: 1})" >> $mongosSettingsFile
#Mongodb shard settings end

#Mongodb configsvr settings start
echo "#config server: "$i >> $startServerShell
for i in ${configsvr_names[@]}
do
    configsvrPath="$configsvrDir/"$i
    echo "$configsvrPath"
    if [ ! -d "$configsvrPath" ]; then
        echo "Not found:$configsvrPath"
        mkdir "$configsvrPath"
    fi

    configsvr_data_path="$configsvrPath/data"
    if [ ! -d "$configsvr_data_path" ]; then
        echo "Not found:$configsvr_data_path"
        mkdir "$configsvr_data_path"
    fi

    configsvr_logs_path="$configsvrPath/logs"
    if [ ! -d "$configsvr_logs_path" ]; then
        echo "Not found:$configsvr_logs_path"
        mkdir "$configsvr_logs_path"
    fi

    configsvr_configFile_path="$configsvrPath/configsvr.conf"
    if [ ! -f "$configsvr_configFile_path" ]; then
        echo "Not found:$configsvr_configFile_path"
        echo "net:
    bindIp: \"$bindIp\"
    port: $clusterPort
processManagement:
    fork: true
    pidFilePath: \"$configsvrPath/mongodb.pid\"
storage:
    dbPath: \"$configsvr_data_path\"
    directoryPerDB: true
systemLog:
    destination: \"file\"
    logAppend: true
    path: \"$configsvr_logs_path/mongodb.log\"
sharding:
    clusterRole: configsvr" > $configsvr_configFile_path
    fi

    configServers[${#configServers[@]}]="$bindIp:$clusterPort"

    #Mongodb configsvr settings end

    let clusterPort=clusterPort+1
    echo "$mongod -f "$configsvr_configFile_path >> $startServerShell
done
#Mongodb configsvr settings end


#Mongodb router server settings start
echo "" >> $startServerShell
configDB=""
for i in `seq 0 $((${#configServers[*]}-1))`
do
    if [ $i = 0 ]; then
        configDB=${configServers[$i]}
        continue
    fi
    configDB=${configDB}","${configServers[$i]}
done

echo "configDB:$configDB"

mongosPath="$mongosDir/mongos_1"
if [ ! -d "$mongosPath" ]; then
        echo "Not found:$mongosPath"
        mkdir "$mongosPath"
fi

mongos_logs_path="$mongosPath/logs"
if [ ! -d "$mongos_logs_path" ]; then
    echo "Not found:$mongos_logs_path"
    mkdir "$mongos_logs_path"
fi

mongos_configFile_path="$mongosPath/mongos.conf"
if [ ! -f "$mongos_configFile_path" ]; then
    echo "Not found:$mongos_configFile_path"
    echo "net:
    bindIp: \"$bindIp\"
    port: $mongosPort
processManagement:
    fork: true
    pidFilePath: \"$mongosPath/mongodb.pid\"
systemLog:
    destination: \"file\"
    logAppend: true
    path: \"$mongos_logs_path/mongodb.log\"
sharding:
    configDB: $configDB" > $mongos_configFile_path
fi

echo "# Start mongos server: "$i >> $startServerShell
echo "$mongos -f "$mongos_configFile_path >> $startServerShell
echo $mongo" $bindIp:$mongosPort/admin "$mongosSettingsFile >> $startMongosSettingsShell
#Mongodb router server settings end

cd $(pwd)
chmod +x $startServerShell
chmod +x $startShardSettingsShell
chmod +x $startMongosSettingsShell


$startServerShell
$startShardSettingsShell
$startMongosSettingsShell