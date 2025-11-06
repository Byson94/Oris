import "std::command" as cmd;

fn page_1() {
    box(#{
        orientation: "v",
        class: "page1",
        spacing: 10,
        space_evenly: false
    }, [
        label(#{ text: "Color Settings", halign: "start", class: "bold-label-heading" }),
        box(#{ orientation: "v", class: "preferred_color" }, [
            label(#{ text: "Preferred Color", halign: "start", class: "bold-label" }),
            box(#{}, [
                button(#{ label: "Dark", onclick: "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'" }),
                button(#{ label: "Light", onclick: "gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'" })
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
        label(#{ text: "Wallpaper Settings", halign: "start", class: "bold-label-heading" }),
        box(#{ orientation: "v", class: "current_wallpaper" }, [
            label(#{ text: "Selected Wallpaper", halign: "start", class: "bold-label" }),
            input(#{ 
                value: cmd::run_and_read("swww query | awk -F'image: ' '/image:/ {print $2}'"),
                focusable: false,
            }),
        ]),
        box(#{ orientation: "v", class: "new_wallpaper" }, [
            label(#{ text: "New Wallpaper", halign: "start", class: "bold-label" }),
            button(#{ 
                label: "Choose new wallpaper", 
                onclick: "scripts/select_wallpaper", 
                timeout: "1h",
                class: "choose_wallpaper_btn"
            })
        ])
    ])
}

fn show_settings(page, anim_class) {
	box(#{
        orientation: "v",
        class: `settings do-fade-in ${anim_class}`
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
                button(#{ label: "Wallpaper", onclick: "ewwii update -pi SHOW_SETTING_PAGE=1 -c ." }),
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
	}, show_settings(page, anim_class))
])