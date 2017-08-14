#!/bin/sh

#
# ansible-vault-merge: helper script for merging changes in ansible-vault file
#

PROGNAME=$(basename $0)

usage() {
    cat <<EOF
usage: ${PROGNAME} [OPTION]... [--] BASE CURRENT OTHER [LOCATION]

  -h, --help Display this help
EOF
}

while test $# -gt 0; do
    case $1 in
        --help|-h)
            usage
            exit 0
            ;;
        --)
            shift 1
            break
            ;;
        -*)
            echo "${PROGNAME}: unknown option $1" >&2
            usage >&2
            exit 1
            ;;
        *)
            # probably the first positional argument
            break
    esac
done

if test $# -lt 3; then
    echo "${PROGNAME}: not enough arguments" >&2
    usage >&2
    exit 1
fi

BASE=$1
CURRENT=$2
OTHER=$3
LOCATION=$4

set -e

echo "ansible-vault-merge ${LOCATION}"

ansible-vault decrypt $BASE > /dev/null
ansible-vault decrypt $CURRENT > /dev/null
ansible-vault decrypt $OTHER > /dev/null

if ! git merge-file -L CURRENT -L BASE -L OTHER $CURRENT $BASE $OTHER; then
    echo "Merge conflict; opening editor to resolve." >&2
    ${EDITOR:-vi} $CURRENT
fi

ansible-vault encrypt $CURRENT
