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
  ${SCRIPT_PATH}/setup.sh --name="atomsd/jenkins-runtime:centos7" --file="${SCRIPT_PATH}/centos7/runtime" --host=centos7-runtime --rebuild --privileged
  ${SCRIPT_PATH}/setup.sh --name="atomsd/jenkins-runtime:centos6" --file="${SCRIPT_PATH}/centos6/runtime" --host=centos6-runtime --rebuild --privileged
else 
  ${SCRIPT_PATH}/setup.sh --name="atomsd/jenkins-runtime:centos7" --file="${SCRIPT_PATH}/centos7/runtime" --host=centos7-runtime --privileged
  ${SCRIPT_PATH}/setup.sh --name="atomsd/jenkins-runtime:centos6" --file="${SCRIPT_PATH}/centos6/runtime" --host=centos6-runtime --privileged
fi 
