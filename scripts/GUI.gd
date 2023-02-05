class_name GUI
extends Control


@onready var btn_start: Button = $ButtonStart
@onready var btn_sprite: TextureRect = $TextureRect
@onready var water: Control = $CanvasLayer/Water
@onready var label_water: Label = $CanvasLayer/Water/LabelWater
@onready var label_score: Label = $CanvasLayer/LabelScore
@onready var label_lvl: Label = $CanvasLayer/LabelLvl
@onready var box_container: HBoxContainer = $CanvasLayer/HBoxContainer
@onready var fade: ColorRect = $CanvasLayer/Fade
@onready var end_panel: Control = $CanvasLayer/EndPanel
@onready var end_panel_label: Control = $CanvasLayer/EndPanel/Label
@onready var btn_restart: Control = $CanvasLayer/ButtonRestart
@onready var label_title: Control = $LabelTitle

var change_score_tween : Tween

const FADE_TIME := 1
const LABEL_WATER_TWEEN_DURATION := 1
const MAX_WATER_VALUE := 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.gui = self

	Global.on_updated_water.connect(_on_updated_water)
	Global.on_changed_level.connect(_on_changed_level)
	Global.on_changed_score.connect(_on_changed_score)

	water.visible = false
	fade.visible = true
	label_score.visible = false
	label_lvl.visible = false
	btn_restart.visible = false

	await get_tree().process_frame
	for child in box_container.get_children():
		var pos = child.global_position + child.size / 2
		Global.card_points.append(pos)
		child.visible = false


func _on_changed_level(id: int):
	label_lvl.text = "L{0}".format([id])


func _on_changed_score(score: int):
	label_score.text = "S{0}".format([score])


func _on_updated_water(prev_value: int, cur_value: int):
	if prev_value == cur_value:
		return

	change_score_tween = create_tween()
	change_score_tween.set_trans(Tween.TRANS_SINE)
	change_score_tween.tween_method(set_label_water_text, prev_value,
		cur_value, LABEL_WATER_TWEEN_DURATION)
	change_score_tween.tween_property(label_water, "scale",
		Vector2(1.2, 1.2), 0.2).from(Vector2.ONE)
	change_score_tween.tween_property(label_water, "scale",
		Vector2.ONE, 0.2)

func set_label_water_text(value: int):
	label_water.label_settings.font_color = Color.WHITE
	label_water.text = "{0}".format([value])


func on_start_move_down():
	btn_start.visible = false

	btn_sprite.use_parent_material = true
	var tween_alpha = create_tween()
	tween_alpha.tween_property(btn_sprite, "self_modulate:a", 0.0, 0.5)


func on_moved_down():
	label_title.visible = false
	water.visible = true
	label_lvl.visible = true
	label_score.visible = true
	btn_restart.visible = true


func show_hint_water(cur_water: int, add_water: int):
	label_water.label_settings.font_color = Color.WHITE

	if add_water == 0:
		label_water.text = "{0}".format([cur_water])
		return

	if add_water > 0:
		if(cur_water == MAX_WATER_VALUE):
			label_water.text = "{0}".format([cur_water])
		elif cur_water + add_water > MAX_WATER_VALUE:
			label_water.text = "{0} + {1}".format([cur_water, MAX_WATER_VALUE - cur_water])
		else:
			label_water.text = "{0} + {1}".format([cur_water, add_water])
	else:
		if cur_water + add_water <= 0:
			label_water.label_settings.font_color = Color.RED

		label_water.text = "{0} - {1}".format([cur_water, abs(add_water)])


func fade_show(show) -> Tween:
	var tween = create_tween()
	var color_to = Color.BLACK if show else Color(Color.BLACK, 0.0)
	tween.tween_property(fade, "color", color_to, FADE_TIME)

	return tween


func update_card_pos(count: int):
	for child in box_container.get_children():
		child.visible = false

	Global.card_points.clear()

	for id in count:
		var child = box_container.get_child(id)
		child.visible = true

	await get_tree().process_frame

	for id in count:
		var child = box_container.get_child(id)
		var pos = child.global_position + child.size / 2
		Global.card_points.append(pos)
		child.visible = false


func show_end_panel():
	end_panel.visible = true
	
	var save_dict = {
		"level_id" : 1
	}
	
	var save_game = FileAccess.open("res://savegame.save", FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	save_game.store_line(json_string)

	var tween = create_tween()
	tween.tween_property(end_panel, "self_modulate:a", 1.0, 1)
	tween.tween_property(end_panel_label, "self_modulate:a", 1.0, 1)


func _on_button_restart_button_down() -> void:
	Global.on_game_over.emit(false)
