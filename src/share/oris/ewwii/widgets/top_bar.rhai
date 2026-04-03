import "std::env" as env;

fn render() {
    return box(#{ 
        orientation: "h", 
    }, [
        box(#{
            class: "top-bar",
        }, [
            box(#{}, [
                left(),
                center(),
                right(),
            ])
        ])
    ])
}

fn left() {
    let ws_info = [
        workspace_1,
        workspace_2,
        workspace_3,
        workspace_4,
        workspace_5,
        workspace_6,
        workspace_7,
        workspace_8,
        workspace_9,
    ];
    let ws_buttons = [];
    for i in 0..9 {
        // let key = "workspace_" + i;
        // if ws_info[i] == () {
        //     ws_info[i] = "·";
        // }

        let onclick = bound([ws_info, i], |vars| {
            let ws_info = vars[0];
            let i = vars[1];
            let icon = ws_info[i];

            if icon != "⨂" {
                // Niri uses 1-based index
                return `niri msg action focus-workspace ${i+1}`
            } else {
                return ""
            }
        });

        ws_buttons.push(
            button(#{ onclick: onclick, label: ws_info[i] })
        )
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
        }, ws_buttons)
    ])
}

fn center() {
    return eventbox(#{ 
        cursor: "pointer",
        halign: "center",
        class: "search-btn",
        onclick: "scripts/app_menu_popup",
    }, [ 
        label(#{ text: "  Application menu" }) 
    ])
}

fn right() {
    return box(#{ 
        orientation: "h", 
        space_evenly: false, 
        halign: "end",
        spacing: 10,
    }, [
        label(#{ text: time, class: "time-wdgt" }),
        button(#{ 
            label: "", 
            class: "power-wdgt", 
            onclick: "scripts/power-menu-popup", 
            timeout: "5s" 
        })
    ])
}

// == POWER MENU == //
fn render_power() {
    return box(#{
        orientation: "v",
        class: `power-menu power-menu-content-box`
    }, [
        button(#{ label: "Log Out", onclick: "wayland-logout" }),
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
        scale(#{
            min: 0,
            max: 101,
            value: value,
            onchange: onchange,
            timeout: "500ms",
        })
    ])
}

fn render_sidebar() {
    return box(#{
        orientation: "v",
        class: `sidebar-content-box`,
        space_evenly: false,
        spacing: 5,
    }, [
        draw_slider(" ", "pamixer --set-volume {}", volume),
        eventbox(#{ 
            cursor: "pointer", 
            class: "cal-box",
            onclick: "scripts/calendar_popup",
            timeout: "5s"
        }, [ label(#{ text: "Toggle Calendar" }) ]),
        box(#{
            orientation: "v",
            class: "sidebar-text-box"
        }, [
            label(#{ 
                text: uptime, 
                class: "sidebar-uptime",
                halign: "start"
            }),
            label(#{ 
                text: bound([date], |vars| {
                    `Date: ${vars[0]}`
                }),
                class: "sidebar-date",
                halign: "start"
            }),
        ]),
    ]);
}

fn render_cal() {
    box(#{
        orientation: "v",
        class: `calendar_popup`
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

fn render_app_menu() {
    box(#{ orientation: "v" }, [
        eventbox(#{
            // 9 = Escape
            onkeypress: "if [ {} == '9' ]; then scripts/app_menu_popup; fi"
        }, [
            box(#{ orientation: "h", space_evenly: false }, [
                label(#{ text: "Search: " }),
                input(#{ })
            ])
        ])
    ])
}


tree([
    poll("date", #{ initial: "", cmd: "date +%d/%m/%Y", interval: "24h" }),
    listen("volume", #{ initial: "", cmd: "scripts/getvol" }),
    poll("day", #{ interval: "20h", cmd: "date '+%d'" }),
    poll("year", #{ interval: "20h", cmd: "date '+%Y'" }),
    poll("time", #{
        initial: "Current time", 
        cmd: `v=$(date +%H:%M); echo "   $v"`, 
        interval: "1m" 
    }),
    poll("uptime", #{
        cmd: `awk '{printf "Uptime: %dh %dm\n", $1/3600, ($1%3600)/60}' /proc/uptime`,
        interval: "2m",
    }),

    // workspaces
    listen("workspace_1", #{ initial: "{}", cmd: "scripts/workspace 1" }),
    listen("workspace_2", #{ initial: "{}", cmd: "scripts/workspace 2" }),
    listen("workspace_3", #{ initial: "{}", cmd: "scripts/workspace 3" }),
    listen("workspace_4", #{ initial: "{}", cmd: "scripts/workspace 4" }),
    listen("workspace_5", #{ initial: "{}", cmd: "scripts/workspace 5" }),
    listen("workspace_6", #{ initial: "{}", cmd: "scripts/workspace 6" }),
    listen("workspace_7", #{ initial: "{}", cmd: "scripts/workspace 7" }),
    listen("workspace_8", #{ initial: "{}", cmd: "scripts/workspace 8" }),
    listen("workspace_9", #{ initial: "{}", cmd: "scripts/workspace 9" }),

    // top bar and contents
    defwindow("bar", #{
        geometry: #{ width: "100%", height: "20px" },
        windowtype: "dock",
        exclusive: true,
        monitor: 0,
    }, render()),

    defwindow("power-menu", #{
        geometry: #{
            y: "10px",
            x: "10px",
            anchor: "top right",
        },
        windowtype: "dialog",
        monitor: 0,
    }, render_power()),

    defwindow("extra-sidebar", #{
        geometry: #{
            y: "10px",
            x: "10px",
            anchor: "top left",
        },
        windowtype: "dialog",
        monitor: 0,
    }, render_sidebar()),

    defwindow("calendar_popup", #{
        geometry: #{
            x: "175px",
            y: "10px",
            anchor: "top left",
            width: "280px",
            height: "150px"
        },
        windowtype: "dialog",
    }, render_cal()),
]);
