#!/bin/bash
DIR=$(cd `dirname $0`; cd ..; pwd)
cd $DIR

source /etc/profile
source ~/.bash_profile
source "$1"
echo "start execute with sparkArgs ${input_param}"

#master=yarn
#master=local[*]
#master=spark://192.168.1.16:7077

#export HADOOP_USER_NAME=kgp
#param_path=/user/${HADOOP_USER_NAME}/etl/etl_kgp_loader/args/${input_param##*/}
#
#hdfs dfs -mkdir -p /user/${HADOOP_USER_NAME}/etl/etl_kgp_loader/args/
#hdfs dfs -put ${input_param} ${param_path}
if [ ${kerberos} -eq 1 ]; then
    kinit -kt ${keytab} ${principal}
    kerberos_str="--principal ${principal} --keytab ${keytab}"
fi

 spark-submit \
        ${kerberos_str} \
        --master ${master} \
        --deploy-mode ${deployMode}\
        --name ${taskName} \
        --queue ${taskQueue} \
        --driver-memory ${driverMemory} \
        --driver-cores  ${driverCores} \
        --executor-memory ${executorMemory} \
        --executor-cores ${executorCores} \
        --num-executors ${executorNum} \
        --conf "spark.yarn.security.credentials.hbase.enabled=true" \
        --class com.haizhi.etl.kgp.loader.KgpSparkLoader \
        ./lib/etl-kgp-loader-*.jar ${inputParam}

#res=$?
#hdfs dfs -rm hdfs://${param_path}
#if [ $res -ne 0 ]; then
#    exit 1
#fi