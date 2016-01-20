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
        docker build -t "${DOCKER_NAME}" "${DOCKER_FILE}"
    fi
    
    # Stop all containers
    docker stop "${DOCKER_HOST}"

    # Remove all stopped containers
    docker rm $(docker ps -a -q)
    
    # Remove all untagged images
    docker rmi $(docker images -q -f dangling=true)

    if [ -n "${PRIVILEGED}" ]; then
	DOCKER_CID=$(docker run --privileged -h $DOCKER_HOST -d -v /usr/share/nginx/html/ci/:/home/jenkins/ci --name="$DOCKER_HOST" "$DOCKER_NAME")
    else 
	DOCKER_CID=$(docker run -h $DOCKER_HOST -d -v /usr/share/nginx/html/ci/:/home/jenkins/ci --name="$DOCKER_HOST" "$DOCKER_NAME")
    fi

    DOCKER_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${DOCKER_CID})

    add_host "${DOCKER_HOST}" ${DOCKER_IP}

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
        --name=*)
            DOCKER_NAME="${v}"
            ;;
        --file=*)
            DOCKER_FILE="${v}"
            ;;
        --host=*)
            DOCKER_HOST="${v}"
            ;;
        --privileged)
            PRIVILEGED=1
	    ;;
        --rebuild)
            REBUILD_IMAGES=1
            ;;
        --help|*)
                cat <<__EOF__
Usage: $0
	--name       - Docker image name.
	--file       - Docker image config file.
	--host       - Docker image host.
	--privileged - Run Docker image with --privileged
        --rebuild    - Reabuild docker images.
__EOF__
        exit 1
    esac
    shift
done

[ -n "${DOCKER_NAME}" ] || die "Please specify docker name"
[ -n "${DOCKER_FILE}" ] || die "Please specify docker config file path"
[ -n "${DOCKER_HOST}" ] || die "Please specify docker host"


umask 0022
main
exit 0
