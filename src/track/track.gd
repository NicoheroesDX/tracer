extends Node2D

@onready var player_camera: Camera2D = $PlayerCamera;
@onready var player: Car = $Player;

@onready var player_ghost: Ghost = $PlayerGhost;
@onready var target_ghost: Ghost = $TargetGhost;

@onready var tile_map: TileMap = $TileMap;
@onready var checkpoint_list: Node = $CheckPoints;
@onready var finish_line: FinishLine = %FinishLine;

@onready var trail_first: Trail = $TrailFirst;
@onready var trail_second: Trail = $TrailSecond;
@onready var trail_boost_area: BoostArea = $BoostArea;

@onready var gui: DrivingInterface = $DrivingInterface;

@onready var countdown_delay: Timer = $CountdownTimer;
@onready var slowmo_timer: Timer = $SlowmoTimer;

@onready var gate_front: Area2D = $FrontChargeGate;
@onready var gate_back: Area2D = $BackChargeGate;

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
	player_ghost.connect_to_map(tile_map);
	player_ghost.set_inputs(Global.current_player_ghost_inputs);
	player_ghost.set_style(Color.hex(0xffffff66))
	target_ghost.connect_to_map(tile_map);
	target_ghost.set_inputs(Global.current_target_ghost_inputs);
	target_ghost.set_style(Color.hex(0xff4444bb))
	
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
	
	toggle_gate_closed(gate_front, false);
	toggle_gate_closed(gate_back, true);
	
	var score_to_check = get_score_to_check();
	
	var has_checkpoint_times = score_to_check != null and not score_to_check.checkpoint_times.is_empty()
	
	for checkpoint: Checkpoint in checkpoint_list.get_children():
		if (has_checkpoint_times):
			var targets = score_to_check.checkpoint_times.get(checkpoint_amount);
			checkpoint.lap_1_target = targets[0];
			checkpoint.lap_2_target = targets[1];
			checkpoint.lap_3_target = targets[2];
		
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
			player_ghost.start();
		if not Global.current_target_ghost_inputs.is_empty():
			target_ghost.start();
	else:
		player.is_allowed_to_move = false;
	
	player.is_in_boost_area = false;
	player_ghost.is_in_boost_area = false;
	target_ghost.is_in_boost_area = false;
	
	if (checkpoints_crossed < checkpoint_amount):
		toggle_gate_closed(gate_front, false);
		toggle_gate_closed(gate_back, true);
	else:
		toggle_gate_closed(gate_front, true);
		toggle_gate_closed(gate_back, false);
	
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
	var score_to_check = get_score_to_check();
	
	if (score_to_check != null):
		match(current_lap):
			1:
				gui.update_time_difference(1,score_to_check.lap_1_time - get_current_lap_time())
				update_checkpoint_time_diff(score_to_check.lap_1_time - get_current_lap_time())
			2:
				gui.update_time_difference(2, score_to_check.lap_2_time - get_current_lap_time())
				update_checkpoint_time_diff((score_to_check.lap_1_time + score_to_check.lap_2_time) +\
					lap_times[0] + get_current_lap_time())
			3:
				gui.update_time_difference(3, score_to_check.lap_3_time - get_current_lap_time())
				gui.time_diff.hide_ui();

func get_score_to_check():
	var score_to_check = null;
	
	if (Global.current_highscore != null):
		score_to_check = Global.current_highscore;
	
	if (Global.current_target != null):
		score_to_check = Global.current_target;
		
		if (Global.current_highscore != null and\
		Global.current_highscore.get_combined_time() < Global.current_target.get_combined_time()):
			score_to_check = Global.current_highscore;
	
	return score_to_check;

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

func toggle_gate_closed(gate: Area2D, is_now_closed: bool):
	gate.visible = is_now_closed;
	gate.monitoring = is_now_closed;

func update_camera_position():
	player_camera.global_position = player.global_position;

func get_race_time() -> int:
	return lap_times[0] + lap_times[1] + lap_times[2];

func get_current_lap_time():
	return lap_times[current_lap-1];

func set_current_lap_time(msec: int):
	lap_times[current_lap-1] = msec;

func update_checkpoint_time_diff(time_diff: int):
	var score_to_check = get_score_to_check();
	
	if score_to_check != null and not score_to_check.checkpoint_times.is_empty():
		gui.update_checkpoint_time_diff(time_diff);

func on_player_crossed_checkpoint(checkpoint: Checkpoint):
	checkpoints_crossed += 1;
	match (current_lap):
		1:
			trail_first.is_current_segment_complete = true;
			checkpoint.lap_1_time = get_race_time();
			update_checkpoint_time_diff(checkpoint.lap_1_target - checkpoint.lap_1_time);
		2:
			trail_second.is_current_segment_complete = true;
			checkpoint.lap_2_time = get_race_time();
			update_checkpoint_time_diff(checkpoint.lap_2_target - checkpoint.lap_2_time);
		3:
			checkpoint.lap_3_time = get_race_time();
			update_checkpoint_time_diff(checkpoint.lap_3_target - checkpoint.lap_3_time);

func on_player_crossed_finish(_finish_line):
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
	
	var score_from_current_race = Highscore.new(lap_times[0], lap_times[1], lap_times[2], \
		Highscore.extract_checkpoint_times(checkpoint_list.get_children()));
	
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
	if (body.get_groups().has("player")):
		match (current_lap):
			1:
				trail_first.is_emitting = false;
			2:
				trail_second.is_emitting = false;

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

func _on_front_charge_gate_body_entered(body: Node2D) -> void:
	if (body.get_groups().has("player")):
		player.destroy();

func _on_back_charge_gate_body_entered(body: Node2D) -> void:
	if (body.get_groups().has("player")):
		match (current_lap):
			1:
				if not trail_first_draw_complete:
					trail_first.is_emitting = false;
					trail_first_draw_complete = true;
					trail_first.push_points_to_boost_area();
			2:
				if not trail_second_draw_complete:
					trail_first.is_emitting = false;
					trail_second_draw_complete = true;
					trail_second.push_points_to_boost_area();
