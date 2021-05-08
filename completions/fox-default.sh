# shellcheck shell=bash

dbDir="${CHOOSE_DB_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/choose/db}"

_in_arr() {
	for e in "${@:2}"; do
		[[ "$e" == "$1" ]] && {
			return 0
		}
	done
	return 1
}

_fox-default-set() {
	local cur="${COMP_WORDS[COMP_CWORD]}"

	local -a dirs=()
	readarray -d $'\0' dirs < <(find "$dbDir" -maxdepth 1 -mindepth 1 -type d -printf '%f\0')

	# if we are completing the second element
	if _in_arr "${COMP_WORDS[2]}" "${dirs[@]}"; then
		local -a files=()
		readarray -d $'\0' files < <(find "$dbDir/${COMP_WORDS[2]}" -maxdepth 1 -mindepth 1 -type f -printf '%f\0')

		# remove _.current
		local -a files_filtered=()
		for file in "${files[@]}"; do
			[ "$file" = "_.current" ] && continue
			files_filtered+=("$file")
		done

		# shellcheck disable=SC2207
		COMPREPLY=($(IFS=' ' compgen -W "${files_filtered[*]}" -- "$cur"))
		return
	fi

	# shellcheck disable=SC2207
	COMPREPLY=($(IFS=' ' compgen -W "${dirs[*]}" -- "$cur"))

}

_fox-default-launch() {
	local cur="${COMP_WORDS[COMP_CWORD]}"

	local -a dirs=()
	readarray dirs < <(plumbing_list_dir "$dbDir")

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
			_fox-default-set ;;
		launch)
			_fox-default-launch ;;
		*) ;;
	esac

} && {
	complete -F _fox-default fox-default
}
