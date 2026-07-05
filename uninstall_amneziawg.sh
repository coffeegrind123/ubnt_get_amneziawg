#!/usr/bin/env bash
###############################################################################
#         File:  uninstall_amneziawg.sh                                       #
#                                                                             #
#        Usage:  uninstall_amneziawg.sh                                       #
#                                                                             #
#  Description:  Uninstall AmneziaWG from Ubiquiti routers and remove         #
#                persistent package.                                          #
#                                                                             #
#       Author:  whiskerz007                                                  #
#      Website:  https://github.com/coffeegrind123/ubnt_get_amneziawg         #
#      License:  MIT                                                          #
###############################################################################

set -o errexit  #Exit immediately if a pipeline returns a non-zero status
set -o errtrace #Trap ERR from shell functions, command substitutions, and commands from subshell
set -o nounset  #Treat unset variables as an error
set -o pipefail #Pipe will exit with last non-zero status if applicable
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
trap die ERR
trap cleanup EXIT

function error_exit() {
  trap - ERR
  local DEFAULT='Unknown failure occured.'
  local REASON="\e[97m${1:-$DEFAULT}\e[39m"
  local FLAG="\e[91m[ERROR] \e[93m$EXIT@$LINE"
  msg "$FLAG $REASON"
  exit $EXIT
}
function warn() {
  local REASON="\e[97m$1\e[39m"
  local FLAG="\e[93m[WARNING]\e[39m"
  msg "$FLAG $REASON"
}
function msg() {
  local TEXT="$1"
  echo -e "$TEXT"
}
function cleanup() {
  if [ ! -z ${VYATTA_API+x} ] && $($VYATTA_API inSession); then
    vyatta_cfg_teardown
  fi
}
function vyatta_cfg_setup() {
  $VYATTA_API setupSession
  if ! $($VYATTA_API inSession); then
    die "Failure occured while setting up vyatta configuration session."
  fi
}
function vyatta_cfg_teardown() {
  if ! $($VYATTA_API teardownSession); then
    die "Failure occured while tearing down vyatta configuration session."
  fi
}
function add_to_path() {
  for DIR in "$@"; do
    if [ -d "$DIR" ] && [[ ":$PATH:" != *":$DIR:"* ]]; then
      PATH="${PATH:+"$PATH:"}$DIR"
    fi
  done
}

if [ "$(id -g -n)" != 'vyattacfg' ] ; then
    echo switching group to vyattacfg...
    exec sg vyattacfg -c "$(which bash) -$- $(readlink -f $0) $*"
fi

[[ $EUID -ne 0 ]] && SUDO='sudo'
add_to_path /sbin /usr/sbin

# Setup vyatta environment
VYATTA_SBIN=/opt/vyatta/sbin
VYATTA_API=${VYATTA_SBIN}/my_cli_shell_api
VYATTA_SET=${VYATTA_SBIN}/my_set
VYATTA_DELETE=${VYATTA_SBIN}/my_delete
VYATTA_COMMIT=${VYATTA_SBIN}/my_commit
VYATTA_SESSION=$(cli-shell-api getSessionEnv $$)
eval $VYATTA_SESSION
export vyatta_sbindir=$VYATTA_SBIN

# Get installed AmneziaWG version (package is named amneziawg)
INSTALLED_VERSION=$(dpkg-query --show --showformat='${Version}' amneziawg 2> /dev/null || true)

# If an AmneziaWG interface is configured, remove it
if $($VYATTA_API existsActive interfaces amneziawg); then
  msg 'Removing running AmneziaWG configuration...'
  vyatta_cfg_setup
  $VYATTA_DELETE interfaces amneziawg
  $VYATTA_COMMIT
  vyatta_cfg_teardown
fi

# If the AmneziaWG module is loaded, remove it
if lsmod | grep -q '^amneziawg'; then
  msg 'Removing AmneziaWG module...'
  ${SUDO-} modprobe --remove amneziawg || \
    die "A problem occured while removing AmneziaWG module."
fi

# Uninstall AmneziaWG package
msg 'Uninstalling AmneziaWG...'
${SUDO-} dpkg --purge amneziawg &> /dev/null || \
  die "A problem occured while uninstalling the package."

# Remove firstboot package
FIRSTBOOT_DEB='/config/data/firstboot/install-packages/amneziawg.deb'
if [ -f $FIRSTBOOT_DEB ]; then
  msg 'Removing AmneziaWG package from firstboot path...'
  ${SUDO-} rm $FIRSTBOOT_DEB || \
    warn "Failure removing debian package from firstboot path."
fi

msg 'AmneziaWG has been successfully uninstalled.'
