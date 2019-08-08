#!/bin/bash

#export SPARK_HOME=~/sjm/spark-2.4.3-bin-hadoop2.7

# --------------config

export ModelType=caffe
export WeightPath=./model/bvlc.caffemodel
export DefPath=./model/deploy_overlap.prototxt
export topN=1
#export redisPath=172.168.0.109:6379

/opt/work/redis-5.0.5/src/redis-server --port $REDIS_PORT > /opt/work/redis.log &
echo "redis server started, please check log in /opt/work/redis.log"

${SPARK_HOME}/bin/spark-submit --master local[*] --driver-memory 20g --executor-memory 120g --executor-cores 56 --total-executor-cores 224 --conf "spark.driver.extraJavaOptions=-Dbigdl.engineType=mkldnn -Dbigdl.mklNumThreads=48"  --jars ./packages/spark-redis-2.4.0-SNAPSHOT-jar-with-dependencies.jar --driver-memory 128g --class com.intel.analytics.zoo.serving.ZooServing ./packages/serving-0.1.0-SNAPSHOT-jar-with-dependencies.jar -t ${ModelType} -d ${DefPath} -w ${WeightPath} -b 512 --redis ${redisPath}


