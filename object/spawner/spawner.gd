extends Node2D
class_name Spawner

signal target_defeated(enemy: EnemyShip)
signal incoming_wave_detected(wave: WaveData)
signal level_cleared_countdown_started()
signal level_cleared()


var EnemyShipScene = preload("res://object/target/enemy/enemy/enemy_ship/enemy_ship.tscn")
var PopupScene = preload("res://object/target/enemy/enemy_popup/enemy_popup.tscn")
var MeteorScene = preload("res://object/target/enemy/meteor/meteor.tscn")
var CrystalScene = preload("res://object/target/enemy/crystal/crystal.tscn")
var GoldScene = preload("res://object/loot/gold/gold.tscn")

@onready var wave_generator = $WaveGenerator
@onready var left_spawn1 = $LeftSpawns/Spawn1
@onready var left_spawn2 = $LeftSpawns/Spawn2
@onready var left_spawn3 = $LeftSpawns/Spawn3
@onready var left_spawn4 = $LeftSpawns/Spawn4
@onready var left_spawn5 = $LeftSpawns/Spawn5
@onready var right_spawn1 = $RightSpawns/Spawn1
@onready var right_spawn2 = $RightSpawns/Spawn2
@onready var right_spawn3 = $RightSpawns/Spawn3
@onready var right_spawn4 = $RightSpawns/Spawn4
@onready var right_spawn5 = $RightSpawns/Spawn5
@onready var timer = $Timer

@export var blaster: Blaster
@export var ship: Ship

var left_spawns: Array[Node]
var right_spawns: Array[Node]
var spawn_regions: Array[Array]
var spawn_occupied := {}
var wait_time = 1

func _ready():
	right_spawns = [right_spawn1, right_spawn2, right_spawn3, right_spawn4, right_spawn5]
	left_spawns = [left_spawn1, left_spawn2, left_spawn3, left_spawn4, left_spawn5]
	spawn_regions = [left_spawns, right_spawns]
	_reset_occupied()
	_position_spawns()
	
func start():
	var waves = [wave_generator.generate_calm_wave(), wave_generator.generate_attack_wave(), wave_generator.generate_calm_wave(),  wave_generator.generate_attack_wave()]
	for wave in waves:
		incoming_wave_detected.emit(wave)
		await get_tree().create_timer(Constant.INCOMING_WAVE_NOTICE_TIME, false).timeout
		await _spawn_wave(wave)	
	level_cleared_countdown_started.emit()
	await get_tree().create_timer(Constant.LEVEL_CLEAR_NOTICE_TIME, false).timeout
	level_cleared.emit()
	
func _spawn_wave(wave: WaveData):
	for group in wave.enemy_groups:
		await _spawn_enemy_group(group)
		if wave.wait_interval:
			await get_tree().create_timer(wave.wait_interval, false).timeout
		
func _spawn_enemy_group(group: EnemyGroupData):
	var count = randi_range(group.min_count, group.max_count)
	for i in range(count):
		var region = spawn_regions.pick_random()
		var spawn = _get_free_spawn(region)
		_spawn_enemy_at(group.enemy_type, region, spawn)
		await get_tree().create_timer(group.wait_interval, false).timeout
	
func _spawn_enemy_at(enemy_type: EnemyGroupData.EnemyType, region: Array[Node], spawn: Node):
	match enemy_type:
		EnemyGroupData.EnemyType.METEOR:
			_spawn_meteor(region, spawn)
		EnemyGroupData.EnemyType.ENEMY_SHIP:
			_spawn_enemy_ship(region, spawn)
		EnemyGroupData.EnemyType.POPUP:
			_spawn_popup(region, spawn)
		_:
			pass
	
func set_blaster(b: Blaster):
	blaster = b
	
func set_ship(s: Ship):
	ship = s
	
func _reset_occupied():
	for spawn in left_spawns + right_spawns:
		spawn_occupied[spawn] = false

func _position_spawns():
	var right_spacing = Constant.SCREEN_HEIGHT / (right_spawns.size() + 1)
	for i in right_spawns.size():
		var right_y = right_spacing * (i + 1)
		right_spawns[i].position = Vector2(Constant.SCREEN_WIDTH, right_y)
	
	var left_spacing = Constant.SCREEN_HEIGHT / (left_spawns.size() + 1)
	for i in left_spawns.size():
		var left_y = left_spacing * (i + 1)
		left_spawns[i].position = Vector2(0, left_y)
	
func _get_free_spawn(region: Array[Node]):
	var free := []
	for spawn in region:
		if not spawn_occupied[spawn]:
			free.append(spawn)
	if free.is_empty():
		return null
	return free.pick_random()

func _spawn_enemy_ship(region: Array[Node], spawn: Node):
	var enemy_ship = EnemyShipScene.instantiate()
	enemy_ship.global_position = spawn.global_position
	enemy_ship.defeated.connect(_on_target_defeated)
	enemy_ship.direction = Vector2.RIGHT if region == left_spawns else Vector2.LEFT
	add_child(enemy_ship)
	
func _spawn_popup(region: Array[Node], spawn: Node):
	var enemy_ship = PopupScene.instantiate()
	if spawn == null:
		return
	spawn_occupied[spawn] = true
	enemy_ship.spawn = spawn
	enemy_ship.global_position = spawn.global_position
	enemy_ship.defeated.connect(_on_target_defeated)
	enemy_ship.removed.connect(_on_target_removed)
	enemy_ship.direction = Vector2.RIGHT if region == left_spawns else Vector2.LEFT
	add_child(enemy_ship)
	
func _spawn_meteor(region: Array[Node], spawn: Node):
	var meteor = MeteorScene.instantiate()
	meteor.global_position = spawn.global_position
	meteor.defeated.connect(_on_target_defeated)
	var y = randf_range(-1, 1)
	var x = 1 if region == left_spawns else -1
	meteor.direction = Vector2(x, y).normalized()
	add_child(meteor)
	
func _on_target_defeated(target: Target):
	target_defeated.emit(target)
	if target.spawn:
		spawn_occupied[target.spawn] = false
	if target is Meteor:
		_spawn_crystals(target)
	if target is Crystal:
		_spawn_gold(target)
		
func _on_target_removed(target: Target):
	if target.spawn:
		spawn_occupied[target.spawn] = false
		
func _spawn_crystals(target: Target):
	var count = randi() % 3
	for i in range(count):
		var crystal = CrystalScene.instantiate()
		crystal.global_position = target.global_position
		crystal.defeated.connect(_on_target_defeated)
		add_child(crystal)
		
func _spawn_gold(target: Target):
	var count = randi() % 10
	for i in range(count):
		var gold = GoldScene.instantiate()
		gold.global_position = target.global_position
		gold.set_blaster(blaster)
		gold.set_ship(ship)
		gold.collected.connect(_on_gold_collected)
		add_child(gold)
		
func _on_gold_collected(gold: Gold):
	gold.queue_free()
	
