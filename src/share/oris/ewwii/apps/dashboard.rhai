import "std::env" as env;

fn get_notifications() {
    return label(#{ text: "None Yet", style: "font-style: italic;" })
}

fn show_dashboard(cpu, mem, extra_classes) {
    let time = localsignal(#{ 
        type: "poll", 
        initial: "", 
        cmd: "date +%H:%M", 
        interval: "1s" 
    });

    let uptime = localsignal(#{
        type: "poll",
        cmd: `awk '{printf "Uptime: %dh %dm\n", $1/3600, ($1%3600)/60}' /proc/uptime`,
        interval: "2m",
    });

    let username = env::get_username();

    let user_spaces = "";
    for x in 0..(username.len() / 2) {
        user_spaces += " ";
    }

	box(#{
        orientation: "v",
        space_evenly: false,
        class: `dashboard ${extra_classes}`
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
                onclick: "scripts/close_with_anim dashboard do-fade-out 0.2" ,
                timeout: "5s"
            })
        ]),

        box(#{ orientation: "h", space_evenly: false, vexpand: true, hexpand: true }, [
            box(#{ orientation: "v", space_evenly: false, vexpand: true, hexpand: true }, [
                box(#{ orientation: "h", space_evenly: false, vexpand: true, hexpand: true }, [
                    box(#{ class: "welcome_user" }, [
                        label(#{ text: `${user_spaces}Hello \n${username}!` })
                    ]),
                    box(#{ class: "dashboard_time" }, [
                        localbind(#{
                            label: time
                        }, [
                            label(#{ text: "Current Time" })
                        ])
                    ]),
                    box(#{ class: "sys_info", orientation: "h", spacing: 6 }, [
                        overlay(#{}, [
                            circular_progress(#{ value: cpu, fg_color: "green" }),
                            label(#{ 
                                text: " ", 
                                style: "margin: 2px 0px 0px 3px; font-size: 10px;" 
                            }),
                        ]),
                        overlay(#{}, [
                            circular_progress(#{ value: mem, fg_color: "green" }),
                            label(#{ text: "", style: "margin-top: 2px; font-size: 10px;" }),
                        ]),
                    ]),
                ]),
                box(#{ orientaiton: "h", space_evenly: false, class: "weather", vexpand: true, hexpand: true }, [
                    label(#{ text: "Weather here" })
                ]),
            ]),

            box(#{ orientation: "v", class: "notification_tray", vexpand: true, hexpand: true }, [
                label(#{ text: "Notifications", class: "bold-label", valign: "start" }),
                get_notifications(),
            ]),
        ])
	])
}

let extra_classes = if is_def_var("EXTRA_CLASS") {
    EXTRA_CLASS
} else {
    ""
};

enter([
    poll("cpu_usage", #{ 
        cmd: `top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | cut -d. -f1`, 
        interval: "5s",
    }),
    poll("mem_usage", #{ 
        cmd: `free | awk '/Mem:/ {print int($3/$2 * 100)}'`, 
        interval: "5s",
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
	}, show_dashboard(cpu_usage, mem_usage, extra_classes))
])