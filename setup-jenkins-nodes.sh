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
  (${SCRIPT_PATH}/setup.sh --name="atomsd/jenkins-build:centos7" --file="${SCRIPT_PATH}/centos7/jenkins" --host=centos7-jenkins --rebuild) 
  (${SCRIPT_PATH}/setup.sh --name="atomsd/jenkins-build:centos6" --file="${SCRIPT_PATH}/centos6/jenkins" --host=centos6-jenkins --rebuild)
else 
  (${SCRIPT_PATH}/setup.sh --name="atomsd/jenkins-build:centos7" --file="${SCRIPT_PATH}/centos7/jenkins" --host=centos7-jenkins)     
  (${SCRIPT_PATH}/setup.sh --name="atomsd/jenkins-build:centos6" --file="${SCRIPT_PATH}/centos6/jenkins" --host=centos6-jenkins)
fi 
