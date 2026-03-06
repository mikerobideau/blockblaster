extends Node2D
class_name Level

var ProjectileScene = preload("res://object/blaster/projectile.tscn")
var EnergyScene = preload("res://object/blaster/energy/energy.tscn")

@onready var targets = $Targets
@onready var ship = $Ship
@onready var blaster = $Blaster
@onready var ultimate = $CanvasLayer/BottomBar/HBox/Ultimate
@onready var ability1 = $CanvasLayer/BottomBar/HBox/Ability1
@onready var health = $CanvasLayer/BottomBar/Health

const NUMBER_OF_WAVES = 3
const WAVE_SIZE = 3
const TARGET_DEFEATED_ULTIMATE_CHARGE = 500

var wave_factory = WaveFactory.new()
var loot_factory = LootFactory.new()
var waves_defeated := 0
var target_factory := TargetFactory.new()
var is_game_over := false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	ship.take_damage.connect(_on_take_ship_damage)
	health.game_over.connect(_on_game_over)
	blaster.fired.connect(_on_blaster_fired)
	blaster.ability1_fired.connect(_on_ability1_fired)
	blaster.set_ultimate(ultimate)
	blaster.set_ability1(ability1)
	_spawn()
	
func _on_game_over():
	if is_game_over == true:
		return
	is_game_over = true
	print_debug('game over')
	
func _on_take_ship_damage(amount: int):
	health.take_damage(amount)

func _on_blaster_fired(position: Vector2):
	var start_pos =  ship.emitter.global_position
	var target_pos = get_global_mouse_position()
	var energy = EnergyScene.instantiate()
	energy.global_position = start_pos
	energy.direction = target_pos - start_pos
	energy.damage = blaster.damage
	energy.radius = blaster.radius
	energy.speed = blaster.speed
	add_child(energy)
	
func _on_ability1_fired(position: Vector2):
	_add_projectile(position)
	for target in targets.get_children():
		var distance = target.position.distance_to(position)
		if distance < blaster.ability1.damage_radius:
			target.take_damage(blaster.ability1.damage_amount, false)

func _add_projectile(position: Vector2):
	var projectile = ProjectileScene.instantiate()
	projectile.position = position
	add_child(projectile)
	
func _spawn():
	for i in range(WAVE_SIZE):
		var target = target_factory.create_wimpy()
		target.speed = 100
		target.position = _random_position()
		target.defeated.connect(_on_target_defeated)
		targets.add_child(target)
	for i in range(WAVE_SIZE):
		var target = target_factory.create_meteor()
		target.speed = 100
		target.position = _random_position()
		target.defeated.connect(_on_target_defeated)
		targets.add_child(target)
	
func _on_target_defeated(target: Target):
	_add_crystals(target)
		
func _on_crystal_defeated(target: Target):
	ultimate.charge(TARGET_DEFEATED_ULTIMATE_CHARGE)
	var gold = loot_factory.create_gold()
	gold.position = target.position
	gold.set_blaster(blaster) #TODO: This will cause issues when switching blasters
	gold.set_ship(ship)
	gold.collected.connect(_on_gold_collected)
	add_child(gold)
	
func _add_crystals(target: Target):
	for i in range(target.number_of_fragments):
		var crystal = target_factory.create_crystal()
		crystal.speed = 100
		crystal.position = target.position
		crystal.defeated.connect(_on_crystal_defeated)
		targets.add_child(crystal)
	
func _on_gold_collected(gold: Gold):
	gold.queue_free()
	
func _on_wave_defeated():
	waves_defeated += 1
	if waves_defeated == NUMBER_OF_WAVES:
		level_clear()
	else:
		for wave in targets.get_children():
			wave.queue_free()
		_spawn()
		
func get_current_wave() -> Wave:
	return targets.get_child(0) as Wave
	
func level_clear():
	print_debug('Level clear!')

func _random_position() -> Vector2:
	return Vector2(randi() % Constant.SCREEN_WIDTH, randi() % Constant.SCREEN_HEIGHT)
