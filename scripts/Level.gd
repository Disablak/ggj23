class_name Level
extends Node2D


const GROUND_START_Y := 700

@export var HIGH_SPRITE: Texture2D
@export var MEDIUM_SPRITE: Texture2D
@export var LOW_SPRITE: Texture2D

@export var count_variant := 4
@export var tutorial_card_angles: Array[int]
var cur_tutorial_card_id = 0
var plant_sprite_tween : Tween

@onready var line_lower_edge: Line2D = $LowerEdge
@onready var plant_sprite: Sprite2D = $Plant

func start_pulse_animation():
	var tween = create_tween().set_loops()
	tween.tween_property(line_lower_edge, "default_color:a", 1, 3)
	tween.tween_property(line_lower_edge, "default_color:a", 0, 3)

func update_plant_sprite(lower_stick_y: int):
	var finish_y := line_lower_edge.get_point_position(0).y
	var total_height := finish_y - GROUND_START_Y
	var one_segment_heigth := total_height / 2

	if lower_stick_y >= finish_y:
		play_tween_change_sprite(HIGH_SPRITE)
	elif lower_stick_y > GROUND_START_Y + one_segment_heigth:
		play_tween_change_sprite(MEDIUM_SPRITE)
	else:
		play_tween_change_sprite(LOW_SPRITE)


func play_tween_change_sprite(texture: Texture2D):
	if plant_sprite.texture == texture:
		return

	plant_sprite.use_parent_material = true

	plant_sprite_tween = create_tween()
	plant_sprite_tween.tween_property(plant_sprite, "self_modulate:a", 0.0, 0.5).from(1.0)
	plant_sprite_tween.tween_property(plant_sprite, "self_modulate:a", 1.0, 0.5).from(0.0)
	await plant_sprite_tween.step_finished
	plant_sprite.texture = texture
	await plant_sprite_tween.step_finished
	plant_sprite.use_parent_material = false


func try_get_tutorial_card() -> int:
	if cur_tutorial_card_id >= tutorial_card_angles.size():
		return -1

	var result = tutorial_card_angles[cur_tutorial_card_id]
	cur_tutorial_card_id += 1
	return result
