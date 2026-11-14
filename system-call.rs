// Compile this using rustc and create file binary: system-call
//  must do: 
// git init
// git remote add origin https://github.com/iron-claw-972/FRC2026
use std::process::Command;

fn main() {
    // Use "sh -c" on Linux/macOS
        let output=Command::new("sh")
        .arg("-c")
        .arg("git ls-tree -d --name-only origin/main:src/main/java/frc/robot/subsystems")
        .output()
        .expect("Failed to execute command");

    // Convert the captured stdout bytes into a readable string
    let stdout = String::from_utf8_lossy(&output.stdout);
    println!("Status: {}", output.status);
    println!("Output: {}", stdout);
}
