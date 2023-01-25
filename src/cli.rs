use std::str;

use clap::{Parser, Subcommand};

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
pub struct Args {
	#[command(subcommand)]
	pub action: Action,

	/// Whether or not to show the GUI
	#[arg(long, default_value_t = false)]
	pub gui: bool,
}

#[derive(Subcommand, Debug)]
pub enum Action {
	Launch { category: String },
	Set { category: String, choice: String },
	Get { category: String },
	List { category: Option<String> },
	Install { category: String, choice: String },
	Uninstall { category: String, choice: String },
	Test { category: String, choice: String },
}
