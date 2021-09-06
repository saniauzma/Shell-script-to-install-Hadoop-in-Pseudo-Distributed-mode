#! /bin/bash

#@Author : Uzma S Langde.
echo "Updating your System"
sudo apt-get update
java_version='echo "$(java -version 2>&1)" | grep "java version" | awk "{ print substr($3, 4, length($3)-9); }"'
echo 'checking for java 8'
if [ $java_version -eq "8" ] ; then
	echo "Java 8 is installed in your system "
else 
	echo "Removing older version of Java and installing java 8"
	sudo apt-get purge openjdk*
	sudo apt-get install openjdk-8-jdk
fi

#find the path of java
#which java
#/usr/bin/java
#above command will print the symbolic link to java 
#read the link
#readlink -f /usr/bin/java

echo 'adding java home to .bashrc'

java_home="export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64"
echo $java_home >> ~/.bashrc

source ~/.bashrc
echo $(java -version)

echo 'installing ssh'
sudo apt-get update
sudo apt-get install openssh-server

echo "ssh key genration state"
ssh-keygen -t rsa -P ""            #rsa algorithm
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
echo 'checking ssh status'
sudo service ssh status

echo "Downloading Hadoop binary"
wget http://mirror.intergrid.com.au/apache/hadoop/common/hadoop-3.2.1/hadoop-3.2.1.tar.gz

echo "untaring the hadoop tar file "
tar -xvzf hadoop-3.2.1.tar.gz

echo "creating a soft link as hadoop to hadoop-3.2.1"
ln -s ~/hadoop-3.2.1 ~/hadoop

hadoop_home="export HADOOP_HOME=~/hadoop"
echo "adding hadoop_home to .bashrc"
echo $hadoop_home >> .bashrc

source ~/.bashrc
echo $(hadoop version)

echo "adding more env vars to .bashrc"
mapred_home="export HADOOP_MAPRED_HOME=\$HADOOP_HOME"
common_home="export HADOOP_COMMON_HOME=\$HADOOP_HOME"
hdfs_home="export HADOOP_HDFS_HOME=\$HADOOP_HOME"
yarn_home="export HADOOP_YARN_HOME=\$HADOOP_HOME"
lib_native_dir="export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native"
hadoop_opt='export HADOOP_OPTS="-Djava.library.path=\$HADOOP_HOME/lib/native"'
path="export PATH=\$PATH:\$HADOOP_HOME/sbin:\$HADOOP_HOME/bin"

echo $mapred_home >> .bashrc
echo $common_home >> .bashrc
echo $hdfs_home >> .bashrc
echo $yarn_home >> .bashrc
echo $lib_native_dir >> .bashrc
echo $hadoop_opt >> .bashrc
echo $path >> .bashrc

source ~/.bashrc

cd ~/hadoop/etc/hadoop
echo "configuring hadoop files"
echo $java_home >> hadoop-env.sh

sed -i '/<configuration>/ a <property>\n\t<name>mapreduce.framework.name</name>\n\t<value>yarn</value>\n</property>' mapred-site.xml


sed -i "/<configuration>/ a <property>\n\t<name>fs.defaultFS</name>\n\t<value>hdfs://localhost:9000</value>\n\t<description>The name of the default file system. A URI whose scheme and authority determine the FileSystemimplementation. The uri sscheme determines the configproperty (fs.SCHEME.impl) naming the FileSystemimplementation class. The uri sauthority is used to determine the host, port, etc. for a filesystem.</description>\n</property>" core-site.xml

cd ~
echo 'creating hdfs directory , namenode and datanode'
mkdir hdfs
cd hdfs/
mkdir namenode
mkdir datanode

cd ~/hadoop/etc/hadoop

sed -i '/<configuration>/ a <property>\n\t<name>dfs.replication</name>\n\t<value>1</value>\n\t<description>Default block replication.The actual number of replications can be specified when the file is created. The default is used if replication is not specified in create time.</description>\n</property>\n\n<property>\n\t<name>dfs.namenode.name.dir</name>\n\t<value>file:/home/uzma/hdfs/namenode</value>\n</property>\n\n<property>\n\t<name>dfs.datanode.data.dir</name>\n\t<value>file:/home/uzma/hdfs/datanode</value>\n</property>' hdfs-site.xml


sed -i '/<configuration>/ a <property>\n\t<name>yarn.nodemanager.aux-services</name>\n\t<value>mapreduce_shuffle</value>\n</property>' yarn-site.xml

cd ~
echo 'formatting namenode'
hdfs namenode -format

echo 'starting hadoop daemons'
start-dfs.sh
start-yarn.sh

jps
echo 'HADOOP PSEUDO DISTRIBUTED MODE INSTALLATION SUCCESSFUL !'

