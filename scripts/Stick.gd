class_name Stick
extends Node2D

@onready var sprite_card := $Sprite2DCard

@export var is_start_stick = false
@export var line2d: Line2D

var id: int = -1

var start_point: Vector2
var end_point: Vector2

var is_connected_to_root: bool:
	set(value):
		show_card(not value)
		is_connected_to_root = value

var can_drag := false
var card_is_visible := false

var start_pos: Vector2
var stick_vector: Vector2
var stick_size: int
var stick_angle: int

var stick_parent: Stick
var stick_children: Array[Stick]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.on_card_move_back.connect(_on_card_move_back)

	start_point = line2d.points[0]
	end_point = line2d.points[1]
	stick_vector = start_point.direction_to(end_point)


func _on_card_move_back(stick: Stick):
	if self == stick:
		move_front(false)


func _input_event(viewport, event, shape_idx):
	if is_connected_to_root or not Global.visual_effects or Global.visual_effects.is_tween_card_move_plays:
		return

	if event is InputEventMouseButton:
		if event.pressed and not can_drag:
			Global.root_controller.on_start_drag_stick(id)
			show_card(false)
			move_front(true)

		can_drag = event.pressed and not is_connected_to_root

		if not event.pressed:
			Global.root_controller.on_release_stick(id)


func move_front(front: bool):
	z_index = 1 if front else 0


func random_generade():
	var random_angle: int = Global.STICK_ANGLES_VARIANTS.pick_random()
	var random_size: int = randi_range(Global.STICK_SIZE, Global.MAX_STICK_SIZE)
	var end_point: Vector2 = Vector2(cos(deg_to_rad(random_angle)), sin(deg_to_rad(random_angle))) * random_size

	stick_size = random_size
	stick_angle = random_angle

	_set_end_point(end_point)


func change_size(new_size: float):
	var new_end_pos: Vector2 = stick_vector * (new_size * stick_size)
	_set_end_point(new_end_pos)


func show_card(show: bool):
	if show == card_is_visible:
		return

	sprite_card.visible = show
	card_is_visible = show


func _set_end_point(point: Vector2):
	line2d.set_point_position(1, point)
	end_point = point
	stick_vector = start_point.direction_to(end_point)
