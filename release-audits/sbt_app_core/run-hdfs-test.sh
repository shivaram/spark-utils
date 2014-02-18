#!/bin/bash

FWDIR="$(cd `dirname $0`; pwd)"

~/ephemeral-hdfs/bin/hadoop fs -rm /input.txt
~/ephemeral-hdfs/bin/hadoop fs -copyFromLocal $FWDIR/input.txt / 

pushd $FWDIR
./sbt/sbt clean assembly
java -cp /root/spark-utils/release-audits/sbt_app_core/target/scala-2.10/simple-project-assembly-1.0.jar main.scala.SparkHdfsApp `cat /root/spark-ec2/masters`
popd
