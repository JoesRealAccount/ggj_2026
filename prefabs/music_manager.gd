extends AudioStreamPlayer


@onready var _music_bus_index: int = AudioServer.get_bus_index("Music")

@onready var _audio_effect_collection: AudioEffectCollection = preload("uid://b3jfmrb7qvgnm")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.world_toggled_is_depression.connect(_on_mask_toggled)

func _on_mask_toggled(is_depression: bool):
	for effect_index: int in range(AudioServer.get_bus_effect_count(_music_bus_index)):
		AudioServer.remove_bus_effect(_music_bus_index, effect_index)
	if is_depression:
		for _audio_effect: AudioEffect in _audio_effect_collection._audio_effects:
			AudioServer.add_bus_effect(_music_bus_index, _audio_effect, AudioServer.get_bus_effect_count(_music_bus_index))
		AudioServer.set_bus_bypass_effects(_music_bus_index, false)
	else:
		AudioServer.set_bus_bypass_effects(_music_bus_index, true)
