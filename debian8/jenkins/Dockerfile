FROM debian:8.3
MAINTAINER AtomSD <support@atomsd.org>

RUN apt-get update && apt-get install -y autoconf \
	build-essential \
	bzip2 \
	curl \
	git \
	gcc \
        g++ \
	openjdk-7-jre \
	linux-kernel-headers \
	libffi-dev \
	net-tools \
	make \
	openssh-server \
	libssl-dev \
	patch \
	ruby \
	ruby-dev \
	libreadline6-dev \
	tar \
	zlib1g-dev \
	fakeroot

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

# Install maven
RUN curl http://apache.spd.co.il/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz | tar xz -C /usr/local
RUN ln -s /usr/local/apache-maven-3.3.9 /usr/local/maven
RUN echo 'export M2_HOME=/usr/local/maven' >> /home/jenkins/.bash_profile
RUN echo 'export M2="$M2_HOME/bin"' >> /home/jenkins/.bash_profile
RUN echo 'PATH="$M2:$PATH"' >> /home/jenkins/.bash_profile

# Install ruby
RUN git clone git://github.com/sstephenson/rbenv.git /home/jenkins/.rbenv
RUN echo 'export PATH="/home/jenkins/.rbenv/bin:$PATH"' >> /home/jenkins/.bash_profile
RUN echo 'eval "$(/home/jenkins/.rbenv/bin/rbenv init -)"' >> /home/jenkins/.bash_profile
RUN git clone git://github.com/sstephenson/ruby-build.git /home/jenkins/.rbenv/plugins/ruby-build
RUN echo 'export PATH="/home/jenkins/.rbenv/plugins/ruby-build/bin:$PATH"' >> /home/jenkins/.bash_profile
ENV RBENV_ROOT /home/jenkins/.rbenv/
ENV PATH "$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"
RUN rbenv install 2.2.3
RUN chown -R jenkins:jenkins /home/jenkins/.rbenv

# Add atoms build dirs
RUN mkdir -p /opt/atoms /var/cache/omnibus
RUN chown -R jenkins:jenkins /opt/atoms
RUN chown -R jenkins:jenkins /var/cache/omnibus

# Set git config 
USER jenkins
RUN git config --global user.email "support@atomsd.org"
RUN git config --global user.name "atomsd"
USER root

# Fix locale issues
RUN apt-get install -y locales
ENV DEBIAN_FRONTEND noninteractive

RUN dpkg-reconfigure locales && \
    locale-gen C.UTF-8 && \
    /usr/sbin/update-locale LANG=C.UTF-8
ENV LC_ALL C.UTF-8

# Standard SSH port
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
