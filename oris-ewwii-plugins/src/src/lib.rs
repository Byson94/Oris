mod app_search;

use ewwii_plugin_api::{EwwiiAPI, Plugin, export_plugin, rhai};

pub struct OrisEwwiiPlugins;

impl Plugin for OrisEwwiiPlugins {
    fn init(&self, host: &dyn EwwiiAPI) {
        use crate::app_search::app_search;

        host.log("Checkpoint 1");
    
        host.register_function("get_place".to_string(), Box::new(|args| {
            println!("ARGS: {:#?}", args);

            rhai::Dynamic::from("yo")
        }));

        host.log("Checkpoint 2");
    }
}

export_plugin!(OrisEwwiiPlugins);
