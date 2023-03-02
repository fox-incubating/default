use std::{fs, path::PathBuf};

use crate::traits::{Category, Choice};

#[path = "terminal-emulator/alacritty.rs"]
mod alacritty;
use alacritty::AlacrittyChoice;

#[path = "terminal-emulator/kitty.rs"]
mod kitty;
use kitty::KittyChoice;

pub struct TerminalEmulatorCategory {}

impl Category for TerminalEmulatorCategory {
	fn name(&self) -> String {
		"terminal-emulator".to_string()
	}
	fn choices(&self) -> Vec<Box<dyn Choice>> {
		let alacritty_choice = AlacrittyChoice {};
		let diff_so_fancy_choice = KittyChoice {};

		vec![Box::new(alacritty_choice), Box::new(diff_so_fancy_choice)]
	}
}

pub fn save_default_terminal_desktop_file(
	name_pretty: &str,
	name: &str,
) -> Result<(), std::io::Error> {
	let file = PathBuf::from(
		"/home/edwin/.dotfiles/.home/xdg_data_dir/applications/choose-terminal-emulator.desktop",
	);

	fs::create_dir_all(file.parent().unwrap())?;
	fs::write(
		file,
		format!(
			"[Desktop Entry]
Type = Application
Name = :TERM: {name_pretty}
GenericName=Terminal emulator
Comment = Use a terminal emulator
TryExec = {name}
Exec = {name}
Icon = choose-fox
Categories = System;TerminalEmulator;\n"
		)
		.as_str(),
	)?;

	Ok(())
}
