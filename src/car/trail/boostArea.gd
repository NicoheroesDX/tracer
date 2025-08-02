class_name BoostArea;
extends Area2D;

var is_active: bool = false;

@onready var collision: CollisionPolygon2D = $Collision;
@onready var visuals: Polygon2D = $Visuals;

func generate_booster(first_trail: Trail, second_trail: Trail):
	var poly_points = [];
	var first_trail_points = first_trail.points;
	var second_trail_points_reversed = second_trail.points.duplicate();
	second_trail_points_reversed.reverse();
	
	for point in first_trail_points:
		poly_points.append(point);
		
	for point in second_trail_points_reversed:
		poly_points.append(point);
	
	visuals.polygon = poly_points;
	collision.polygon = poly_points;
	
	is_active = true;
