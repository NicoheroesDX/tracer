class_name InputCapture;
extends Node;

var input_axis: float;

var is_accelerating: bool;
var acceleration_strength: float;

var is_decelerating: bool;
var deceleration_strength: float;

var is_boosting: bool;

func _init(axis: float, is_accel: bool, accel_strength: float, is_decel: bool, decel_strength: float, boost: bool):
	self.input_axis = axis;
	self.is_accelerating = is_accel;
	self.acceleration_strength = accel_strength;
	self.is_decelerating = is_decel;
	self.deceleration_strength = decel_strength;
	self.is_boosting = boost;
