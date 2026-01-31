extends Control

@onready var _minute_display: RichTextLabel = %MinuteDisplay


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.game_stopwatch == null:
		await get_tree().create_timer(0.1).timeout
		_ready()
	else:
		GameManager.game_stopwatch.minute_changed.connect(_on_minute_changed)

func _on_minute_changed(minute: int):
	_minute_display.text = str(minute+1)