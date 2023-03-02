use crate::{
	traits::Choice,
	util::{is_command_installed, run_command},
};

use super::{run_info, write_git_diff_conf};

pub struct DifftasticChoice {}

impl Choice for DifftasticChoice {
	fn name(&self) -> String {
		"difftastic".to_string()
	}

	fn install(&self) {
		run_command(vec!["cargo", "install", "difftastic"]);
	}

	fn uninstall(&self) {
		run_command(vec!["cargo", "uninstall", "difftastic"]);
	}

	fn is_installed(&self) -> bool {
		is_command_installed("difftastic")
	}

	fn run(&self) {
		run_info();
	}

	fn switch(&self) -> Result<(), std::io::Error> {
		write_git_diff_conf("./difftastic.conf")
	}
}
