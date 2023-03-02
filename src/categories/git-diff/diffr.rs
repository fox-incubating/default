use crate::{
	traits::Choice,
	util::{is_command_installed, run_command},
};

use super::{run_info, write_git_diff_conf};

pub struct DiffrChoice {}

impl Choice for DiffrChoice {
	fn name(&self) -> String {
		"diffr".to_string()
	}

	fn install(&self) {
		run_command(vec!["cargo", "install", "diffr"]);
	}

	fn uninstall(&self) {
		run_command(vec!["cargo", "uninstall", "diffr"]);
	}

	fn is_installed(&self) -> bool {
		is_command_installed("diffr")
	}

	fn run(&self) {
		run_info();
	}

	fn switch(&self) -> Result<(), std::io::Error> {
		write_git_diff_conf("./diffr.conf")
	}
}
