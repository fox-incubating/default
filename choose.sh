#!/usr/bin/env bash

# async issues with +u when sourcing
set -Eo pipefail

DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

# ------------------------- start ------------------------ #
source "$DIR/lib/util.sh"
source "$DIR/lib/plumbing.sh"

dbDir="${CHOOSE_DB_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/choose/db}"

main() {
	[ -z "$1" ] && {
		util_show_help
		notify_die "$gui" 'No subcommand found'
		return
	}

	# whether or not we are launching GUI selection interfaces
	local gui=no
	if [ "$1" = "--gui" ]; then
		gui=yes
		shift
	fi

	case "$*" in
	*--gui*)
		notify_die "$gui" "Must place '--gui' as first arg"
		return
		;;
	esac


	case "$1" in
	set)
		shift

		local category="$1"
		local program="$2"

		category="$(util_get_category "$category" "$gui")"
		ifCmdFailed "$?" && return


		program="$(util_get_program "$category" "$program" "$gui")"
		ifCmdFailed "$?" && return

		# source pre-exec
		if [ -s "$dbDir/$category/set.sh" ]; then
			source "$dbDir/$category/set.sh"
		fi

		echo "$program" >| "$dbDir/$category/_.current"
		notify_info "$gui" "Category '$category' defaults to '$program'"
		;;
	launch)
		shift

		local category="$1"

		category="$(util_get_category_filter "$category" "$gui")"
		ifCmdFailed "$?" && return

		# get variable
		program="$(<"$dbDir/$category/_.current")"

		# ensure variable (we already use 'ensure_has_dot_current' in
		# util_get_category_filter; this is another safeguard)
		[ -z "$program" ] && {
			notify_die "$gui" "program for '$category' is not set. Please set with 'fox-default set'"
			return
		}

		# ------------------------ launch ------------------------ #
		# source pre-exec
		if [ -s "$dbDir/$category/launch.sh" ]; then
			source "$dbDir/$category/launch.sh"
		fi

		# if program file has content, it means
		# we manually set an execute command. source it
		if [ -s "$dbDir/$category/$program/launch.sh" ]; then
			source "$dbDir/$category/$program/launch.sh"
			die
			return
		# if file does not have content, we raw exec it
		else
			# ensure variable is in the environment
			command -v "$program" &>/dev/null || {
				notify_die "$gui" "Executable '$program' does not exist or is not in the current environment"
				return
			}

			exec "$program"
		fi
		;;
	get)
		shift

		local category="$1"
		;;
	--help)
		util_show_help
		;;
	*)
		notify_die "$gui" "Subcommand not found"
		return
	;;
	esac
}

main "$@"
