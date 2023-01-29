class_name Stick
extends Node2D


@export var is_connected_to_root: bool
@export var start_point: Vector2
@export var end_point: Vector2
@export var line2d: Line2D

var can_drag := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_point = line2d.points[0]
	end_point = line2d.points[1]


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
