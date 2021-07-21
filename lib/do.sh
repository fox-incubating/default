# shellcheck shell=bash

do_set() {
	local category="$1"
	local program="$2"
	local gui="$3"

	# Get category
	if ! helper_get_category "$category" "$gui"; then
		log.die "$gui" "Could not get category"
	fi
	category="$REPLY"

	# Get program
	if ! helper_get_program "$category" "$program" "$gui"; then
		log.die "$gui" "Could not get program"
	fi
	program="$REPLY"

	# Actually set
	printf "%s" "$program" >| "$dbDir/$category/_.current"

	log.info "Category '$category' defaults to '$program'"
}

do_launch() {
	local category="$1"
	local gui="$2"

	if ! helper_get_category_filter "$category" "$gui"; then
		exit 1
	fi
	category="$REPLY"

	# Check to ensure category is set
	if [ ! -f "$dbDir/$category/_.current" ]; then
		log.die "$gui" "Program for '$category' is not set. Please set with 'choose set'"
	fi

	program="$(<"$dbDir/$category/_.current")"

	# ensure variable (we already use 'ensure_has_dot_current' in
	# helper_get_category_filter; this is another safeguard)
	if [ -z "$program" ]; then
		log.die "$gui" "Program for '$category' is not set. Please set with 'choose set'"
	fi

	# ------------------------ launch ------------------------ #
	# Source category pre
	if [ -f "$dbDir/$category/pre.sh" ]; then
		source "$dbDir/$category/pre.sh"
	fi

	# Source program pre
	if [ -f "$dbDir/$category/$program/pre.sh" ]; then
		source "$dbDir/$category/$program/pre.sh"
	fi

	# Source launch if it exists. If otherwise, infer
	# the launch command from the program name
	if [ -f "$dbDir/$category/$program/launch.sh" ]; then
		if ! source "$dbDir/$category/$program/launch.sh"; then
			log.die "$gui" "Source failed"
		fi
	else
		if ! command -v "$program" &>/dev/null; then
			log.die "$gui" "Executable '$program' does not exist or is not in the current environment"
		fi

		exec "$program"
	fi

	# Source program post
	if [ -f "$dbDir/$category/$program/post.sh" ]; then
		source "$dbDir/$category/$program/post.sh"
	fi

	# Source category post
	if [ -f "$dbDir/$category/post.sh" ]; then
		source "$dbDir/$category/post.sh"
	fi
}

do_print() {
	local category="$1"

	program="$(<"$dbDir/$category/_.current")"

	# ensure variable (we already use 'ensure_has_dot_current' in
	# helper_get_category_filter; this is another safeguard)
	if [ -z "$program" ]; then
		log.die "$gui" "Program for '$category' is not set. Please set with 'choose set'"
	fi
}
