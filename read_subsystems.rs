use std::fs;
use std::path::Path;

fn load_subsystems<P: AsRef<Path>>(path: P) -> Result<Vec<String>, std::io::Error> {
    let content = fs::read_to_string(path)?;
    let subsystems: Vec<String> = content
        .lines()
        .map(str::trim)
        .filter(|line| !line.is_empty())
        .map(ToOwned::to_owned)
        .collect();
    Ok(subsystems)
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let list_path = dirs_or_scratch_path();
    let subsystems = load_subsystems(list_path)?;

    println!("Loaded {} subsystems: {:?}", subsystems.len(), subsystems);
    Ok(())
}

fn dirs_or_scratch_path() -> std::path::PathBuf {
    let home = std::env::var("HOME").unwrap_or_else(|_| ".".to_string());
    Path::new(&home).join("scratch-dir/out/subsystems.txt")
}
