# shellcheck shell=bash

choose-print() {
	local category="$1"

	program="$(<"$db_dir/$category/_.current")"

	# ensure variable (we already use 'ensure_has_dot_current' in
	# helper_get_category_filter; this is another safeguard)
	if [ -z "$program" ]; then
		log.die "$gui" "Program for '$category' is not set. Please set with 'choose set'"
	fi
}
