class_name GUI
extends Control


@onready var btn_start: Button = $ButtonStart
@onready var label_water: Label = $LabelWater
@onready var box_container: HBoxContainer = $HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.gui = self

	Global.on_updated_water.connect(_on_updated_water)

	await get_tree().process_frame
	for child in box_container.get_children():
		var pos = child.global_position + child.size / 2
		Global.card_points.append(pos)
		child.visible = false


func _on_updated_water(value: int):
	label_water.text = "WATER: {0}".format([value])


func on_start_move_down():
	btn_start.visible = false


func on_moved_down():
	label_water.visible = true

func show_hint_water(cur_water: int, plus_water):
	label_water.label_settings.font_color = Color.WHITE

	if plus_water == null:
		_on_updated_water(cur_water)
		return

	if plus_water:
		label_water.text = "WATER: {0} + {1}".format([cur_water, Global.PART_WATER])
	else:
		if cur_water - Global.PART_WATER == 0:
			label_water.label_settings.font_color = Color.RED
			label_water.text = "WATER: {0} - {1}".format([cur_water, Global.PART_WATER])
		else:
			label_water.text = "WATER: {0} - {1}".format([cur_water, Global.PART_WATER])
