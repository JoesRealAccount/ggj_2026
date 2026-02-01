extends Area3D


func _ready() -> void:
	body_entered.connect(_on_area_3d_body_entered)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		SignalManager.player_death.emit()
