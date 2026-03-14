extends Target
class_name EnemyPopup

var EnergyFireScene = preload("res://object/target/enemy/energy/energy_fire/energy_fire.tscn")

@export var popup_distance := 50.0
@export var popup_time := 0.15
@export var wait_to_pop_down := 2.0

var start_pos: Vector2

func _ready():
	damage_radius = 100
	damage = 1
	direction = Vector2.RIGHT if global_position.x < Constant.SCREEN_WIDTH / 2 else Vector2.LEFT
	rotation = -PI / 2 if direction == Vector2.LEFT else PI / 2
	_popup()
	fire_timer.start()
	
func _popup():

	start_pos = global_position
	var end_pos = global_position + direction * popup_distance
	var tween = create_tween()
	tween.tween_property(self, 'global_position', end_pos, popup_time)	
	tween.tween_callback(_fire)
	tween.tween_interval(wait_to_pop_down)
	tween.tween_callback(_pop_down)
	
func _pop_down():
	var end_pos = start_pos
	var tween = create_tween()
	tween.tween_property(self, 'global_position', start_pos, popup_time)	
	tween.tween_callback(_remove)

func _physics_process(delta: float):
	pass

func _get_energy_scene():
	var energy = EnergyFireScene.instantiate()
	energy.global_position = emitter.global_position
	energy.direction = Vector2.UP.rotated(rotation)
	return energy
