class_name TrailPen;
extends Node2D;

var trail_first: Trail;
var trail_second: Trail;
var trail_boost_area: BoostArea;

func connect_to_world(t1: Trail, t2: Trail, boost: BoostArea):
	trail_first = t1;
	trail_second = t2;
	trail_boost_area = boost

func _process(delta: float) -> void:
	if !trail_boost_area.is_active and Input.is_action_just_pressed("debug_1"):
		print("DEBUG: Added booster");
		trail_boost_area.generate_booster(trail_first, trail_second);
	elif trail_boost_area.is_active and Input.is_action_just_pressed("debug_1"):
		print("DEBUG: Removed booster");
		trail_boost_area.is_active = false;
		trail_boost_area.visuals.polygon.clear();
		trail_boost_area.collision.polygon = PackedVector2Array()
	elif Input.is_action_just_pressed("debug_2"):
		print("DEBUG: Cleared Trails");
		trail_first.curve.clear_points();
		trail_second.curve.clear_points();
		trail_first.visuals.clear_points()
		trail_second.visuals.clear_points();
	elif Input.is_action_just_pressed("debug_3"):
		print("DEBUG: Shortened trail");
		trail_first.curve.remove_point(trail_first.curve.get_point_count() - 1);
		trail_second.curve.remove_point(trail_second.curve.get_point_count() - 1);
		trail_first.visuals.points = trail_first.curve.get_baked_points();
		trail_second.visuals.points = trail_second.curve.get_baked_points();


func _unhandled_input(event: InputEvent) -> void:
	var viewport := get_viewport()
	var camera := viewport.get_camera_2d()
	
	if (trail_first != null and trail_second != null and trail_boost_area != null and event is InputEventMouseButton):
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			trail_first.add_point(camera.get_global_mouse_position());
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			trail_second.add_point(camera.get_global_mouse_position());
