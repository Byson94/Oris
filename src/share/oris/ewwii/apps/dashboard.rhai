import "std::env" as env;

fn get_notifications() {
    return label(#{ text: "None Yet", style: "font-style: italic;" })
}

fn show_dashboard(extra_classes) {
    let time = localsignal(#{ 
        type: "poll", 
        initial: "", 
        cmd: "date '+%H:%M'", 
        interval: "1m" 
    });

    let uptime = localsignal(#{
        type: "poll",
        cmd: `awk '{printf "Uptime: %dh %dm\n", $1/3600, ($1%3600)/60}' /proc/uptime`,
        interval: "2m",
    });

    let username = env::get_username();

	box(#{
        orientation: "v",
        space_evenly: false,
        class: `dashboard do-fade-in ${extra_classes}`
    }, [
        box(#{ class: "header" }, [
            localbind(#{
                label: uptime
            }, [
                label(#{ text: "", class: "small-font", halign: "start" }),
            ]),
            button(#{ 
                label: "Close", 
                halign: "end", 
                class: "close-btn small-font", 
                onclick: "scripts/close_with_anim dashboard do-fade-out 0.1 DASHB_ANIM_CLASS" ,
                timeout: "5s"
            })
        ]),

        box(#{ orientation: "h", space_evenly: false, vexpand: true, hexpand: true }, [
            box(#{ orientation: "v", space_evenly: false, vexpand: true, hexpand: true }, [
                box(#{ orientation: "h", space_evenly: false, vexpand: true, hexpand: true }, [
                    box(#{ class: "welcome_user", hexpand: true }, [
                        label(#{ text: `Hello, ${username}!` })
                    ]),
                    box(#{ class: "dashboard_time", hexpand: true }, [
                        box(#{ halign: "center" }, [
                            localbind(#{
                                label: time
                            }, [
                                label(#{ text: "Current Time" })
                            ])
                        ])
                    ]),
                ]),
                box(#{ 
                    orientaiton: "h", 
                    space_evenly: false, 
                    vexpand: true, 
                    hexpand: true,
                }, [
                    box(#{ orientation: "v" }, [
                        box(#{ class: "music_dashb" }, [
                            label(#{ text: "music here" })
                        ]),
                        box(#{ class: "weather" }, [
                            label(#{ text: "Weather here" })
                        ]),
                    ]),
                    box(#{ class: "todo", hexpand: true }, [
                        label(#{ text: "TODO" })
                    ])
                ]),
            ]),

            box(#{ orientation: "v", class: "notification_tray", vexpand: true, hexpand: true }, [
                label(#{ text: "Notifications", class: "bold-label", valign: "start" }),
                get_notifications(),
            ]),
        ])
	])
}

let extra_classes = if is_def_var("DASHB_ANIM_CLASS") {
    DASHB_ANIM_CLASS
} else {
    ""
};

enter([
	defwindow("dashboard", #{
        geometry: #{
            x: "175px",
            y: "15px",
            anchor: "center",
            width: "80%",
            height: "80%"
        },
        windowtype: "dialog",
	}, show_dashboard(extra_classes))
])