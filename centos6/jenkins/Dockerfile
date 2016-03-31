FROM centos:6
MAINTAINER AtomSD <support@atomsd.org>
RUN yum update -y && yum install -y autoconf \
        bzip2 \
        curl \
        fakeroot \
        git \
        gcc \
        gcc-c++ \
	gettext \
        java-1.7.0-openjdk \
	java-1.7.0-openjdk-devel \
        kernel-devel \
        libffi-devel \
	lib-devel \
	net-tools \
	make \
        openssh-server \
	openssl-devel \
	perl-CPAN \
        patch \
        ruby \
        ruby-devel \
        rubygems \
	readline-devel \
	rpm-build \
        tar \
	which \
        zlib-devel

# Add jenkins user
RUN useradd -ms /bin/bash jenkins
RUN echo "jenkins:jenkins" | chpasswd
RUN echo "root:jenkins" | chpasswd

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

# Set up SSHD config
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config

# Install Maven
RUN curl http://apache.spd.co.il/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz | tar xz -C /usr/local
RUN ln -s /usr/local/apache-maven-3.3.9 /usr/local/maven
RUN echo 'export M2_HOME=/usr/local/maven' >> /home/jenkins/.bashrc
RUN echo 'export M2="$M2_HOME/bin"' >> /home/jenkins/.bashrc
RUN echo 'PATH="$M2:$PATH"' >> /home/jenkins/.bashrc

# Install ruby
RUN git clone git://github.com/sstephenson/rbenv.git /home/jenkins/.rbenv
RUN echo 'export PATH="/home/jenkins/.rbenv/bin:$PATH"' >> /home/jenkins/.bashrc
RUN echo 'eval "$(/home/jenkins/.rbenv/bin/rbenv init -)"' >> /home/jenkins/.bashrc
RUN git clone git://github.com/sstephenson/ruby-build.git /home/jenkins/.rbenv/plugins/ruby-build
RUN echo 'export PATH="/home/jenkins/.rbenv/plugins/ruby-build/bin:$PATH"' >> /home/jenkins/.bashrc
ENV RBENV_ROOT /home/jenkins/.rbenv/
ENV PATH "$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"
RUN rbenv install 2.2.3
RUN chown -R jenkins:jenkins /home/jenkins/.rbenv

# Add atoms build dirs
RUN mkdir -p /opt/atoms /var/cache/omnibus
RUN chown -R jenkins:jenkins /opt/atoms
RUN chown -R jenkins:jenkins /var/cache/omnibus

# Update GIT to a newer version then cetnos6 reo
RUN yum install -y curl-devel expat-devel
RUN curl https://git-core.googlecode.com/files/git-1.8.5.3.tar.gz | tar xz -C /usr
RUN /usr/git-1.8.5.3/configure
RUN cd /usr/git-1.8.5.3/ && make
RUN cd /usr/git-1.8.5.3/ && make prefix=/usr install

# Set git config 
RUN git config --global user.email "support@atomsd.org"
RUN git config --global user.name "atomsd"

# Standard SSH port
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
