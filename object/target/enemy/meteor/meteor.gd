extends Target
class_name Meteor

var center_offset = 500

func _ready():
	var center = get_viewport_rect().size / 2
	var offset = Vector2(
		randf_range(-center_offset, center_offset),
		randf_range(-center_offset, center_offset)
	)
	var dest = center + offset
	var to_dest = dest - global_position
	var distance = to_dest.length()
	direction = to_dest.normalized()
	speed = 200
	rotation = randf() * TAU
