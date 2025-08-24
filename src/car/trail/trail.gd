class_name Trail;
extends Node2D;

@onready var curve := Curve2D.new();
var car: Car;
var boost_area: BoostArea;

var is_collidable: bool = true;
var is_emitting: bool = false;
var last_point = null;

var last_time: int = 0;

@onready var visuals: Line2D = $Visuals;
@onready var collision: Area2D = $Collision;
@onready var animation: AnimationPlayer = $AnimationPlayer;
@onready var trail_sound: AudioStreamPlayer2D = $TrailSound;

const MAX_LENGTH: int = 200000000;
const THICKNESS: float = 12.0;

var is_current_segment_complete: bool = false;
var unassigned_booster_points: PackedVector2Array = [];

func set_pitch(pitch_value: float):
	trail_sound.pitch_scale = pitch_value;

func attach_to_car(attached_car: Car):
	car = attached_car;

func attach_to_boost_area(attached_area: BoostArea):
	boost_area = attached_area;

func set_color(color: Color):
	if (visuals != null):
		visuals.default_color = color;

func _process(delta) -> void:
	var current_time = Time.get_ticks_msec();
	
	if is_emitting and not trail_sound.playing:
		trail_sound.play();
	elif not is_emitting:
		trail_sound.stop();

	if (((current_time - last_time) > 80) and car != null and is_emitting):
		last_time = current_time;
		add_point(car.global_position);

func clear_and_keep_last_entry(array: PackedVector2Array):
	return array.slice(array.size() - 1, array.size())

func add_point(point_position: Vector2):
	curve.add_point(point_position);
	unassigned_booster_points.append(point_position);
	
	if (is_current_segment_complete):
		push_points_to_boost_area();
	if (curve.get_baked_points().size() > MAX_LENGTH):
		curve.remove_point(0);

	visuals.points = curve.get_baked_points();
	update_trail(point_position);

func push_points_to_boost_area():
	boost_area.push_points(unassigned_booster_points.duplicate());
	unassigned_booster_points = clear_and_keep_last_entry(unassigned_booster_points);
	is_current_segment_complete = false;

func remove_collision():
	is_collidable = false;

func update_trail(new_point: Vector2):
	if last_point == null:
		last_point = car.global_position;
	
	var local_new = to_local(new_point)
	var distance = last_point.distance_to(local_new)

	if distance >= 10.0:
		var dir = (local_new - last_point).normalized()
		var normal = Vector2(-dir.y, dir.x) * (THICKNESS / 2.0)
		
		var p1 = last_point + normal
		var p2 = local_new + normal
		var p3 = local_new - normal
		var p4 = last_point - normal
		
		var polygon = CollisionPolygon2D.new()
		polygon.polygon = PackedVector2Array([p1, p2, p3, p4])
		polygon.disabled = true
		collision.add_child(polygon)

		var timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = 1.0
		add_child(timer)
		timer.start()

		timer.timeout.connect(func():
			if is_instance_valid(polygon):
				polygon.disabled = false
			timer.queue_free()
		)
		
		last_point = local_new

func _on_collision_body_entered(body: Node2D) -> void:
	if is_collidable:
		if (body.get_groups().has("player")):
			car.destroy();

func trail_fade_out():
	animation.play("fadeOut");
