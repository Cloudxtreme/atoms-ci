#!/bin/sh

get_full_path() {
    # Absolute path to this script, e.g. /home/user/bin/foo.sh
    SCRIPT=$(readlink -f $0)

    if [ ! -d ${SCRIPT} ]; then
        # Absolute path this script is in, thus /home/user/bin
        SCRIPT=`dirname $SCRIPT`
    fi

    ( cd "${SCRIPT}" ; pwd )
}

die() {
    local localmsg="$1"
    echo "FATAL: ${localmsg}" >&2
    exit 1
}

is_root_user() {
    [ $(id -u) = 0 ] || die "Please run as root."
}

add_yum_remo(){
cat <<- EOF > /etc/yum.repos.d/docker.repo
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
}

prepare_docker_images(){
    docker build -t atomsd/atomsd-centos7-jenkins:latest $(get_full_path ./)/centos7/jenkins
    docker build -t atomsd/atomsd-centos6-jenkins:latest $(get_full_path ./)/centos6/jenkins

    # Remove all stopped containers
    docker rm $(docker ps -a -q)
    
    # Remove all untagged images
    docker rmi $(docker images -q -f dangling=true)
}

main(){
    is_root_user
    add_yum_remo

    yum -y update
    yum -y install docker-engine
    systemctl start docker

    prepare_docker_images
}

umask 0022
main
exit 0
