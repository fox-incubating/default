#!/usr/bin/env bash

# async issues with +u when sourcing
set -Eeo pipefail

db_dir="${CHOOSE_DB_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/choose/db}"

main.choose() {
	declare -A args=()
	declare -a argsCommands=()

	# shellcheck disable=SC1091
	bash-args parse "$@" <<-"EOF"
	@arg launch - (category) Launches the default program in a particular category
	@arg set - (category) (application) Sets the default program in a particular category
	@flag [gui] - Whether to open a GUI
	@flag [help.h] - Show help menu
	@flag [version.v] - Show version
	EOF

	if [ -z "${argsCommands[0]}" ]; then
		printf "%s\n" "$argsHelpText"
		log.die "$gui" 'No subcommand found'
	fi

	local gui="${args[gui]}"

	case "${argsCommands[0]}" in
	set)
		local category="${argsCommands[1]}"
		local program="${argsCommands[2]}"

		source "$BASALT_PACKAGE_DIR/pkg/commands/choose-set.sh"
		choose-set "$category" "$program" "$gui"
		;;
	launch)
		local category="${argsCommands[1]}"

		source "$BASALT_PACKAGE_DIR/pkg/commands/choose-launch.sh"
		choose-launch "$category" "$gui"
		;;
	print)
		local category="${argsCommands[1]}"

		source "$BASALT_PACKAGE_DIR/pkg/commands/choose-print.sh"
		choose-print "$category" "$gui"
		;;
	*)
		log.die "Subcommand '${argsCommands[0]}' not found"
	esac
}
