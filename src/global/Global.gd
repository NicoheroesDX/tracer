extends Node

signal transition_complete;

const SAVE_GAME_FOLDER = "user://";
const SAVE_FILE_NAME = "tracer.data";
const TARGET_FILE_NAME = "target.data";
const SAVED_PLAYER_GHOST_FILE_NAME = "player.ghost";
const SAVED_TARGET_GHOST_FILE_NAME = "target.ghost";
const LAP_1_KEY = "highscore_lap_1";
const LAP_2_KEY = "highscore_lap_2";
const LAP_3_KEY = "highscore_lap_3";
const CHECKPOINT_KEY_PREFIX = "check_"
const KEY_VALUE_SEPARATOR = "=";
const CSV_SEPARATOR = ";";
const MAX_INDEX_LENGTH_CHECKPOINTS = 3;
const SHARED_GHOST_FILE_EXTENSION = ".trsg";
const TEMP_FOLDER = SAVE_GAME_FOLDER + "temp/";

var current_highscore: Highscore;

var current_player_ghost_inputs: Array[InputCapture] = [];
var current_target_ghost_inputs: Array[InputCapture] = [];

func toggle_music(is_playing: bool):
	var music_player = get_tree().root.get_node("MainScene").get_node("RaceMusic")
	if (music_player != null):
		if is_playing and not music_player.playing:
			music_player.play();
		elif not is_playing:
			music_player.stop();

func save_highscore(new_highscore: Highscore):
	var save_file = FileAccess.open(SAVE_GAME_FOLDER + SAVE_FILE_NAME, FileAccess.WRITE);
	
	save_file.store_line(LAP_1_KEY + KEY_VALUE_SEPARATOR + str(new_highscore.lap_1_time));
	save_file.store_line(LAP_2_KEY + KEY_VALUE_SEPARATOR + str(new_highscore.lap_2_time));
	save_file.store_line(LAP_3_KEY + KEY_VALUE_SEPARATOR + str(new_highscore.lap_3_time));
	
	var checkpoint_index = 0;
	for check in new_highscore.checkpoint_times:
		save_file.store_line(\
			CHECKPOINT_KEY_PREFIX +\
			str(checkpoint_index).pad_zeros(3) +\
			KEY_VALUE_SEPARATOR +\
			str(check[0]) + CSV_SEPARATOR +\
			str(check[1]) + CSV_SEPARATOR +\
			str(check[2])\
		);
		checkpoint_index += 1;
	
	save_file.close();

func download_highscore():
	const file_name = "ghost_XX_YY_ZZZ" + SHARED_GHOST_FILE_EXTENSION;
	const file_path = TEMP_FOLDER + file_name;
	
	if (create_shared_ghost_file(file_path)):
		var ghost_file := FileAccess.open(file_path, FileAccess.READ);
		if ghost_file:
			var content := ghost_file.get_buffer(ghost_file.get_length());
			ghost_file.close();
			WebOnly.download_file(file_name, content);
		else:
			print("ERROR: Could not access ghost file");

func create_shared_ghost_file(file_path: String) -> bool:
	var save_game_directory := DirAccess.open(SAVE_GAME_FOLDER)
	if not save_game_directory.dir_exists(TEMP_FOLDER):
		var err = save_game_directory.make_dir(TEMP_FOLDER)
		if err != OK:
			print("ERROR: Failed to create folder");
			return false;
	
	var zip_file = ZIPPacker.new();
	var err = zip_file.open(file_path);
	if err != OK:
		print("ERROR: Failed to create archive");
		return false;
	
	zip_file.start_file("hello.txt");
	zip_file.write_file("Hello World".to_utf8_buffer());
	zip_file.close_file();
	
	zip_file.start_file("bye.txt");
	zip_file.write_file("Bye World".to_utf8_buffer());
	zip_file.close_file();
	
	zip_file.close();
	return true;

func load_highscore():
	if not FileAccess.file_exists(SAVE_GAME_FOLDER + SAVE_FILE_NAME):
		print("ERROR: Failed to load Highscore from file");
		return;
	
	const expected_keys = [LAP_1_KEY, LAP_2_KEY, LAP_3_KEY];
	var save_file = FileAccess.open(SAVE_GAME_FOLDER + SAVE_FILE_NAME, FileAccess.READ);
	var extracted_times: Array[int] = [];
	
	for expected_key in expected_keys:
		# Aborts process, when end of file is reached too early
		if save_file.eof_reached():
			print("ERROR: EOF reached");
			return null;
		
		# Gets the next line and splits it on the separator
		var line = save_file.get_line().strip_edges();
		var line_parts = line.split(KEY_VALUE_SEPARATOR);
		
		# Aborts process, when line is not a valid key-value pair
		if line_parts.size() != 2:
			print("ERROR: Invalid key value pair: size is " + str(line_parts.size()));
			return null;
		
		# Extract the key-value pair
		var key: String = line_parts[0];
		var value: int = line_parts[1].to_int();
		
		# Aborts process, when key is not the expected key or the value is not a valid int
		if (key != expected_key or str(value) != line_parts[1]):
			print("ERROR: Invalid key value pair: type error");
			return null;
		
		# Add the time to the array of extracted times
		extracted_times.append(value);
	
	# Aborts process, when the array does not include the time for all three laps
	if (extracted_times.size() != 3):
		print("ERROR: Invalid amount of loaded lap times: size is " + str(extracted_times.size()));
		return null;
	
	if save_file.eof_reached():
		print("ERROR: EOF reached");
		return null;
	
	var extracted_checkpoint_times: Array = [];
	
	while not save_file.eof_reached():
		var line: String = save_file.get_line().strip_edges();
		
		if line.length() == 0:
			continue;
		
		if not line.begins_with(CHECKPOINT_KEY_PREFIX):
			print("ERROR: Invalid checkpoint time key");
			return null;
		
		line = line.substr(CHECKPOINT_KEY_PREFIX.length() + MAX_INDEX_LENGTH_CHECKPOINTS + KEY_VALUE_SEPARATOR.length());
		var line_parts = line.split(CSV_SEPARATOR);
		
		if line_parts.size() != 3:
			print("ERROR: Invalid amount of lap times " + str(line_parts.size()) + ". Expected: a lap count of 3");
			return null;
		
		extracted_checkpoint_times.append([int(line_parts[0]), int(line_parts[1]), int(line_parts[2])]);
	
	return Highscore.new(extracted_times.get(0), extracted_times.get(1), extracted_times.get(2), extracted_checkpoint_times);

func load_player_ghost():
	if not FileAccess.file_exists(SAVE_GAME_FOLDER + SAVED_PLAYER_GHOST_FILE_NAME):
		print("ERROR: Failed to load Player Ghost from file");
		return null;
	
	var ghost_file = FileAccess.open(SAVE_GAME_FOLDER + SAVED_PLAYER_GHOST_FILE_NAME, FileAccess.READ);
	var extracted_inputs: Array[InputCapture] = [];
	
	while not ghost_file.eof_reached():
		var line = ghost_file.get_line().strip_edges();
		var line_parts = line.split(CSV_SEPARATOR);
		
		if line.length() == 0:
			continue;
		
		if line_parts.size() != 6:
			print("ERROR: Invalid CSV line length of " + str(line_parts.size()) + ". Expected: a length of 6");
			return null;
		
		var input_capture := InputCapture.new(float(line_parts[0]), Global.from_binary_str(line_parts[1]), float(line_parts[2]),\
			Global.from_binary_str(line_parts[3]), float(line_parts[4]), Global.from_binary_str(line_parts[5]));
		
		extracted_inputs.append(input_capture);
	
	return extracted_inputs;

func change_scene_with_transition(pathToScene):
	var transitionLayer = get_tree().root.get_node("MainScene").get_node("TransitionLayer")
	if (transitionLayer != null):
		transitionLayer.start_transition_and_change_scene(pathToScene)
	else:
		change_scene(pathToScene)

func change_scene(pathToScene):
	var mainScene = get_tree().root.get_node("MainScene").get_node("MainDisplay")
	var transitionLayer = get_tree().root.get_node("MainScene").get_node("TransitionLayer")
	
	if (mainScene != null):
		var removable = mainScene.get_child(0)
		removable.queue_free()
		
		var scene_to_instantiate = load(pathToScene)
		var instantiated_scene = scene_to_instantiate.instantiate()
		
		mainScene.add_child(instantiated_scene)

static func to_binary_str(boolean_value: bool) -> String:
	return "0" if boolean_value == false else "1";

static func from_binary_str(string_value: String) -> bool:
	match (string_value):
		"0":
			return false;
		"1":
			return true;
		_:
			push_error("Invalid boolean: expected '0' or '1' - Fallback to: false")
			return false;
