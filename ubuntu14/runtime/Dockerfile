FROM ubuntu:14.04

MAINTAINER AtomSD <support@atomsd.org>
RUN apt-get update -y && apt-get install -y openjdk-7-jre \
        openssh-server \
        libssl-dev \
	net-tools

# Add jenkins user
RUN useradd -ms /bin/bash jenkins
RUN echo "jenkins:jenkins" | chpasswd
RUN echo "root:jenkins" | chpasswd

# Set up SSH
RUN mkdir /var/run/sshd && mkdir /var/log/ssh

# Set up SSHD config
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Standard SSH port
EXPOSE 22 80 443
CMD ["/usr/sbin/sshd", "-D"]
