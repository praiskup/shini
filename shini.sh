#! /bin/sh

# Parse ini files by plain shell.
# Copyright (C) 2017 Pavel Raiskup
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Library General Public License for more details.
#
# You should have received a copy of the GNU Library General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

if test -z "$SHELLINI_LOADED"; then
SHELLINI_LOADED=:

: ${SHINI_KW_SUMTOOL=sha256sum}
: ${SHINI_DEBUG=false}

_si_error ()
{
    echo >&2 " ERROR: $*"
    false
}

_shini_debug ()
{
    if $SHINI_DEBUG; then
        echo >&2 " * $*"
    fi
    :
}

_shini_cleanup_keyword_expensive ()
{
    _si_raw_key=$1
    set -- `echo "$1" | $SHINI_KW_SUMTOOL`
    eval _si_sum_check='$_si_sum_check_'"$1"
    # TODO: do something wiser than exit.
    test -n "$_si_sum_check" && test "$_si_sum_check" != "$_si_raw_key" && {
        echo >&2 "sum ($SHINI_KW_SUMTOOL) clash: '$_si_raw_key' vs. '$_si_sum_check'"
        exit 1
    }
    eval _si_sum_check_"$1"=\$_si_raw_key
    _si_keyword_expensive="___k___$1"
}

__si_varname ()
{
    _shini_cleanup_keyword "$2"
    __si_varname_result=$1__$_si_keyword
}

_shini_cleanup_keyword ()
{
    __si_shell_chars='*?"\\$;&()|^<>#{}. 	'
    case $1 in
    *[$__si_shell_chars]*)
        # We need sed, unfortunately
        _shini_cleanup_keyword_expensive "$1"
        _si_keyword=$_si_keyword_expensive
        ;;
    *)
        # Perhaps we can avoid calling sed?
        if eval "$1= :" >/dev/null 2>/dev/null; then
            _si_keyword=$1
        else
            _shini_cleanup_keyword_expensive "$1"
            _si_keyword=$_si_keyword_expensive
        fi
        ;;
    esac
}

_shini_section ()
{
    _si_trim_space "$1"

    _si_save_IFS=$IFS
    IFS='[]'
    set -- $_trim_val
    IFS=$_si_save_IFS

    _shini_cleanup_keyword "$2"
    _shini_debug section: "[$_si_keyword]"
    _si_section=$_si_keyword
}

_si_trim_space ()
{
    # Try to avoid calling sed if possible.
    _trim_val=$1
    case $1 in
    [\ \	]*|*[\ \	])
        # TODO: We could use ${VAR##} and ${VAR%%} when available.
        _trim_val=`echo "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`
        ;;
    esac
}


_shini_line ()
{
    __shini_line=$1
    # Trim trailing/leading whitespace.
    set -- $1
    case $* in
    '['?*']')
        case $__shini_line in
        *'['*'['*|*'['*']'*']'*|*'[]'*)
            _si_error syntax
            ;;
        *)
            _shini_section "$__shini_line"
            ;;
        esac
        ;;
    '')
        _shini_debug 'empty line'
        ;;
    [';#']*)
        _shini_debug 'comment'
        ;;
    *=*)
        save_IFS=$IFS
        IFS='='
        set -- $__shini_line
        IFS=$save_IFS
        _si_key=$1 ; shift
        _si_sep=
        _si_value=
        while test $# -gt 0; do
            _si_value="$_si_value$_si_sep$1"
            _si_sep='='
            shift
        done

        # Drop leading/trailing spaces from key.
        _si_trim_space "$_si_key"
        _si_key=$_trim_val
        _si_trim_space "$_si_value"
        _si_value=$_trim_val

        __si_set "$_si_section" "$_si_key" "$_si_value"
        ;;
    *)
        _shini_debug unparsed: "$1"
        ;;
    esac
}


__si_set ()
{
    __si_varname "$1" "$2"
    eval "__SI_VAL__$__si_varname_result=\$3"
    eval "__SI_VAL_SET__$__si_varname_result=y"
}


shini_parse ()
{
    _si_section=DEFAULT
    test -f "$1" || exit 1
    while IFS= read -r line <&9 || test -n "$line"
    do
        _shini_line "$line"
    done 9<"$1"
}


__si_get ()
{
    _si_value=
    __si_varname "$@"
    if eval 'test x = x"$__SI_VAL_SET__'"$__si_varname_result\""; then
        _si_error "$__si_varname_result unset"
    else
        eval "_si_value=\$__SI_VAL__$__si_varname_result"
    fi
}


# shini_get [-s SECTION] PARAM
# -----------------------------
# Sets '$shini_value' variable.  SECTION parameter is optional - section can be
# set in advance by '$si_section' variable.  If neither is specified, 'DEFAULT'
# is used.
shini_get ()
{
    shini_value=
    _si_section=DEFAULT
    test -n "$si_section" && _si_section=$si_section

    _si_param_unset=:
    while test $# -gt 0; do
        case $1 in
        -s)
            shift
            test $# -eq 0 && break
            _si_section=$1
            shift
            ;;
        *)
            $_si_param_unset || break
            _si_param_unset=false
            _si_param=$1
            shift
            ;;
        esac
    done

    _shini_cleanup_keyword "$_si_section"
    _si_section=$_si_keyword

    if test -n "$_si_param" && test -n "$_si_section"; then
        __si_get "$_si_section" "$_si_param"
        shini_value=$_si_value
    else
        _si_error "bad params"
    fi
}
fi
