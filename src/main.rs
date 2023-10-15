use std::{fs, path::PathBuf, process::exit};

use clap::Parser;
use cli::{Action, Args};

mod cli;
mod config;
mod util;

// EXECUTION PROVIDER
// rust "inline exec"
// shell script combo (putting together every application of a category in a single shell script to save space / times)
// shell script
// desktop file

fn main() {
	let cli = Args::parse();
	let mut data = util::get_data();
	// let cfg = config::config().unwrap();

	match cli.action {
		Action::Launch { category } => {
			let chosen = util::get_default_choice(&category);
			util::run(&category, chosen.as_str(), "launch");
		}
		Action::Set { category, choice } => {
			util::assert_category(&category);
			util::assert_choice(&category, &choice);
			data.categories.categories.insert(category, choice);
			util::save_data(&data);
		}
		Action::Get { category } => {
			util::assert_category(&category);
			let key = data.categories.categories.get(&category).unwrap();
			println!("{}", key);
		}
		Action::List { category } => {
			let list = |dir: PathBuf| {
				for entry in fs::read_dir(&dir)
					.expect(format!("Directory does not exist: {}", dir.to_str().unwrap()).as_str())
				{
					let path = entry.unwrap().path();
					let basename = path.file_name().unwrap();

					let s = String::from(basename.to_str().unwrap());
					let s = s.strip_suffix(".sh").unwrap_or(&s);
					println!("{}", s);
				}
			};

			let choose_dir = util::get_main_dir();
			if let Some(category) = category {
				let dir = choose_dir.join("categories").join(category);
				list(dir);
			} else {
				let dir = choose_dir.join("categories");
				list(dir);
			}
		}
		Action::Install { category, choice } => {
			util::run(&category, &choice, "install");
		}
		Action::Uninstall { category, choice } => {
			util::run(&category, &choice, "uninstall");
		}
		Action::Test { category, choice } => {
			util::run(&category, &choice, "test");
		}
	}
}
