class_name BoostArea;
extends Node2D;

var is_active: bool = false;

var boost_segments: Array[BoostSegment] = [];

var is_first_lap: bool = true;

func activate():
	is_active = true;
	
	for segment in boost_segments:
		segment.visualize();

func push_points(points: PackedVector2Array):
	if is_first_lap:
		create_new_segment(points);
	else:
		add_next_missing_points(points);

func create_new_segment(points_from_first_lap: PackedVector2Array):
	var new_segment = BoostSegment.new();
	new_segment.first_trail_points = points_from_first_lap;
	boost_segments.append(new_segment);

func add_next_missing_points(points_from_second_lap: PackedVector2Array):
	var ind = -1;
	for segment in boost_segments:
		ind += 1;
		
		if segment.second_trail_points.is_empty():
			segment.second_trail_points = points_from_second_lap;
			segment.generate_booster();
			add_child(segment)
			print("Added segment to scene!");
			return;
