class_name Highscore;
extends Node;

var lap_1_time = -1;
var lap_2_time = -1;
var lap_3_time = -1;

# Two-dimensional Array: index = checkpoint_index > [lap_1_time, lap_2_time, lap_3_time]
var checkpoint_times: Array = []

func _init(time_1: int, time_2: int, time_3: int, c_times: Array) -> void:
	lap_1_time = time_1;
	lap_2_time = time_2;
	lap_3_time = time_3;
	checkpoint_times = c_times;

func get_combined_time() -> int:
	return lap_1_time + lap_2_time + lap_3_time;

static func extract_checkpoint_times(checkpoints: Array[Node]) -> Array:
	var result = [];
	for check in checkpoints:
		result.append([check.lap_1_time, check.lap_2_time, check.lap_3_time]);
	return result;
