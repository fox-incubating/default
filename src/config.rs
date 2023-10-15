use std::{collections::HashMap, fs};

use anyhow::Result;
use serde::Deserialize;
use serde_yaml;

#[derive(Debug, Deserialize)]
#[serde(untagged)]
pub enum Run {
	String,
	Vec(String),
}

#[derive(Debug, Deserialize)]
pub struct Choice {
	pub run: Run,
	pub install: String,
	pub uninstall: String,
	pub check: String,
}

#[derive(Debug, Deserialize)]
pub struct Category {
	pub default: String,
	#[serde(flatten)]
	pub choices: HashMap<String, Choice>,
}

#[derive(Debug, Deserialize)]
pub struct Config {
	#[serde(flatten)]
	pub categories: HashMap<String, Category>,
}

pub fn config() -> Result<Config> {
	let yaml =
		fs::read_to_string("/home/edwin/.dotfiles/os/unix/user/.config/fox-default/config.yaml")?;
	let cfg: Config = serde_yaml::from_str(&yaml)?;

	Ok(cfg)
}
