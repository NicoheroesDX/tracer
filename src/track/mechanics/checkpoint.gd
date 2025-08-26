class_name Checkpoint;
extends TargetArea;

var is_checked: bool = false;

var lap_1_target: int = -1;
var lap_2_target: int = -1;
var lap_3_target: int = -1;

var lap_1_time: int = -1;
var lap_2_time: int = -1;
var lap_3_time: int = -1;

func reset() -> void:
	is_checked = false;

# @Override
func on_player_entered() -> void:
	if not is_checked:
		is_checked = true;
		player_crossed.emit(self);

func get_times() -> Array[int]:
	return [lap_1_time, lap_2_time, lap_3_time];

func set_targets(lap1: int, lap2: int, lap3: int):
	lap_1_target = lap1;
	lap_2_target = lap2;
	lap_3_target = lap3;
