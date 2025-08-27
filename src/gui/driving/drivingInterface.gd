class_name DrivingInterface;
extends CanvasLayer;

@onready var grid: GridContainer = $Grid;

@onready var race_time: Label = %TimeCount;

@onready var lap_1_time: Label = %Lap1Time;
@onready var lap_2_time: Label = %Lap2Time;
@onready var lap_3_time: Label = %Lap3Time;

@onready var lap_1_diff: Label = %Lap1Difference;
@onready var lap_2_diff: Label = %Lap2Difference;
@onready var lap_3_diff: Label = %Lap3Difference;

@onready var countdown: Label = $Center/Countdown;
@onready var countdown_progress: ProgressBar = $Center/BarMargin/CountdownProgress;

@onready var animation: AnimationPlayer = $AnimationPlayer;
@onready var end_screen: EndScreen = $EndScreen;

@onready var boost_label: Label = $BoostLabelContainer/BoostLabel;
@onready var speedometer: Speedometer = %Speedometer;

@onready var time_diff: TimeDiff = %TimeDiff;

var is_race_frozen: bool = false;

var is_lap_1_frozen: bool = false;
var is_lap_2_frozen: bool = false;
var is_lap_3_frozen: bool = false;

func _ready() -> void:
	toggle_side_ui(false);
	end_screen.hide();
	lap_2_time.hide();
	lap_3_time.hide();
	
	boost_label.hide();
	
	countdown.hide();
	countdown_progress.hide();

func toggle_side_ui(is_visible: bool):
	if (is_visible):
		grid.show();
	else:
		grid.hide();

func start_countdown():
	animation.play("countdown");

func update_race_time(text: String):
	if not is_race_frozen: 
		race_time.text = text;

func freeze_race_time(text: String):
	is_race_frozen = true;

func display_time(lap: int):
	match (lap):
		1:
			lap_1_time.show();
		2:
			lap_2_time.show();
		3:
			lap_3_time.show();

func update_time(lap: int, text: String):
	match (lap):
		1:
			if not is_lap_1_frozen: 
				lap_1_time.text = text;
		2:
			if not is_lap_2_frozen: 
				lap_2_time.text = text;
		3:
			if not is_lap_3_frozen: 
				lap_3_time.text = text;

func update_time_difference(lap: int, difference: int):
	match (lap):
		1:
			lap_1_diff.text = get_sign_for_difference(difference) + DrivingInterface.format_time(abs(difference));
			lap_1_diff.modulate = get_color_for_difference(difference);
		2:
			lap_2_diff.text = get_sign_for_difference(difference) + DrivingInterface.format_time(abs(difference));
			lap_2_diff.modulate = get_color_for_difference(difference);
		3:
			lap_3_diff.text = get_sign_for_difference(difference) + DrivingInterface.format_time(abs(difference));
			lap_3_diff.modulate = get_color_for_difference(difference);

func freeze_time(lap: int, text: String):
	update_time(lap, text);
	match (lap):
		1:
			is_lap_1_frozen = true;
		2:
			is_lap_2_frozen = true;
		3:
			is_lap_3_frozen = true;

func show_victory_screen(lap_times: Array[int]):
	time_diff.hide_ui();
	end_screen.toggle_mood(true);
	end_screen.refresh_data(lap_times);
	end_screen.show_and_enable_controls();

func show_lose_screen(lap_times: Array[int]):
	time_diff.hide_ui();
	end_screen.toggle_mood(false);
	end_screen.refresh_data(lap_times);
	end_screen.show_and_enable_controls();

func update_checkpoint_time_diff(new_time: int):
	time_diff.update(new_time);

static func get_sign_for_difference(difference: int):
	if (difference < 0):
		return "+";
	elif (difference > 0):
		return "-";
	else:
		return "";

static func get_color_for_difference(difference: int):
	if (difference < 0):
		return Color.LIGHT_SALMON;
	elif (difference > 0):
		return Color.LIGHT_SKY_BLUE;
	else:
		return Color.LIGHT_YELLOW;

static func format_time(msec: int):
	var minutes = msec / 60000
	var seconds = (msec / 1000) % 60
	var milliseconds = msec % 1000
	
	return "%02d:%02d.%03d" % [minutes, seconds, milliseconds]
