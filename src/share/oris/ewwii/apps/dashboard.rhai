import "std::env" as env;
import "std::command" as cmd;

fn show_dashboard() {
    let username = env::get_username();

    let play_btn_label = bound([is_playing], |vars| {
        if !(vars[0] == "true") { "󰐊" } else { "" }
    });

    // let weather_json = if weather != "{}" {
    //     parse_json(weather)
    // } else {
    //     #{
    //         weather: "Loading...",
    //         temperature: "0.0",
    //         message: "Hopefully its a good day!"
    //     }
    // };

	box(#{
        orientation: "v",
        space_evenly: false,
        class: DASHB_ANIM_CLASS,
    }, [
        // menu bar
        box(#{ class: "header" }, [
            label(#{ text: uptime, class: "small-font", halign: "start" }),
            button(#{ 
                label: "Close", 
                halign: "end", 
                class: "close-btn small-font", 
                onclick: `scripts/close_with_anim dashboard do-fade-out 0.1 DASHB_ANIM_CLASS "dashboard "`,
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
                            label(#{ text: standard_time })
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
                            label(#{ text: music, class: "music-title" }),
                
                            box(#{ 
                                space_evenly: false, 
                                spacing: 20, 
                                halign: "center",
                                class: "music-controls"
                            }, [
                                // play random button
                                button(#{ 
                                    onclick: "mpc random off; mpc play $(shuf -i 1-$(mpc playlist | wc -l) -n 1)", 
                                    label: "󰒟",
                                    class: "special-control"
                                }),

                                // prev button
                                button(#{ onclick: "mpc prev", label: "󰒮" }),

                                // Play button
                                button(#{
                                    onclick: "mpc toggle",
                                    label: play_btn_label, // can be both play/pause button
                                }),

                                // next button
                                button(#{ onclick: "mpc next", label: "󰒭" }),

                                // restart button
                                button(#{ 
                                    onclick: "mpc seek 0", 
                                    label: "󰜉",
                                    class: "special-control"
                                }),
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
                                spacing: 10
                            }, [
                                label(#{
                                    widget_name: "weather-and-temperature",
                                    text: "",
                                    class: "weather-heading"
                                }),
                                label(#{
                                    widget_name: "weather-message",
                                    text: "",
                                    class: "weather-msg" 
                                })
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
                                onaccept: `scripts/add_todo_to_ui -s "{}" -a`
                            }),
                        ]),
                        scroll(#{ propagate_natural_height: true, hscroll: false }, [
                            box(#{ orientation: "v", widget_name: "all_todos" }, [
                                // Will be dynamically added
                            ])
                        ])
                    ])
                ]),
            ]),

            // notification area
            box(#{ orientation: "v", class: "notification_tray", vexpand: true, hexpand: true }, [
                stack(#{ selected: SELECTED_NOTIF_PAGE }, [
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
                    scroll(#{ hscroll: false }, [
                        box(#{ 
                            orientation: "v", 
                            class: "all_notifications",
                            widget_name: "all_notifications",
                            space_evenly: false
                        }, [
                            // generated here
                        ])
                    ])
                ])
            ]),
        ])
	])
}

tree([
    listen("is_playing", #{ initial: "false", cmd: "scripts/music state" }),
    listen("__weather__", #{ initial: "{}", cmd: "scripts/weather", interval: "1h" }),
    listen("music", #{ initial: "", cmd: "scripts/music title" }),
    poll("uptime", #{
        cmd: `awk '{printf "Uptime: %dh %dm\n", $1/3600, ($1%3600)/60}' /proc/uptime`,
        interval: "2m",
    }),

    // Dummys
    poll("DASHB_ANIM_CLASS", #{
        cmd: "",
        initial: "",
    }),

    poll("SELECTED_NOTIF_PAGE", #{
        cmd: "",
        initial: "",
    }),

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
	}, show_dashboard())
]);