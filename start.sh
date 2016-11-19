#!/usr/bin/env bash
#echo "Current directory:$(pwd)"
#cd $(pwd)
##shard 1
#$mongod -f ./shard/shard_1/master/mongodb.conf &
#./bin/mongod -f ./shard/shard_1/slaver/mongodb.conf &
#./bin/mongod -f ./shard/shard_1/arbiter/mongodb.conf &
##shard 2
#./bin/mongod -f ./shard/shard_2/master/mongodb.conf &
#./bin/mongod -f ./shard/shard_2/slaver/mongodb.conf &
#./bin/mongod -f ./shard/shard_2/arbiter/mongodb.conf &
##shard 3
#./bin/mongod -f ./shard/shard_3/master/mongodb.conf &
#./bin/mongod -f ./shard/shard_3/slaver/mongodb.conf &
#./bin/mongod -f ./shard/shard_3/arbiter/mongodb.conf &
##config server
#./bin/mongod -f ./configsvr/svr_1/configsvr.conf &
#./bin/mongod -f ./configsvr/svr_2/configsvr.conf &
#./bin/mongod -f ./configsvr/svr_3/configsvr.conf &
##router server
#./bin/mongos -f ./mongos/mongos_1/mongos.conf &