FROM centos:7
MAINTAINER AtomSD <support@atomsd.org>
RUN yum update && yum install -y java-1.7.0-openjdk ruby tar curl git
RUN curl http://apache.spd.co.il/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz | tar xz -C /usr/local
RUN ln -s /usr/local/apache-maven-3.3.9 /usr/local/maven
