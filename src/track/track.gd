extends Node2D

@onready var player_camera: Camera2D = $PlayerCamera;
@onready var player: Car = $Player;

@onready var ghost: Ghost = $Ghost;

@onready var tile_map: TileMap = $TileMap;
@onready var checkpoint_list: Node = $CheckPoints;
@onready var finish_line: FinishLine = %FinishLine;

@onready var trail_first: Trail = $TrailFirst;
@onready var trail_second: Trail = $TrailSecond;
@onready var trail_boost_area: BoostArea = $BoostArea;

@onready var gui: DrivingInterface = $DrivingInterface;

@onready var countdown_delay: Timer = $CountdownTimer;
@onready var slowmo_timer: Timer = $SlowmoTimer;

@onready var barrier_front: Area2D = $FrontDeathBarrier;
@onready var barrier_back: Area2D = $BackDeathBarrier;

@onready var trail_pen: TrailPen = $TrailPen;

var is_race_started: bool = false;
var is_race_over: bool = false;

var is_race_restarting: bool = false;

var current_lap: int = 1;
var current_lap_start_msec: int = -1;
var lap_times: Array[int] = [0, 0, 0]

var trail_first_draw_complete: bool = false;
var trail_second_draw_complete: bool = false;

var checkpoint_amount = 0;
var checkpoints_crossed = 0;

func _ready() -> void:
	Global.toggle_music(true);
	player.connect_to_map(tile_map);
	ghost.connect_to_map(tile_map);
	ghost.set_inputs(Global.current_player_ghost_inputs);
	trail_pen.connect_to_world(trail_first, trail_second, trail_boost_area);
	
	player.destroyed.connect(on_player_destroyed);
	player.destroyed_animation_ended.connect(on_player_destroyed_animation_ended);
	finish_line.player_crossed.connect(on_player_crossed_finish);
	
	trail_first.set_pitch(0.5);
	trail_second.set_pitch(0.7);
	
	trail_first.set_color(Color.AQUA);
	trail_second.set_color(Color.HOT_PINK);
	
	trail_first.attach_to_car(player)
	trail_second.attach_to_car(player)
	
	trail_first.attach_to_boost_area(trail_boost_area);
	trail_second.attach_to_boost_area(trail_boost_area);
	
	toggle_barrier_active(barrier_front, false);
	toggle_barrier_active(barrier_back, true);
	
	for checkpoint in checkpoint_list.get_children():
		checkpoint_amount += 1;
		checkpoint.player_crossed.connect(on_player_crossed_checkpoint);
	
	Global.transition_complete.connect(start_countdown);

func _process(delta: float) -> void:
	if is_race_started and not is_race_over and not is_race_restarting and Input.is_action_just_pressed("race_restart"):
		is_race_restarting = true;
		Global.change_scene_with_transition("res://src/track/Track.tscn");
	
	update_camera_position();
	update_lap_time();
	update_speedometer();

func _physics_process(delta: float) -> void:	
	if (is_race_started and not is_race_over):
		player.is_allowed_to_move = true;
		if not Global.current_player_ghost_inputs.is_empty():
			ghost.start();
	else:
		player.is_allowed_to_move = false;
	
	player.is_in_boost_area = false;
	ghost.is_in_boost_area = false;
	
	if (checkpoints_crossed < checkpoint_amount):
		toggle_barrier_active(barrier_front, false);
		toggle_barrier_active(barrier_back, true);
	else:
		toggle_barrier_active(barrier_front, true);
		toggle_barrier_active(barrier_back, false);
	
	if trail_boost_area.is_active:
		for segment in trail_boost_area.boost_segments:
			for body in segment.get_overlapping_bodies():
				if (body.get_groups().has("player")):
					player.is_in_boost_area = true;

func apply_slowo_effect():
	gui.boost_label.show();
	Engine.time_scale = 0.01;
	slowmo_timer.start();
	gui.toggle_side_ui(false);
	gui.animation.speed_scale = 100;
	gui.start_countdown();

func update_lap_time() -> void:
	if is_race_started and not is_race_over:
		var current_time_msec = Time.get_ticks_msec();
		set_current_lap_time(current_time_msec - current_lap_start_msec);
		gui.update_race_time(DrivingInterface.format_time(get_race_time()));
		gui.update_time(current_lap, DrivingInterface.format_time(get_current_lap_time()));

func update_difference_to_highscore():
	if (Global.current_highscore != null):
		match(current_lap):
			1:
				gui.update_time_difference(1, Global.current_highscore.lap_1_time - get_current_lap_time())
			2:
				gui.update_time_difference(2, Global.current_highscore.lap_2_time - get_current_lap_time())
			3:
				gui.update_time_difference(3, Global.current_highscore.lap_3_time - get_current_lap_time())

func update_speedometer():
	gui.speedometer.update_current_speed(player.get_display_speed());

func start_countdown():
	countdown_delay.start();
	gui.start_countdown();

func start_race() -> void:
	is_race_started = true;
	current_lap_start_msec = Time.get_ticks_msec();

func reset_all_checkpoints():
	checkpoints_crossed = 0;
	for checkpoint in checkpoint_list.get_children():
		checkpoint.reset();

func toggle_barrier_active(barrier: Area2D, is_now_active: bool):
	barrier.visible = is_now_active;
	barrier.monitoring = is_now_active;

func update_camera_position():
	player_camera.global_position = player.global_position;

func get_race_time() -> int:
	return lap_times[0] + lap_times[1] + lap_times[2];

func get_current_lap_time():
	return lap_times[current_lap-1];

func set_current_lap_time(msec: int):
	lap_times[current_lap-1] = msec;

func on_player_crossed_checkpoint():
	checkpoints_crossed += 1;
	match (current_lap):
		1:
			trail_first.is_current_segment_complete = true;
		2:
			trail_second.is_current_segment_complete = true;

func on_player_crossed_finish():
	if (checkpoint_amount == checkpoints_crossed):
		on_player_lap_finished();

func on_player_lap_finished():
	gui.freeze_time(current_lap, DrivingInterface.format_time(get_current_lap_time()));
	match (current_lap):
		1:
			trail_first.push_points_to_boost_area();
			update_difference_to_highscore();
			reset_all_checkpoints();
			gui.display_time(2);
			trail_boost_area.is_first_lap = false;
		2:
			trail_second.push_points_to_boost_area();
			update_difference_to_highscore();
			reset_all_checkpoints();
			trail_first.remove_collision();
			trail_second.remove_collision();
			trail_boost_area.activate();
			gui.display_time(3);
		3:
			update_difference_to_highscore();
			on_player_race_finished();

	if (current_lap < 3):
		current_lap_start_msec = Time.get_ticks_msec();
		current_lap += 1;

func on_player_race_finished():
	player.turn_off_engine_sounds();
	is_race_over = true;
	
	var score_from_current_race = Highscore.new(lap_times[0], lap_times[1], lap_times[2]);
	
	gui.show_victory_screen(lap_times);
	if (Global.current_highscore == null or score_from_current_race.get_combined_time() < Global.current_highscore.get_combined_time()):
		Global.save_highscore(score_from_current_race);
		Global.current_highscore = score_from_current_race;
		player.ghost_recorder.save_ghost();
		Global.current_player_ghost_inputs = Global.load_player_ghost();
	elif Global.current_player_ghost_inputs.is_empty():
		player.ghost_recorder.save_ghost();
		Global.current_player_ghost_inputs = Global.load_player_ghost();

func _on_charge_zone_body_entered(body: Node2D) -> void:
	if is_race_started:
		if (body.get_groups().has("player")):
			# LOGIC_X
			match (current_lap):
				1:
					trail_first.is_emitting = false;
					trail_first_draw_complete = true;
					trail_first.push_points_to_boost_area();
				2:
					trail_second.is_emitting = false;
					trail_second_draw_complete = true;
					trail_second.push_points_to_boost_area();

func _on_charge_zone_body_exited(body: Node2D) -> void:
	if (body.get_groups().has("player")):
		match (current_lap):
			1:
				trail_first.is_emitting = !trail_first_draw_complete;
			2:
				trail_second.is_emitting = !trail_second_draw_complete;

func _on_countdown_timer_timeout() -> void:
	current_lap_start_msec = Time.get_ticks_msec();
	is_race_started = true;
	gui.toggle_side_ui(true);

func on_player_destroyed() -> void:
	if not is_race_over:
		is_race_over = true;
		trail_first.trail_fade_out();
		trail_second.trail_fade_out();

func on_player_destroyed_animation_ended() -> void:
	gui.show_lose_screen(lap_times);

func _on_slowmo_timer_timeout() -> void:
	current_lap_start_msec = Time.get_ticks_msec();
	gui.boost_label.hide();
	Engine.time_scale = 1.0;
	gui.animation.speed_scale = 1;
	gui.toggle_side_ui(true);

func _on_front_death_barrier_body_entered(body: Node2D) -> void:
	if (body.get_groups().has("player")):
		player.destroy();

func _on_back_death_barrier_body_entered(body: Node2D) -> void:
	# TODO: Rename into charge gate, and to LOGIC_X here
	if (body.get_groups().has("player")):
		player.destroy();
