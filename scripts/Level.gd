class_name Level
extends Node2D


const GROUND_START_Y := 700

@export var HIGH_SPRITE: Texture2D
@export var MEDIUM_SPRITE: Texture2D
@export var LOW_SPRITE: Texture2D

@onready var line_lower_edge: Line2D = $LowerEdge
@onready var plant_sprite: Sprite2D = $Plant


func update_plant_sprite(lower_stick_y: int):
	var finish_y := line_lower_edge.get_point_position(0).y
	var total_height := finish_y - GROUND_START_Y
	var one_segment_heigth := total_height / 3

	if lower_stick_y > GROUND_START_Y + one_segment_heigth * 2:
		play_tween_change_sprite(HIGH_SPRITE)
	elif lower_stick_y > GROUND_START_Y + one_segment_heigth:
		play_tween_change_sprite(MEDIUM_SPRITE)
	else:
		play_tween_change_sprite(LOW_SPRITE)


func play_tween_change_sprite(texture: Texture2D):
	if plant_sprite.texture == texture:
		return

	var tween = create_tween()
	tween.tween_property(plant_sprite, "self_modulate:a", 0.0, 0.5).from(1.0)
	tween.tween_property(plant_sprite, "self_modulate:a", 1.0, 0.5).from(0.0)
	await tween.step_finished
	plant_sprite.texture = texture



