extends Node

signal transition_complete;

const SAVE_GAME_FOLDER = "user://";
const SAVE_FILE_NAME = "tracer.data";
const LAP_1_KEY = "highscore_lap_1";
const LAP_2_KEY = "highscore_lap_2";
const LAP_3_KEY = "highscore_lap_3";
const KEY_VALUE_SEPARATOR = "=";

var current_highscore: Highscore;

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
	save_file.close();

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
	
	return Highscore.new(extracted_times.get(0), extracted_times.get(1), extracted_times.get(2));

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
