extends Node2D
class_name Spawner

signal target_defeated(enemy: EnemyShip)

var EnemyShipScene = preload("res://object/target/enemy/enemy/enemy_ship/enemy_ship.tscn")

@onready var spawn1 = $Spawns/Spawn1
@onready var spawn2 = $Spawns/Spawn2
@onready var spawn3 = $Spawns/Spawn3
@onready var spawn4 = $Spawns/Spawn4
@onready var spawn5 = $Spawns/Spawn5
@onready var timer = $Timer

var spawns: Array[Node]
var wait_time = 3

func _ready():
	spawns = [spawn1, spawn2, spawn3, spawn4, spawn5]
	_position_spawns()
	timer.wait_time = 2
	timer.timeout.connect(_spawn)
	timer.start()

func _position_spawns():
	var spacing = Constant.SCREEN_HEIGHT / (spawns.size() + 1)
	for i in spawns.size():
		var y = spacing * (i + 1)
		spawns[i].position = Vector2(0, y)
	
func _spawn():
	var enemy_ship = EnemyShipScene.instantiate()
	var spawner = spawns.pick_random()
	enemy_ship.position = spawner.position
	enemy_ship.defeated.connect(_on_target_defeated)
	add_child(enemy_ship)
	
func _on_target_defeated(enemy: EnemyShip):
	target_defeated.emit(enemy)
