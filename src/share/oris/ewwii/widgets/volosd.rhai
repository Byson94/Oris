fn render_volosd(volume) {
	box(#{ class: "volosd metric", space_evenly: false }, [
		label(#{ text: "Volume:" }),
		scale(#{ value: volume, active: false, min: 0, max: 101 })
	])
}

let volume = if is_def_var("injected_volume") {
	parse_int(injected_volume)
} else {
	50
};

enter([
	defwindow("volosd", #{
		geometry: #{
            anchor: "bottom left",
        },
        windowtype: "dialog",
        monitor: 0,
	}, render_volosd(volume))
])