#!/usr/bin/env bash

# async issues with +u when sourcing
set -Eo pipefail

# shellcheck disable=SC2164
DIR="$(dirname "$(cd "$(dirname "$0")"; pwd -P)/$(basename "$0")")"

# ------------------------- start ------------------------ #
source "$DIR/lib/util.sh"

defaultsDir="${XDG_CONFIG_HOME:-$HOME/.config}/fox-default/defaults"

main() {
	[ -z "$1" ] && {
		util_show_help
		die 'No subcommand found'
	}

	case "$1" in
	set)
		shift

		local category="$1"
		local launcher="$2"

		# ensure variable
		[ -z "$category" ] && {
			category="$(cd "$defaultsDir" && find . -type d | cut -c 3- | grep "\S" | fzf)"
			if [ $? -ne 0 ]; then
				die "Did not complete previous selection properly. Exiting"
			fi
		}

		# validate variable
		[ -d "$defaultsDir/$category" ] || {
			die "Category does not exist"
		}


		# ensure variable
		[ -z "$launcher" ] && {
			launcher="$(cd "$defaultsDir/$category" && find . | cut -c 3- | grep "\S" | fzf)"
			if [ $? -ne 0 ]; then
				die "Did not complete previous selection properly. Exiting"
			fi
		}

		# validate variable
		[ -f "$defaultsDir/$category/$launcher" ] || {
			die "Application does not exist"
		}

		echo "$launcher" >| "$defaultsDir/$category.current"
		printf "Category '%s' defaults to '%s\n" "$category" "$launcher"
		;;
	launch)
		shift

		local category="$1"

		# ensure variable
		[ -z "$category" ] && {
			local category
			category="$(cd "$defaultsDir" && find . -type d | cut -c 3- | grep "\S" | fzf)"
			if [ $? -ne 0 ]; then
				die "Did not complete previous selection properly. Exiting"
			fi
		}

		# validate variable
		if [ ! -d "$defaultsDir/$category" ] || [ ! -r "$defaultsDir/$category.current" ]; then
			die "Application category '$category' does not exist"
		fi


		# get variable
		launcher="$(<"$defaultsDir/$category.current")"

		# ensure variable
		[ -z "$launcher" ] && {
			die "Launcher is not set. Please set with 'fox-default set'"
		}

		# ------------------------ launch ------------------------ #
		# if launcher file has content, it means
		# we manually set an execute command. source it
		if [ -s "$defaultsDir/$category/$launcher" ]; then
			source "$defaultsDir/$category/$launcher"
			exit
		fi

		# launcher file doesn't have content...

		# ensure variable is in the environment
		command -v "$launcher" &>/dev/null 2>&1 || {
			die "Executable '$launcher' does not exist or is not in the current environment"
		}

		# shellcheck disable=SC2093
		exec "$launcher"

		;;
	*)
		die "Subcommand not found"
	;;
	esac
}

main "$@"
