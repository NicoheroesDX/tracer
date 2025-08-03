class_name Trail;
extends Node2D;

@onready var curve := Curve2D.new();
var car: Car;

var is_collidable: bool = true;
var is_emitting: bool = false;
var last_point = null;

@onready var visuals: Line2D = $Visuals;
@onready var collision: Area2D = $Collision;
@onready var animation: AnimationPlayer = $AnimationPlayer;
@onready var timer: Timer = $PlacementTimer;

const MAX_LENGTH: int = 5000;
const THICKNESS: float = 12.0;

func attach_to_car(attached_car: Car):
	car = attached_car;

func set_color(color: Color):
	if (visuals != null):
		visuals.default_color = color;

func place_trail_spot() -> void:
	if (car != null and is_emitting):
		curve.add_point(car.global_position);
		
		if (curve.get_baked_points().size() > MAX_LENGTH):
			curve.remove_point(0);
		
		visuals.points = curve.get_baked_points();
		update_trail(car.global_position);

func remove_collision():
	is_collidable = false;
	for collision_shape in collision.get_children():
		collision_shape.queue_free()

func update_trail(new_point: Vector2):
	if last_point == null:
		last_point = car.global_position;
	
	var local_new = to_local(new_point)
	var distance = last_point.distance_to(local_new)

	if distance >= 10.0:
		visuals.add_point(local_new)
		
		var dir = (local_new - last_point).normalized()
		var normal = Vector2(-dir.y, dir.x) * (THICKNESS / 2.0)
		
		var p1 = last_point + normal
		var p2 = local_new + normal
		var p3 = local_new - normal
		var p4 = last_point - normal
		
		var polygon = CollisionPolygon2D.new()
		polygon.polygon = PackedVector2Array([p1, p2, p3, p4])
		polygon.disabled = true  # Disable physics for now
		collision.add_child(polygon)

		# Create a timer to enable it later
		var timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = 1.0  # Delay in seconds
		add_child(timer)
		timer.start()

		timer.timeout.connect(func():
			if is_instance_valid(polygon):
				polygon.disabled = false
			timer.queue_free()
		)
		
		last_point = local_new

func _on_collision_body_entered(body: Node2D) -> void:
	if (body.get_groups().has("player")):
		car.destroy();

func trail_fade_out():
	animation.play("fadeOut");

func _on_placement_timer_timeout() -> void:
	place_trail_spot();
