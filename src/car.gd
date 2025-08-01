extends CharacterBody2D;

class_name Car;

var current_speed: float = 0.0;

const HANDLING: float = 60;
const ACCELERATION: float = 30;
const DECELERATION: float = 10;
const RESITANCE: float = 0.90;

func _physics_process(delta: float) -> void:
	var input_direction: float = Input.get_axis("car_steer_left", "car_steer_right");
	const turn_power: float = HANDLING / 200000;
	
	if abs(velocity.x) > abs(velocity.y):
		current_speed = abs(velocity.x)
	else:
		current_speed = abs(velocity.y)
	
	rotation += turn_power * current_speed * input_direction;
	
	var direction = Vector2.UP.rotated(rotation);
	
	if Input.is_action_pressed("car_accelerate"):
		velocity += direction * ACCELERATION;
	if Input.is_action_pressed("car_reverse"):
		velocity -= direction * DECELERATION;
	
	velocity *= RESITANCE;
	move_and_slide();
