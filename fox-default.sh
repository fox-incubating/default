#!/usr/bin/env bash

# async issues with +u when sourcing
set -Eo pipefail

DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

# ------------------------- start ------------------------ #
source "$DIR/lib/util.sh"
source "$DIR/lib/plumbing.sh"

defaultsDir="${XDG_CONFIG_HOME:-$HOME/.config}/fox-default/defaults"

main() {
	[ -z "$1" ] && {
		util_show_help
		notify_die "$gui" 'No subcommand found' || return
	}

	# whether or not we are launching GUI selection interfaces
	local gui=no
	if [ "$1" = "--gui" ]; then
		gui=yes
		shift
	fi

	case "$*" in
	*--gui*)
		notify_die "$gui" "Must place '--gui' as first arg" || return
		;;
	esac


	case "$1" in
	set)
		shift

		local category="$1"
		local launcher="$2"

		# ensure variable
		[ -z "$category" ] && {
			local cmd="fzf"
			if [ "$gui" = "yes" ]; then
				cmd="rofi -dmenu"
			fi

			category="$(plumbing_list_dir "$defaultsDir" | $cmd)" || {
				notify_die "$gui" "Did not complete previous selection properly. Exiting" || return
			}
		}

		# validate variable
		[ -d "$defaultsDir/$category" ] || {
			notify_die "$gui" "Category '$category' does not exist" || return
		}


		# ensure variable
		[ -z "$launcher" ] && {
			local cmd="fzf"
			if [ "$gui" = "yes" ]; then
				cmd="rofi -dmenu"
			fi

			launcher="$(plumbing_list_file "$defaultsDir/$category" | grep -v "_.current" | $cmd)" || {
				notify_die "$gui" "Did not complete previous selection properly. Exiting" || return
			}
		}

		# validate variable
		[ -f "$defaultsDir/$category/$launcher" ] || {
			notify_die "$gui" "Application '$launcher' does not exist" || return
		}

		# set variable
		echo "$launcher" >| "$defaultsDir/$category/_.current"
		printf "Category '%s' defaults to '%s'\n" "$category" "$launcher" | tee /dev/tty | xargs -I{} notify-send "{}"
		;;
	launch)
		shift

		local category="$1"

		# ensure variable
		[ -z "$category" ] && {
			local cmd="fzf"
			if [ "$gui" = "yes" ]; then
				cmd="rofi -dmenu"
			fi

			ensure_has_dot_current() {
				while IFS= read -r dir; do
					if [ -s "$defaultsDir/$dir/_.current" ]; then
						echo "$dir"
					fi
				done
			}

			category="$(plumbing_list_dir "$defaultsDir" | ensure_has_dot_current | grep "\S" | $cmd)" || {
				notify_die "$gui" "Did not complete previous selection properly. Exiting" || return
			}

		}

		# validate variable
		if [ ! -d "$defaultsDir/$category" ] || [ ! -s "$defaultsDir/$category/_.current" ]; then
			notify_die "$gui" "Application category '$category' does not exist" || return
		fi

		# get variable
		launcher="$(<"$defaultsDir/$category/_.current")"

		# ensure variable
		[ -z "$launcher" ] && {
			notify_die "$gui" "Launcher for '$category' is not set. Please set with 'fox-default set'" || return
		}

		# ------------------------ launch ------------------------ #
		# if launcher file has content, it means
		# we manually set an execute command. source it
		if [ -s "$defaultsDir/$category/$launcher" ]; then
			source "$defaultsDir/$category/$launcher"
			die
		fi

		# launcher file doesn't have content...

		# ensure variable is in the environment
		command -v "$launcher" &>/dev/null 2>&1 || {
			notify_die "$gui" "Executable '$launcher' does not exist or is not in the current environment" || return
		}

		exec "$launcher"
		;;
	--help)
		util_show_help
		;;
	*)
		notify_die "$gui" "Subcommand not found" || return
	;;
	esac
}

main "$@"
