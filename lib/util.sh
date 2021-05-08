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


# ------------------- helper functions ------------------- #

util_show_help() {
	cat <<-EOF
		Usage:
		    choose [command]

		Commands:
		    launch [category]
		        Launches the default program in a particular category

		    set [category] [application]
		        Sets the default program in a particular category

		Flags:
		    --help
		    --gui

		Examples:
		    choose launch image-viewer
		    choose set image-viewer svix
		    choose --ignore-errors get image-viewer
		    choose --gui set
		    choose --help
	EOF
}

util_get_cmd() {
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

# almost duplicate of util_get_category_filter
util_get_category() {
	local category="$1"
	local gui="$2"

	if [ -z "$category" ]; then
		local cmd
		cmd="$(util_get_cmd "$gui")"

		category="$(plumbing_list_dir "$dbDir" | $cmd)"
		ifCmdFailed "$?" && {
			notify_die "$gui" "Did not complete previous selection properly"
			return
		}
	fi

	# validate
	if [ ! -d "$dbDir/$category" ]; then
		notify_die "$gui" "Application category '$category' does not exist"
		return
	elif [ ! -s "$dbDir/$category/_.current" ]; then
		notify_die "$gui" "Application category '$category' does not have a default program associated with it"
		return
	fi

	printf "%s" "$category"
}


# almost duplicate of util_get_category
util_get_category_filter() {
	local category="$1"
	local gui="$2"

	[ -z "$category" ] && {
		local userSelectCmd
		userSelectCmd="$(util_get_cmd "$gui")"

		ensure_has_dot_current() {
			while IFS= read -r dir; do
				if [ -s "$dbDir/$dir/_.current" ]; then
					echo "$dir"
				fi
			done
		}

		category="$(
			plumbing_list_dir "$dbDir" \
			| ensure_has_dot_current \
			| grep "\S" \
			| $userSelectCmd
		)"
		ifCmdFailed "$?" && {
			notify_die "$gui" "Did not complete previous selection properly"
			return
		}
	}

	# validate
	if [ ! -d "$dbDir/$category" ]; then
		notify_die "$gui" "Application category '$category' does not exist"
		return
	elif [ ! -s "$dbDir/$category/_.current" ]; then
		notify_die "$gui" "Application category '$category' does not have a default program associated with it"
		return
	fi

	printf "%s" "$category"
}

util_get_program() {
	local category="$1"
	local program="$2"
	local gui="$3"

	[ -z "$program" ] && {
		local userSelectCmd="fzf"
		userSelectCmd="$(util_get_cmd "$gui")"

		program="$(
			plumbing_list_dir "$dbDir/$category" \
			| grep -v "_.current" \
			| $userSelectCmd
		)"
		ifCmdFailed "$?" && {
			notify_die "$gui" "Did not complete previous selection properly"
			return
		}
	}

	# validate variable
	[ -d "$dbDir/$category/$program" ] || {
		notify_die "$gui" "Application '$program' does not exist"
		return
	}

	printf "%s" "$program"
}
