extends Node2D

var music_audio_bus: int = AudioServer.get_bus_index("MusicBus");
var sfx_audio_bus: int = AudioServer.get_bus_index("SFXBus");

@onready var score_container: VBoxContainer = %ScoreContainer;
@onready var highscore_time: Label = %HighscoreTime;
@onready var start_button: Button = $Button;
@onready var music_mute: CheckButton = %MusicButton;
@onready var sfx_mute: CheckButton = %SFXButton;

func _ready() -> void:
	Global.current_highscore = Global.load_highscore();
	var player_ghost_data = Global.load_player_ghost();
	if (player_ghost_data):
		Global.current_player_ghost_inputs = player_ghost_data;
	else:
		Global.current_player_ghost_inputs = [];
	if (Global.current_highscore == null):
		score_container.visible = false;
	else:
		highscore_time.text = DrivingInterface.format_time(Global.current_highscore.get_combined_time());
	start_button.grab_focus();
	music_mute.button_pressed = AudioServer.is_bus_mute(music_audio_bus);
	sfx_mute.button_pressed = AudioServer.is_bus_mute(sfx_audio_bus);

func _on_button_pressed() -> void:
	Global.change_scene_with_transition("res://src/track/Track.tscn")

func _on_music_button_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(music_audio_bus, toggled_on);

func _on_sfx_button_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(sfx_audio_bus, toggled_on);
