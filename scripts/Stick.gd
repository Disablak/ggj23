class_name Stick
extends Node2D


@export var is_start_stick = false
@export var line2d: Line2D

var start_point: Vector2
var end_point: Vector2

var is_connected_to_root: bool
var can_drag := false

var start_pos: Vector2
var stick_vector: Vector2
var stick_size: int

var stick_parent: Stick
var stick_children: Array[Stick]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_point = line2d.points[0]
	end_point = line2d.points[1]
	stick_vector = start_point.direction_to(end_point)


func _input_event(viewport, event, shape_idx):
	if is_connected_to_root:
		return

	if event is InputEventMouseButton:
		if event.pressed and not can_drag:
			Global.root_controller.on_start_drag_stick(self)

		can_drag = event.pressed and not is_connected_to_root

		if not event.pressed:
			Global.root_controller.on_release_stick()

func _process(delta):
	if is_connected_to_root:
		return

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and can_drag:
		position = get_global_mouse_position()


func random_generade():
	var random_angle: int = Global.STICK_ANGLES_VARIANTS.pick_random()
	var random_size: int = randi_range(Global.STICK_SIZE, Global.MAX_STICK_SIZE)
	var end_point: Vector2 = Vector2(cos(deg_to_rad(random_angle)), sin(deg_to_rad(random_angle))) * random_size
	stick_size = random_size
	_set_end_point(end_point)


func change_size(new_size: float):
	var new_end_pos: Vector2 = stick_vector * (new_size * stick_size)
	_set_end_point(new_end_pos)


func _set_end_point(point: Vector2):
	line2d.set_point_position(1, point)
	end_point = point
	stick_vector = start_point.direction_to(end_point)
