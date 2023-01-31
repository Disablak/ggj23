class_name RootController
extends Node2D

signal on_wrong_release(released_stick : Stick)

const DISTANCE_TO_DETECT_POINTS := 20
const MAX_STICK_CHILDREN := 3

@export var sticks_count_variant := 4
@export var lower_edge: int = 800
@export var line2d_lower_edge: Line2D
@export var stick_scene: PackedScene
@export var draw_hints: DrawHints

var dict_pos_and_stick = {}
var all_sticks_in_root: Array[Stick]
var selected_stick: Stick:
	get: return get_stick(cur_stick_id)

var lowest_stick: Stick = null

var lower_edge_start: Vector2
var lower_edge_end: Vector2

var obstacles: Array[Obstacle]

var available_id: int = 0
var cur_stick_id: int = -1


var cur_water: int = 100:
	set(value):
		cur_water = clampi(value, 0, Global.MAX_WATER)
		Global.on_updated_water.emit(cur_water)

		if cur_water == 0:
			Global.on_game_over.emit(false)
			printerr("game over!")


func _ready() -> void:
	Global.root_controller = self
	Global.on_ui_inited.connect(init_game)


func init_game():
	init_start_sticks()
	try_to_spawn_new_sticks()
	find_all_obstacles()

	lower_edge_start = Vector2(0, lower_edge)
	lower_edge_end = Vector2(get_viewport_rect().size.x, lower_edge)
	line2d_lower_edge.add_point(lower_edge_start)
	line2d_lower_edge.add_point(lower_edge_end)


func find_all_obstacles():
	for child in get_children():
		if child is Obstacle:
			obstacles.append(child)


func _process(delta: float) -> void:
	move_stick()

	if cur_stick_id == -1:
		return

	for stick in all_sticks_in_root:
		var stick_pos = get_stick_end_pos(stick)
		var distance_to_points = stick_pos.distance_to(selected_stick.position)
		draw_hints.clear_hint_point()
		draw_hints.clear_stick()

		if distance_to_points > DISTANCE_TO_DETECT_POINTS:
			continue

		var dir = Vector2(cos(deg_to_rad(selected_stick.stick_angle)), sin(deg_to_rad(selected_stick.stick_angle)))
		var future_size: int = selected_stick.stick_size
		if lowest_stick == stick:
			future_size *= float(cur_water) / 100

		var future_stick_start = get_stick_end_pos(stick) + dir * (float(future_size) / 10)
		var future_stick_end = get_stick_end_pos(stick) + dir * future_size

		draw_hints.draw_hint(stick_pos, Color.RED)
		draw_hints.draw_future_stick(future_stick_start, future_stick_end, Color.RED)

		if stick.stick_children.size() >= MAX_STICK_CHILDREN:
			return

		for stick_child in stick.stick_children:
			if stick_child.stick_angle == selected_stick.stick_angle:
				printerr("Sticks angle are same!")
				return

		for stick_j in all_sticks_in_root:
			var interaction = Geometry2D.segment_intersects_segment(get_stick_start_pos(stick_j), get_stick_end_pos(stick_j), future_stick_start, future_stick_end)
			if interaction != null:
				printerr("Sticks interacts!")
				return

		for obstacle in obstacles:
			if obstacle.is_intersect_obstacle(future_stick_start, future_stick_end):
				printerr("Sticks intersect obstacle!")
				return

		draw_hints.draw_hint(stick_pos, Color.GREEN)
		draw_hints.draw_future_stick(future_stick_start, future_stick_end, Color.GREEN)
		return


func move_stick():
	if cur_stick_id == -1:
		return

	if selected_stick.is_connected_to_root or not Global.visual_effects or Global.visual_effects.is_tween_card_move_plays:
		return

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and selected_stick.can_drag:
		selected_stick.position = get_global_mouse_position()


func on_start_drag_stick(id: int):
	cur_stick_id = id


func on_release_stick(id: int):
	if cur_stick_id == -1:
		return

	for stick in all_sticks_in_root:
		var stick_pos = get_stick_end_pos(stick)
		var distance_to_points = stick_pos.distance_to(selected_stick.position)
		if distance_to_points > DISTANCE_TO_DETECT_POINTS:
			continue

		var dir = Vector2(cos(deg_to_rad(selected_stick.stick_angle)), sin(deg_to_rad(selected_stick.stick_angle)))
		var future_stick_start = get_stick_end_pos(stick) + dir * (float(selected_stick.stick_size) / 10)
		var future_stick_end = get_stick_end_pos(stick) + dir * selected_stick.stick_size

		if stick.stick_children.size() >= MAX_STICK_CHILDREN:
			printerr("Too many sticks!")
			release_stick_wrong()
			return

		for stick_child in stick.stick_children:
			if stick_child.stick_angle == selected_stick.stick_angle:
				printerr("Sticks angle are same!")
				release_stick_wrong()
				return

		for stick_j in all_sticks_in_root:
			var interaction = Geometry2D.segment_intersects_segment(get_stick_start_pos(stick_j), get_stick_end_pos(stick_j), future_stick_start, future_stick_end)
			if interaction != null:
				printerr("Sticks interacts!")
				release_stick_wrong()
				return

		for obstacle in obstacles:
			if obstacle.is_intersect_obstacle(future_stick_start, future_stick_end):
				printerr("Sticks intersect obstacle!")
				release_stick_wrong()
				return

		set_sticks(stick, selected_stick, stick_pos)
		return

	release_stick_wrong()


func release_stick_wrong():
	on_wrong_release.emit(selected_stick)
	cur_stick_id = -1


func init_start_sticks():
	for stick in get_children():
		if not stick is Stick:
			continue

		stick.is_connected_to_root = true
		all_sticks_in_root.append(stick)

		if is_lowest(stick):
			lowest_stick = stick


func try_to_spawn_new_sticks():
	for pos in Global.card_points:
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
	new_stick.show_card(true)
	new_stick.id = available_id
	available_id += 1
	return new_stick


func set_sticks(parent_stick: Stick, child_stick: Stick, parent_end_pos: Vector2):
	parent_stick.stick_children.append(child_stick)
	child_stick.stick_parent = parent_stick

	child_stick.position = parent_end_pos
	child_stick.is_connected_to_root = true
	all_sticks_in_root.append(child_stick)
	dict_pos_and_stick.erase(child_stick.start_pos)

	if lowest_stick == parent_stick:
		var stick_size = float(cur_water) / 100
		child_stick.change_size(stick_size)

	if is_lowest(child_stick):
		lowest_stick = child_stick
		cur_water -= Global.PART_WATER
	else:
		cur_water += Global.PART_WATER

	if is_stick_intersects_finish(child_stick):
		Global.on_game_over.emit(true)
		print("FINISH")

	draw_hints.clear_hint_point()
	draw_hints.clear_stick()

	try_to_spawn_new_sticks()

	cur_stick_id = -1


func is_stick_intersects_finish(stick: Stick):
	return Geometry2D.segment_intersects_segment(get_stick_start_pos(stick), get_stick_end_pos(stick), lower_edge_start, lower_edge_end)


func is_lowest(stick: Stick) -> bool:
	return lowest_stick == null or get_stick_end_pos(lowest_stick).y < get_stick_end_pos(stick).y


func get_stick_start_pos(stick: Stick) -> Vector2:
	return stick.position + stick.start_point


func get_stick_end_pos(stick: Stick) -> Vector2:
	return stick.position + stick.end_point


func get_stick(id) -> Stick:
	for stick in dict_pos_and_stick.values():
		if stick.id == id:
			return stick

	return null
