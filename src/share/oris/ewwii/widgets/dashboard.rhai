fn show_dashboard() {
	box(#{}, [
		button(#{ label: "Close" })
	])
}

enter([
	defwindow("dashboard", #{
        geometry: #{
            x: "175px",
            y: "15px",
            anchor: "center",
            width: "270px",
            height: "60px"
        },
        windowtype: "dialog",
	}, show_dashboard())
])