extends Node
class_name WaveGenerator

var Timeline = preload("res://object/spawner/timeline.gd")
var TimelineEvent = preload("res://object/spawner/timeline_event.gd")
var coins = preload("res://resource/enemy_group/coins.tres")
var meteor_shower = preload("res://resource/enemy_group/meteor_shower.tres")
var linear_ships = preload("res://resource/enemy_group/linear_ships.tres")
var triple_homing = preload("res://resource/enemy_group/triple_homing.tres")
var patrol = preload("res://resource/enemy_group/patrol.tres")
var popup_ships = preload("res://resource/enemy_group/popup_ships.tres")

var padding := 100
	
func create() -> WaveData:
	var wave = WaveData.new()
	wave.resource_name = 'wave'
	wave.timeline = Timeline.new()
	var t = 0.0
	t = add_perimeter(wave.timeline, EnemyGroupData.EnemyType.HOMING, t, 2, 10)
	t = add_stream(wave.timeline, EnemyGroupData.EnemyType.METEOR, t, 2, 5)
	return wave
	
func add_stream(timeline: Timeline, type: EnemyGroupData.EnemyType, start_time: float, count: int, interval: int):
	for i in range(count):
		var event := TimelineEvent.new()
		event.time = start_time + i * interval
		event.scene = type
		event.position = get_offscreen_spawn_position()
		timeline.events.append(event)
	return start_time + count * interval

func add_perimeter(timeline: Timeline, type: EnemyGroupData.EnemyType, start_time: float, count: int, interval: int):
	for i in range(count):
		var event := TimelineEvent.new()
		event.time = start_time
		event.scene = type
		event.position = get_offscreen_spawn_position()
		timeline.events.append(event)
	return start_time + interval
	
func generate_popup_wave():
	var wave = WaveData.new()
	wave.resource_name = 'popup'
	var timeline = Timeline.new()
	var positions = [get_top_left_position(), get_top_right_position(), get_bottom_left_position(), get_bottom_right_position()]
	for pos in positions:
		var event = TimelineEvent.new()
		event.time = 1
		event.scene = EnemyGroupData.EnemyType.POPUP
		event.position = pos
		timeline.events.append(event)
	wave.timeline = timeline
	return wave

func get_offscreen_spawn_position():
	var side = randi() % 4
	match side:
		0: #top
			return Vector2(randf_range(0, Constant.SCREEN_WIDTH), -padding)
		1: #right
			return Vector2(Constant.SCREEN_WIDTH + padding, randf_range(0, Constant.SCREEN_HEIGHT))
		2: #bottom
			return Vector2(randf_range(0, Constant.SCREEN_WIDTH), Constant.SCREEN_HEIGHT + padding)
		3: #left
			return Vector2(randf_range(0, Constant.SCREEN_WIDTH), Constant.SCREEN_HEIGHT + padding)

func get_top_left_position():
	return Vector2(0, padding)

func get_top_right_position():
	return Vector2(Constant.SCREEN_WIDTH, padding)
	
func get_bottom_left_position():
	return Vector2(0, Constant.SCREEN_HEIGHT - padding)

func get_bottom_right_position():
	return Vector2(Constant.SCREEN_WIDTH, Constant.SCREEN_HEIGHT - padding)
