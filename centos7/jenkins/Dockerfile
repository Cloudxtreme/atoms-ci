FROM centos:7
MAINTAINER AtomSD <support@atomsd.org>
RUN yum update -y && yum install -y autoconf \
	bzip2 \
	curl \
	git \
	gcc \
        gcc-c++ \
	java-1.7.0-openjdk \
	kernel-devel \
	libffi-devel \
	make \
	openssh-server \
	openssl-devel \
	patch \
	ruby \
	ruby-devel \
	rubygems \
	readline-devel \
	tar \
	zlib-devel

# Install maven 
RUN curl http://apache.spd.co.il/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz | tar xz -C /usr/local
RUN ln -s /usr/local/apache-maven-3.3.9 /usr/local/maven


# Add jenkins user
RUN useradd -ms /bin/bash jenkins
RUN echo "jenkins:jenkins" | chpasswd
RUN echo "root:jenkins" | chpasswd

# Install ruby
RUN git clone git://github.com/sstephenson/rbenv.git /home/jenkins/.rbenv
RUN echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> /home/jenkins/.bashrc
RUN echo 'eval "$(/home/jenkins/.rbenv/bin/rbenv init -)"' >> /home/jenkins/.bashrc
RUN git clone git://github.com/sstephenson/ruby-build.git /home/jenkins/.rbenv/plugins/ruby-build
RUN echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> /home/jenkins/.bashrc
RUN chown -R jenkins:jenkins /home/jenkins/.rbenv

# Set up SSH 
RUN mkdir /var/run/sshd && mkdir /var/log/ssh

# Set up SSH Host Key
RUN /usr/bin/ssh-keygen -q -t rsa1 -f /etc/ssh/ssh_host_key -C '' -N ''
RUN chmod 600 /etc/ssh/ssh_host_key && chmod 644 /etc/ssh/ssh_host_key.pub
RUN /usr/bin/ssh-keygen -q -t rsa -f /etc/ssh/ssh_host_rsa_key -C '' -N ''
RUN chmod 600 /etc/ssh/ssh_host_rsa_key && chmod 644 /etc/ssh/ssh_host_rsa_key.pub
RUN /usr/bin/ssh-keygen -q -t dsa -f /etc/ssh/ssh_host_dsa_key -C '' -N ''
RUN chmod 600 /etc/ssh/ssh_host_dsa_key && chmod 644 /etc/ssh/ssh_host_dsa_key.pub
RUN /usr/bin/ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -C '' -N ''
RUN chmod 600 /etc/ssh/ssh_host_ecdsa_key && chmod 644 /etc/ssh/ssh_host_ecdsa_key.pub
RUN /usr/bin/ssh-keygen -q -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -C '' -N ''
RUN chmod 600 /etc/ssh/ssh_host_ed25519_key && chmod 644 /etc/ssh/ssh_host_ed25519_key.pub

# Set up SSHD config
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd  
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config

# Add atoms build dirs
RUN mkdir -p /opt/atoms /var/cache/omnibus
RUN chown -R jenkins:jenkins /opt/atoms
RUN chown -R jenkins:jenkins /var/cache/omnibus

# Standard SSH port
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
