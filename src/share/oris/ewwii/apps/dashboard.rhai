import "std::env" as env;
import "std::command" as cmd;

fn show_dashboard(weather, music, is_playing, extra_classes) {
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

    let play_btn_label = if !(is_playing == "true") { "󰐊" } else { "" };

    let weather_json = if weather != "{}" {
        parse_json(weather)
    } else {
        #{
            weather: "Loading...",
            temperature: "0.0",
            message: "Hopefully its a good day!"
        }
    };

	box(#{
        orientation: "v",
        space_evenly: false,
        class: `dashboard ${extra_classes}`
    }, [
        // menu bar
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

        // content area
        box(#{ orientation: "h", space_evenly: false, vexpand: true, hexpand: true }, [
            box(#{ orientation: "v", space_evenly: false, hexpand: true }, [
                // top side widgets
                box(#{ orientation: "h", space_evenly: false, hexpand: true }, [
                    // greeter
                    box(#{ class: "welcome_user", hexpand: true }, [
                        label(#{ text: `Hello, ${username}!` })
                    ]),
                    // time widget
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
                // bottom side widgets
                box(#{ 
                    orientaiton: "h", 
                    space_evenly: false, 
                    vexpand: true, 
                    hexpand: true,
                }, [
                    box(#{ orientation: "v", space_evenly: true }, [    
                        // music area
                        box(#{ class: "music_dashb", orientation: "v" }, [
                            // title
                            label(#{ text: ": " + music, class: "music-title" }),
                
                            box(#{ 
                                space_evenly: false, 
                                spacing: 20, 
                                halign: "center",
                                class: "music-controls"
                            }, [
                                // prev button
                                button(#{ onclick: "mpc prev", label: "󰒮" }),

                                // Play button
                                button(#{
                                    onclick: "mpc toggle",
                                    label: play_btn_label, // can be both play/pause button
                                }),

                                // next button
                                button(#{ onclick: "mpc next", label: "󰒭" }),
                            ])
                        ]),
                        // weather
                        box(#{ 
                            class: "weather", 
                            orientation: "v", 
                        }, [
                            box(#{ 
                                orientation: "v", 
                                valign: "center", 
                                space_evenly: false,
                            }, [
                                label(#{ 
                                    text: `󰖐  ${weather_json["weather"]} |   ${weather_json["temperature"]}`, 
                                    class: "weather-heading" 
                                }),
                                label(#{ text: weather_json["message"], class: "weather-msg" })
                            ])
                        ]),
                    ]),
                    // todo box
                    box(#{ 
                        class: "todo", 
                        hexpand: true, 
                        orientation: "v",
                        space_evenly: false
                    }, [
                        box(#{ 
                            class: "todo-header", 
                            valign: "start", 
                            space_evenly: false,
                        }, [
                            input(#{ 
                                hexpand: true, 
                                onaccept: `scripts/add_todo_to_ui "{}"`
                            }),
                        ]),
                        scroll(#{ propagate_natural_height: true }, [
                            box(#{ orientation: "v", widget_name: "all_todos" }, [
                                // Will be dynamically added
                            ])
                        ])
                    ])
                ]),
            ]),

            // notification area
            box(#{ orientation: "v", class: "notification_tray", vexpand: true, hexpand: true }, [
                stack(#{ selected: 0 }, [
                    // no notifications yet page
                    box(#{ 
                        orientation: "v", 
                        space_evenly: false, 
                        valign: "center",
                        style: "margin-bottom: 2em;"
                    }, [
                        label(#{ text: "", style: "font-size: 4em;" }),
                        label(#{ 
                            text: "No Notifications Yet", 
                            style: "font-style: italic; margin-left: 1em;",
                        })
                    ]),
                    box(#{ orientation: "v", class: "all_notifications" }, [
                        // generated here
                    ])
                ])
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
    listen("is_playing", #{ initial: "false", cmd: "scripts/music state" }),
    listen("music", #{ initial: "", cmd: "scripts/music title" }),
    poll("weather", #{ initial: "{}", cmd: "scripts/weather" }),

	defwindow("dashboard", #{
        geometry: #{
            x: "175px",
            y: "15px",
            anchor: "center",
            width: "80%",
            height: "80%"
        },
        windowtype: "dialog",
        focusable: "ondemand"
	}, show_dashboard(weather, music, is_playing, extra_classes))
]);