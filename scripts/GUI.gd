extends Control


@onready var label_water: Label = $LabelWater
@onready var box_container: HBoxContainer = $HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.on_updated_water.connect(_on_updated_water)

	await get_tree().process_frame
	for child in box_container.get_children():
		var pos = child.global_position + child.size / 2
		Global.card_points.append(pos)
		child.visible = false

	Global.on_ui_inited.emit()



func _on_updated_water(value: int):
	label_water.text = "WATER: {0}".format([value])
