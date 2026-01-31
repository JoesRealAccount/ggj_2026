extends Node3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	print("Kill area triggered by: ", body.name)
	print("Is in group 'player': ", body.is_in_group("player"))
	if body.is_in_group("player"):
		SignalManager.player_death.emit()
