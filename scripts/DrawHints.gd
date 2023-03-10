class_name DrawHints
extends Node2D


var hint_color: Color
var hint_pos: Vector2 = Vector2(-100, -100)
var future_stick_start: Vector2
var future_stick_end: Vector2
var future_stick_color: Color
var lower_line_y: int = -1000


func draw_hint(pos: Vector2, color: Color):
	hint_pos = pos
	hint_color = color
	queue_redraw()


func draw_future_stick(start: Vector2, end: Vector2, color: Color):
	future_stick_start = start
	future_stick_end = end
	future_stick_color = color
	queue_redraw()


func draw_lower_line(y: int):
	lower_line_y = y


func clear_lower_line():
	lower_line_y = -1000


func clear_hint_point():
	hint_pos = Vector2(-100, -100)
	queue_redraw()


func clear_stick():
	future_stick_start = Vector2(-100, -100)
	future_stick_end = Vector2(-100, -100)
	queue_redraw()


func _draw() -> void:
	draw_circle(hint_pos, 15, hint_color)
	draw_line(future_stick_start, future_stick_end, future_stick_color, 10)
	draw_line(Vector2(-200, lower_line_y), Vector2(2000, lower_line_y), Color.WHITE)
