extends Node2D
class_name Level

@onready var waves = $Waves
@onready var blaster = $Blaster

const NUMBER_OF_WAVES = 3

var wave_factory = WaveFactory.new()
var loot_factory = LootFactory.new()
var waves_defeated := 0

func _ready() -> void:
	spawn_wave()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed('left_click'):
		var wave = get_current_wave()
		for target in wave.get_targets():
			var distance = target.position.distance_to(event.position)
			if distance < blaster.radius:
				var is_bullseye = distance < target.BULLSEYE_RADIUS
				target.take_damage(blaster.damage_amount, is_bullseye)
				target.freeze(blaster.freeze)
	
func spawn_wave():
	var wave = wave_factory.create()
	wave.defeated.connect(_on_wave_defeated)
	wave.target_defeated.connect(_on_target_defeated)
	waves.add_child(wave)
	
func _on_target_defeated(position: Vector2):
	var gold = loot_factory.create_gold()
	gold.position = position
	add_child(gold)
	
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
