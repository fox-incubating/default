use crate::{
	categories::git_diff::run_info,
	traits::Choice,
	util::{is_command_installed, run_command},
};

use super::save_default_terminal_desktop_file;

pub struct KittyChoice {}

impl Choice for KittyChoice {
	fn name(&self) -> String {
		"kitty".to_string()
	}

	fn install(&self) {
		run_command(vec!["npm", "install", "-g", "git-split-diffs"]);
	}

	fn uninstall(&self) {
		run_command(vec!["npm", "uninstall", "-g", "git-split-diffs"]);
	}

	fn is_installed(&self) -> bool {
		is_command_installed("git-split-diffs")
	}

	fn run(&self) {
		run_info();
	}

	fn switch(&self) -> Result<(), std::io::Error> {
		save_default_terminal_desktop_file("Kitty", "kitty")
	}
}
