extends Node2D

@onready var player_camera: Camera2D = $PlayerCamera;
@onready var player: Car = $Player;
@onready var tile_map: TileMap = $TileMap;

func _ready() -> void:
	player.connect_to_map(tile_map);

func _process(delta: float) -> void:
	update_camera_position();

func update_camera_position():
	player_camera.global_position = player.global_position;
