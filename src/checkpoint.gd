class_name Checkpoint;
extends TargetArea;

var is_checked: bool = false;

func reset() -> void:
	is_checked = false;

# @Override
func on_player_entered() -> void:
	if not is_checked:
		is_checked = true;
		player_crossed.emit();
