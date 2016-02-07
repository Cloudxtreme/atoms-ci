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

if [ -n "${REBUILD_IMAGES}" ]; then
    REBUILD_STR="--rebuild"
fi 

${SCRIPT_PATH}/setup.sh --name="atomsd/jenkins-build:centos6" --file="${SCRIPT_PATH}/centos6/jenkins" --host=centos6-jenkins ${REBUILD_STR}
${SCRIPT_PATH}/setup.sh --name="atomsd/jenkins-build:centos7" --file="${SCRIPT_PATH}/centos7/jenkins" --host=centos7-jenkins ${REBUILD_STR}
#${SCRIPT_PATH}/setup.sh --name="atomsd/jenkins-build:fedora22" --file="${SCRIPT_PATH}/fedora22/jenkins" --host=fedora22-jenkins ${REBUILD_STR}
${SCRIPT_PATH}/setup.sh --name="atomsd/jenkins-build:ubuntu14" --file="${SCRIPT_PATH}/ubuntu14/jenkins" --host=ubuntu14-jenkins ${REBUILD_STR}
${SCRIPT_PATH}/setup.sh --name="atomsd/jenkins-build:ubuntu15" --file="${SCRIPT_PATH}/ubuntu15/jenkins" --host=ubuntu15-jenkins ${REBUILD_STR}
${SCRIPT_PATH}/setup.sh --name="atomsd/jenkins-build:debian8" --file="${SCRIPT_PATH}/debian8/jenkins" --host=debian8-jenkins ${REBUILD_STR}
