slint::include_modules!();

fn main() -> Result<(), slint::PlatformError> {
    let ui = AppWindow::new()?;

    // 1. Imagine this is the data you fetched dynamically from GitHub
    let fetched_from_github: Vec<String> = vec![
        "v1.0.0-alpha".to_string(),
        "v1.1.2-beta".to_string(),
        "v2.0.0-stable".to_string(),
    ];

    // 2. Convert standard Strings to Slint's SharedString
    let slint_strings: Vec<slint::SharedString> = fetched_from_github
        .into_iter()
        .map(slint::SharedString::from)
        .collect();

    // 3. Wrap the vector in a Slint ModelRc / VecModel
    let model = std::rc::Rc::new(slint::VecModel::from(slint_strings));

    // 4. Set the property on the Slint UI instance
    ui.set_github_items(model.into());

    // Optional: handle selection changes in Rust if needed
    let ui_handle = ui.as_weak();
    ui.on_selected(move |value| {
        println!("User picked: {}", value);
    });

    ui.run()
}
