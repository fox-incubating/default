use std::collections::HashMap;
use std::process::exit;
use std::str;
use std::{env, fs, path::PathBuf, process::Command};

use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct Categories {
	#[serde(flatten)]
	pub categories: HashMap<String, String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Data {
	pub categories: Categories,
}

pub fn run(category: &str, choice: &str, action: &str) {
	let choose_dir = get_main_dir();

	let choice_file = choose_dir
		.join("categories")
		.join(category)
		.join(format!("{}.sh", choice));

	let exit_status = Command::new(choose_dir.join("launcher.sh"))
		.arg(choice_file)
		.arg(action)
		.spawn()
		.unwrap()
		.wait()
		.unwrap();

	let code = exit_status.code().unwrap();
	exit(code);
}

pub fn assert_category(category: &str) -> bool {
	let dir = get_main_dir().join("categories").join(category);
	if !dir.exists() {
		eprintln!("Category does not exist: {}", category);
		exit(1);
	}
	true
}

pub fn assert_choice(category: &str, choice: &str) -> bool {
	let dir = get_main_dir()
		.join("categories")
		.join(category)
		.join(format!("{}.sh", choice));
	if !dir.exists() {
		eprintln!("Choice does not exist: {}", choice);
		exit(1);
	}
	true
}

pub fn get_default_choice(category: &str) -> String {
	let data = get_data();
	if data.categories.categories.get(category.clone()).is_some() {
		return data.categories.categories.get(category).unwrap().clone();
	} else {
		eprintln!("Could not find category: {}", category);
		exit(1);
	}
}

pub fn get_data() -> Data {
	let path = get_main_dir().join("data.json");

	let content = fs::read_to_string(path).unwrap();
	let data: Data = serde_json::from_str(content.as_str()).unwrap();
	data
}

pub fn save_data(data: &Data) {
	let path = get_main_dir().join("data.json");

	let deserialized = serde_json::to_string(data).unwrap();
	fs::write(path, deserialized).unwrap();
}

pub fn get_main_dir() -> PathBuf {
	let dotfiles_dir = match env::var("XDG_CONFIG_HOME") {
		Ok(val) => {
			let p = PathBuf::from(val);
			if p.is_absolute() {
				p
			} else {
				PathBuf::from(dirs::home_dir().unwrap()).join(".config")
			}
		}
		Err(..) => PathBuf::from(dirs::home_dir().unwrap()).join(".config"),
	};

	dotfiles_dir.join("fox-default")
}
