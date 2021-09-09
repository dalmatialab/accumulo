![example workflow](https://github.com/dalmatialab/accumulo/actions/workflows/main.yml/badge.svg)


# Supported tags and respective Dockerfile links

 - [2.0.1-rc-1](https://github.com/dalmatialab/accumulo/blob/1cf52471e294c46011f2701da7bfd115d72e1c3f/Dockerfile)
 - [2.0.1-rc-2](https://github.com/dalmatialab/accumulo/blob/c4aa20196676256df8ae60a4b515c4caba6d0fe7/Dockerfile)

# What is Accumulo ? 

[Apache Accumulo](https://accumulo.apache.org/) is a sorted, distributed key/value store that provides robust, scalable data storage and retrieval. With Apache Accumulo, users can store and manage large data sets across a cluster. Accumulo uses Apache Hadoop's HDFS to store its data and Apache Zookeeper for consensus.  

<img src="https://github.com/dalmatialab/accumulo/blob/b3bd964f5d5319df37dc91a91af9c530d66fcff2/logo.png?raw=true" width="300" height="120">

This Accumulo image comes with [Geomesa](https://www.geomesa.org/) support. Shortly, it is used to store, analyse and query multidimensional, high volume spatio-temporal data.  

<img src = "https://github.com/dalmatialab/accumulo/blob/b3bd964f5d5319df37dc91a91af9c530d66fcff2/logo1.png?raw=true" width="300" height="120">

# How to use this image

## Start Accumulo master instance

    $ docker run -d --name some-master -e HADOOP_MASTER_ADDRESS=hadoop-namenode -e ZOOKEEPERS=zookeeper -e ACCUMULO_PASSWORD=GisPwd image:tag master

Where:

 - `some-master` is name you want to assign to your container
 - `hadoop-namenode` is Hadoop namenode instance endpoint where Accumulo will store data
 - `zookeeper` is Zookeeper instance 
 - `image` is Docker image name
 - `tag` is Docker image version

## Start Accumulo tserver instance

    $ docker run -d --name some-tserver -e HADOOP_MASTER_ADDRESS=hadoop-namenode -e ZOOKEEPERS=zookeeper image:tag tserver

Where:

 - `some-tserver` is name you want to assign to your container
 - `hadoop-namenode` is Hadoop namenode instance endpoint where Accumulo will store data
 - `zookeeper` is Zookeeper instance 
 - `image` is Docker image name
 - `tag` is Docker image version

## Start Accumulo garbage collector instance

    $ docker run -d --name some-garbage-collector -e HADOOP_MASTER_ADDRESS=hadoop-namenode -e ZOOKEEPERS=zookeeper image:tag gc --auto-init

Where:

 - `some-garbage-collector` is name you want to assign to your container
 - `hadoop-namenode` is Hadoop namenode instance endpoint where Accumulo will store data
 - `zookeeper` is Zookeeper instance 
 - `image` is Docker image name
 - `tag` is Docker image version

## Start Accumulo monitor instance

    $ docker run -d --name some-monitor -e HADOOP_MASTER_ADDRESS=hadoop-namenode -e ZOOKEEPERS=zookeeper -p 9995:9995 image:tag monitor

Where:

 - `some-monitor` is name you want to assign to your container
 - `hadoop-namenode` is Hadoop namenode instance endpoint where Accumulo will store data
 - `zookeeper` is Zookeeper instance 
 - `image` is Docker image name
 - `tag` is Docker image version

## Environment variables

**ZOOKEEPERS**

This is *required* variable. It specifies Zookeeper instance endpoint which will take care about Accumulo distribution.

**HADOOP_MASTER_ADDRESS**

This is *required* variable. It specifies Hadoop namenode endpoint where Accumulo will store data.

**ACCUMULO_PASSWORD**

This is *required* variable. It specifies Accumulo password.

**TZ**

This is *optional* variable. It specifes timezone. Default value is `Europe/Zagreb`.

## Ports

Accumulo monitor exposes user interface at port 9995.

## NOTE

Recommended setup is one master, one monitor, one garbage collector and two or more tservers.  

Before starting Accumulo **Zookeeper and Hadoop** must be **up**.  

After Accumulo with Geomesa plugin is up, **before ingesting data** it is important to **setup namespace** and **load appropriate jars on classpath**.  
To do that **execute into accumulo-master container** and run:

	$ docker exec -it accumulo-master /bin/bash
    $$$ cd /opt/geomesa/bin
	$$$ setup-namespace.sh -u root -n namespace-name

Where:

 - `namespace-name` specifies namespace where Geomesa jars will be loaded. Only that namespace is available to store Geomesa data.

# License

