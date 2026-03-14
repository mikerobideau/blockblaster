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
var target_db := TargetDatabase.new()
	
func create(budget: int, total_time: int) -> WaveData:
	var t = 0.0
	var wave = WaveData.new()
	wave.resource_name = 'wave'
	wave.timeline 	= Timeline.new()
	
	while budget > 0:
		print_debug('==========')
		print_debug('Budget is ' + str(budget) + ' and time is ' + str(t))
		var count = randi_range(1, 2)
		var interval = 0
		var candidates = Target.TargetType.values().filter(func(d): 
			return target_db.find(d).difficulty * count <= budget
		)
		if candidates.size() == 0:
			break
		var target = candidates.pick_random()
		var data = target_db.find(target)
		var pattern = data.supported_patterns.pick_random()
		match pattern:
			Pattern.Type.STREAM:
				print_debug('Adding stream of ' + str(count))
				t = add_stream(wave.timeline, target, t, count, interval)
			Pattern.Type.LEFT_RIGHT_STREAM:
				print_debug('Adding left-right stream of ' + str(count))
				t = add_left_right_stream(wave.timeline, target, t, count, interval)
			Pattern.Type.PERIMETER:
				print_debug('Adding perimeter of ' + str(count))
				t = add_perimeter(wave.timeline, target, t, count, interval)
			Pattern.Type.FOUR_CORNERS:
				print_debug('Adding four corners of ' + str(count))
				t = add_four_corners(wave.timeline, target, t, interval)
		
		var cost = data.difficulty * count
		print_debug('cost is ' + str(data.difficulty) + ' * ' + str(count) + ' = ' + str(cost))
		budget -= cost
		
		if budget > 0:
			var avg_cost = 2 #TODO: Improve this logic to consider actual average
			var ships_remaining_estimate = max(1, budget / avg_cost)
			var avg_interval_per_ship = (total_time - t) / ships_remaining_estimate
			var batch_interval = avg_interval_per_ship * count
			t += batch_interval * randf_range(0.85, 1.15)
	return wave
	
func add_stream(timeline: Timeline, type: Target.TargetType, start_time: float, count: int, interval: int):
	for i in range(count):
		var event := TimelineEvent.new()
		event.time = start_time + i * interval
		event.scene = type
		event.position = get_offscreen_spawn_position()
		timeline.events.append(event)
	return start_time + count * interval

func add_left_right_stream(timeline: Timeline, type: Target.TargetType, start_time: float, count: int, interval: int):
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
	
func add_four_corners(timeline: Timeline, type: Target.TargetType, start_time: float, interval: int):
	var positions = [get_top_left_position(), get_top_right_position(), get_bottom_left_position(), get_bottom_right_position()]
	for pos in positions:
		var event = TimelineEvent.new()
		event.time = start_time
		event.scene = type
		event.position = pos
		timeline.events.append(event)
	return start_time + interval

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
