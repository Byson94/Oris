fn render_time(time) {
	label(#{ text: time.split()[0] /* removed space */ })
}

enter([
	defwindow("time", #{
		geometry: #{ anchor: "center" },
        stacking: "bg",
        monitor: 0,
	}, render_time(time))
]);
