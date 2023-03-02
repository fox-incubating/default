use crate::{
	traits::Choice,
	util::{is_command_installed, run_command},
};

use super::{run_info, write_git_diff_conf};

pub struct DeltaChoice {}

impl Choice for DeltaChoice {
	fn name(&self) -> String {
		"delta".to_string()
	}

	fn install(&self) {
		run_command(vec!["cargo", "install", "git-delta"]);
	}

	fn uninstall(&self) {
		run_command(vec!["cargo", "uninstall", "git-delta"]);
	}

	fn is_installed(&self) -> bool {
		is_command_installed("delta")
	}

	fn run(&self) {
		run_info()
	}

	fn switch(&self) -> Result<(), std::io::Error> {
		write_git_diff_conf("./delta.conf")
	}
}
