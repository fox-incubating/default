# shellcheck shell=bash

choose-set() {
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
		if ! sh -e "$db_dir/$category/set-pre.sh" "$db_dir/$category" "$program"; then
			return 1
		fi
	fi

	# Source program pre
	if [ -f "$db_dir/$category/$program/set-pre.sh" ]; then
		if ! sh -e "$db_dir/$category/$program/set-pre.sh" "$db_dir/$category" "$program"; then
			return 1
		fi
	fi

	# Actually set
	printf "%s" "$program" >| "$db_dir/$category/_.current"

	# Source program post
	if [ -f "$db_dir/$category/$program/set-post.sh" ]; then
		if ! sh -e "$db_dir/$category/$program/set-post.sh" "$db_dir/$category" "$program"; then
			return 1
		fi
	fi

	# Source category post
	if [ -f "$db_dir/$category/set-post.sh" ]; then
		if ! sh -e "$db_dir/$category/set-post.sh" "$db_dir/$category" "$program"; then
			return 1
		fi
	fi

	log.info "Category '$category' defaults to '$program'"
}

