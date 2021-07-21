# shellcheck shell=bash


# -------------------------- run ------------------------- #
trap sigint INT
sigint() {
	set +x
	log.die "$gui" 'Received SIGINT'
}

# -------------------- util functions -------------------- #
log.die() {
	local gui="$1"
	local msg="$2"

	if [ "$gui" = yes ]; then
		notify-send -u critical "Choose: $msg. Exiting"
	fi

	if [ -n "$msg" ]; then
		printf "\033[0;31m%s\033[0m\n" "Error: $msg" >&2
	fi

	exit 1
}

log.info() {
	local msg="$1"

	if [ "$msg" = yes ]; then
		notify-send "Choose: $msg"
	fi

	printf "\033[0;34m%s\033[0m\n" "Info: $msg"
}

ensure.non_zero() {
	local variable="$1"
	local value="$2"

	if [ -z "$value" ]; then
		log.die "$gui" "Error: '$variable' is empty"
	fi
}
