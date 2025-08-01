extends Node2D

@onready var player_camera: Camera2D = $PlayerCamera;
@onready var player: Car = $Player;

func _process(delta: float) -> void:
	player_camera.global_position = player.global_position;
