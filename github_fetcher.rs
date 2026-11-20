// Compile this using rustc and create file binary: system-call
//  must do: 
// git init
// git remote add origin https://github.com/iron-claw-972/FRC2026
use std::process::Command;
use std::error::Error;

pub fn fetch_github_items() -> Result<Vec<String>, Box<dyn Error>> {
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
    
    let items: Vec<&str> = stdout.split_whitespace().collect();
    
//    println!("{:?}", items); 
//    println!("Status: {}", output.status);

    if !stderr.is_empty() {
        eprintln!("Stderr: {}", stderr);
    }
    OK(items)
}
