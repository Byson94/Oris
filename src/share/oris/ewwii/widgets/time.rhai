fn render_time() {
	box(#{ halign: "center" }, [
		label(#{ text: standard_time })
	])
}

tree([
	poll("standard_time", #{
		initial: "00:00", 
		cmd: `date '+%H:%M'`, 
		interval: "1m" 
	}),

	defwindow("time", #{
		geometry: #{ anchor: "center" },
        stacking: "bg",
        monitor: 0,
	}, render_time())
]);
