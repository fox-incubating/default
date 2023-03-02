use std::str;
use std::{env, fs, path::PathBuf, process::Command};

use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug)]
pub struct Choices {
	pub shell_prompt_bash: Option<String>,
	pub shell_prompt_zsh: Option<String>,
	pub git_diff: Option<String>,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct Data {
	pub choices: Choices,
}

pub fn run(category: &str, choice: &str, action: &str) {
	let choose_dir = get_choose_dir();

	let choice_file = choose_dir
		.join("choices")
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
	// println!("code: {}", code);
}

pub fn get_data() -> Data {
	let path = get_choose_dir().join("data.json");

	let content = fs::read_to_string(path).unwrap();
	let data: Data = serde_json::from_str(content.as_str()).unwrap();
	data
}

pub fn save_data(data: &Data) {
	let path = get_choose_dir().join("data.json");

	let deserialized = serde_json::to_string(data).unwrap();
	fs::write(path, deserialized).unwrap();
}

pub fn get_choose_dir() -> PathBuf {
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

	dotfiles_dir.join("choose")
}

pub fn run_command(command: Vec<&str>) -> bool {
	let output = Command::new(&command[0])
		.args(&command[1..])
		.output()
		.unwrap();

	output.status.success()
}

pub fn is_command_installed(command_name: &str) -> bool {
	run_command(vec![
		"bash",
		"-c",
		format!("command -v {}", command_name).as_str(),
	 ])
}
