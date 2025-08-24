class_name BoostSegment;
extends Area2D;

var related_boost_area: BoostArea;

var first_trail_points: PackedVector2Array = [];
var second_trail_points: PackedVector2Array = [];

var visuals: Polygon2D;
var collision: CollisionPolygon2D;

var area_color: Color = Color(0.729412, 0.572549, 1, 0.784314);

func _init() -> void:
	visuals = Polygon2D.new();
	visuals.color = Color.TRANSPARENT;
	collision = CollisionPolygon2D.new();

func visualize():
	visuals.color = area_color;

func attach_to_boost_area(area: BoostArea):
	related_boost_area = area;

func generate_booster():
	var poly_points = [];
	
	for point in first_trail_points:
		poly_points.append(point);
	
	for i in range(second_trail_points.size() - 1, -1, -1):
		poly_points.append(second_trail_points[i]);
	
	visuals.polygon = poly_points;
	collision.polygon = poly_points;
	
	add_child(visuals);
	add_child(collision);
