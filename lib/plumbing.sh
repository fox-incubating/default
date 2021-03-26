# shellcheck shell=bash

plumbing_list_dir() {
	find "$1" -maxdepth 1 -mindepth 1 -printf "%f\n" -type d
}
