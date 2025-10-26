fn render_volosd() {
	let volume = if is_def_var("injected_volume") {
		injected_volume
	} else {
		50
	};

	box(#{ class: "volosd metric", space_evenly: false }, [
		label(#{ text: "Volume:" }),
		scale(#{ value: volume, active: false })
	])
}

enter([
	defwindow("volosd", #{
		geometry: #{
            anchor: "bottom left",
        },
        windowtype: "dialog",
        monitor: 0,
	}, render_volosd())
])