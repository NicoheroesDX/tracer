class_name GhostController;
extends Node;

var is_finished: bool = false;
var is_active: bool = false;

var next_input_index = 0;

var input_capture_history: Array[InputCapture] = [];

func get_next_input():
	var next_input = input_capture_history.get(next_input_index);
	if (next_input_index + 1 < input_capture_history.size()):
		next_input_index += 1;
	else:
		self.finish();
	return next_input;

func start():
	is_active = true;

func pause():
	is_active = false;

func finish():
	is_active = false;
	is_finished = true;
