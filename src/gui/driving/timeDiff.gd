class_name TimeDiff;
extends CenterContainer;

@onready var triangle: TextureRect = %DiffTriangle;
@onready var time: Label = %DiffTime;

var up_texture: Texture2D;
var neutral_texture: Texture2D;
var down_texture: Texture2D;

func _ready() -> void:
	self.visible = false;
	up_texture = load("res://src/gui/driving/assets/graphics/triangle_up.svg");
	neutral_texture = load("res://src/gui/driving/assets/graphics/triangle_neutral.svg");
	down_texture = load("res://src/gui/driving/assets/graphics/triangle_down.svg");

func update(new_time: int):
	self.visible = true;
	time.text = format_four_digits(new_time);
	
	if (new_time > 0):
		triangle.texture = up_texture;
	elif (new_time < 0):
		triangle.texture = down_texture;
	else:
		triangle.texture = neutral_texture;

func hide_ui():
	self.visible = false;

func format_four_digits(ms: int) -> String:
	if ms >= 999_900:
		return "9999"; # limit that can be displayed

	var seconds = abs(ms / 1000.0);
	var result = "%0.3f" % seconds;
	result = result.substr(0, 5);
		
	return result;
