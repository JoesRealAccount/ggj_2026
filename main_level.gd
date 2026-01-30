extends Node3D


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("back_to_menu"):
		get_tree().change_scene_to_file("res://main_screen.tscn")
