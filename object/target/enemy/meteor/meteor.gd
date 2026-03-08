extends Target

var size: Vector2
var base_polygon: PackedVector2Array

func _ready():
	fire_timer.wait_time = fire_timeout
	fire_timer.timeout.connect(_fire)
	fire_timer.start()
	rotation = randf() * TAU
	base_polygon = hit_box.polygon
	_resize()
	_start()
	
func _start():
	direction = _random_up_direction()

func _physics_process(delta: float):
	position += direction * speed * delta

func _random_up_direction():
	var x = deg_to_rad(randf_range(0, 180))
	return Vector2(cos(x), sin(x)).normalized()

func _resize():
	if sprite.texture:
		var texture_size = sprite.texture.get_size()
		sprite.scale = size / texture_size
	
	var scaled_polygon := PackedVector2Array()
	for p in base_polygon:
		scaled_polygon.append(Vector2(
			p.x * sprite.scale.x,
			p.y * sprite.scale.y
		))
	
	hit_box.polygon = scaled_polygon
