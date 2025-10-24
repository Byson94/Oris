import "api::slib" as slib;

fn render_app_menu() {
    let init_app_list = slib::call_fn("app_list", []);

    let app_widget = [];
    let index = 0;

    for app in init_app_list {
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
                    input(#{ onchange: "" })
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
                    onaccept: "notify-send {}",
                    selection_model: "single",
                    class: "app-menu-list-item-flow",
                    focusable: true,
                    default_select: 0
                }, app_widget)
            ])
        ])
    ])
}

enter([
    defwindow("application_menu", #{
        geometry: #{
            anchor: "top center",
            width: "270px",
            height: "60px"
        },
        focusable: "exclusive",
    }, render_app_menu()),
])