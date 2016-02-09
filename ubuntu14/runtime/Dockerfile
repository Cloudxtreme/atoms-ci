FROM ubuntu:14.04

MAINTAINER AtomSD <support@atomsd.org>

# Install required packages
RUN apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
      apt-transport-https \
      ca-certificates \
      nano \
      openjdk-7-jre \
      openssh-server \
      vim

# Change root password
RUN echo "root:jenkins" | chpasswd

# Set up SSH
RUN mkdir /var/run/sshd && mkdir /var/log/ssh

# Set up SSHD config
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Disabling use DNS in ssh since it tends to slow connecting
RUN echo "UseDNS no" >> /etc/ssh/sshd_config

# Fix locale issues
ENV DEBIAN_FRONTEND noninteractive
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales

# Standard SSH port
EXPOSE 22 80 443
CMD ["/usr/sbin/sshd", "-D"]
