extends Node2D


@export var level_id := 0
@export var levels: Array[PackedScene]

@onready var root_controller: RootController = $RootController as RootController
@onready var gui: GUI = $GUI as GUI
@onready var camera = $Camera2D

const MENU_POS = Vector2(0, -800)
const GAME_POS = Vector2.ZERO
const TWEEN_TIME = 2


func _ready() -> void:
	Global.on_game_over.connect(_on_game_over)

	on_game_started()


func on_game_started():
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
	if not is_win:
		restart_level()


func restart_level():
	root_controller.deinit_game()
	on_game_started()
	root_controller.on_moved_down()
