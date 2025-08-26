class_name FinishLine;
extends TargetArea;

# @Override
func on_player_entered() -> void:
	player_crossed.emit(self);
