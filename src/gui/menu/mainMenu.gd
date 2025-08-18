extends Node2D

var music_audio_bus: int = AudioServer.get_bus_index("MusicBus")
var sfx_audio_bus: int = AudioServer.get_bus_index("SFXBus")

func _ready() -> void:
	%MusicButton.button_pressed = AudioServer.is_bus_mute(music_audio_bus);
	%SFXButton.button_pressed = AudioServer.is_bus_mute(sfx_audio_bus);

func _on_button_pressed() -> void:
	Global.change_scene_with_transition("res://src/track/Track.tscn")

func _on_music_button_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(music_audio_bus, toggled_on);

func _on_sfx_button_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(sfx_audio_bus, toggled_on);
