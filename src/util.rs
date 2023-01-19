use std::process::exit;
use std::str;
use std::{env, fs, path::PathBuf, process::Command};

use serde::{Deserialize, Serialize};

pub struct Config {}

#[derive(Serialize, Deserialize)]
pub struct Choices {
	pub shell_prompt_bash: Option<String>,
}

#[derive(Serialize, Deserialize)]
pub struct Data {
	pub choices: Choices,
}

pub fn launch(category: &str, choice: String) {
	let entrypoint =
		"/storage/ur/storage_home/Docs/Programming/Repositories/default/choose/src/launcher.sh";

	let choice_file = PathBuf::from(format!("{}", env::var("HOME").unwrap()))
		.join(".dotfiles/os/*nix/user/.config/choose/choices")
		.join(category)
		.join(format!("{}.sh", choice.as_str()));

	Command::new(entrypoint)
		.arg(choice_file)
		.arg("launch")
		.spawn()
		.unwrap();
}

pub fn run(category: &str, choice: &str, action: &str) {
	let entrypoint =
		"/storage/ur/storage_home/Docs/Programming/Repositories/default/choose/src/launcher.sh";

	let choice_file = PathBuf::from(format!("{}", env::var("HOME").unwrap()))
		.join(".dotfiles/os/*nix/user/.config/choose/choices")
		.join(category)
		.join(format!("{}.sh", choice));

	let exit_status = Command::new(entrypoint)
		.arg(choice_file)
		.arg(action)
		.spawn()
		.unwrap()
		.wait()
		.unwrap();

	let code = exit_status.code().unwrap();
	exit(code);
}

pub fn get_data() -> Data {
	let path = PathBuf::from(format!("{}", env::var("HOME").unwrap()))
		.join(".dotfiles/os/*nix/user/.config/choose/data.json");
	let content = fs::read_to_string(path).unwrap();
	let data: Data = serde_json::from_str(content.as_str()).unwrap();
	data
}

pub fn save_data(data: &Data) {
	let path = PathBuf::from(format!("{}", env::var("HOME").unwrap()))
		.join(".dotfiles/os/*nix/user/.config/choose/data.json");

	let deserialized = serde_json::to_string(data).unwrap();
	fs::write(path, deserialized).unwrap();
}
