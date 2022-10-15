use std::process::Command;
use std::str;

use clap::{Parser,Subcommand};

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
	#[command(subcommand)]
	action: Action,

	/// Whether or not to show the GUI
	#[arg(long, default_value_t = false)]
	gui: bool
}

#[derive(Subcommand, Debug)]
enum Action {
	Launch {
		category: String,
	},
	Set {
		category: String,
		value: String
	},
	Get {
		category: String
	}
}

// EXECUTION PROVIDER
// rust "inline exec"
// shell script combo (putting together every application of a category in a single shell script to save space / times)
// shell script
// desktop file

fn run(args: &[&str]) {
	let output = Command::new("starship").args(["init", "bash", "--print-full-init"]).output().expect("Failed to execute child process");
	if output.status.success() {
		println!("{}", str::from_utf8(&output.stdout.clone()).unwrap())
	} {
		println!("{}", str::from_utf8(&output.stderr.clone()).unwrap());

	}
}

fn main() {
	let cli = Args::parse();

	match cli.action {
		Action::Launch { category } => {
			match category.as_str() {
				"application-launcher" => {

				},
				"file-manager" => {

				},
				"image-viewer" => {

				},
				"image-editor" => {

				},
				"shell-prompt-bash" => {
					let args = ["starship", "init", "bash", "--print-full-init"];
					run(args.as_slice());
				},
				"shell-prompt-zsh" => {
					let args = ["starship", "init", "zsh", "--print-full-init"];
					run(args.as_slice());
				},
				"menu-bar-text" => {
					let args = ["i3blocks"];
					run(args.as_slice());
				},
				"terminal-emulator" => {
					let args = ["kitty"];
					run(args.as_slice());
				},
				// brightness
				"brightness-increase" => {

				},
				"brightness-decrease" => {

				},
				"brightness-reset" => {

				},
				// song
				"song-previous" => {

				},
				"song-pause" => {

				},
				"song-next" => {

				},
				// volume
				"volume-lower" => {

				},
				"volume-raise" => {

				},
				"volume-mute" => {

				},
				"window-manager" => {

				}
				&_ => todo!()
			}
		},
		Action::Set { category, value } => {

		},
		Action::Get { category } => {

		}
	}
}
