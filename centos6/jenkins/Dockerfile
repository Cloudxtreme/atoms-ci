FROM centos:6
MAINTAINER AtomSD <support@atomsd.org>
RUN yum update -y && yum install -y java-1.7.0-openjdk ruby tar curl git openssh-server
RUN curl http://apache.spd.co.il/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz | tar xz -C /usr/local
RUN ln -s /usr/local/apache-maven-3.3.9 /usr/local/maven
RUN mkdir -p /var/run/sshd
RUN useradd -ms /bin/bash jenkins
RUN echo "jenkins:jenkins" | chpasswd

# Standard SSH port
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
