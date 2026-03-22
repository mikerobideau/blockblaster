extends Node2D
class_name Spawner

signal target_defeated(target: Target)
signal incoming_wave_detected(wave: WaveData)
signal wave_complete(wave: WaveData)
signal gold_collected(gold: Gold)

enum WaveState {
	IDLE,
	SPAWNING,    #timeline still has events to process
	CLEARING,    #timeline exhausted, waiting for targets to despawn
	COMPLETE
}

var TargetScene = preload('res://object/target/target.tscn')
var CrystalScene = preload("res://object/target/enemy/crystal/crystal.tscn")
var GoldScene = preload("res://object/loot/gold/gold.tscn")
var TelegraphScene = preload("res://object/target/visual/telegraph/telegraph.tscn")

@onready var music_player = $MusicPlayer

@export var blaster: Blaster
@export var ship: Ship

var wave_state := WaveState.IDLE
var current_wave: WaveData
var event_index := 0
var start_time := 0.0
var target_db := TargetDatabase.new()
var leader_ref: Target
var active_targets: Array[Target] = []
var loot_resolver := LootResolver.new()

func  _ready():
	pass
	
func start_wave(wave: WaveData):
	print_debug('start wave')
	incoming_wave_detected.emit(wave)
	await get_tree().create_timer(Constant.INCOMING_WAVE_NOTICE_TIME, false).timeout
	print_debug('wave wait timeout complete')
	current_wave = wave
	event_index = 0
	start_time = Time.get_ticks_msec() / 1000.0
	wave_state = WaveState.SPAWNING
	
func _process(delta):
	match wave_state:
		WaveState.IDLE:
			return
		WaveState.SPAWNING:
			_process_timeline(delta)
		WaveState.CLEARING:
			if active_targets.is_empty():
				_on_wave_cleared()
		WaveState.COMPLETE:
			return
		_:
			return
	
func _process_timeline(delta):
	var time = Time.get_ticks_msec() / 1000.0 - start_time
	var events = current_wave.timeline.events
	while event_index < events.size() and events[event_index].time <= time:
		_spawn_event(events[event_index])
		event_index += 1
	if event_index >= events.size():
		wave_state = WaveState.CLEARING

func _on_wave_cleared():
	wave_state = WaveState.COMPLETE
	wave_complete.emit(current_wave)
	current_wave = null
	wave_state = WaveState.IDLE	

func _check_wave_cleared():
	if active_targets.is_empty():
		wave_complete.emit(current_wave)
	
func _spawn_event(event: TimelineEvent) -> void:
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
		active_targets.append(instance)
		instance.defeated.connect(_on_target_defeated)
		instance.removed.connect(_on_target_removed)
	add_child(instance)
	return instance

func _on_target_defeated(target: Target):
	active_targets.erase(target)
	target_defeated.emit(target)
	if target.data and target.data.loot_table:
		loot_resolver.resolve(
			target.data.loot_table,
			target.global_position,
			self, 
			blaster,
			ship
		)
		
func _on_target_removed(target: Target):
	active_targets.erase(target)

func _on_gold_collected(gold: Gold):
	gold_collected.emit(gold)
	gold.queue_free()
	
func set_blaster(b: Blaster):
	blaster = b
	
func set_ship(s: Ship):
	ship = s
