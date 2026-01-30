extends MeshInstance3D

## Light pulsing speed in milliseconds. Higher is slower.
@export_range(0.1, 1000.0) var pulse_speed: float = 800.0


func _process(_delta: float) -> void:
	var energy = _calculate_light_energy()
	
	# get all light children and make the energy pulse
	for child in get_children():
		if child is OmniLight3D:
			var light := child as OmniLight3D
			light.light_energy = energy


func _calculate_light_energy() -> float:
	return 2.0 + sin(Time.get_ticks_msec() / pulse_speed) * 1.0
