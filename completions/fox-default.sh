# shellcheck shell=bash

_fox-default-launch() {
	local cur="${COMP_WORDS[COMP_CWORD]}"

	local -a dirs=()
	for dir in "${XDG_CONFIG_HOME:-$HOME/.config}"/fox-default/defaults/*/; do
		dirs+=("$(basename "$dir")")
	done

	# shellcheck disable=SC2207
	COMPREPLY=($(IFS=' ' compgen -W "${dirs[*]}" -- "$cur"))
}

_fox-default() {
	local i=1 cmd

	# iterate over COMP_WORDS (ending at currently completed word)
	# this ensures we get command completion even after passing flags
	while [[ "$i" -lt "$COMP_CWORD" ]]; do
		local s="${COMP_WORDS[i]}"
		case "$s" in
		# if our current word starts with a '-', it is not a subcommand
		-*) ;;
		# we are completing a subcommand, set cmd
		*)
			cmd="$s"
			break
			;;
		esac
		(( i++ ))
	done

	# check if we're completing 'fox-default'
	if [[ "$i" -eq "$COMP_CWORD" ]]; then
		local cur="${COMP_WORDS[COMP_CWORD]}"
		# shellcheck disable=SC2207
		COMPREPLY=($(compgen -W "set launch --help --version" -- "$cur"))
		return
	fi

	# if we're not completing 'fox-default', then we're completing a subcommand
	case "$cmd" in
		set)
			COMPREPLY=() ;;
		launch)
			_fox-default-launch ;;
		*) ;;
	esac

} && complete -F _fox-default fox-default
