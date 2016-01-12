#!/bin/sh

#
# gpg-vault-password-file: script for managing an encrypted vault password file
#

PROGNAME=$(basename $0)

usage() {
    cat <<EOF
usage: ${PROGNAME} [OPTION]... [--] new-password-file

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

if test $# -lt 1; then
    echo "${PROGNAME}: not enough arguments" >&2
    usage >&2
    exit 1
fi

PASSWORD_SCRIPT=$1
PASSWORD_CIPHERTEXT=$1.asc

MARKER_COMMENT="# !!! Written by gpg-vault-password-file !!!"

if test -e ${PASSWORD_SCRIPT}; then
    if ! grep -q -F "${MARKER_COMMENT}" ${PASSWORD_SCRIPT}; then
        echo "${PROGNAME}: refusing to overwrite ${PASSWORD_SCRIPT}" >&2
        exit 1
    fi

    OLD_VAULT_PASSWORD=$(${PASSWORD_SCRIPT})
else
    # If the ciphertext exists, but not the script
    if test -e ${PASSWORD_CIPHERTEXT}; then
        echo "${PROGNAME}: refusing to overwrite ${PASSWORD_CIPHERTEXT}" >&2
        exit 1
    fi
fi

read -s -p "Enter vault password [$(echo ${OLD_VAULT_PASSWORD} | sed 's/.*\(...\)/***\1/')]: " VAULT_PASSWORD
echo
if test -z "${VAULT_PASSWORD}"; then
    VAULT_PASSWORD="${OLD_VAULT_PASSWORD}"
fi

if test -z "${VAULT_PASSWORD}"; then
    echo "${PROGNAME}: empty password" >&2
    exit 1
fi

cat <<EOF > ${PASSWORD_SCRIPT}
#!/bin/sh
${MARKER_COMMENT}
gpg --decrypt --batch < \$0.asc 2> /dev/null
EOF
chmod a+x ${PASSWORD_SCRIPT}
echo "${VAULT_PASSWORD}" | gpg --encrypt --armor --default-recipient-self > ${PASSWORD_CIPHERTEXT}

