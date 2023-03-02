use crate::{
	traits::Choice,
	util::{is_command_installed, run_command},
};

use super::{run_info, write_git_diff_conf};

pub struct GitSplitDiffsChoice {}

impl Choice for GitSplitDiffsChoice {
	fn name(&self) -> String {
		"git-split-diffs".to_string()
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
		write_git_diff_conf("./git-split-diffs.conf")
	}
}
