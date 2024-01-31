#!/bin/bash

set -e

shell_join() {
  local arg
  printf "%s" "$1"
  shift
  for arg in "$@"; do
    printf " "
    printf "%s" "${arg// /\ }"
  done
}

ohai() {
  printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$(shell_join "$@")"
}

warn() {
  printf "${tty_red}Warning${tty_reset}: %s\n" "$(chomp "$1")"
}

# The line below extracts the version from the list of tags in the Tuist repository.
LATEST_VERSION=$(git ls-remote -t --sort=v:refname https://github.com/tuist/tuist.git | sed -ne '$s/.*tags\/\(.*\)/\1/p')
ohai "Downloading tuistenv..."
[ -f /tmp/tuistenv.zip ] && rm /tmp/tuistenv.zip
[ -f /tmp/tuistenv ] && rm /tmp/tuistenv
curl -LSsf --output /tmp/tuistenv.zip https://github.com/tuist/tuist/releases/download/${LATEST_VERSION}/tuistenv.zip
ohai "Unzipping tuistenv..."
unzip -o /tmp/tuistenv.zip -d /tmp/tuistenv > /dev/null
ohai "Installing tuistenv..."

INSTALL_DIR="/usr/local/bin"

sudo_if_install_dir_not_writeable() {
  local command="$1"
  if [ -w $INSTALL_DIR ]; then
    bash -c "${command}"
  else
    bash -c "sudo ${command}"
  fi
}

if [[ ! -d $INSTALL_DIR ]]; then
  sudo_if_install_dir_not_writeable "mkdir -p ${INSTALL_DIR}"
fi

if [[ -f "${INSTALL_DIR}/tuist" ]]; then
  sudo_if_install_dir_not_writeable "rm ${INSTALL_DIR}/tuist"
fi

sudo_if_install_dir_not_writeable "mv /tmp/tuistenv/tuistenv \"${INSTALL_DIR}/tuist\""
sudo_if_install_dir_not_writeable "chmod +x \"${INSTALL_DIR}/tuist\""

rm -rf /tmp/tuistenv
rm /tmp/tuistenv.zip

ohai "tuistenv installed. Try running 'tuist'"
ohai "Check out the documentation at https://docs.tuist.io/"