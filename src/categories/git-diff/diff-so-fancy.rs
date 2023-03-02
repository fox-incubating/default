use std::path::Path;

use crate::{traits::Choice, util::run_command};

use super::{run_info, write_git_diff_conf};

pub struct DiffSoFancyChoice {
	dir: String,
	base_dirs: directories::BaseDirs,
}

impl DiffSoFancyChoice {
	pub fn new() -> Self {
		let base_dirs = directories::BaseDirs::new().expect("Failed to construct base_dirs");

		Self {
			base_dirs: base_dirs.clone(),
			dir: base_dirs.home_dir().to_str().unwrap().to_string(),
		}
	}
}

impl Choice for DiffSoFancyChoice {
	fn name(&self) -> String {
		"diff-so-fancy".to_string()
	}

	fn install(&self) {
		let dir = &self.dir;
		let home_dir = &self.base_dirs.home_dir().to_str().unwrap();

		run_command(vec![
			"git",
			"clone",
			"https://github.com/so-fancy/diff-so-fancy",
			dir,
		]);
		run_command(vec![
			"ln",
			"-sf",
			format!("{dir}/diff-so-fancy").as_str(),
			format!("{home_dir}/dotfiles/.data/bin/diff-so-fancy",).as_str(),
		]);
	}

	fn uninstall(&self) {
		let dir = &self.dir;
		let home_dir = &self.base_dirs.home_dir().to_str().unwrap();

		run_command(vec!["rm", "-rf", dir]);
		run_command(vec![
			"unlink",
			format!("{home_dir}/.dotfiles/.data/.bin/diff-so-fancy").as_str(),
		]);
	}

	fn is_installed(&self) -> bool {
		let dir = &self.dir;

		Path::new(dir).is_dir()
	}

	fn run(&self) {
		run_info()
	}

	fn switch(&self) -> Result<(), std::io::Error> {
		write_git_diff_conf("./diff-so-fancy.conf")
	}
}
