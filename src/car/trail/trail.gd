class_name Trail;
extends Line2D;

@onready var curve := Curve2D.new();
var car: Car

var is_emitting: bool = false;

const MAX_LENGTH: int = 2000;

func attach_to_car(attached_car: Car):
	car = attached_car;

func _process(delta: float) -> void:
	if (car != null and is_emitting):
		curve.add_point(car.global_position);
		
		if (curve.get_baked_points().size() > MAX_LENGTH):
			curve.remove_point(0);
		
		points = curve.get_baked_points();
