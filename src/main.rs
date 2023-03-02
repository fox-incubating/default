use clap::Parser;
use cli::{Action, Args};

mod categories;
mod cli;
mod traits;
mod util;

fn main() {
	let cli = Args::parse();
	let mut data = util::get_data();

	let categoriesObj = categories::Categories {};
	let categories = categoriesObj.get_categories();

	match cli.action {
		Action::Launch { category } => {
			// for c in categories {
			// 	if c.name() == category.as_str() {
			// 		c.choices();
			// 	}
			// }

			match category.as_str() {
				"application-launcher" => {}
				"file-manager" => {}
				"image-viewer" => {}
				"image-editor" => {}
				"git-diff" => {
					panic!("No launch applicable");
				}
				"shell-prompt-bash" => {
					let choice = data
						.choices
						.shell_prompt_bash
						.unwrap_or(String::from("starship"));
					util::run("shell-prompt-bash", choice.as_str(), "launch");
				}
				"shell-prompt-zsh" => {
					let choice = data
						.choices
						.shell_prompt_zsh
						.unwrap_or(String::from("starship"));
					util::run("shell-prompt-zsh", choice.as_str(), "launch");
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
			util::run(category.as_str(), choice.as_str(), "switch");

			match category.as_str() {
				"shell-prompt-bash" => data.choices.shell_prompt_bash = Some(String::from(choice)),
				"shell-prompt-zsh" => data.choices.shell_prompt_zsh = Some(String::from(choice)),
				"git-diff" => data.choices.git_diff = Some(String::from(choice)),
				_ => {}
			};

			util::save_data(&data);
		}
		Action::Get { category } => for category in categories {},
		Action::List { category } => {
			if let Some(category_name) = category {
				if let Some(n) = categories
					.iter()
					.position(|item| item.name() == category_name)
				{
					let v = &categories[n];
					for choice in v.choices() {
						println!("{}", choice.name());
					}
				} else {
					eprintln!("Failed to find category with name");
				}
			} else {
				for category in categories {
					println!("{}", category.name());
				}
			}
			// let list = |dir: PathBuf| {
			// 	for entry in fs::read_dir(&dir)
			// 		.expect(format!("Directory does not exist: {}", dir.to_str().unwrap()).as_str())
			// 	{
			// 		let path = entry.unwrap().path();
			// 		let basename = path.file_name().unwrap();

			// 		println!("{}", basename.to_str().unwrap());
			// 	}
			// };

			// let choose_dir = util::get_choose_dir();
			// if let Some(category) = category {
			// 	let dir = choose_dir.join("choices").join(category);
			// 	list(dir);
			// } else {
			// 	let dir = choose_dir.join("choices");
			// 	list(dir);
			// }
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
