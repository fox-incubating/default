#!/usr/bin/env bash

# async issues with +u when sourcing
set -Eo pipefail

DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

# if [ "${BASH_SOURCE[0]}" != "$0" ]; then
# 	GLOBAL_is_sourced=yes
# else
# 	GLOBAL_is_sourced=no
# fi

# ------------------------- start ------------------------ #
source "$DIR/lib/util.sh"
source "$DIR/lib/plumbing.sh"

defaultsDir="${XDG_CONFIG_HOME:-$HOME/.config}/fox-default/defaults"

main() {
	[ -z "$1" ] && {
		util_show_help
		die 'No subcommand found' || return
	}

	# gui
	local gui=no
	if [ "$1" = "--gui" ]; then
		gui=yes
		shift
	fi

	case "$*" in
	*--gui*)
		die "Must place '--gui' as first arg" || return
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
				die "Did not complete previous selection properly. Exiting" || return
			}

		}

		# validate variable
		[ -d "$defaultsDir/$category" ] || {
			die "Category does not exist" || return
		}


		# ensure variable
		[ -z "$launcher" ] && {
			local cmd="fzf"
			if [ "$gui" = "yes" ]; then
				cmd="rofi -dmenu"
			fi

			launcher="$(plumbing_list_dir "$defaultsDir/$category" | $cmd)" || {
				die "Did not complete previous selection properly. Exiting" || return
			}
		}

		# validate variable
		[ -f "$defaultsDir/$category/$launcher" ] || {
			die "Application does not exist" || return
		}

		echo "$launcher" >| "$defaultsDir/$category.current"
		printf "Category '%s' defaults to '%s\n" "$category" "$launcher"
		;;
	launch)
		shift

		local category="$1"

		# ensure variable
		[ -z "$category" ] && {
			if [ "$gui" = "yes" ]; then
				# TODO: fox-default for selection chooser / filter thing
				category="$(cd "$defaultsDir" && find . -type d | cut -c 3- | grep "\S" | rofi -dmenu)"
				if [ $? -ne 0 ]; then
					die "Did not complete previous selection properly. Exiting" || return
				fi
			else
				local category
				category="$(cd "$defaultsDir" && find . -type d | cut -c 3- | grep "\S" | fzf)"
				if [ $? -ne 0 ]; then
					die "Did not complete previous selection properly. Exiting" || return
				fi
			fi
		}

		# validate variable
		if [ ! -d "$defaultsDir/$category" ] || [ ! -r "$defaultsDir/$category.current" ]; then
			die "Application category '$category' does not exist" || return
		fi

		# get variable
		launcher="$(<"$defaultsDir/$category.current")"

		# ensure variable
		[ -z "$launcher" ] && {
			[ "$gui" = yes ] && {
				notify-send "Launcher for '$category' is not set. Please set one"
			}
			die "Launcher for '$category' is not set. Please set with 'fox-default set'" || return
		}

		# ------------------------ launch ------------------------ #
		# if launcher file has content, it means
		# we manually set an execute command. source it
		if [ -s "$defaultsDir/$category/$launcher" ]; then
			source "$defaultsDir/$category/$launcher"
			if [ "${BASH_SOURCE[0]}" = "$0" ]; then
				return 1
			else
				echo "exit 1"
				# exit 1
			fi
		fi

		# launcher file doesn't have content...

		# ensure variable is in the environment
		command -v "$launcher" &>/dev/null 2>&1 || {
			die "Executable '$launcher' does not exist or is not in the current environment" || return
		}

		# shellcheck disable=SC2093
		exec "$launcher"

		;;
	--help)
		util_show_help
		;;
	*)
		die "Subcommand not found"
	;;
	esac
}

main "$@"
