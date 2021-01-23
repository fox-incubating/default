#!/usr/bin/env bash

# async issues with +u when sourcing
set -o pipefail

defaultsDir="${XDG_CONFIG_HOME:-$HOME/.config}/fox-default/defaults"

main() {
	: "${1:?"Error: First parameter 'action' not found"}"

	case "$1" in
	set)
		local category launcher

		category="$(cd "$defaultsDir" && find . -type d | cut -c 3- | grep "\S" | fzf)"
		# shellcheck disable=SC2181
		if [ $? -ne 0 ]; then
			echo "Error: Did not complete previous selection properly. Exiting"
			return 1
		fi

		launcher="$(cd "$defaultsDir/$category" && find . | cut -c 3- | grep "\S" | fzf)"

		cat >| "$defaultsDir/$category.current" <<< "$launcher"
		echo "$launcher"
		;;
	launch)
		: "${2:?"Error: Second parameter 'application category' not found"}"

		[ "$2" = "-" ] && {
			local category
			category="$(cd "$defaultsDir" && find . -type d | cut -c 3- | grep "\S" | fzf)"
			cat "$defaultsDir/$category.current"
			return
		}

		local category="$2"
		if [ -d "$defaultsDir/$category" ] && [ -r "$defaultsDir/$category.current" ]; then
			launcher="$(< "$defaultsDir/$category.current")"
			# if launcher file has content, source our shim
			if [ -s "$defaultsDir/$category/$launcher" ]; then
				# shellcheck source=/dev/null
				source "$defaultsDir/$category/$launcher"
			# launcher file contentless; just exec it
			elif [ -n "$launcher" ]; then
				# shellcheck disable=SC2093
				exec "$launcher"
			else
				echo "Error: '$category' not set" >&2
			fi
		else
			echo "Error: application category '$category' does not exist" >&2
		fi
		;;
	*)
		echo "Error: Subcommand not found" >&1
		return 1
	;;
	esac
}

main "$@"
