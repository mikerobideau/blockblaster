extends Node2D
class_name Spawner

signal target_defeated(target: Target)
signal incoming_wave_detected(wave: WaveData)
signal wave_complete(wave: WaveData)
signal gold_collected(gold: Gold)

var TargetScene = preload('res://object/target/target.tscn')
var CrystalScene = preload("res://object/target/enemy/crystal/crystal.tscn")
var GoldScene = preload("res://object/loot/gold/gold.tscn")
var TelegraphScene = preload("res://object/target/visual/telegraph/telegraph.tscn")

@onready var music_player = $MusicPlayer

@export var blaster: Blaster
@export var ship: Ship

var event_index := 0
var current_wave: WaveData
var start_time := 0.0
var target_db := TargetDatabase.new()
var leader_ref: Target

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

	var time = Time.get_ticks_msec() / 1000.0 - start_time
	var events = current_wave.timeline.events

	while event_index < events.size() and events[event_index].time <= time:
		_spawn_event(events[event_index])
		event_index += 1
		
	if event_index >= events.size():
		_wave_complete()
		
func _wave_complete():
	wave_complete.emit(current_wave)
	current_wave = null
	
func _spawn_event(event: TimelineEvent) -> void:
	if event.is_gold:
		_spawn_gold_at(event.position, event.gold_count)
		return
	if event.telegraph:
		_telegraph_then_spawn(event)
	else:
		_do_spawn(event)
	
func _do_spawn(event: TimelineEvent) -> Target:
	var data = Database.target.find_by_type(event.scene)
	var instance_data = data.duplicate()
	if instance_data.movement:
		instance_data.movement = instance_data.movement.duplicate()
		if instance_data.movement is TravelToPointMovement:
			instance_data.movement.waypoint = event.waypoint

	var instance = _spawn_single_enemy(instance_data, event.position)
	instance.data = instance_data

	if event.follow_leader and leader_ref != null:
		instance.parent_target = leader_ref
	if event.follow_leader and leader_ref == null:
		push_warning('Spawner attempted to spawn a follower with no leader defined')
	if event.is_leader:
		leader_ref = instance

	return instance

func _telegraph_then_spawn(event: TimelineEvent):
	var telegraph = TelegraphScene.instantiate()
	telegraph.global_position = event.position
	add_child(telegraph)
	await get_tree().create_timer(Constant.TELEGRAPH_DURATION, false).timeout
	telegraph.queue_free()
	_do_spawn(event)
		
func _spawn_single_enemy(data: TargetData, position: Vector2) -> Target:
	var instance = data.scene.instantiate()
	instance.data = data
	instance.global_position = position
	if instance is Target:
		instance.defeated.connect(_on_target_defeated)
	add_child(instance)
	return instance

func _on_target_defeated(target: Target):
	target_defeated.emit(target)
	if target is Meteor:
		_spawn_crystals(target)
	if target is Crystal:
		_spawn_gold_from_target(target)

func _spawn_crystals(target: Target):
	var count = randi() % 3
	for i in range(count):
		var crystal = CrystalScene.instantiate()
		crystal.global_position = target.global_position
		crystal.defeated.connect(_on_target_defeated)
		add_child(crystal)

func _spawn_gold_at(position: Vector2, count: int):
	for i in range(count):
		var gold = GoldScene.instantiate()
		gold.global_position = position
		gold.collected.connect(_on_gold_collected)
		gold.set_blaster(blaster)
		gold.set_ship(ship)
		gold.collected.connect(_on_gold_collected)
		add_child(gold)
		
func _spawn_gold_from_target(target: Target):
	var bonus = randi_range(1, 6)
	var count : int
	if bonus == 6:
		count = 100
	else:	
		count = randi_range(0, 5)
	for i in range(count):
		var gold = GoldScene.instantiate()
		gold.global_position = target.global_position
		gold.set_blaster(blaster)
		gold.set_ship(ship)
		gold.collected.connect(_on_gold_collected)
		add_child(gold)
	
func _on_gold_collected(gold: Gold):
	gold_collected.emit(gold)
	gold.queue_free()
	
func set_blaster(b: Blaster):
	blaster = b
	
func set_ship(s: Ship):
	ship = s
