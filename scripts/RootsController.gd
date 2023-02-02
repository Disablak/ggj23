class_name RootController
extends Node2D

signal on_wrong_release(released_stick : Stick)

const DISTANCE_TO_DETECT_POINTS := 20
const MAX_STICK_CHILDREN := 3

@onready var draw_hints: DrawHints = $DrawHints
@export var stick_scene: PackedScene

var level: Level
var sticks_count_variant := 4
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
		var prev_value := cur_water
		cur_water = clampi(value, 0, Global.MAX_WATER)
		Global.on_updated_water.emit(prev_value, cur_water)

		if cur_water == 0:
			Global.on_game_over.emit(false)


func _ready() -> void:
	Global.root_controller = self


func init_game(level: Level):
	add_child(level)
	self.level = level
	level.line_lower_edge.visible = false

	init_start_sticks()
	find_all_obstacles()

	lower_edge_start = level.line_lower_edge.get_point_position(0)
	lower_edge_end = level.line_lower_edge.get_point_position(1)

	cur_water = 100


func deinit_game():
	all_sticks_in_root.clear()

	for stick in dict_pos_and_stick.values():
		stick.queue_free()

	dict_pos_and_stick.clear()

	lowest_stick = null
	obstacles.clear()

	available_id = 0
	cur_stick_id = -1

	level.queue_free()
	level = null


func on_moved_down():
	level.line_lower_edge.visible = true
	try_to_spawn_new_sticks()


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
		var distance_to_points = stick_pos.distance_to(get_stick_start_pos(selected_stick))
		draw_hints.clear_hint_point()
		draw_hints.clear_stick()
		draw_hints.clear_lower_line()
		show_hint_water(0)

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

		if future_stick_end.y > get_stick_end_pos(lowest_stick).y:
			show_hint_water(-Globals.PART_WATER)
			draw_hints.draw_lower_line(future_stick_end.y)
		else:
			show_hint_water(Globals.STICK_WATER * (stick.stick_children.size() + 1))

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
		var distance_to_points = stick_pos.distance_to(get_stick_start_pos(selected_stick))
		if distance_to_points > DISTANCE_TO_DETECT_POINTS:
			continue

		var dir = Vector2(cos(deg_to_rad(selected_stick.stick_angle)), sin(deg_to_rad(selected_stick.stick_angle)))
		var future_size: int = selected_stick.stick_size

		var future_stick_start = get_stick_end_pos(stick) + dir * (float(future_size) / 10)
		var future_stick_end = get_stick_end_pos(stick) + dir * future_size

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

		set_sticks(stick, selected_stick)
		return

	release_stick_wrong()


func release_stick_wrong():
	draw_hints.clear_hint_point()
	draw_hints.clear_stick()
	show_hint_water(0)
	draw_hints.clear_lower_line()
	on_wrong_release.emit(selected_stick)
	cur_stick_id = -1


func init_start_sticks():
	for stick in level.get_children():
		if not stick is Stick:
			continue

		stick.is_connected_to_root = true
		stick.line2d.default_color.a = 1.0
		all_sticks_in_root.append(stick)

		for stick_j in level.get_children():
			if not stick_j is Stick:
				continue

			var distance_to_points = get_stick_end_pos(stick).distance_to(get_stick_start_pos(stick_j))
			if distance_to_points < DISTANCE_TO_DETECT_POINTS:
				if stick.stick_children.size() >= MAX_STICK_CHILDREN:
					printerr("sticks have max children")
					continue

				stick.stick_children.append(stick_j)
				print("connected in init")

		if is_lowest(stick):
			lowest_stick = stick


func try_to_spawn_new_sticks():
	for pos in Global.card_points:
		if dict_pos_and_stick.has(pos):
			continue

		spawn_new_stick(pos)


func spawn_new_stick(pos) -> Stick:
	var new_stick: Stick = stick_scene.instantiate()
	level.add_child(new_stick)
	dict_pos_and_stick[pos] = new_stick

	new_stick.random_generade()
	new_stick.start_pos = pos
	new_stick.position = pos
	new_stick.show_card(true)
	new_stick.play_spawn()
	new_stick.id = available_id
	available_id += 1
	return new_stick


func set_sticks(parent_stick: Stick, child_stick: Stick):
	parent_stick.stick_children.append(child_stick)
	child_stick.stick_parent = parent_stick

	child_stick.position = get_stick_end_pos(parent_stick) - child_stick.line2d.position
	child_stick.is_connected_to_root = true
	all_sticks_in_root.append(child_stick)
	dict_pos_and_stick.erase(child_stick.start_pos)

	if is_lowest(child_stick):
		lowest_stick = child_stick
		cur_water -= Global.PART_WATER
	else:
		cur_water += Global.STICK_WATER * parent_stick.stick_children.size()

	if is_stick_intersects_finish(child_stick):
		Global.on_game_over.emit(true)
		print("FINISH")

	draw_hints.clear_hint_point()
	draw_hints.clear_stick()
	draw_hints.clear_lower_line()

	try_to_spawn_new_sticks()

	cur_stick_id = -1


func is_stick_intersects_finish(stick: Stick):
	return Geometry2D.segment_intersects_segment(get_stick_start_pos(stick), get_stick_end_pos(stick), lower_edge_start, lower_edge_end)


func is_lowest(stick: Stick) -> bool:
	return lowest_stick == null or get_stick_end_pos(lowest_stick).y < get_stick_end_pos(stick).y


func get_stick_start_pos(stick: Stick) -> Vector2:
	return stick.position + stick.line2d.position + stick.start_point


func get_stick_end_pos(stick: Stick) -> Vector2:
	return stick.position + stick.line2d.position + stick.end_point


func get_stick(id) -> Stick:
	for stick in dict_pos_and_stick.values():
		if stick.id == id:
			return stick

	return null


func show_hint_water(add_water: int):
	Global.gui.show_hint_water(cur_water, add_water)

