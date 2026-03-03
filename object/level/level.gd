extends Node2D
class_name Level

var ProjectileScene = preload("res://object/blaster/projectile.tscn")

@onready var waves = $Waves
@onready var blaster = $Blaster

const NUMBER_OF_WAVES = 3

var wave_factory = WaveFactory.new()
var loot_factory = LootFactory.new()
var waves_defeated := 0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	spawn_wave()
	blaster.fired.connect(_on_blaster_fired)
	
func _on_blaster_fired(position: Vector2):
	_add_projectile(position)
	var wave = get_current_wave()
	for target in wave.get_targets():
		var distance = target.position.distance_to(position)
		if distance < blaster.radius:
			var is_bullseye = distance < target.BULLSEYE_RADIUS
			target.take_damage(blaster.damage_amount, is_bullseye)
			target.freeze(blaster.freeze)	
	
func _add_projectile(position: Vector2):
	var projectile = ProjectileScene.instantiate()
	projectile.position = position
	add_child(projectile)
	
func spawn_wave():
	var wave = wave_factory.create()
	wave.defeated.connect(_on_wave_defeated)
	wave.target_defeated.connect(_on_target_defeated)
	waves.add_child(wave)
	
func _on_target_defeated(position: Vector2):
	var gold = loot_factory.create_gold()
	gold.position = position
	gold.set_blaster(blaster) #TODO: This will cause issues when switching blasters
	gold.collected.connect(_on_gold_collected)
	add_child(gold)
	
func _on_gold_collected(gold: Gold):
	print_debug('Gold collected')
	gold.queue_free()
	
func _on_wave_defeated():
	waves_defeated += 1
	if waves_defeated == NUMBER_OF_WAVES:
		level_clear()
	else:
		for wave in waves.get_children():
			wave.queue_free()
		spawn_wave()
		
func get_current_wave() -> Wave:
	return waves.get_child(0) as Wave
	
func level_clear():
	print_debug('Level clear!')

func _process(delta: float) -> void:
	pass
