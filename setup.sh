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

    if [ -n "${REBUILD_IMAGES}" ]; then
        docker build -t atomsd/jenkins-build:centos7 $(get_full_path ./)/centos7/jenkins
        docker build -t atomsd/jenkins-build:centos6 $(get_full_path ./)/centos6/jenkins
    fi
    
    # Stop all containers
    docker stop $(docker ps -a -q)

    # Remove all stopped containers
    docker rm $(docker ps -a -q)
    
    # Remove all untagged images
    docker rmi $(docker images -q -f dangling=true)

    CID_CENTOS7=$(docker run -h centos7-jenkins  -d atomsd/jenkins-build:centos7)
    CID_CENTOS6=$(docker run -h centos6-jenkins  -d atomsd/jenkins-build:centos6)

    IP_CENTOS7=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${CID_CENTOS7})
    IP_CENTOS6=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${CID_CENTOS6})

    add_host "centos7-jenkins" ${IP_CENTOS7}
    add_host "centos6-jenkins" ${IP_CENTOS6}

    rm -rf /root/.ssh/known_hosts
}

add_host(){
    host_name=$1
    new_ip=$2

    # Remove previous host name
    sed "/$host_name/d" /etc/hosts > /etc/hosts.tmp
    cp -f /etc/hosts.tmp /etc/hosts

    echo "${new_ip}    $host_name" >> /etc/hosts
}

main(){
    is_root_user
    add_yum_remo

    yum -y update
    yum -y install docker-engine
    systemctl start docker

    prepare_docker_images
}


while [ -n "$1" ]; do
    v="${1#*=}"
    case "$1" in
        --rebuild)
            REBUILD_IMAGES=1
            ;;
        --help|*)
                cat <<__EOF__
Usage: $0
        --rebuild  - Rebuild docker images.
__EOF__
        exit 1
    esac
    shift
done

umask 0022
main
exit 0
