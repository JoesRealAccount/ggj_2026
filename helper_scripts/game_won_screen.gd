extends Control

@onready var _minutes_passed_text_label: RichTextLabel = %MinutesPassed
@onready var _acts_completed_text_label: RichTextLabel = %ActsCompleted
@onready var _continue_button: Button = %ContinueButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.game_won.connect(_on_game_won)

func _on_game_won():
	show()
	_continue_button.grab_focus()
	get_tree().paused = true
	_minutes_passed_text_label.text = str(int(GameManager.game_completion_time))
	_acts_completed_text_label.text = str(int(GameManager.game_completion_time/60))

func _on_continue_button_pressed():
	get_tree().paused = false
	hide()
	SignalManager.player_death.emit()
