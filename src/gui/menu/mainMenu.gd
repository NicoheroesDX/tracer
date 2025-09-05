extends Node2D

var music_audio_bus: int = AudioServer.get_bus_index("MusicBus");
var sfx_audio_bus: int = AudioServer.get_bus_index("SFXBus");

@onready var score_container: VBoxContainer = %ScoreContainer;
@onready var target_container: VBoxContainer = %TargetContainer;
@onready var highscore_time: Label = %HighscoreTime;
@onready var target_time: Label = %TargetTime;
@onready var settings_button: Button = $Options;
@onready var load_button: Button = $Load;
@onready var start_button: Button = $Start;
@onready var save_button: Button = $Save;
@onready var about_button: Button = $About;

@onready var settings_dialog: ColorRect = %SettingsDialog;
@onready var about_dialog: ColorRect = %AboutDialog;

@onready var about_back_button: Button = $AboutDialog/Back;

@onready var settings_back_button: Button = $SettingsDialog/Back;
@onready var clear_record: Button = %ClearRecord;
@onready var clear_target: Button = %ClearTarget;
@onready var music_mute: CheckButton = %MusicButton;
@onready var sfx_mute: CheckButton = %SFXButton;

var settings_dialog_visible: bool = false;
var about_dialog_visible: bool = false;
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
	settings_dialog.visible = settings_dialog_visible;
	about_dialog.visible = about_dialog_visible;
	
	settings_button.disabled = is_dialog_open();
	load_button.disabled = is_dialog_open();
	start_button.disabled = is_dialog_open();
	save_button.disabled = is_dialog_open() or block_saving;
	
	clear_record.disabled = !settings_dialog_visible;
	clear_target.disabled = !settings_dialog_visible;
	music_mute.disabled = !settings_dialog_visible;
	sfx_mute.disabled = !settings_dialog_visible;

func is_dialog_open() -> bool:
	return settings_dialog_visible or about_dialog_visible;

func _on_options_pressed() -> void:
	settings_dialog_visible = true;
	settings_back_button.call_deferred("grab_focus");

func _on_load_pressed() -> void:
	Global.upload_file();

func _on_start_pressed() -> void:
	Global.change_scene_with_transition("res://src/track/Track.tscn")

func _on_save_pressed() -> void:
	Global.download_ghost();

func _on_about_pressed() -> void:
	about_dialog_visible = true;
	about_back_button.call_deferred("grab_focus");

func _on_options_back_pressed() -> void:
	settings_dialog_visible = false;
	settings_button.call_deferred("grab_focus");

func _on_about_back_pressed() -> void:
	about_dialog_visible = false;
	about_button.call_deferred("grab_focus");

func _on_music_button_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(music_audio_bus, toggled_on);

func _on_sfx_button_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(sfx_audio_bus, toggled_on);

func _on_clear_record_pressed() -> void:
	Global.delete_record_data();

func _on_clear_target_pressed() -> void:
	Global.delete_target_data();
