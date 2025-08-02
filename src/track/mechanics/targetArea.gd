class_name TargetArea;
extends Area2D;

signal player_crossed;

# @Abstract
func on_player_entered() -> void:
	pass;

func _on_body_entered(body: Node2D) -> void:
	if (body.get_groups().has("player")):
		on_player_entered();
