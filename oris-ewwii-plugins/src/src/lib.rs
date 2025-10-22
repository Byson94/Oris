mod app_search;

use ewwii_plugin_api::{EwwiiAPI, Plugin, export_plugin, rhai};

pub struct OrisEwwiiPlugins;

impl Plugin for OrisEwwiiPlugins {
    fn init(&self, host: &dyn EwwiiAPI) {
        use crate::app_search;

        let _ = host.register_function("app_list".to_string(), Box::new(|_args| {
            rhai::Dynamic::from(app_search::app_list())
        }));

        let _ = host.register_function("fuzzy_search".to_string(), Box::new(|args| {
            if let Some(query) = args.get(0).and_then(|d| d.clone().into_string().ok()) {
                rhai::Dynamic::from(app_search::fuzzy_search(&query))
            } else {
                rhai::Dynamic::from(app_search::fuzzy_search(""))
            }
        }));

        let _ = host.register_function("get_info".to_string(), Box::new(|args| {
            if let Some(app_name) = args.get(0).and_then(|d| d.clone().into_string().ok()) {
                rhai::Dynamic::from(app_search::get_info(&app_name))
            } else {
                rhai::Dynamic::from(String::new())
            }
        }));
    }
}

export_plugin!(OrisEwwiiPlugins);

