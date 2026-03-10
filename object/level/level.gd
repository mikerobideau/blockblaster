extends Node2D
class_name Level

var ProjectileScene = preload("res://object/blaster/projectile.tscn")
var EnergyScene = preload("res://object/blaster/energy/energy.tscn")
var CardScene = preload("res://object/ui/card/card.tscn")
var BlasterScene = preload("res://object/blaster/blaster.tscn")
var pea_shooter = preload("res://resource/blaster/pea_shooter.tres")
var lava_shooter = preload("res://resource/blaster/lava_shooter.tres")

@onready var targets = $Area2Ds
@onready var ship = $Ship
@onready var incoming_wave_label = $CanvasLayer/IncomingWave/Label
@onready var blaster = $CanvasLayer/BottomBar/HBox/Blaster
@onready var ultimate = $CanvasLayer/BottomBar/HBox/Ultimate
@onready var ability1 = $CanvasLayer/BottomBar/HBox/Ability1
@onready var health = $CanvasLayer/BottomBar/HBox/Health
@onready var menu = $Menu
@onready var spawner = $Spawner

const TARGET_DEFEATED_ULTIMATE_CHARGE = 10

var loot_factory = LootFactory.new()
var target_factory := TargetFactory.new()
var is_game_over := false

func _ready() -> void:
	#get_tree().debug_collisions_hint = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	ship.damage_taken.connect(_on_ship_damage_taken)
	health.game_over.connect(_on_game_over)
	blaster.fired.connect(_on_blaster_fired)
	blaster.ability1_fired.connect(_on_ability1_fired)
	blaster.set_ultimate(ultimate)
	blaster.set_ability1(ability1)
	spawner.set_blaster(blaster)
	spawner.set_ship(ship)
	spawner.target_defeated.connect(_on_target_defeated)
	spawner.incoming_wave_detected.connect(_on_incoming_wave)
	spawner.start()
	
func _on_game_over():
	if is_game_over == true:
		return
	is_game_over = true
	print_debug('game over')
	
func _pause():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	
func _unpause():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false
	
func _on_ship_damage_taken(amount: int):
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
	energy.texture = blaster.data.energy_icon
	add_child(energy)
	
func _on_ability1_fired(position: Vector2):
	_add_projectile(position)
	for target in get_children():
		if target is Target:
			var distance = target.position.distance_to(position)
			if distance < blaster.ability1.damage_radius:
				target.take_damage(blaster.ability1.damage_amount, false)

func _add_projectile(position: Vector2):
	var projectile = ProjectileScene.instantiate()
	projectile.position = position
	add_child(projectile)
	
#TODO: Will not work for meteor
func _on_target_defeated(target: Target):
	ultimate.charge(TARGET_DEFEATED_ULTIMATE_CHARGE)
	#_add_loot(target)
	
func _add_loot(target: Area2D):
	var loot_blaster = loot_factory.create_loot_blaster()
	loot_blaster.position = target.position
	loot_blaster.picked_up.connect(_preview_loot_blaster)
	add_child(loot_blaster)
		
func _preview_loot_blaster(loot_blaster: LootBlaster):
	loot_blaster.queue_free()
	_pause()
	var card = CardScene.instantiate()
	card.added.connect(_on_blaster_added)
	card.declined.connect(_on_blaster_declined)
	card.data = lava_shooter
	var camera = get_viewport().get_camera_2d()
	var center = camera.get_screen_center_position()
	card.global_position = center
	menu.add_child(card)
		
func _on_blaster_added(data: BlasterData):
	_clear_menu()
	_unpause()
	blaster.update(data)
	
func _on_blaster_declined():
	_clear_menu()
	_unpause()
	
func _clear_menu():
	for child in menu.get_children():
		child.queue_free()
	
func _on_incoming_wave(wave: WaveData):
	incoming_wave_label.visible = true
	for i in range(Constant.INCOMING_WAVE_NOTICE_TIME, 0, -1):
		incoming_wave_label.visible = true
		incoming_wave_label.text = 'Incoming ' + wave.resource_name + ' in %d ' % i
		await get_tree().create_timer(1.0).timeout
	incoming_wave_label.visible = false
	
func level_clear():
	print_debug('Level clear!')

func _random_position() -> Vector2:
	return Vector2(randi() % Constant.SCREEN_WIDTH, randi() % Constant.SCREEN_HEIGHT)
