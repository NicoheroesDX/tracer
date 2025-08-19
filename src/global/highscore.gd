class_name Highscore;
extends Node;

var lap_1_time = -1;
var lap_2_time = -1;
var lap_3_time = -1;

func _init(time_1: int, time_2: int, time_3) -> void:
	lap_1_time = time_1;
	lap_2_time = time_2;
	lap_3_time = time_3;

func get_combined_time() -> int:
	return lap_1_time + lap_2_time + lap_3_time;
