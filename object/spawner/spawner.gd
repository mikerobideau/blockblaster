extends Node2D
class_name Spawner

signal target_defeated(enemy: EnemyShip)

var EnemyShipScene = preload("res://object/target/enemy/enemy/enemy_ship/enemy_ship.tscn")

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

var left_spawns: Array[Node]
var right_spawns: Array[Node]

var spawn_regions: Array[Array]
var wait_time = 1

func _ready():
	right_spawns = [right_spawn1, right_spawn2, right_spawn3, right_spawn4, right_spawn5]
	left_spawns = [left_spawn1, left_spawn2, left_spawn3, left_spawn4, left_spawn5]
	spawn_regions = [left_spawns, right_spawns]
	_position_spawns()
	timer.wait_time = wait_time
	timer.timeout.connect(_spawn)
	timer.start()

func _position_spawns():
	var right_spacing = Constant.SCREEN_HEIGHT / (right_spawns.size() + 1)
	for i in right_spawns.size():
		var right_y = right_spacing * (i + 1)
		right_spawns[i].position = Vector2(Constant.SCREEN_WIDTH, right_y)
	
	var left_spacing = Constant.SCREEN_HEIGHT / (left_spawns.size() + 1)
	for i in left_spawns.size():
		var left_y = left_spacing * (i + 1)
		left_spawns[i].position = Vector2(0, left_y)
	
func _spawn():
	var enemy_ship = EnemyShipScene.instantiate()
	var region = spawn_regions.pick_random()
	var spawner = region.pick_random()
	enemy_ship.global_position = spawner.global_position
	enemy_ship.defeated.connect(_on_target_defeated)
	enemy_ship.direction = Vector2.RIGHT if region == left_spawns else Vector2.LEFT
	add_child(enemy_ship)
	
func _on_target_defeated(enemy: EnemyShip):
	target_defeated.emit(enemy)
