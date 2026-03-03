extends Node2D
class_name Crosshair

@export var size := 10.0
@export var thickness := 2.0
@export var gap := 4.0
@export var color := Color.WHITE

func _process(_delta):
	global_position = get_global_mouse_position()
	queue_redraw()

func _draw():
	# Horizontal left
	draw_line(
		Vector2(-size - gap, 0),
		Vector2(-gap, 0),
		color,
		thickness
	)

	# Horizontal right
	draw_line(
		Vector2(gap, 0),
		Vector2(size + gap, 0),
		color,
		thickness
	)

	# Vertical up
	draw_line(
		Vector2(0, -size - gap),
		Vector2(0, -gap),
		color,
		thickness
	)

	# Vertical down
	draw_line(
		Vector2(0, gap),
		Vector2(0, size + gap),
		color,
		thickness
	)
