extends Target
class_name EnemyPatrol

var orbit_radius := 400
var orbit_speed := 1
var orbit_angle := 0.0
var orbit_center := Vector2.ZERO
var orbiting = false

func _ready():
	super()
	speed = 500
	var viewport = get_viewport_rect().size
	orbit_center = viewport / 2
	fire_timer.start()

func _physics_process(delta):
	if !orbiting:
		var to_center = orbit_center - global_position
		var distance = to_center.length()
		
		if distance < orbit_radius:
			orbiting = true
			orbit_angle = (global_position - orbit_center).angle()
			return
		var direction = to_center.normalized()
		global_position += direction * speed * delta
		rotation = direction.angle() + sprite_forward_offset

	else:
		orbit_angle += orbit_speed * delta
		var offset = Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius
		global_position = orbit_center + offset
		rotation = orbit_angle - PI / 2
