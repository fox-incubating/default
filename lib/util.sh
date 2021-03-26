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
	msg="fox-default: $2"

	[ "$1" = yes ] && {
		notify-send "$msg"
	}

	die "$msg"
}

ensure() {
	"$@" || die "'$*' failed"
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
