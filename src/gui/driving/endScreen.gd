class_name EndScreen;
extends CenterContainer;

@onready var end_title: Label = $EndVBox/EndTitle;

var victory_mood: bool = true;

func toggle_mood(is_victorious):
	victory_mood = is_victorious;

func _process(delta: float) -> void:
	if (victory_mood):
		end_title.modulate = Color.WHITE;
		end_title.text = "Victory!"
	else:
		end_title.modulate = Color.RED;
		end_title.text = "Game Over!"

func _on_retry_button_pressed() -> void:
	Global.change_scene_with_transition("res://src/track/Track.tscn")

func _on_menu_button_pressed() -> void:
	Global.change_scene_with_transition("res://src/gui/menu/MainMenu.tscn")
