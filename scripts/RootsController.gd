class_name RootController
extends Node2D


const DISTANCE_TO_DETECT_POINTS := 20

@export var all_sticks: Array[Stick]

var selected_stick: Stick


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.root_controller = self

	for idx in 3:
		var child = get_child(idx)
		child.is_connected_to_root = true
		all_sticks.append(get_child(idx))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if selected_stick == null:
		return

	pass


func on_start_drag_stick(stick: Stick):
	selected_stick = stick


func on_release_stick():
	for stick in all_sticks:
		var stick_pos = stick.position + stick.end_point
		var distance_to_points = stick_pos.distance_to(selected_stick.position)
		if distance_to_points > DISTANCE_TO_DETECT_POINTS:
			continue

		selected_stick.position = stick_pos
		selected_stick.is_connected_to_root = true
		all_sticks.append(selected_stick)
		selected_stick = null
		return





