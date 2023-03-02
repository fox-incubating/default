use crate::traits::Choice;

use super::{run_info, write_git_diff_conf};

pub struct ColorDiffChoice {}

impl Choice for ColorDiffChoice {
	fn name(&self) -> String {
		"colordiff".to_string()
	}

	fn install(&self) {}

	fn uninstall(&self) {}

	fn is_installed(&self) -> bool {
		false
	}

	fn run(&self) {
		run_info()
	}

	fn switch(&self) -> Result<(), std::io::Error> {
		write_git_diff_conf("./colordiff.conf")
	}
}
