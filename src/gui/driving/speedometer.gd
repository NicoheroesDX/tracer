class_name Speedometer;
extends CenterContainer;

@onready var pointer: Node2D = $Pointer;
@onready var speed_label: Label = %Speed;

func update_current_speed(new_speed: float):
	speed_label.text = str(int(round(new_speed)));
	pointer.rotation = new_speed * 0.03 + 0.25;
