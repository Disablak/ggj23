class_name Globals
extends Node


const STICK_SIZE := 100
const MAX_STICK_SIZE := 150

const MAX_WATER := 100
const PART_WATER := 25
const STICK_ANGLES_VARIANTS: Array[int] = [30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150]
const CARD_STICK_POSES: Array[Vector2] = [
	Vector2(300, 500), Vector2(400, 500),
	Vector2(500, 500), Vector2(600, 500)
]

signal on_updated_water(new_value: int)
signal on_game_over(is_win: bool)

var root_controller: RootController
