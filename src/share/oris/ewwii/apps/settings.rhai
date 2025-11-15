import "std::command" as cmd;

fn horizontal_rule_dark() {
    box(#{
        class: "horizontal_rule_dark",
        hexpand: true 
    }, [])
}

fn horizontal_rule() {
    box(#{
        class: "horizontal_rule",
        hexpand: true 
    }, [])
}

fn page_1() {
    box(#{
        orientation: "v",
        class: "page1",
        spacing: 10,
        space_evenly: false
    }, [
        label(#{ text: "Color Settings", halign: "start", class: "bold-label-heading" }),
        horizontal_rule_dark(),
        label(#{ text: "Gtk Color", halign: "start", class: "bold-label" }),
        box(#{ orientation: "v", space_evenly: false, spacing: 5 }, [
            label(#{ text: "Preferred Color", halign: "start", class: "small-label" }),
            box(#{}, [
                button(#{ 
                    label: "Dark", onclick: "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'",
                    class: "theme-button"
                }),
                button(#{ 
                    label: "Light", onclick: "gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'",
                    class: "theme-button"
                })
            ]),
        ])
    ])
}

fn page_2() {
    box(#{
        orientation: "v",
        class: "page2",
        spacing: 10,
        space_evenly: false
    }, [
        label(#{ text: "Appearance Settings", halign: "start", class: "bold-label-heading" }),
        horizontal_rule_dark(),

        // Wallpaper section
        label(#{ text: "Wallpaper", halign: "start", class: "bold-label" }),
        box(#{ 
            orientation: "v", 
            class: "current_wallpaper",
            space_evenly: false,
            spacing: 5
        }, [
            label(#{ text: "Selected Wallpaper", halign: "start", class: "small-label" }),
            input(#{ 
                value: cmd::run_and_read("swww query | awk -F'image: ' '/image:/ {print $2}'").split()[0],
                active: false,
                class: "input-area"
            }),
        ]),
        box(#{ 
            orientation: "v", 
            class: "new_wallpaper",
            space_evenly: false,
            spacing: 5
        }, [
            label(#{ text: "New Wallpaper", halign: "start", class: "small-label" }),
            button(#{ 
                label: "Choose new wallpaper", 
                onclick: "scripts/select_wallpaper", 
                timeout: "1h",
                class: "choose_wallpaper_btn"
            })
        ]),
        // Wallpaper section over
        horizontal_rule(),

        // Bar Styling section
        label(#{ text: "Bar Styling", halign: "start", class: "bold-label" }),
        box(#{
            orientation: "v",
            space_evenly: false,
            spacing: 5
        }, [
            label(#{ text: "Margin", halign: "start", class: "small-label" }),
            box(#{ orientation: "h" }, [
                button(#{ label: "Sticky", class: "theme-button" }),
                button(#{ label: "Floating", class: "theme-button" }),
            ])
        ]),
        // Bar Styling section over
    ])
}

fn page_3() {
    box(#{
        orientation: "v",
        class: "page3",
        spacing: 10,
        space_evenly: false
    }, [
        label(#{ text: "Function Settings", halign: "start", class: "bold-label-heading" }),
        horizontal_rule_dark(),
        box(#{ orientation: "v", class: "battery_settings" }, [
            label(#{ text: "Battery", halign: "start", class: "bold-label" }),
        ]),
    ])
}

fn show_settings(page, anim_class) {
	box(#{
        orientation: "v",
        class: `settings ${anim_class}`
    }, [
        box(#{
            orientation: "h",
            space_evenly: false
        }, [
            box(#{
                class: "sidebar",
                orientation: "v",
                space_evenly: false,
            }, [
                button(#{ label: "Color", onclick: "ewwii update -pi SHOW_SETTING_PAGE=0 -c ." }),
                button(#{ label: "Appearance", onclick: "ewwii update -pi SHOW_SETTING_PAGE=1 -c ." }),
                button(#{ label: "Functions", onclick: "ewwii update -pi SHOW_SETTING_PAGE=2 -c ." }),
                button(#{ 
                    label: "Close", 
                    valign: "end", 
                    onclick: "scripts/close_with_anim settings do-fade-out 0.1 SETTINGS_ANIM_CLASS", 
                    timeout: "5s",
                    class: "close_btn"  
                })
            ]),
            stack(#{
                selected: page,
                class: "content_space",
                hexpand: true
            }, [                
                page_1(),
                page_2(),
                page_3(),
            ]),
        ]),
	])
}

let page = if is_def_var("SHOW_SETTING_PAGE") {
    SHOW_SETTING_PAGE
} else {
    0
};

let anim_class = if is_def_var("SETTINGS_ANIM_CLASS") {
    SETTINGS_ANIM_CLASS
} else {
    ""
};

enter([
	defwindow("settings", #{
        geometry: #{
            x: "175px",
            y: "15px",
            anchor: "center",
            width: "80%",
            height: "80%"
        },
        windowtype: "dialog",
        focusable: "ondemand"
	}, show_settings(page, anim_class))
])