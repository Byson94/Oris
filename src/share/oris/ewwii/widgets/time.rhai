fn render_time(time) {
	localbind(#{
		label: time
	}, [
		label(#{ text: ""})
	])
}

let time = localsignal(#{ 
    type: "poll", 
    initial: "", 
    cmd: "date '+%H:%M'", 
    interval: "1m" 
});

enter([
	defwindow("time", #{
		geometry: #{ anchor: "center" },
        stacking: "bg",
        monitor: 0,
	}, render_time(time))
]);
