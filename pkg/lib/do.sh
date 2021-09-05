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
	if [ -f "$db_dir/$category/set-pre.sh" ]; then
		if ! sh "$db_dir/$category/set-pre.sh" "$db_dir/$category" "$program"; then
			return 1
		fi
	fi

	# Source program pre
	if [ -f "$db_dir/$category/$program/set-pre.sh" ]; then
		if ! sh "$db_dir/$category/$program/set-pre.sh" "$db_dir/$category" "$program"; then
			return 1
		fi
	fi

	# Actually set
	printf "%s" "$program" >| "$db_dir/$category/_.current"

	# Source program post
	if [ -f "$db_dir/$category/$program/set-post.sh" ]; then
		if ! sh "$db_dir/$category/$program/set-post.sh" "$db_dir/$category" "$program"; then
			return 1
		fi
	fi

	# Source category post
	if [ -f "$db_dir/$category/set-post.sh" ]; then
		if ! sh "$db_dir/$category/set-post.sh" "$db_dir/$category" "$program"; then
			return 1
		fi
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
	if [ ! -f "$db_dir/$category/_.current" ]; then
		log.die "$gui" "Program for '$category' is not set. Please set with 'choose set'"
	fi

	program="$(<"$db_dir/$category/_.current")"

	# ensure variable (we already use 'ensure_has_dot_current' in
	# helper_get_category_filter; this is another safeguard)
	if [ -z "$program" ]; then
		log.die "$gui" "Program for '$category' is not set. Please set with 'choose set'"
	fi

	# ------------------------ launch ------------------------ #
	# Source category pre
	if [ -f "$db_dir/$category/launch-pre.sh" ]; then
		if ! sh "$db_dir/$category/launch-pre.sh" "$db_dir/$category" "$program"; then
			return 1
		fi
	fi

	# Source program pre
	if [ -f "$db_dir/$category/$program/launch-pre.sh" ]; then
		if ! sh "$db_dir/$category/$program/launch-pre.sh" "$db_dir/$category" "$program"; then
			return 1
		fi
	fi

	# Source launch if it exists. If otherwise, infer
	# the launch command from the program name
	if [ -f "$db_dir/$category/$program/launch.sh" ]; then
		if ! sh "$db_dir/$category/$program/launch.sh" "$db_dir/$category" "$program"; then
			log.die "$gui" "Source failed" # TODO: fix error message
		fi
	else
		log.die "$gui" "launch.sh for program '$program' does not exist"
	fi

	# Source program post
	if [ -f "$db_dir/$category/$program/launch-post.sh" ]; then
		if ! sh "$db_dir/$category/$program/launch-post.sh" "$db_dir/$category" "$program"; then
			return 1
		fi
	fi

	# Source category post
	if [ -f "$db_dir/$category/launch-post.sh" ]; then
		if ! sh "$db_dir/$category/launch-post.sh" "$db_dir/$category" "$program"; then
			return 1
		fi
	fi
}

do_print() {
	local category="$1"

	program="$(<"$db_dir/$category/_.current")"

	# ensure variable (we already use 'ensure_has_dot_current' in
	# helper_get_category_filter; this is another safeguard)
	if [ -z "$program" ]; then
		log.die "$gui" "Program for '$category' is not set. Please set with 'choose set'"
	fi
}
