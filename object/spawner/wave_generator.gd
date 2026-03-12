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
	#t = add_perimeter(wave.timeline, Target.TargetType.ENEMY_SHIP, t, 10, 2)
	t = add_stream(wave.timeline, Target.TargetType.ENEMY_SHIP, t, 5, 1)
	return wave
	
func choose_random_enemy_type():
	pass
	
func add_stream(timeline: Timeline, type: Target.TargetType, start_time: float, count: int, interval: int):
	for i in range(count):
		var event := TimelineEvent.new()
		event.time = start_time + i * interval
		event.scene = type
		event.position = get_left_right_spawn_position()
		timeline.events.append(event)
	return start_time + count * interval

func add_perimeter(timeline: Timeline, type: Target.TargetType, start_time: float, count: int, interval: int):
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
		event.scene = Target.TargetType.POPUP
		event.position = pos
		timeline.events.append(event)
	wave.timeline = timeline
	return wave

func get_offscreen_spawn_position() -> Vector2:
	var side = randi() % 4
	match side:
		0:
			return get_random_top_position()
		1:
			return get_random_right_position()	
		2:
			return get_random_bottom_position()
		3:
			return get_random_left_position()
		_:
			return Vector2.ZERO

func get_left_right_spawn_position() -> Vector2:
	var side = randi() % 2
	match side:
		0:
			return get_random_left_position()
		1:
			return get_random_right_position()
		_:
			return Vector2.ZERO

func get_random_top_position() -> Vector2:
	return Vector2(randf_range(0, Constant.SCREEN_WIDTH), -padding)

func get_random_bottom_position() -> Vector2:
	return Vector2(randf_range(0, Constant.SCREEN_WIDTH), Constant.SCREEN_HEIGHT + padding)
	
func get_random_left_position() -> Vector2:
	return Vector2(-padding, randf_range(0, Constant.SCREEN_HEIGHT))

func get_random_right_position() -> Vector2:
	return Vector2(Constant.SCREEN_WIDTH + padding, randf_range(0, Constant.SCREEN_HEIGHT))
	
func get_top_left_position():
	return Vector2(0, padding)

func get_top_right_position():
	return Vector2(Constant.SCREEN_WIDTH, padding)
	
func get_bottom_left_position():
	return Vector2(0, Constant.SCREEN_HEIGHT - padding)

func get_bottom_right_position():
	return Vector2(Constant.SCREEN_WIDTH, Constant.SCREEN_HEIGHT - padding)
