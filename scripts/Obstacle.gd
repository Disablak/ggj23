class_name Obstacle
extends Node2D


@onready var line2d: Line2D = $Line2D


func is_intersect_obstacle(point_a: Vector2, point_b: Vector2):
	for idx in line2d.points.size():
		var prev_point := position + line2d.get_point_position(clampi(idx - 1, 0, line2d.points.size() - 1))
		var cur_point := position + line2d.get_point_position(idx)
		if Geometry2D.segment_intersects_segment(point_a, point_b, prev_point, cur_point):
			return true

	return false
