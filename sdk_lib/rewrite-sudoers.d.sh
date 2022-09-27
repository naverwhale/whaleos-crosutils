#!/bin/bash
# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -e

if [[ "${UID:-$(id -u)}" != 0 ]]; then
  # Note that since we're screwing w/ sudo variables, this script
  # explicitly bounces up to root for everything it does- that way
  # if anyone introduces a temp depriving in the sudo setup, it can't break
  # mid upgrade.

  # shellcheck source=../common.sh
  . "$(dirname "$(dirname "$0")")/common.sh" || exit 1

  load_environment_whitelist
  echo "Rewriting with env list ${ENVIRONMENT_WHITELIST[*]}"
  exec sudo bash "$0" / "${USER}" "${ENVIRONMENT_WHITELIST[@]}"
  exit 1
fi

# Reaching here means we're root.

if [[ $# -lt 2 ]]; then
  echo "Invoked with wrong number of args; expected root USER [variables]*" >&2
  exit 1
fi

root=$1
username=$2
shift 2
set -- "$@" CROS_WORKON_SRCROOT PORTAGE_USERNAME

cat > "${root}/etc/sudoers.d/90_cros" <<EOF
Defaults env_keep += "$*"

# We need adm currently to let sudo work inside ebuilds.
%adm ALL=(ALL) ALL
root ALL=(ALL) ALL
${username} ALL=NOPASSWD: ALL

# Simplify the -v option checks due to overlap of the adm group and the user's
# supplementary groups.  We don't set any passwords, so disable asking.
# https://crbug.com/762445
Defaults verifypw = any
EOF

chmod 0440 "${root}/etc/sudoers.d/90_cros"
chown root:root "${root}/etc/sudoers.d/90_cros"
