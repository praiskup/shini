#! /bin/sh

abs_aux_dir=`pwd`/gl-mod/bootstrap/build-aux

all_shells_script=$0
. "./gl-mod/bootstrap/tests/test-all-shells.sh"

base=$1

set -e
(
  . ./shini.sh
  shini_parse "$base".ini
  . ./"$base".sh
) > "$base".out 2>"$base".err

cmp "$base".out "$base".exp || all_shells_error "unexpected output"

$all_shells_exit_cmd
