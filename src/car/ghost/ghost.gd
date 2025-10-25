class_name Ghost;
extends CharacterBody2D;

var map: TileMap;

var current_speed: float = 0.0;

var is_in_boost_area: bool = false;
var is_allowed_to_move: bool = false;

const BOOST_MULTIPLIER = 1.5;

const HANDLING: float = 70;
const ACCELERATION: float = 30;
const DECELERATION: float = 20;
const RESITANCE: float = 0.91;

var steering_effect: float = 1.0;
var speed_effect: float = 1.0;

@onready var ghost_controller: GhostController = $GhostController;
@onready var sprite: Sprite2D = $Sprite2D;

var default_sprite_modulation = Color(1, 1, 1, 0.4);

func _ready() -> void:
	sprite.modulate = Color.TRANSPARENT;

func _physics_process(delta: float) -> void:
	if ghost_controller.is_active:
		sprite.modulate = default_sprite_modulation;
		var current_input: InputCapture = ghost_controller.get_next_input();
		
		apply_effects_for_road_type(get_current_road_type());
		
		var input_direction: float = current_input.input_axis;
		var turn_power: float = HANDLING / 200000;
		
		if not is_allowed_to_move:
			input_direction = 0.0;
		
		if abs(velocity.x) > abs(velocity.y):
			current_speed = abs(velocity.x)
		else:
			current_speed = abs(velocity.y)
		
		rotation += turn_power * current_speed * input_direction * steering_effect;
		
		var direction = Vector2.UP.rotated(rotation);
		
		var boost = 1.0;
		
		if current_input.is_boosting:
			boost = BOOST_MULTIPLIER;
			
		if is_allowed_to_move and current_input.is_accelerating:
			velocity += direction * (ACCELERATION * current_input.acceleration_strength) * speed_effect * boost;
		if is_allowed_to_move and current_input.is_decelerating:
			velocity -= direction * (DECELERATION * current_input.deceleration_strength) * speed_effect;
		
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

func set_inputs(inputs: Array[InputCapture]):
	ghost_controller.input_capture_history = inputs;

func set_style(color: Color):
	default_sprite_modulation = color;

func start():
	self.is_allowed_to_move = true;
	ghost_controller.is_active = true;
