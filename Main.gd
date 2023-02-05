extends Node2D


@export var level_id := 0
@export var levels: Array[PackedScene]

@onready var root_controller: RootController = $RootController as RootController
@onready var gui: GUI = $GUI as GUI
@onready var camera = $Camera2D
@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

const MENU_POS = Vector2(0, -800)
const GAME_POS = Vector2.ZERO
const TWEEN_TIME = 1


func _ready() -> void:
	Global.on_game_over.connect(_on_game_over)

	gui.fade_show(false)
	on_game_started()


func on_game_started():
	if FileAccess.file_exists("res://savegame.save"):
		var save_game = FileAccess.open("res://savegame.save", FileAccess.READ)
		while save_game.get_position() < save_game.get_length():
			var json_string = save_game.get_line()

			var json = JSON.new()

			var parse_result = json.parse(json_string)
			if not parse_result == OK:
				continue

			var node_data = json.get_data()
			level_id = node_data["level_id"]
			Global.emit_signal("on_changed_level", level_id)

	var spawned_level = levels[level_id].instantiate()
	root_controller.init_game(spawned_level)


func _on_button_start_button_down() -> void:
	press_start()


func press_start():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(camera, "position", GAME_POS, TWEEN_TIME)
	tween.tween_callback(on_moved_to_game)

	gui.on_start_move_down()


func on_moved_to_game():
	gui.on_moved_down()
	root_controller.on_moved_down()


func _on_game_over(is_win: bool):
	Global.enable_input(false)

	if(root_controller.level.plant_sprite_tween and
	root_controller.level.plant_sprite_tween.is_running()):
		await root_controller.level.plant_sprite_tween.finished
		await get_tree().create_timer(0.5).timeout

	if(gui.change_score_tween and gui.change_score_tween.is_running()):
		await gui.change_score_tween.finished

	await gui.fade_show(true).finished

	if is_win:
		next_level()
	else:
		restart_level()

	await get_tree().create_timer(0.8).timeout

	gui.fade_show(false)
	Global.enable_input(true)

func next_level():
	level_id += 1
	Global.on_changed_level.emit(level_id)

	if level_id >= levels.size():
		gui.show_end_panel()
		return

	var save_dict = {
		"level_id" : level_id
	}

	var save_game = FileAccess.open("res://savegame.save", FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	save_game.store_line(json_string)

	restart_level()


func restart_level():
	root_controller.deinit_game()
	on_game_started()
	root_controller.on_moved_down()
