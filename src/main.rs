use std::{fs, path::PathBuf};

use clap::Parser;
use cli::{Action, Args};

mod cli;

mod util;

// EXECUTION PROVIDER
// rust "inline exec"
// shell script combo (putting together every application of a category in a single shell script to save space / times)
// shell script
// desktop file

fn main() {
	let cli = Args::parse();
	let mut data = util::get_data();

	match cli.action {
		Action::Launch { category } => {
			match category.as_str() {
				"application-launcher" => {}
				"file-manager" => {}
				"image-viewer" => {}
				"image-editor" => {}
				"shell-prompt-bash" => {
					let choice = data
						.choices
						.shell_prompt_bash
						.unwrap_or(String::from("starship"));
					util::run("shell-prompt-bash", choice.as_str(), "launch");
				}
				"shell-prompt-zsh" => {
					let _args = vec!["starship", "init", "zsh", "--print-full-init"];
				}
				"menu-bar-text" => {
					let _args = vec!["i3blocks"];
				}
				"terminal-emulator" => {
					let _args = vec!["kitty"];
				}
				// brightness
				"brightness-increase" => {}
				"brightness-decrease" => {}
				"brightness-reset" => {}
				// song
				"song-previous" => {}
				"song-pause" => {}
				"song-next" => {}
				// volume
				"volume-lower" => {}
				"volume-raise" => {}
				"volume-mute" => {}
				"window-manager" => {}
				&_ => todo!(),
			}
		}
		Action::Set { category, choice } => {
			match category.as_str() {
				"shell-prompt-bash" => data.choices.shell_prompt_bash = Some(String::from(choice)),
				_ => {}
			};

			util::save_data(&data);
		}
		Action::Get { category: _ } => {}
		Action::List { category } => {
			let list = |dir: PathBuf| {
				for entry in fs::read_dir(&dir)
					.expect(format!("Directory does not exist: {}", dir.to_str().unwrap()).as_str())
				{
					let path = entry.unwrap().path();
					let basename = path.file_name().unwrap();

					println!("{}", basename.to_str().unwrap());
				}
			};

			let choose_dir = util::get_choose_dir();
			if let Some(category) = category {
				let dir = choose_dir.join("choices").join(category);
				list(dir);
			} else {
				let dir = choose_dir.join("choices");
				list(dir);
			}
		}
		Action::Install { category, choice } => {
			util::run(category.as_str(), choice.as_str(), "install")
		}
		Action::Uninstall { category, choice } => {
			util::run(category.as_str(), choice.as_str(), "uninstall")
		}
		Action::Test { category, choice } => util::run(category.as_str(), choice.as_str(), "test"),
	}
}
