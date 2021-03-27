# shellcheck shell=bash

plumbing_list_dir() {
	find "$1" -maxdepth 1 -mindepth 1 -type d -printf "%f\n"
}


plumbing_list_file() {
	find "$1" -maxdepth 1 -mindepth 1 -type f -printf "%f\n"
}
