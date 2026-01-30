extends Node3D


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("back_to_menu"):
		get_tree().change_scene_to_file("res://scenes/main_screen.tscn")
