import "std::env" as env;
// import "widgets/app_menu" as _app_menu;
import "widgets/time" as _time;
import "widgets/volosd" as _volosd;
import "apps/settings" as _settings;
import "apps/dashboard" as _dashboard;

fn render(wsp_info) {
    return box(#{ 
        orientation: "h", 
    }, [
        box(#{
            class: "top-bar",
        }, [
            box(#{}, [
                left(wsp_info),
                center(),
                right(),
            ])
        ])
    ])
}

fn left(ws_info) {
    let ws_info = parse_json(ws_info);
    let ws_buttons = [];
    for i in 1..10 {
        let key = "workspace_" + i;
        if ws_info[key] == () {
            ws_info[key] = "·";
        }

        let onclick = "";
        let icon = ws_info[key];

        if icon != "⨂" {
            onclick = `niri msg action focus-workspace ${i}`
        }

        ws_buttons.push(
            button(#{ onclick: onclick, label: ws_info[key] })
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
    let time = localsignal(#{ 
        type: "poll", 
        initial: "", 
        cmd: `v=$(date +%H:%M); echo "  $v"`, 
        interval: "1s" 
    });
    return box(#{ 
        orientation: "h", 
        space_evenly: false, 
        halign: "end",
        spacing: 10,
    }, [
        localbind(#{
            label: time
        }, [
            label(#{ text: "", class: "time-wdgt" }),
        ]),
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
        scale(#{
            min: 0,
            max: 101,
            value: value,
            onchange: onchange,
            timeout: "500ms",
        })
    ])
}

fn render_sidebar(volume, date) {
    let uptime = localsignal(#{
        type: "poll",
        cmd: `awk '{printf "Uptime: %dh %dm\n", $1/3600, ($1%3600)/60}' /proc/uptime`,
        interval: "2m",
    });

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
            localbind(#{
                label: uptime
            }, [
                label(#{ 
                    text: "", 
                    class: "sidebar-uptime",
                    halign: "start"
                }),
            ]),
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

enter([
    listen("wsp_info", #{ initial: "{}", cmd: "scripts/workspace" }),
    poll("date", #{ initial: "", cmd: "date +%d/%m/%Y", interval: "24h" }),
    listen("volume", #{ initial: "", cmd: "scripts/getvol" }),
    poll("day", #{ interval: "20h", cmd: "date '+%d'" }),
    poll("year", #{ interval: "20h", cmd: "date '+%Y'" }),

    // top bar and contents
    defwindow("bar", #{
        geometry: #{ width: "100%", height: "20px" },
        windowtype: "dock",
        exclusive: true,
        monitor: 0,
    }, render(wsp_info)),

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
    }, render_sidebar(volume, date)),

    defwindow("calendar_popup", #{
        geometry: #{
            x: "175px",
            y: "10px",
            anchor: "top left",
            width: "270px",
            height: "60px"
        },
        windowtype: "dialog",
    }, render_cal(day, year)),
]);