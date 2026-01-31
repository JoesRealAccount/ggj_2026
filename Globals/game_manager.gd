extends Node

var depression_transparency: float = 0.9
var happiness_transparency: float = 0.0

var game_stopwatch: Stopwatch

func _ready() -> void:
    SignalManager.game_started.connect(_on_game_started)

func _on_game_started():
    game_stopwatch = Stopwatch.new()
    add_child(game_stopwatch)
