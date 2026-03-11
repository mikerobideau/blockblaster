extends Node2D
class_name Spawner

signal target_defeated(target: Target)

var EnemyShipScene = preload("res://object/target/enemy/enemy/enemy_ship/enemy_ship.tscn")
var PopupScene = preload("res://object/target/enemy/enemy_popup/enemy_popup.tscn")
var PatrolScene = preload("res://object/target/enemy/enemy_patrol/enemy_patrol.tscn")
var MeteorScene = preload("res://object/target/enemy/meteor/meteor.tscn")
var CrystalScene = preload("res://object/target/enemy/crystal/crystal.tscn")
var GoldScene = preload("res://object/loot/gold/gold.tscn")

@onready var music_player = $MusicPlayer

@export var blaster: Blaster
@export var ship: Ship

var timeline = preload("res://resource/timeline/level1_timeline.tres")
var event_index := 0

func  _ready():
	pass
	
func _process(delta):
	var time = Time.get_ticks_msec() / 1000.0
	if event_index >= timeline.events.size():
		return

	while event_index < timeline.events.size() and timeline.events[event_index].time <= time:
		_spawn_event(timeline.events[event_index])
		event_index += 1
		
func _spawn_event(event: TimelineEvent):
	var scene: Area2D
	match event.scene:
		EnemyGroupData.EnemyType.PATROL:
			scene = PatrolScene.instantiate()
		EnemyGroupData.EnemyType.METEOR:
			scene = MeteorScene.instantiate()
		_:
			return
	scene.global_position = event.position
	scene.direction = Vector2.RIGHT
	if scene is Target:
		scene.defeated.connect(_on_target_defeated)
	add_child(scene)

func _on_target_defeated(target: Target):
	target_defeated.emit(target)
	if target is Meteor:
		_spawn_crystals(target)
	if target is Crystal:
		_spawn_gold(target)

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
	
func set_blaster(b: Blaster):
	blaster = b
	
func set_ship(s: Ship):
	ship = s
