use std::fs;

use crate::traits::{Category, Choice};

#[path = "git-diff/colordiff.rs"]
mod colordiff;
use colordiff::ColorDiffChoice;

#[path = "git-diff/delta.rs"]
mod delta;
use delta::DeltaChoice;

#[path = "git-diff/diff-so-fancy.rs"]
mod diff_so_fancy;
use diff_so_fancy::DiffSoFancyChoice;

#[path = "git-diff/diffr.rs"]
mod diffr;
use diffr::DiffrChoice;

#[path = "git-diff/difftastic.rs"]
mod difftastic;
use difftastic::DifftasticChoice;

#[path = "git-diff/git-split-diffs.rs"]
mod git_split_diffs;
use git_split_diffs::GitSplitDiffsChoice;

pub struct GitDiffCategory {}

impl Category for GitDiffCategory {
	fn name(&self) -> String {
		"git-diff".to_string()
	}

	fn choices(&self) -> Vec<Box<dyn Choice>> {
		let delta_choice = DeltaChoice {};
		let diff_so_fancy_choice = DiffSoFancyChoice::new();
		let color_diff_choice = ColorDiffChoice {};
		let diffr_choice = DiffrChoice {};
		let difftastic_choice = DifftasticChoice {};
		let git_split_diffs = GitSplitDiffsChoice {};

		vec![
			Box::new(delta_choice),
			Box::new(diff_so_fancy_choice),
			Box::new(color_diff_choice),
			Box::new(diffr_choice),
			Box::new(difftastic_choice),
			Box::new(git_split_diffs),
		]
	}
}

pub fn run_info() {
	println!("Do not run this manually; it will automatically when invoking 'git diff'")
}

pub fn write_git_diff_conf(path: &str) -> Result<(), std::io::Error> {
	let file = "/home/edwin/.dotfiles/.home/xdg_config_dir/git/include/diff";
	fs::create_dir_all(file)?;
	fs::write(
		file,
		format!(
			"[include]
path = {}\n",
			path
		),
	)?;

	Ok(())
}
