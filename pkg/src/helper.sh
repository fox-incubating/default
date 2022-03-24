# shellcheck shell=bash

helper_get_cmd() {
	local isGui="$1"

	local cmd="fzf"
	if [ "$isGui" = "yes" ]; then
		# TODO: check for choose value
		if command -v rofi >&/dev/null; then
			cmd="rofi -dmenu"
		elif command -v dmenu >&/dev/null; then
			cmd="dmenu"
		fi
	fi

	REPLY="$cmd"
}

# almost duplicate of helper_get_category_filter
helper_get_category() {
	REPLY=
	local category="$1"
	local gui="$2"

	if [ -z "$category" ]; then
		helper_get_cmd "$gui"
		local cmd="$REPLY"

		if ! category="$(plumbing_list_dir "$db_dir" | $cmd)"; then
			log.die "$gui" "Did not complete previous selection properly"
		fi
	fi

	# validate
	if [ ! -d "$db_dir/$category" ]; then
		log.die "$gui" "Application category '$category' does not exist"
	fi

	REPLY="$category"
}


# almost duplicate of helper_get_category
helper_get_category_filter() {
	REPLY=
	local category="$1"
	local gui="$2"

	if [ -z "$category" ]; then
		helper_get_cmd "$gui"
		local userSelectCmd="$REPLY"

		ensure_has_dot_current() {
			while IFS= read -r dir; do
				if [ -f "$db_dir/$dir/_.current" ]; then
					echo "$dir"
				fi
			done
		}

		if ! category="$(
			plumbing_list_dir "$db_dir" \
			| ensure_has_dot_current \
			| grep "\S" \
			| $userSelectCmd
		)"; then
			log.die "$gui" "Did not complete previous selection properly"
		fi
	fi

	# validate
	if [ ! -d "$db_dir/$category" ]; then
		log.die "$gui" "Application category '$category' does not exist"
	elif [ ! -s "$db_dir/$category/_.current" ]; then
		log.die "$gui" "Application category '$category' does not have a default program associated with it"
	fi

	REPLY="$category"
}

helper_get_program() {
	REPLY=
	local category="$1"
	local program="$2"
	local gui="$3"

	if [ -z "$program" ]; then
		local userSelectCmd="fzf"
		helper_get_cmd "$gui"
		userSelectCmd="$REPLY"

		if ! program="$(
			plumbing_list_dir "$db_dir/$category" \
			| grep -v "_.current" \
			| $userSelectCmd
		)"; then
			log.die "$gui" "Did not complete previous selection properly"
		fi
	fi

	# validate variable
	if [ ! -d "$db_dir/$category/$program" ]; then
		log.die "$gui" "Application '$program' does not exist"
	fi

	REPLY="$program"
}
