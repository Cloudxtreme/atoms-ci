FROM debian:8.3

MAINTAINER AtomSD <support@atomsd.org>

# Install required packages
RUN apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      apt-transport-https \
      ca-certificates \
      locales \
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

# Setup systemd
RUN cd /lib/systemd/system/sysinit.target.wants/; ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1 \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*; \
rm -f /lib/systemd/system/plymouth*; \
rm -f /lib/systemd/system/systemd-update-utmp*;
RUN systemctl set-default multi-user.target
ENV init /lib/systemd/systemd
ENTRYPOINT ["/lib/systemd/systemd"]

RUN systemctl enable ssh

# Standard SSH port
EXPOSE 22 80 443
