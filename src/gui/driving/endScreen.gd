class_name EndScreen;
extends CenterContainer;

@onready var end_title: Label = $EndVBox/EndTitle;

@onready var end_time: Label = %EndTime;
@onready var end_diff: Label = %EndDifference;

@onready var end_lap_1_time: Label = %EndTimeLap1;
@onready var end_lap_2_time: Label = %EndTimeLap2;
@onready var end_lap_3_time: Label = %EndTimeLap3;

@onready var diff_lap_1: Label = %DifferenceLap1;
@onready var diff_lap_2: Label = %DifferenceLap2;
@onready var diff_lap_3: Label = %DifferenceLap3;

@onready var retry_button: Button = %RetryButton;
@onready var menu_button: Button = %MenuButton;

var victory_mood: bool = true;
var is_new_record: bool = false;

func toggle_mood(is_victorious):
	victory_mood = is_victorious;

func _process(delta: float) -> void:
	if (victory_mood):
		if (is_new_record):
			end_title.text = "New Record!"
			end_title.modulate = Color.GOLD;
		else:
			end_title.text = "Victory!"
			end_title.modulate = Color.WHITE;
	else:
		end_title.text = "Game Over!"
		end_title.modulate = Color.RED;

func show_and_enable_controls():
	self.show();
	retry_button.disabled = false;
	menu_button.disabled = false;
	retry_button.grab_focus();

func refresh_data(lap_times: Array[int]):
	end_time.text = DrivingInterface.format_time(lap_times[0]+lap_times[1]+lap_times[2]);
	end_lap_1_time.text = "LAP 1   " + DrivingInterface.format_time(lap_times[0]);
	end_lap_2_time.text = "LAP 2   " + DrivingInterface.format_time(lap_times[1]);
	end_lap_3_time.text = "LAP 3   " + DrivingInterface.format_time(lap_times[2]);
	
	if (victory_mood and Global.current_highscore != null):
		var full_race_difference = Global.current_highscore.get_combined_time() - (lap_times[0]+lap_times[1]+lap_times[2]);
		
		if (full_race_difference > 0):
			is_new_record = true;
		
		end_diff.text = DrivingInterface.get_sign_for_difference(full_race_difference) + DrivingInterface.format_time(abs(full_race_difference));
		end_diff.modulate = DrivingInterface.get_color_for_difference(full_race_difference);
		
		var difference_for_lap_1 = Global.current_highscore.lap_1_time - lap_times[0];
		diff_lap_1.text = DrivingInterface.get_sign_for_difference(difference_for_lap_1) + DrivingInterface.format_time(abs(difference_for_lap_1));
		diff_lap_1.modulate = DrivingInterface.get_color_for_difference(difference_for_lap_1);
		
		var difference_for_lap_2 = Global.current_highscore.lap_2_time - lap_times[1];
		diff_lap_2.text = DrivingInterface.get_sign_for_difference(difference_for_lap_2) + DrivingInterface.format_time(abs(difference_for_lap_2));
		diff_lap_2.modulate = DrivingInterface.get_color_for_difference(difference_for_lap_2);
		
		var difference_for_lap_3 = Global.current_highscore.lap_3_time - lap_times[2];
		diff_lap_3.text = DrivingInterface.get_sign_for_difference(difference_for_lap_3) + DrivingInterface.format_time(abs(difference_for_lap_3));
		diff_lap_3.modulate = DrivingInterface.get_color_for_difference(difference_for_lap_3);
	else:
		end_diff.visible = false;
		diff_lap_1.visible = false;
		diff_lap_2.visible = false;
		diff_lap_3.visible = false;

func _on_retry_button_pressed() -> void:
	Global.change_scene_with_transition("res://src/track/Track.tscn")

func _on_menu_button_pressed() -> void:
	Global.toggle_music(false);
	Global.change_scene_with_transition("res://src/gui/menu/MainMenu.tscn")
