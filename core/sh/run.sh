#!/usr/bin/env bash

binDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${binDir} && cd ../
curDir=`pwd`
#binDir="$( cd $(dirname $0) && pwd )"
#curDir="$( cd $(dirname $binDir); pwd )"
packageName=${curDir##*/}
moduleName=${packageName%-*}

# 因为对taurus项目改名成kgp-taurus，获取的名称与jar有冲突，这里手动指定
packageName=taurus

if [ ! -n "$PRO_PATH" ]; then
    export PRO_PATH="${curDir}"
fi

profiles=$2
#移除了cdh570,cdh514替换原有的cdh570,即移除了原有的haizhi profile,将haizhi-cdh514 profile替换haizhi profile
if [ "${profiles}" == "haizhi-cdh514" ]; then
  profiles="haizhi"
fi

rootDir=${curDir}
libPath=${rootDir}/lib
libPathCustomize=${rootDir}/libcustomize
sourcePath=${rootDir}/conf
export logPath=${rootDir}/logs
stopPath=${rootDir%-*}

if [ ! -d ${logPath} ]; then
    mkdir -p ${logPath}
fi

start() {
    echo "start ${moduleName}..."
    nohup java -Dloader.path=${libPathCustomize},${libPath},${sourcePath} -XX:+UseConcMarkSweepGC \
    -DJM.LOG.PATH=${logPath} -DJM.SNAPSHOT.PATH=${sourcePath} \
    -Xms2048m -Xmx2048m -XX:+PrintGCDateStamps -XX:+PrintGCDetails -Xloggc:${logPath}/java_gc.log \
    -Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8 -Duser.timezone=Asia/Shanghai \
    -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${logPath} -jar ${libPath}/${packageName}-web-*.jar \
   --spring.profiles.active=${profiles} --isJar=true > /dev/null 2>&1 &
}

stop() {
    pid=`ps -ef | grep ${stopPath} | grep -v grep | awk '{print $2}'`
    echo "stop ${moduleName}..."
    if [ -n "${pid}" ]
    then
        kill -9 $pid
    fi
}

restart() {
    stop
    start
}

case "$1" in
	start|stop|restart)
  		case "$2" in
  		    haizhi|haizhi-fi|haizhi-ksyun|haizhi-cdh514|haizhi-tdh|test|uat)
  		        $1
  		        ;;
  		    *)
  		        echo $"Usage: $0 {start|stop|restart} {haizhi|haizhi-fi|haizhi-ksyun|haizhi-cdh514|haizhi-tdh|test|uat}"
  		        exit 2
  		esac
		;;
	*)
		echo $"Usage: $0 {start|stop|restart}"
		exit 1
esac
