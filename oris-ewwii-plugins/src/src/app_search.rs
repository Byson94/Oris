use ewwii_plugin_api::rhai::{Array, Dynamic};
use std::fs;
use std::path::Path;
use std::ffi::OsStr;

/// Return all `.desktop` apps found in standard directories.
pub fn app_list() -> Array {
    let mut result = Array::new();
    let home = std::env::var("HOME").unwrap_or_default();
    let dirs = vec![
        "/usr/share/applications".to_string(),
        "/usr/local/share/applications".to_string(),
        format!("{}/.local/share/applications", home),
    ];

    for dir in dirs {
        if let Ok(entries) = fs::read_dir(dir) {
            for entry in entries.flatten() {
                let path = entry.path();
                if path.extension().and_then(OsStr::to_str) == Some("desktop") {
                    if let Ok(contents) = fs::read_to_string(&path) {
                        for line in contents.lines() {
                            let line = line.trim();
                            if line.starts_with("Name=") {
                                if let Some(name) = line.strip_prefix("Name=") {
                                    result.push(Dynamic::from(name.to_string()));
                                }
                                break;
                            }
                        }
                    }
                }
            }
        }
    }

    result
}

/// Simple fuzzy matcher: returns array of apps matching the query, sorted by score.
pub fn fuzzy_search(query: &str) -> Array {
    let apps = app_list();
    let mut scored: Vec<(String, i32)> = vec![];

    for app in apps.iter() {
        if let Ok(name) = app.clone().into_string() {
            let score = fuzzy_score(&name, query);
            if score > 0 {
                scored.push((name, score));
            }
        }
    }

    // Sort descending by score
    scored.sort_by(|a, b| b.1.cmp(&a.1));

    // Return only names
    scored.into_iter().map(|(name, _)| name.into()).collect()
}

/// Get the raw contents of the `.desktop` file for the given app.
pub fn get_info(app_name: &str) -> String {
    let home = std::env::var("HOME").unwrap_or_default();
    let dirs = vec![
        "/usr/share/applications".to_string(),
        "/usr/local/share/applications".to_string(),
        format!("{}/.local/share/applications", home),
    ];

    for dir in dirs {
        let path = Path::new(&dir).join(format!("{}.desktop", app_name));
        if path.exists() {
            if let Ok(contents) = fs::read_to_string(path) {
                return contents;
            }
        }
    }

    String::new()
}

/// Internal fuzzy scoring: higher is better.
fn fuzzy_score(target: &str, query: &str) -> i32 {
    if query.is_empty() {
        return 0;
    }

    let mut score = 0;
    let mut last_match_index = 0;
    let target_lower = target.to_lowercase();
    let query_lower = query.to_lowercase();

    for q_char in query_lower.chars() {
        if let Some(pos) = target_lower[last_match_index..].find(q_char) {
            last_match_index += pos + 1;
            score += 1;
        } else {
            return 0;
        }
    }

    score
}

