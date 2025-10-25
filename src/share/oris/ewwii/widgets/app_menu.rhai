import "api::slib" as slib;
import "std::command" as cmd;

fn render_app_menu(app_list) {
    let app_widget = [];
    let index = 0;

    for app in app_list {
        app_widget.push(
            eventbox(#{ class: "app-menu-list-item", cursor: "pointer", widget_name: app }, [
                label(#{ 
                    text: app, 
                    halign: "start", 
                    focusable: true,
                })
            ])
        );
        index = index + 1
    }

    eventbox(#{ 
        orientation: "v", 
        // 9 == Escape
        onkeypress: "if [ {} == '9' ]; then scripts/app_menu_popup; fi", 
    }, [
        box(#{ orientation: "v", space_evenly: false }, [
            box(#{
                // 9 = Escape
                onkeypress: "if [ {} == '9' ]; then scripts/app_menu_popup; fi",
                class: "app-menu-searchbar"
            }, [
                box(#{ orientation: "h", space_evenly: false }, [
                    label(#{ text: "Search: " }),
                    input(#{ 
                        onchange: "scripts/update_applist {}" 
                    })
                ])
            ]),
            scroll(#{
                orientation: "v",
                class: "app-menu-content",
                height: 300,
                vscroll: true,
                hscroll: false
            }, [                    
                flowbox(#{
                    onaccept: "notify-send '{}'",
                    selection_model: "browse",
                    class: "app-menu-list-item-flow",
                    focusable: true,
                    default_select: 0
                }, app_widget)
            ])
        ])
    ])
}

let app_list;

if is_def_var("new_app_list") {
    if new_app_list == "" {
        app_list = slib::call_fn("app_list", []);
    } else {
        app_list = slib::call_fn("fuzzy_search", [new_app_list]);
    }
} else {
    app_list = slib::call_fn("app_list", []);
}

enter([
    defwindow("application_menu", #{
        geometry: #{
            anchor: "top center",
            width: "270px",
            height: "60px"
        },
        focusable: "exclusive",
    }, render_app_menu(app_list)),
])