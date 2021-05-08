# shellcheck shell=bash


# -------------------------- run ------------------------- #

trap sigint INT
sigint() {
	set +x
	die 'Received SIGINT'
}


# -------------------- util functions -------------------- #

req() {
	curl --proto '=https' --tlsv1.2 -sSLf "$@"
}

die() {
	[ -n "$*" ] && {
		log_error "${*-'die: '}. Exiting"
	}

	if [ "${BASH_SOURCE[0]}" != "$0" ]; then
		return 1
	else
		exit 1
	fi
}

notify_die() {
	msg="$2"

	[ "$1" = yes ] && {
		notify-send -u critical "Choose: $msg. Exiting"
	}

	die "$msg"
}

notify_info() {
	msg="$2"

	[ "$1" = yes ] && {
		notify-send "Choose: $msg"
	}

	log_info "$msg"
}

log_info() {
	printf "\033[0;34m%s\033[0m\n" "Info: $*"
}

log_warn() {
	printf "\033[1;33m%s\033[0m\n" "Warn: $*" >&2
}

log_error() {
	printf "\033[0;31m%s\033[0m\n" "Error: $*" >&2
}

ifCmdFailed() {
	statusCode="$1"
	[ -z "$statusCode" ] && die "ifCmdFailed: statusCode cannot be empty"

	if [ "$statusCode" -eq 0 ]; then
		return 1
	else
		# if the statusCode is not zero (command failed),
		# we return success so the '&&' operation works
		return 0
	fi
}

get_cmd() {
	local isGui="$1"

	local cmd="fzf"
	if [ "$isGui" = "yes" ]; then
		# TODO: check for fox-default value
		if command -v rofi >&/dev/null; then
			cmd="rofi -dmenu"
		elif command -v dmenu >&/dev/null; then
			cmd="dmenu"
		fi
	fi

	printf "%s" "$cmd"
}


# ------------------- helper functions ------------------- #

util_show_help() {
	cat <<-EOF
		Usage:
		    fox-default [command]

		Commands:
		    launch [category]
		        Launches the default program in a particular category

		    set [category] [application]
		        Sets the default program in a particular category

		Flags:
		    --help
		    --gui

		Examples:
		    fox-default launch image-viewer
		    fox-default set image-viewer svix
		    fox-default --gui set
		    fox-default --help
	EOF
}
