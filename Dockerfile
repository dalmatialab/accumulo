FROM ubuntu:20.04
LABEL maintainer="dalmatialab"

# Install tzdata and set right timezone
ENV DEBIAN_FRONTEND="noninteractive"
RUN apt update && apt-get -y install tzdata
ENV TZ=Europe/Zagreb

# Java installation
RUN apt-get update && apt-get install -y openjdk-8-jdk wget

# Tools instalation
RUN apt-get update && apt-get install wget libc-bin make curl libxml2-utils netcat -y
RUN apt-get --reinstall install libc-bin
RUN apt-get update && apt-get install -y g++

# Environment version variables
ENV HADOOP_VERSION 3.3.0
ENV ACCUMULO_VERSION 2.0.1
ENV SCALA_GEOMESA_VERSION 2.11-3.1.0
ENV ZOOKEEPER_VERSION 3.6.3

# Environment home variables
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV ACCUMULO_HOME /opt/accumulo
ENV HADOOP_HOME /opt/hadoop
ENV ZOOKEEPER_HOME /opt/zookeeper 
ENV GEOMESA_HOME /opt/geomesa 

# Adding on path
ENV PATH $ACCUMULO_HOME/bin:$PATH
ENV PATH $HADOOP_HOME/bin:$PATH
ENV PATH $JAVA_HOME/bin:$PATH
ENV PATH $ZOOKEEPER_HOME/bin:$PATH
ENV PATH $GEOMESA_HOME/bin:$PATH

# Extra environment variables
ENV HADOOP_CONF_DIR /opt/hadoop/etc/hadoop
ENV ACCUMULO_CONF_DIR /opt/accumulo/conf

# Accumulo installation
RUN mkdir -p /opt/accumulo 
RUN cd /opt/accumulo && wget https://downloads.apache.org/accumulo/$ACCUMULO_VERSION/accumulo-$ACCUMULO_VERSION-bin.tar.gz && tar -xvzf accumulo-$ACCUMULO_VERSION-bin.tar.gz --strip-components 1 && rm accumulo-$ACCUMULO_VERSION-bin.tar.gz

# Zookeeper installation
RUN mkdir -p /opt/zookeeper
RUN cd /opt/zookeeper && wget https://downloads.apache.org/zookeeper/zookeeper-$ZOOKEEPER_VERSION/apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz && tar -xvzf apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz  --strip-components 1 && rm apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz
RUN cd $ACCUMULO_CONF_DIR && rm accumulo.properties accumulo-client.properties

# Hadoop installation
RUN mkdir -p /opt/hadoop
RUN cd /opt/hadoop && wget https://downloads.apache.org/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz &&  tar -xvzf hadoop-$HADOOP_VERSION.tar.gz --strip-components 1 && rm hadoop-$HADOOP_VERSION.tar.gz
RUN cd $HADOOP_CONF_DIR   && rm core-site.xml hdfs-site.xml

# Geomesa installation
RUN mkdir -p  /opt/geomesa
RUN cd /opt/geomesa && wget https://github.com/locationtech/geomesa/releases/download/geomesa_$SCALA_GEOMESA_VERSION/geomesa-accumulo_$SCALA_GEOMESA_VERSION-bin.tar.gz && tar -xvzf geomesa-accumulo_$SCALA_GEOMESA_VERSION-bin.tar.gz --strip-components 1 && rm geomesa-accumulo_$SCALA_GEOMESA_VERSION-bin.tar.gz

# Installing geomesa runtime
RUN mkdir -p $ACCUMULO_HOME/lib/ext/
RUN cp $GEOMESA_HOME/dist/accumulo/geomesa-accumulo-distributed-runtime_$SCALA_GEOMESA_VERSION.jar $ACCUMULO_HOME/lib/ext/geomesa-accumulo-distributed-runtime_$SCALA_GEOMESA_VERSION.jar

# Copy configuration files for hadoop and accumulo
COPY ./lib/opt /opt/
COPY ./lib/sbin /sbin/

RUN echo yes | $GEOMESA_HOME/bin/install-shapefile-support.sh
RUN echo yes | $GEOMESA_HOME/bin/install-dependencies.sh
RUN sed -i 's/\${ZOOKEEPER_HOME}\/\*/\${ZOOKEEPER_HOME}\/\*\:\${ZOOKEEPER_HOME}\/lib\/\*/g' /opt/accumulo/conf/accumulo-env.sh
RUN bash -c "/opt/accumulo/bin/accumulo-util build-native"

RUN apt-get update && apt-get install netcat-traditional

RUN chmod a+x /sbin/entrypoint.sh
ENTRYPOINT [ "/sbin/entrypoint.sh" ]