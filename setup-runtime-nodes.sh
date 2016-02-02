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

while [ -n "$1" ]; do
    v="${1#*=}"
    case "$1" in
        --rebuild)
            REBUILD_IMAGES=1
            ;;
        --help|*)
                cat <<__EOF__
Usage: $0
        --rebuild  - Reabuild docker images.
__EOF__
        exit 1
    esac
    shift
done


SCRIPT_PATH="$(get_full_path ./)"
echo ${SCRIPT_PATH}

if [ -n "${REBUILD_IMAGES}" ]; then
    REBUILD_STR="--rebuild"
fi

${SCRIPT_PATH}/setup.sh --name="atomsd/jenkins-runtime:centos6" --file="${SCRIPT_PATH}/centos6/runtime" --host=centos6-runtime ${REBUILD_STR} --privileged
${SCRIPT_PATH}/setup.sh --name="atomsd/jenkins-runtime:centos7" --file="${SCRIPT_PATH}/centos7/runtime" --host=centos7-runtime ${REBUILD_STR} --privileged

cp nginx-docker.tmpl /etc/nginx/conf.d/docker-centos6-runtime.conf
cp nginx-docker.tmpl /etc/nginx/conf.d/docker-centos7-runtime.conf

sed -i -e s/SUB_DOMAIN/centos6-runtime/g /etc/nginx/conf.d/docker-centos6-runtime.conf
sed -i -e s/SUB_DOMAIN/centos7-runtime/g /etc/nginx/conf.d/docker-centos7-runtime.conf

systemctl restart nginx
