use std::error::Error;
use std::process::Command;

pub fn fetch_github_items() -> Result<Vec<String>, Box<dyn Error>> {
    // Ensure origin/main is fetched if running in a freshly initialized repo:
    // git init
    // git remote add origin https://github.com/iron-claw-972/FRC2026
    // git fetch origin main
    let output = Command::new("git")
        .args([
            "ls-tree",
            "-d",
            "--name-only",
            "origin/main:src/main/java/frc/robot/subsystems",
        ])
        .output()?;

    let stderr = String::from_utf8_lossy(&output.stderr);
    if !stderr.trim().is_empty() {
        eprintln!("Stderr: {}", stderr.trim());
    }

    if !output.status.success() {
        return Err(format!(
            "git ls-tree exited with status {}: {}",
            output.status,
            stderr.trim()
        )
        .into());
    }

    let stdout = String::from_utf8_lossy(&output.stdout);
    let items: Vec<String> = stdout
        .lines()
        .map(str::trim)
        .filter(|s| !s.is_empty())
        .map(str::to_string)
        .collect();

    Ok(items)
}
