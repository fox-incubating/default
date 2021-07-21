#!/usr/bin/env bash

# @brief Fixes the choose 'database' by converting the schema from
# version 1 to 2

set -e
shopt -s nullglob extglob globstar

main() {
	local dbDir="${CHOOSE_DB_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/choose/db}"

	for categoryDir in "$dbDir"/*; do
		if [ ! -d "$categoryDir" ]; then
			printf "%s\n" "Warning: Category dir '$categoryDir' is not a directory. Skipping"
			continue
		fi

		categoryHasCurrent=no
		for programDir in "$categoryDir"/*; do
			# Special case '_.current'
			if [ "${programDir##*/}" = "_.current" ]; then
				categoryHasCurrent=yes

				if [ -d "$programDir" ]; then
					printf "%s\n" "Warning: '$programDir' is not a file. Converting"

					rmdir "$programDir"
					mkdir -p "${programDir%/*}"
					touch "$programDir"

				fi

				continue
			fi

			# General case
			if [ ! -d "$programDir" ]; then
				printf "%s\n" "Warning: Program dir '$programDir' is not a directory. Converting"

				rm "$programDir"
				mkdir -p "$programDir"

				continue
			fi

			if [ ! -f "$programDir/launch.sh" ]; then
				touch"$programDir/launch.sh"
			fi

			for programScript in "$programDir"/*; do
				if [ ! -f "$programScript" ]; then
					printf "%s\n" "Warning: Program script '$programScript' is not a file. Skipping"
					continue
				fi

				if [[ "$programScript" == *@(\{|\})* ]]; then
					printf "%s\n" "Warning: program script '$programScript' has malformated name. Skipping"
					continue
				fi
			done
		done

		if [ "$categoryHasCurrent" = no ]; then
			touch "$categoryDir/_.current"
		fi
	done
}

main "$@"
