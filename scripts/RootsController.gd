class_name RootController
extends Node2D


const DISTANCE_TO_DETECT_POINTS := 20
const MAX_STICK_CHILDREN := 3

@export var started_sticks_count = 3

var all_sticks: Array[Stick]
var selected_stick: Stick = null
var lowest_stick: Stick = null

var cur_water: int = 100:
	set(value):
		cur_water = clampi(value, 0, Global.MAX_WATER)
		Global.on_updated_water.emit(cur_water)

		if cur_water == 0:
			Global.on_game_over.emit(false)
			printerr("game over!")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.root_controller = self

	for idx in started_sticks_count:
		var child = get_child(idx)
		child.is_connected_to_root = true
		all_sticks.append(get_child(idx))

		if is_lowest(child):
			lowest_stick = child



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

		if stick.stick_children.size() >= MAX_STICK_CHILDREN:
			printerr("Too many sticks!")
			return

		for stick_j in all_sticks:
			var interaction = Geometry2D.segment_intersects_segment(get_stick_start_pos(stick_j), get_stick_end_pos(stick_j), get_stick_start_pos(selected_stick), get_stick_end_pos(selected_stick))
			if interaction != null:
				printerr("Sticks interacts!")
				return

		set_sticks(stick, selected_stick, stick_pos)
		return


func set_sticks(parent_stick: Stick, child_stick: Stick, parent_end_pos: Vector2):
	parent_stick.stick_children.append(child_stick)
	child_stick.stick_parent = parent_stick

	child_stick.position = parent_end_pos
	child_stick.is_connected_to_root = true
	all_sticks.append(child_stick)

	if lowest_stick == parent_stick:
		var stick_size = float(cur_water) / 100
		child_stick.change_size(stick_size)
		cur_water -= Global.PART_WATER
#		print("stick size {0}".format([stick_size]))
#		print("- water, stick with debaff")
	else:
		cur_water += Global.PART_WATER
#		print("+ water")

	if is_lowest(child_stick):
		lowest_stick = child_stick
		print("new lowest stick!")

	selected_stick = null


func is_lowest(stick: Stick) -> bool:
	return lowest_stick == null or get_stick_end_pos(lowest_stick).y < get_stick_end_pos(stick).y


func get_stick_start_pos(stick: Stick) -> Vector2:
	return stick.position + stick.start_point


func get_stick_end_pos(stick: Stick) -> Vector2:
	return stick.position + stick.end_point
