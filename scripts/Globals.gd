class_name Globals
extends Node


const STICK_SIZE := 80
const MAX_STICK_SIZE := 80

const MAX_WATER := 100
const PART_WATER := 50
const STICK_WATER := 10
const STICK_ANGLES_VARIANTS: Array[int] = [30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150]
const CARD_STICK_POSES: Array[Vector2] = [
	Vector2(200, 500), Vector2(400, 500),
	Vector2(600, 500), Vector2(800, 500)
]

signal on_updated_water(prev_value:int, new_value: int)
signal on_game_over(is_win: bool)
signal on_card_move_back(stick: Stick)

var root_controller: RootController
var visual_effects: VisualEffects
var gui: GUI
var card_points: Array[Vector2]
