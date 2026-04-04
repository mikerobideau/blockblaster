extends Camera2D

@export var deadzone_left = 0.2
@export var deadzone_right = 0.4
@export var catch_speed = 8.0
@export var ship: Ship
@export var viewport_size: Vector2

var target_x = 0.0

func _ready():
	viewport_size = get_viewport().get_visible_rect().size
	
func set_ship(s: Ship):
	ship = s
	target_x = s.global_position.x

func _physics_process(delta: float):
	print_debug('processing physics')
	if ship == null:
		print_debug('no ship!')
		return
		
	var half_w := viewport_size.x / 2.0
	var ship_screen_x := ship.global_position.x - (global_position.x - half_w) #ship position from left
	var ship_screen_fraction := ship_screen_x / viewport_size.x
	
	if ship_screen_fraction > deadzone_right:
		print_debug('past the deadzone!')
		var overshoot = (ship_screen_fraction - deadzone_right) * viewport_size.x
		target_x += overshoot
		
	#Smooth camera towards target_x
	global_position.x = lerp(global_position.x, target_x, catch_speed * delta)
