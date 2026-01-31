extends Sprite3D

@onready var controller_texture: Texture2D = preload("res://images/tut_controller.png")
@onready var keyboard_texture: Texture2D = preload("res://images/tut_keyboard.png")

func _ready() -> void:
	if Input.get_connected_joypads().size() > 0:
		texture = controller_texture
	else:
		texture = keyboard_texture

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		texture = controller_texture
	elif event is InputEventKey:
		texture = keyboard_texture