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

		# ensure variable
		[ -z "$category" ] && {
			local cmd
			cmd="$(get_cmd "$gui")"

			category="$(plumbing_list_dir "$dbDir" | $cmd)"
			ifCmdFailed "$?" && {
				notify_die "$gui" "Did not complete previous selection properly"
				return
			}
		}

		# validate variable
		[ -d "$dbDir/$category" ] || {
			notify_die "$gui" "Category '$category' does not exist"
			return
		}

		# ensure variable
		[ -z "$program" ] && {
			local userSelectCmd="fzf"
			userSelectCmd="$(get_cmd "$gui")"

			program="$(
				plumbing_list_dir "$dbDir/$category" \
				| grep -v "_.current" \
				| $userSelectCmd
			)"
			ifCmdFailed "$?" && {
				notify_die "$gui" "Did not complete previous selection properly"
				return
			}
		}

		# validate variable
		[ -d "$dbDir/$category/$program" ] || {
			notify_die "$gui" "Application '$program' does not exist"
			return
		}

		# set variable
		echo "$program" >| "$dbDir/$category/_.current"
		notify_info "$gui" "Category '$category' defaults to '$program'"
		;;
	launch)
		shift

		local category="$1"

		# ensure variable
		[ -z "$category" ] && {
			local userSelectCmd
			userSelectCmd="$(get_cmd "$gui")"

			ensure_has_dot_current() {
				while IFS= read -r dir; do
					if [ -s "$dbDir/$dir/_.current" ]; then
						echo "$dir"
					fi
				done
			}

			category="$(
				plumbing_list_dir "$dbDir" \
				| ensure_has_dot_current \
				| grep "\S" \
				| $userSelectCmd
			)"
			ifCmdFailed "$?" && {
				notify_die "$gui" "Did not complete previous selection properly"
				return
			}

		}

		# validate variable
		if [ ! -d "$dbDir/$category" ] || [ ! -s "$dbDir/$category/_.current" ]; then
			notify_die "$gui" "Application category '$category' does not exist"
			return
		fi

		# get variable
		program="$(<"$dbDir/$category/_.current")"

		# ensure variable
		[ -z "$program" ] && {
			notify_die "$gui" "program for '$category' is not set. Please set with 'fox-default set'"
			return
		}

		# ------------------------ launch ------------------------ #
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
