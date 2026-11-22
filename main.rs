use slint::Model;

mod github_fetcher;

slint::include_modules!();

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let ui = AppWindow::new()?;

    let fetched_items: Vec<String> = match github_fetcher::fetch_github_items() {
        Ok(items) if !items.is_empty() => items,
        Ok(_) => vec!["(No subsystems found)".to_string()],
        Err(err) => {
            eprintln!("Failed to load GitHub subsystems: {err}");
            vec!["(Error loading subsystems)".to_string()]
        }
    };

    let slint_strings: Vec<slint::SharedString> = fetched_items
        .into_iter()
        .map(slint::SharedString::from)
        .collect();

    let model = std::rc::Rc::new(slint::VecModel::from(slint_strings));
    ui.set_github_items(model.into());

    if let Some(first) = ui.get_github_items().row_data(0) {
        ui.set_selected_item(first);
    }

    // Weak handle lets code inside `on_item_selected` read/write UI properties safely
    let ui_weak = ui.as_weak();
    ui.on_item_selected(move |value| {
        println!("Selected subsystem: {}", value);

        if let Some(ui) = ui_weak.upgrade() {
            ui.set_selected_item(value.clone());
            // Example: run additional Rust logic using `value.as_str()`
            // analyze_subsystem(value.as_str());
        }
    });

    ui.run()?;
    Ok(())
}