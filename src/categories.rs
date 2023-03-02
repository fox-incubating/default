use serde::{Deserialize, Serialize};
use serde_with::serde_as;
use std::{collections::HashMap, fs, path::PathBuf};

use crate::traits::Category;

#[path = "categories/git-diff.rs"]
mod git_diff;
pub use git_diff::GitDiffCategory;

#[path = "categories/terminal-emulator.rs"]
mod terminal_emulator;
pub use terminal_emulator::TerminalEmulatorCategory;

#[serde_as]
#[derive(Serialize, Deserialize, Debug)]
struct Defaults {
	#[serde_as(as = "Vec<(_, _)>")]
	defaults: HashMap<String, String>,
}

pub struct Categories {
	pub categories: Vec<Box<dyn Category>>,
	pub defaults: Defaults,
	pub defaults_file: PathBuf,
}

impl Categories {
	pub fn new(&self) -> Self {
		let mut m = HashMap::new();
		let defaults_file = directories::ProjectDirs::from("dev", "kofler", "defaultmgr")
			.unwrap()
			.state_dir()
			.unwrap()
			.join("defaults.json");

		let content = fs::read_to_string(defaults_file).unwrap_or(String::from("{}"));
		let p: Defaults = serde_json::from_str(content.as_str()).unwrap();

		Categories {
			categories: self.get_categories(),
			defaults: Defaults { defaults: m },
			defaults_file,
		}
	}

	pub fn get_categories(&self) -> Vec<Box<dyn Category>> {
		let git_diff_category = GitDiffCategory {};
		let terminal_emulator_category = TerminalEmulatorCategory {};

		vec![
			Box::new(git_diff_category),
			Box::new(terminal_emulator_category),
		]
	}

	pub fn get_default(&self, category: &str) -> Option<&String> {
		// self.defaults.get(category)
		return Some(&"".to_string());
	}

	pub fn set_default(&self, category: &str, choice: &str) {
		// self
		// 	.defaults
		// 	.insert(String::from(category), String::from(choice));
		// self.save();
	}

	pub fn save(&self) {}
}
