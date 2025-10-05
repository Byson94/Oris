import "std::env" as env;

fn render(wsp_info, time) {
    return box(#{ orientation: "h" }, [
        box(#{
            class: "top-bar"
        }, [
            left(wsp_info),
            center(),
            right(time),
        ])
    ])
}

fn left(ws_info) {
    let ws_info = parse_json(ws_info);
    for i in 1..10 {
        let key = "workspace_" + i;
        if ws_info[key] == () {
            ws_info[key] = "·";
        }
    }

    box(#{
        class: "left-side",
        orientation: "h",
        space_evenly: false,
        haligh: "start",
        spacing: 5,
    }, [
        button(#{ 
            label: "", 
            class: "sidebar-revealer", 
            style: "font-size: 20px;",
            onclick: "scripts/sidebar-popup",
            timeout: "5s"
        }),

        box(#{
            class: "workspace",
            orientation: "h",
            space_evenly: false,
            halign: "start",
            spacing: 5,
        }, [
            button(#{ onclick: "hyprctl dispatch workspace 1", label: ws_info["workspace_1"] }),
            button(#{ onclick: "hyprctl dispatch workspace 2", label: ws_info["workspace_2"] }),
            button(#{ onclick: "hyprctl dispatch workspace  3", label: ws_info["workspace_3"] }),
            button(#{ onclick: "hyprctl dispatch workspace  4", label: ws_info["workspace_4"] }),
            button(#{ onclick: "hyprctl dispatch workspace  5", label: ws_info["workspace_5"] }),
            button(#{ onclick: "hyprctl dispatch workspace  6", label: ws_info["workspace_6"] }),
            button(#{ onclick: "hyprctl dispatch workspace  7", label: ws_info["workspace_7"] }),
            button(#{ onclick: "hyprctl dispatch workspace  8", label: ws_info["workspace_8"] }),
            button(#{ onclick: "hyprctl dispatch workspace  9", label: ws_info["workspace_9"] }),
            button(#{ onclick: "hyprctl dispatch workspace  10", label: ws_info["workspace_10"] }),
        ])
    ])
}

fn center() {
    return eventbox(#{ 
        cursor: "pointer",
        halign: "center",
        class: "search-btn",
    }, [ 
        label(#{ text: "  Application menu" }) 
    ])
}

fn right(time) {
    return box(#{ 
        orientation: "h", 
        space_evenly: false, 
        halign: "end",
        spacing: 10,
    }, [
        label(#{ text: `   ${time}`, class: "time-wdgt" }),
        button(#{ label: "", class: "power-wdgt", onclick: "scripts/power-menu-popup", timeout: "5s" })
    ])
}

// == POWER MENU == //
fn render_power() {
    return box(#{
        orientation: "v",
        class: "power-menu-content-box"
    }, [
        button(#{ label: "Log Out", onclick: `loginctl terminate-user ${env::get_username()}` }),
        button(#{ label: "Reboot", onclick: "systemctl reboot" }),
        button(#{ label: "Shutdown", class: "shutdown-btn", onclick: "systemctl poweroff" }),
    ]);
}

// == SIDE BAR == //
fn draw_slider(icon, onchange, value) {
    return box(#{
        orientation: "h",
        class: "metric",
        space_evenly: false,
    }, [
        box(#{ class: "label" }, [
            label(#{ text: icon }),
        ]),
        slider(#{
            min: 0,
            max: 101,
            value: value,
            onchange: onchange,
            timeout: "500ms",
        })
    ])
}

fn render_sidebar(volume, uptime, date) {
    let uptime_seconds = parse_float(uptime.split(" ")[0]);
    let total_seconds = to_int(uptime_seconds);
    let uptime_hours = total_seconds / 3600;
    let uptime_minutes = (total_seconds % 3600) / 60;

    return box(#{
        orientation: "v",
        class: "sidebar-content-box",
        space_evenly: false,
        spacing: 5
    }, [
        draw_slider(" ", "pamixer --set-volume {}", volume),
        eventbox(#{ 
            cursor: "pointer", 
            class: "cal-box",
            onclick: "scripts/calendar_popup",
        }, [ label(#{ text: "Toggle Calendar" }) ]),
        box(#{
            orientation: "v",
            class: "sidebar-text-box"
        }, [
            label(#{ 
                text: `Uptime: ${uptime_hours}h ${uptime_minutes}m`, 
                class: "sidebar-uptime",
                halign: "start"
            }),
            label(#{ 
                text: `Date: ${date}`, 
                class: "sidebar-date",
                halign: "start"
            }),
        ]),
    ]);
}

fn render_cal(day, year) {
    box(#{
        orientation: "v",
    }, [
        box(#{ class: "calendar", orientation: "v" }, [
            box(#{ class: "calendar-in" }, [
                calendar(#{
                    class: "calendar",
                    day: day,
                    year: year,
                })
            ])
        ])
    ])
}

enter([
    listen("wsp_info", #{ initial: "{}", cmd: "scripts/workspace" }),
    poll("time", #{ initial: "", cmd: "date +%H:%M", interval: "10s" }),
    poll("date", #{ initial: "", cmd: "date +%d/%m/%Y", interval: "24h" }),
    poll("uptime", #{ initial: "0", cmd: "cat /proc/uptime", interval: "1m" }),
    listen("volume", #{ initial: "", cmd: "scripts/getvol" }),
    poll("day", #{ interval: "20h", cmd: "date '+%d'" }),
    poll("year", #{ interval: "20h", cmd: "date '+%Y'" }),

    // top bar and contents
    defwindow("bar", #{
        geometry: #{ width: "100%", height: "20px" },
        windowtype: "dock",
        exclusive: true,
        monitor: 0,
    }, render(wsp_info, time)),

    defwindow("power-menu", #{
        geometry: #{
            y: "10px",
            x: "10px",
            anchor: "top right",
            width: "80px",
            height: "60px"
        },
        windowtype: "dialog",
        monitor: 0,
    }, render_power()),

    defwindow("extra-sidebar", #{
        geometry: #{
            y: "10px",
            x: "10px",
            anchor: "top left",
            width: "80px",
            height: "60px"
        },
        windowtype: "dialog",
        monitor: 0,
    }, render_sidebar(volume, uptime, date)),

    // Bottom dock
    defwindow("calendar_popup", #{
        geometry: #{
            x: "175px",
            y: "15px",
            anchor: "top left",
            width: "270px",
            height: "60px"
        },
        windowtype: "dialog",
    }, render_cal(day, year)),
]);
