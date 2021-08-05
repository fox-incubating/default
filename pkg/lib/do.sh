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

	# -------------------------- set ------------------------- #
	# Source category pre
	if [ -f "$dbDir/$category/set-pre.sh" ]; then
		sh "$dbDir/$category/set-pre.sh" "$dbDir/$category" "$program"
	fi

	# Source program pre
	if [ -f "$dbDir/$category/$program/set-pre.sh" ]; then
		sh "$dbDir/$category/$program/set-pre.sh" "$dbDir/$category" "$program"
	fi

	# Actually set
	printf "%s" "$program" >| "$dbDir/$category/_.current"

	# Source program post
	if [ -f "$dbDir/$category/$program/set-post.sh" ]; then
		sh "$dbDir/$category/$program/set-post.sh" "$dbDir/$category" "$program"
	fi

	# Source category post
	if [ -f "$dbDir/$category/set-post.sh" ]; then
		sh "$dbDir/$category/set-post.sh" "$dbDir/$category" "$program"
	fi

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
	if [ -f "$dbDir/$category/launch-pre.sh" ]; then
		sh "$dbDir/$category/launch-pre.sh" "$dbDir/$category" "$program"
	fi

	# Source program pre
	if [ -f "$dbDir/$category/$program/launch-pre.sh" ]; then
		sh "$dbDir/$category/$program/launch-pre.sh" "$dbDir/$category" "$program"
	fi

	# Source launch if it exists. If otherwise, infer
	# the launch command from the program name
	if [ -f "$dbDir/$category/$program/launch.sh" ]; then
		if ! sh "$dbDir/$category/$program/launch.sh" "$dbDir/$category" "$program"; then
			log.die "$gui" "Source failed"
		fi
	else
		log.die "$gui" "launch.sh for program '$program' does not exist"
	fi

	# Source program post
	if [ -f "$dbDir/$category/$program/launch-post.sh" ]; then
		sh "$dbDir/$category/$program/launch-post.sh" "$dbDir/$category" "$program"
	fi

	# Source category post
	if [ -f "$dbDir/$category/launch-post.sh" ]; then
		sh "$dbDir/$category/launch-post.sh" "$dbDir/$category" "$program"
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
