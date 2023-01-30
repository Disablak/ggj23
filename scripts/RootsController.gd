class_name RootController
extends Node2D


const DISTANCE_TO_DETECT_POINTS := 20
const MAX_STICK_CHILDREN := 3

@export var sticks_count_variant := 4
@export var stick_scene: PackedScene

var dict_pos_and_stick = {}
var all_sticks_in_root: Array[Stick]
var selected_stick: Stick = null
var lowest_stick: Stick = null

var cur_water: int = 100:
	set(value):
		cur_water = clampi(value, 0, Global.MAX_WATER)
		Global.on_updated_water.emit(cur_water)

		if cur_water == 0:
			Global.on_game_over.emit(false)
			printerr("game over!")


func _ready() -> void:
	Global.root_controller = self

	init_start_sticks()
	try_to_spawn_new_sticks()


func init_start_sticks():
	for stick in get_children():
		if not stick is Stick:
			continue

		stick.is_connected_to_root = true
		all_sticks_in_root.append(stick)

		if is_lowest(stick):
			lowest_stick = stick


func try_to_spawn_new_sticks():
	for pos in Global.CARD_STICK_POSES:
		if dict_pos_and_stick.has(pos):
			continue

		spawn_new_stick(pos)


func spawn_new_stick(pos) -> Stick:
	var new_stick: Stick = stick_scene.instantiate()
	add_child(new_stick)
	dict_pos_and_stick[pos] = new_stick

	new_stick.random_generade()
	new_stick.start_pos = pos
	new_stick.position = pos
	return new_stick


func on_start_drag_stick(stick: Stick):
	selected_stick = stick


func on_release_stick():
	for stick in all_sticks_in_root:
		var stick_pos = stick.position + stick.end_point
		var distance_to_points = stick_pos.distance_to(selected_stick.position)
		if distance_to_points > DISTANCE_TO_DETECT_POINTS:
			continue

		if stick.stick_children.size() >= MAX_STICK_CHILDREN:
			printerr("Too many sticks!")
			return

		for stick_j in all_sticks_in_root:
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
	all_sticks_in_root.append(child_stick)
	remove_from_available(child_stick)

	if lowest_stick == parent_stick:
		var stick_size = float(cur_water) / 100
		child_stick.change_size(stick_size)
		cur_water -= Global.PART_WATER
	else:
		cur_water += Global.PART_WATER

	if is_lowest(child_stick):
		lowest_stick = child_stick
		print("new lowest stick!")

	selected_stick = null


func is_lowest(stick: Stick) -> bool:
	return lowest_stick == null or get_stick_end_pos(lowest_stick).y < get_stick_end_pos(stick).y


func remove_from_available(stick: Stick):
	dict_pos_and_stick.erase(stick.start_pos)
	try_to_spawn_new_sticks()


func get_stick_start_pos(stick: Stick) -> Vector2:
	return stick.position + stick.start_point


func get_stick_end_pos(stick: Stick) -> Vector2:
	return stick.position + stick.end_point
