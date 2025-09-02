extends Node2D

var music_audio_bus: int = AudioServer.get_bus_index("MusicBus");
var sfx_audio_bus: int = AudioServer.get_bus_index("SFXBus");

@onready var score_container: VBoxContainer = %ScoreContainer;
@onready var target_container: VBoxContainer = %TargetContainer;
@onready var highscore_time: Label = %HighscoreTime;
@onready var target_time: Label = %TargetTime;
@onready var options_button: Button = $Options;
@onready var load_button: Button = $Load;
@onready var start_button: Button = $Start;
@onready var save_button: Button = $Save;
@onready var about_button: Button = $About;

@onready var dialog: ColorRect = %Dialog;

@onready var back_button: Button = %BackButton;
@onready var clear_record: Button = %ClearRecord;
@onready var clear_target: Button = %ClearTarget;
@onready var music_mute: CheckButton = %MusicButton;
@onready var sfx_mute: CheckButton = %SFXButton;

var dialog_visible: bool = false;
var block_saving: bool = true;

func _ready() -> void:
	Global.current_highscore = Global.load_player_highscore();
	var player_ghost_data = Global.load_player_ghost();
	if (player_ghost_data):
		Global.current_player_ghost_inputs = player_ghost_data;
	else:
		Global.current_player_ghost_inputs = [];
	if (Global.current_highscore == null):
		score_container.visible = false;
	else:
		highscore_time.text = DrivingInterface.format_time(Global.current_highscore.get_combined_time());
	
	Global.current_target = Global.load_target_highscore();
	var target_ghost_data = Global.load_target_ghost();
	if (target_ghost_data):
		Global.current_target_ghost_inputs = target_ghost_data;
	else:
		Global.current_target_ghost_inputs = [];
	if (Global.current_target == null):
		target_container.visible = false;
	else:
		target_time.text = DrivingInterface.format_time(Global.current_target.get_combined_time());
	
	start_button.grab_focus();
	music_mute.button_pressed = AudioServer.is_bus_mute(music_audio_bus);
	sfx_mute.button_pressed = AudioServer.is_bus_mute(sfx_audio_bus);
	block_saving = Global.current_highscore == null or Global.current_player_ghost_inputs.is_empty();

func _process(delta: float) -> void:
	dialog.visible = dialog_visible;
	
	options_button.disabled = dialog_visible;
	load_button.disabled = dialog_visible;
	start_button.disabled = dialog_visible;
	save_button.disabled = dialog_visible or block_saving;
	
	clear_record.disabled = !dialog_visible;
	clear_target.disabled = !dialog_visible;
	music_mute.disabled = !dialog_visible;
	sfx_mute.disabled = !dialog_visible;


func _on_options_pressed() -> void:
	dialog_visible = true;
	await get_tree().process_frame
	back_button.call_deferred("grab_focus");

func _on_load_pressed() -> void:
	Global.upload_file();

func _on_start_pressed() -> void:
	Global.change_scene_with_transition("res://src/track/Track.tscn")

func _on_save_pressed() -> void:
	Global.download_ghost();

func _on_back_pressed() -> void:
	dialog_visible = false;
	options_button.call_deferred("grab_focus");

func _on_music_button_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(music_audio_bus, toggled_on);

func _on_sfx_button_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(sfx_audio_bus, toggled_on);

func _on_clear_record_pressed() -> void:
	Global.delete_record_data();

func _on_clear_target_pressed() -> void:
	Global.delete_target_data();
