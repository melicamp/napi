#!/bin/bash

RESULT="failed"
AWK="awk"

usage() {
    "./run_unit_tests.sh [ OPTIONS ] <unit_tests>"
}

while getopts "a:h" option; do
    case "$option" in
        "a")
            AWK="$OPTARG"
            ;;
        "h")
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

#
# execute the unit tests
#
docker-compose run \
    --rm \
    napitester bash -s <<CMD_EOF && RESULT="succeeded"

    [ "$AWK" != "awk" ] &&
        sudo update-alternatives --set awk "$AWK"

    # make an array of unit tests
    tests=( ./*test.sh )

    # run argv unit tests only if provided
    [ $# -gt 0 ] && tests=( "$@" )

    for tc in "\${tests[@]}"; do
        echo " ** executing [\$tc]"
        kcov --exclude-pattern=shunit,mock \
            ../coverage "\$tc" ||
            exit \$?
    done
    exit 0
CMD_EOF

# send notifications
notify-send "Tests ${RESULT}"
