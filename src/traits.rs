pub trait Category {
	fn name(&self) -> String;
	fn choices(&self) -> Vec<Box<dyn Choice>>;
}

pub trait Choice {
	fn name(&self) -> String;

	fn install(&self);
	fn uninstall(&self);
	fn is_installed(&self) -> bool;
	fn run(&self);
	fn switch(&self) -> Result<(), std::io::Error>;
}
