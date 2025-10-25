class_name GhostRecorder;
extends Node;

var input_capture_history: Array[InputCapture] = [];

func capture_input(axis: float, is_accel: bool, accel_strength: float, is_decel: bool, decel_strength: float, boost: bool):
	input_capture_history.append(InputCapture.new(axis, is_accel, accel_strength, is_decel, decel_strength, boost));

func save_ghost():
	var ghost_file = FileAccess.open(Global.SAVE_GAME_FOLDER + Global.SAVED_PLAYER_GHOST_FILE_NAME, FileAccess.WRITE);
	var inputs_to_save = input_capture_history.duplicate();
	
	for input: InputCapture in inputs_to_save:
		ghost_file.store_line(\
			str(input.input_axis) + Global.CSV_SEPARATOR +\
			Global.to_binary_str(input.is_accelerating) + Global.CSV_SEPARATOR +\
			str(input.acceleration_strength) + Global.CSV_SEPARATOR +\
			Global.to_binary_str(input.is_decelerating) + Global.CSV_SEPARATOR +\
			str(input.deceleration_strength) + Global.CSV_SEPARATOR +\
			Global.to_binary_str(input.is_boosting)\
		);
	
	ghost_file.close();
