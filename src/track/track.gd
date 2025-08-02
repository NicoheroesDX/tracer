extends Node2D

@onready var player_camera: Camera2D = $PlayerCamera;
@onready var player: Car = $Player;
@onready var tile_map: TileMap = $TileMap;
@onready var checkpoint_list: Node = $CheckPoints;
@onready var finish_line: FinishLine = %FinishLine;

@onready var trail_first: Trail = Trail.new();
@onready var trail_second: Trail = Trail.new();

var current_lap: int = 1;

var checkpoint_amount = 0;
var checkpoints_crossed = 0;

func _ready() -> void:
	player.connect_to_map(tile_map);
	finish_line.player_crossed.connect(on_player_crossed_finish);
	
	trail_first.default_color = Color.AQUA;
	trail_second.default_color = Color.HOT_PINK;
	
	add_child(trail_first);
	add_child(trail_second);
	
	trail_first.attach_to_car(player)
	trail_first.is_emitting = true;
	
	trail_second.attach_to_car(player)
	trail_second.is_emitting = false;
	
	for checkpoint in checkpoint_list.get_children():
		checkpoint_amount += 1;
		checkpoint.player_crossed.connect(on_player_crossed_checkpoint);

func _process(delta: float) -> void:
	update_camera_position();

func reset_all_checkpoints():
	checkpoints_crossed = 0;
	for checkpoint in checkpoint_list.get_children():
		checkpoint.reset();

func update_camera_position():
	player_camera.global_position = player.global_position;

func on_player_crossed_checkpoint():
	checkpoints_crossed += 1;

func on_player_crossed_finish():
	if (checkpoint_amount == checkpoints_crossed):
		on_player_lap_finished();

func on_player_lap_finished():
	match (current_lap):
		1:
			reset_all_checkpoints();
			trail_first.is_emitting = false;
			trail_second.is_emitting = true;
		2:
			reset_all_checkpoints();
			trail_second.is_emitting = false;
		3:
			on_player_race_finished();
	
	current_lap += 1;
	print("You are now on Lap: " + str(current_lap));

func on_player_race_finished():
	print("You won!");
