fn render_time(time) {
	label(#{ text: time.split()[0] /* removed space */ })
}

enter([
	defwindow("time", #{
		geometry: #{ y: "30%", anchor: "top center" },
        stacking: "bg",
        monitor: 0,
	}, render_time(time))
])