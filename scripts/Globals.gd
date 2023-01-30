class_name Globals
extends Node


const STICK_SIZE := 100
const MAX_WATER := 100
const PART_WATER := 25

signal on_updated_water(new_value: int)
signal on_game_over(is_win: bool)

var root_controller: RootController
