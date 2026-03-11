extends Node2D
class_name Spawner

signal target_defeated(target: Target)
signal incoming_wave_detected(wave: WaveData)
signal wave_complete(wave: WaveData)

var EnemyShipScene = preload("res://object/target/enemy/enemy/enemy_ship/enemy_ship.tscn")
var PopupScene = preload("res://object/target/enemy/enemy_popup/enemy_popup.tscn")
var PatrolScene = preload("res://object/target/enemy/enemy_patrol/enemy_patrol.tscn")
var MeteorScene = preload("res://object/target/enemy/meteor/meteor.tscn")
var HomingScene = preload("res://object/target/enemy/enemy_homing/enemy_homing.tscn")
var CrystalScene = preload("res://object/target/enemy/crystal/crystal.tscn")
var GoldScene = preload("res://object/loot/gold/gold.tscn")

@onready var music_player = $MusicPlayer

@export var blaster: Blaster
@export var ship: Ship

var event_index := 0
var current_wave: WaveData
var start_time := 0.0

func  _ready():
	pass
	
func start_wave(wave: WaveData):
	incoming_wave_detected.emit(wave)
	await get_tree().create_timer(Constant.INCOMING_WAVE_NOTICE_TIME, false).timeout
	current_wave = wave
	event_index = 0
	start_time = Time.get_ticks_msec() / 1000.0
	
func _process(delta):
	if current_wave == null:
		return

	var time = Time.get_ticks_msec() / 1000.0
	var events = current_wave.timeline.events

	while event_index < events.size() and events[event_index].time <= time:
		_spawn_event(events[event_index])
		event_index += 1
		
	if event_index >= events.size():
		_wave_complete()
		
func _wave_complete():
	wave_complete.emit(current_wave)
	current_wave = null
		
func _spawn_event(event: TimelineEvent):
	var scene: Area2D
	match event.scene:
		EnemyGroupData.EnemyType.PATROL:
			scene = PatrolScene.instantiate()
		EnemyGroupData.EnemyType.POPUP:
			scene = PopupScene.instantiate()
		EnemyGroupData.EnemyType.METEOR:
			scene = MeteorScene.instantiate()
		EnemyGroupData.EnemyType.HOMING:
			scene = HomingScene.instantiate()
		_:
			return
	scene.global_position = event.position
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
