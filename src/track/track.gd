extends Node2D

@onready var player_camera: Camera2D = $PlayerCamera;
@onready var player: Car = $Player;
@onready var tile_map: TileMap = $TileMap;
@onready var checkpoint_list: Node = $CheckPoints;
@onready var finish_line: FinishLine = %FinishLine;

@onready var trail_first: Trail = $TrailFirst;
@onready var trail_second: Trail = $TrailSecond;
@onready var trail_boost_area: BoostArea = $BoostArea;

@onready var gui: DrivingInterface = $DrivingInterface;

var is_race_started: bool = false
var is_race_over: bool = false

var current_lap: int = 1;
var current_lap_start_msec: int = -1;
var lap_times: Array[int] = [0, 0, 0]

var checkpoint_amount = 0;
var checkpoints_crossed = 0;

func _ready() -> void:
	player.connect_to_map(tile_map);
	finish_line.player_crossed.connect(on_player_crossed_finish);
	
	trail_first.set_color(Color.AQUA);
	trail_second.set_color(Color.HOT_PINK);
	
	trail_first.attach_to_car(player)
	trail_second.attach_to_car(player)
	
	for checkpoint in checkpoint_list.get_children():
		checkpoint_amount += 1;
		checkpoint.player_crossed.connect(on_player_crossed_checkpoint);
	
	Global.transition_complete.connect(start_race);

func _process(delta: float) -> void:
	update_camera_position();
	update_lap_time();

func _physics_process(delta: float) -> void:
	player.is_in_boost_area = false;
	
	if trail_boost_area.is_active:
		for body in trail_boost_area.get_overlapping_bodies():
			if (body.get_groups().has("player")):
				player.is_in_boost_area = true;

func update_lap_time() -> void:
	if is_race_started and not is_race_over:
		var current_time_msec = Time.get_ticks_msec();
		set_current_lap_time(current_time_msec - current_lap_start_msec);
		gui.update_race_time(DrivingInterface.format_time(get_race_time()));
		gui.update_time(current_lap, DrivingInterface.format_time(get_current_lap_time()));

func start_race() -> void:
	is_race_started = true;
	current_lap_start_msec = Time.get_ticks_msec();

func reset_all_checkpoints():
	checkpoints_crossed = 0;
	for checkpoint in checkpoint_list.get_children():
		checkpoint.reset();

func update_camera_position():
	player_camera.global_position = player.global_position;

func get_race_time() -> int:
	return lap_times[0] + lap_times[1] + lap_times[2];

func get_current_lap_time():
	return lap_times[current_lap-1];

func set_current_lap_time(msec: int):
	lap_times[current_lap-1] = msec;

func on_player_crossed_checkpoint():
	checkpoints_crossed += 1;

func on_player_crossed_finish():
	if (checkpoint_amount == checkpoints_crossed):
		on_player_lap_finished();

func on_player_lap_finished():
	gui.freeze_time(current_lap, DrivingInterface.format_time(get_current_lap_time()));
	
	match (current_lap):
		1:
			reset_all_checkpoints();
			gui.display_time(2);
		2:
			reset_all_checkpoints();
			trail_first.remove_collision();
			trail_second.remove_collision();
			trail_boost_area.generate_booster(trail_first, trail_second);
			gui.display_time(3);
		3:
			on_player_race_finished();

	if (current_lap < 3):
		current_lap_start_msec = Time.get_ticks_msec();
		current_lap += 1;
		print("You are now on Lap: " + str(current_lap));

func on_player_race_finished():
	is_race_over = true;
	Global.change_scene_with_transition("res://src/gui/menu/MainMenu.tscn")

func _on_charge_zone_body_entered(body: Node2D) -> void:
	if (body.get_groups().has("player")):
		match (current_lap):
			1:
				trail_first.is_emitting = false;
			2:
				trail_second.is_emitting = false;

func _on_charge_zone_body_exited(body: Node2D) -> void:
	if (body.get_groups().has("player")):
		match (current_lap):
			1:
				trail_first.is_emitting = true;
			2:
				trail_second.is_emitting = true;
