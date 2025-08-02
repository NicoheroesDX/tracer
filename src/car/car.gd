class_name Car;
extends CharacterBody2D;

signal crossed_finish;

var map: TileMap;

var current_speed: float = 0.0;

const HANDLING: float = 60;
const ACCELERATION: float = 30;
const DECELERATION: float = 10;
const RESITANCE: float = 0.90;

var steering_effect: float = 1.0;
var speed_effect: float = 1.0;

func _physics_process(delta: float) -> void:
	apply_effects_for_road_type(get_current_road_type());
	
	var input_direction: float = Input.get_axis("car_steer_left", "car_steer_right");
	var turn_power: float = HANDLING / 200000;
	
	if abs(velocity.x) > abs(velocity.y):
		current_speed = abs(velocity.x)
	else:
		current_speed = abs(velocity.y)
	
	rotation += turn_power * current_speed * input_direction * steering_effect;
	
	var direction = Vector2.UP.rotated(rotation);
	
	if Input.is_action_pressed("car_accelerate"):
		velocity += direction * ACCELERATION * speed_effect;
	if Input.is_action_pressed("car_reverse"):
		velocity -= direction * DECELERATION * speed_effect;
	
	velocity *= RESITANCE;
	move_and_slide();

func connect_to_map(tile_map: TileMap) -> void:
	map = tile_map;

func get_current_road_type() -> String:
	if (map != null):
		var current_tile = map.local_to_map(map.to_local(global_position))
		var tile_data = map.get_cell_tile_data(-1, current_tile)
		
		if tile_data:
			if tile_data.has_custom_data("RoadType"):
				return tile_data.get_custom_data("RoadType")
	return "";

func apply_effects(new_speed_effect: float, new_steering_effect: float):
	speed_effect = new_speed_effect;
	steering_effect = new_steering_effect;

func apply_default_effects():
	apply_effects(1.0, 1.0);

func apply_effects_for_road_type(road_type: String):	
	match road_type:
		"grass":
			apply_effects(0.3, 0.8);
		"asphalt", "finish", _:
			apply_default_effects();
