// Compile this using rustc and create file binary: system-call
//  must do: 
// git init
// git remote add origin https://github.com/iron-claw-972/FRC2026
use std::process::Command;

fn main() {
    let output = Command::new("git")
        .args([
            "ls-tree",
            "-d",
            "--name-only",
            "origin/main:src/main/java/frc/robot/subsystems",
        ])
        .output()
        .expect("Failed to execute command");

    let stdout = String::from_utf8_lossy(&output.stdout);
    let stderr = String::from_utf8_lossy(&output.stderr);

    println!("Status: {}", output.status);
    println!("Output: {}", stdout);
    if !stderr.is_empty() {
        eprintln!("Stderr: {}", stderr);
    }
}
