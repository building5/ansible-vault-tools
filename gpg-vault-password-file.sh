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

# Get the old password, if there is one
if test -e ${PASSWORD_SCRIPT}; then
  if test -x ${PASSWORD_SCRIPT}; then
    # existing password is a script. Run it!
    OLD_VAULT_PASSWORD="$(${PASSWORD_SCRIPT})"
  elif test -f ${PASSWORD_SCRIPT}; then
    # existing password is plain. Cat it!
    OLD_VAULT_PASSWORD="$(cat ${PASSWORD_SCRIPT})"
  else
    echo "${PROGNAME}: ${PASSWORD_SCRIPT} is not a file" >&2
    exit 1
  fi

  if test $? -ne 0; then
    echo "${PROGNAME}: failed to read ${PASSWORD_SCRIPT}" >&2
    exit 1
  fi
else
  # If the ciphertext exists, but not the script
  if test -e ${PASSWORD_CIPHERTEXT}; then
    echo "${PROGNAME}: refusing to overwrite ${PASSWORD_CIPHERTEXT}" >&2
    exit 1
  fi
fi

# Get the new password, if there is one
echo "Press Ctrl-c to abort without changing anything"
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
# !!! Written by gpg-vault-password-file !!!
gpg --decrypt --batch < \$0.asc 2> /dev/null
EOF
chmod a+x ${PASSWORD_SCRIPT}
echo "${VAULT_PASSWORD}" | gpg --encrypt --armor --default-recipient-self > ${PASSWORD_CIPHERTEXT}

