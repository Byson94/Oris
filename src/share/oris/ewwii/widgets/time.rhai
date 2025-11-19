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
    cmd: `time=$(date '+%H:%M' | tr -d '[:space:]'); echo "$time"`, 
    interval: "1m" 
});

enter([
	defwindow("time", #{
		geometry: #{ anchor: "center" },
        stacking: "bg",
        monitor: 0,
	}, render_time(time))
]);
