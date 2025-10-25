class_name Car;
extends CharacterBody2D;

signal crossed_finish;
signal destroyed;
signal destroyed_animation_ended;

@onready var death_particles: GPUParticles2D = $DeathParticles;
@onready var boost_particles: GPUParticles2D = $BoostParticles;
@onready var animation: AnimationPlayer = $AnimationPlayer;

@onready var engine_sound: AudioStreamPlayer2D = $EngineSound;
@onready var trail_decay_sound: AudioStreamPlayer2D = $TrailDecaySound;
@onready var boost_sound: AudioStreamPlayer2D = $BoostSound;

@onready var ghost_recorder: GhostRecorder = $GhostRecorder;

var map: TileMap;

var current_speed: float = 0.0;

var is_in_boost_area: bool = false;
var is_allowed_to_move: bool = false;
var is_destroyed: bool = false;

var is_preloading_particles = false;

const BOOST_MULTIPLIER = 1.5;

const HANDLING: float = 70;
const ACCELERATION: float = 30;
const DECELERATION: float = 20;
const RESITANCE: float = 0.91;

var steering_effect: float = 1.0;
var speed_effect: float = 1.0;

var is_virtually_accelerated: bool = false;
var is_virtually_decelerated: bool = false;
var virtual_input_direction: float = 0.0;

func _ready():
	preload_particles();

func _process(delta: float) -> void:
	if (is_preloading_particles):
		is_preloading_particles = false;
		death_particles.emitting = false;
		boost_particles.emitting = false;

func _physics_process(delta: float) -> void:
	apply_effects_for_road_type(get_current_road_type());
	
	var input_direction: float = get_steering_input();
	var turn_power: float = HANDLING / 200000;
	
	if is_destroyed:
		turn_off_engine_sounds();
	
	if not is_allowed_to_move:
		input_direction = 0.0;
	
	if abs(velocity.x) > abs(velocity.y):
		current_speed = abs(velocity.x)
	else:
		current_speed = abs(velocity.y)
	
	rotation += turn_power * current_speed * input_direction * steering_effect;
	
	var direction = Vector2.UP.rotated(rotation);
	
	var boost = 1.0;
	
	if is_in_boost_area:
		if not boost_sound.playing:
			boost_sound.play();
		boost_particles.emitting = true;
		boost = BOOST_MULTIPLIER;
	else:
		boost_sound.stop();
		boost_particles.emitting = false;
	
	var acceleration_strength = Input.get_action_strength("car_accelerate")
	var deceleration_strength = Input.get_action_strength("car_reverse")
	
	if (is_virtually_accelerated):
		acceleration_strength = 1.0;
	
	if (is_virtually_decelerated):
		deceleration_strength = 1.0;
	
	if is_allowed_to_move and acceleration_strength > 0.0:
		velocity += direction * (ACCELERATION * acceleration_strength) * speed_effect * boost;
	if is_allowed_to_move and deceleration_strength > 0.0:
		velocity -= direction * (DECELERATION * deceleration_strength) * speed_effect;
	
	engine_sound.pitch_scale = 0.5 + (velocity.length() * 0.003)
	engine_sound.volume_db = min(-12 + (velocity.length() * 0.02), 0.0)
	
	if is_allowed_to_move and ghost_recorder != null:
		ghost_recorder.capture_input(input_direction, acceleration_strength > 0.0,\
			acceleration_strength, deceleration_strength > 0.0,\
			deceleration_strength, is_in_boost_area);
	
	velocity *= RESITANCE;
	move_and_slide();

func connect_to_map(tile_map: TileMap) -> void:
	map = tile_map;

func get_steering_input() -> float:
	var input_value: float = Input.get_axis("car_steer_left", "car_steer_right");
	var virtual_input_value: float = virtual_input_direction;
	var gyro_value: float = clamp(WebOnly.get_device_rotation() / 30.0, -1.0, 1.0);
	
	var combined_value = input_value + virtual_input_value + gyro_value;
	
	if (combined_value >= 0):
		return min(1.0, combined_value);
	else:
		return max(-1.0, combined_value);

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

func turn_off_engine_sounds():
	engine_sound.stop();

func get_display_speed():
	return (velocity.length()*0.2)+0.3

func destroy():
	if not is_destroyed:
		trail_decay_sound.play();
		death_particles.emitting = true;
		is_destroyed = true;
		destroyed.emit();
		animation.play("death");

func apply_effects_for_road_type(road_type: String):	
	match road_type:
		"grass":
			apply_effects(0.3, 0.8);
		"asphalt", "finish", _:
			apply_default_effects();

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if (anim_name == "death"):
		destroyed_animation_ended.emit()

func preload_particles():
	is_preloading_particles = true;
	death_particles.emitting = true;
	boost_particles.emitting = true;
