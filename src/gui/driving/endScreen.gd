class_name EndScreen;
extends CenterContainer;

@onready var end_title: Label = $EndVBox/EndTitle;

@onready var end_time: Label = %EndTime;

@onready var end_lap_1_time: Label = %EndTimeLap1;
@onready var end_lap_2_time: Label = %EndTimeLap2;
@onready var end_lap_3_time: Label = %EndTimeLap3;

var victory_mood: bool = true;

func toggle_mood(is_victorious):
	victory_mood = is_victorious;

func _process(delta: float) -> void:
	if (victory_mood):
		end_title.modulate = Color.WHITE;
		end_title.text = "Victory!"
	else:
		end_title.modulate = Color.RED;
		end_title.text = "Game Over!"

func refresh_data(lap_times: Array[int]):
	end_time.text = DrivingInterface.format_time(lap_times[0]+lap_times[1]+lap_times[2]);
	end_lap_1_time.text = DrivingInterface.format_time(lap_times[0]);
	end_lap_2_time.text = DrivingInterface.format_time(lap_times[1]);
	end_lap_3_time.text = DrivingInterface.format_time(lap_times[2]);

func _on_retry_button_pressed() -> void:
	Global.change_scene_with_transition("res://src/track/Track.tscn")

func _on_menu_button_pressed() -> void:
	Global.change_scene_with_transition("res://src/gui/menu/MainMenu.tscn")
