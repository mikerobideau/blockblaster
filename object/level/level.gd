extends Node2D
class_name Level

var ProjectileScene = preload("res://object/blaster/projectile.tscn")
var EnergyScene = preload("res://object/blaster/energy/energy.tscn")
var CardScene = preload("res://object/ui/card/card.tscn")
var BlasterScene = preload("res://object/blaster/blaster.tscn")

@onready var camera = $Camera2D
@onready var background = $BackgroundCanvas/Background
@onready var targets = $Area2Ds
@onready var ship = $Ship
@onready var incoming_wave_label = $CanvasLayer/IncomingWave/Label
@onready var game_state_label = $CanvasLayer/GameState
@onready var blaster_ui = $CanvasLayer/BottomBar/HBox/BlasterUi
@onready var ultimate = $CanvasLayer/BottomBar/HBox/Ultimate
@onready var ability1_ui = $CanvasLayer/BottomBar/HBox/Ability1
@onready var health = $CanvasLayer/BottomBar/HBox/Health
@onready var money = $CanvasLayer/BottomBar/HBox/Money
@onready var menu = $CanvasLayer/Menu
@onready var spawner = $Spawner
@onready var environment_spawner = $EnvironmentSpawner

const TARGET_DEFEATED_ULTIMATE_CHARGE = 10
const ZONES = [
	[0,     "shallows"],
	[3000,  "reef"],
	[7000,  "midnight"],
	[12000, "hydrothermal"],
	[18000, "bioluminescent"],
]
 
var current_zone_index := 0
var is_game_over := false
var wave_gen = WaveGenerator.new()
var blaster: PlayerBlaster

func _ready() -> void:	
	background.set_biome('shallows')
	#get_tree().debug_collisions_hint = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	camera.ship = ship
	ship.camera = camera
	ship.damage_taken.connect(_on_ship_damage_taken)
	health.game_over.connect(_on_game_over)
	blaster = ship.blaster
	blaster.setup(blaster.default_blaster_data, ship.emitter)
	blaster.set_ship(ship)
	blaster.set_ultimate(ultimate)
	blaster_ui.update(blaster.data)
	spawner.set_blaster(blaster)
	spawner.set_ship(ship)
	spawner.target_defeated.connect(_on_target_defeated)
	spawner.incoming_wave_detected.connect(_on_incoming_wave)
	spawner.gold_collected.connect(_on_gold_collected)
	spawner.health_collected.connect(_on_health_collected)
	spawner.loot_blaster_collected.connect(_on_loot_blaster_collected)
	spawner.loot_ability_collected.connect(_on_loot_ability_collected)
	environment_spawner.camera = camera
	environment_spawner.blaster = blaster
	environment_spawner.ship = ship
	environment_spawner.gold_collected.connect(_on_gold_collected)
	environment_spawner.health_collected.connect(_on_health_collected)
	environment_spawner.loot_blaster_collected.connect(_on_loot_blaster_collected)
	environment_spawner.loot_ability_collected.connect(_on_loot_ability_collected)
	_start()
	
func _process(delta: float):
	_update_zone()
	
func _update_zone():
	var next_index := current_zone_index + 1
	if next_index >= ZONES.size():
		return
	var next_threshold: float = ZONES[next_index][0]
	if camera.global_position.x >= next_threshold:
		current_zone_index = next_index
		var biome: String = ZONES[current_zone_index][1]
		background.set_biome(biome)
		
	
func _start():
	#environment_spawner.start()
	var waves = []
	var wave_number = 1
	var min_difficulty = 1
	var max_difficulty = 500
	var a = min_difficulty
	var b = min_difficulty * 2
	while a <= max_difficulty:
		waves.append(wave_gen.create(a, wave_number))
		var next = a + b
		a = b
		b = next
		wave_number += 1
		
	#for wave in waves:
	#	spawner.start_wave(wave)
	#	await spawner.wave_complete
	#	await get_tree().create_timer(2, false).timeout
		
	#await _on_level_cleared_countdown_started()
	#_on_level_clear()
	
func _on_game_over():
	if is_game_over == true:
		return
	is_game_over = true
	_pause()
	game_state_label.text = 'GAME OVER'
	
func _on_level_clear():
	_pause()
	incoming_wave_label.visible = false
	game_state_label.text = 'LEVEL CLEAR'
	
func _pause():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	
func _unpause():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false
	
func _on_gold_collected(gold: Gold):
	money.add(gold.value)	
	
func _on_health_collected(h: LootHealth):
	health.heal(h.value)

func _on_ship_damage_taken(amount: int):
	health.take_damage(amount)

func _add_projectile(position: Vector2):
	var projectile = ProjectileScene.instantiate()
	projectile.position = position
	add_child(projectile)
	
func _on_target_defeated(target: Target):
	ultimate.charge(TARGET_DEFEATED_ULTIMATE_CHARGE)
		
func _on_loot_blaster_collected(loot_blaster: LootBlaster):
	print_debug('loot blaster collected')
	loot_blaster.queue_free()
	_pause()
	var card = CardScene.instantiate()
	card.added.connect(_on_blaster_added)
	card.declined.connect(_on_blaster_declined)
	card.data = loot_blaster.data
	var camera = get_viewport().get_camera_2d()
	var center = camera.get_screen_center_position()
	card.global_position = center
	menu.add_child(card)
	
func _on_loot_ability_collected(loot_ability: LootAbility):
	print_debug('loot ability collected')
	loot_ability.queue_free()
	_pause()
	var card = CardScene.instantiate()
	card.added.connect(_on_ability_added)
	card.declined.connect(_on_ability_declined)
	card.data = loot_ability.data
	var camera = get_viewport().get_camera_2d()
	var center = camera.get_screen_center_position()
	card.global_position = center
	menu.add_child(card)
		
func _on_blaster_added(data: BlasterData):
	_clear_menu()
	_unpause()
	blaster_ui.update(data)
	blaster.setup(data, ship.emitter)
	
func _on_blaster_declined():
	_clear_menu()
	_unpause()
	
func _on_ability_added(data: AbilityData):
	_clear_menu()
	_unpause()
	ability1_ui.update(data)
	#ability1.setup(data, ship.emitter)
	
func _on_ability_declined():
	_clear_menu()
	_unpause()
	
func _clear_menu():
	for child in menu.get_children():
		child.queue_free()
	
func _on_level_cleared_countdown_started():
		await _update_incoming_message_label('Level clear', Constant.LEVEL_CLEAR_NOTICE_TIME)
	
func _on_incoming_wave(wave: WaveData):
	_update_incoming_message_label('Incoming ' + wave.resource_name, Constant.INCOMING_WAVE_NOTICE_TIME)

func _update_incoming_message_label(text: String, countdown):
	incoming_wave_label.visible = true
	for i in range(countdown, 0, -1):
		incoming_wave_label.visible = true
		incoming_wave_label.text = text + ' in %d... ' % i
		await get_tree().create_timer(1.0, false).timeout
	incoming_wave_label.visible = false

func _random_position() -> Vector2:
	return Vector2(randi() % Constant.SCREEN_WIDTH, randi() % Constant.SCREEN_HEIGHT)
