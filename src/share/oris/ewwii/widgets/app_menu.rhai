import "api::slib" as slib;

fn render_app_menu() {
    let init_app_list = slib::call_fn("app_list", []);

    let app_widget = [];

    for app in init_app_list {
        app_widget.push(
            eventbox(#{ class: "app-menu-list-item", cursor: "pointer" }, [
                label(#{ text: app, halign: "start" })
            ])
        );
    }

    box(#{ orientation: "v", space_evenly: false }, [
        eventbox(#{
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
        }, [box(#{ orientation: "v" }, app_widget)])
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