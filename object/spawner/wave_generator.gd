extends Node
class_name WaveGenerator

var Timeline = preload("res://object/spawner/timeline.gd")
var TimelineEvent = preload("res://object/spawner/timeline_event.gd")
var coins = preload("res://resource/enemy_group/coins.tres")
var padding := 100
var target_db := TargetDatabase.new()
	
func create(budget: int, total_time: int) -> WaveData:
	print_debug('creating')
	var t = 0.0
	var wave = WaveData.new()
	wave.resource_name = 'wave'
	wave.timeline 	= Timeline.new()
	
	while budget > 0:
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
				#print_debug('Adding stream of ' + str(count))
				t = add_stream(wave.timeline, target, t, count, interval)
		
		var cost = data.difficulty * count
		#print_debug('cost is ' + str(data.difficulty) + ' * ' + str(count) + ' = ' + str(cost))
		budget -= cost
		
		if budget > 0:
			var avg_cost = 2 #TODO: Improve this logic to consider actual average
			var ships_remaining_estimate = max(1, budget / avg_cost)
			var avg_interval_per_ship = (total_time - t) / ships_remaining_estimate
			var batch_interval = avg_interval_per_ship * count
			t += batch_interval * randf_range(0.85, 1.15)
			
	print_debug('no budget left')
	return wave
	
func add_stream(timeline: Timeline, type: Target.TargetType, start_time: float, count: int, interval: int):
	var data = target_db.find(type)
	for i in range(count):
		var event := TimelineEvent.new()
		event.time = start_time + i * interval
		event.scene = type
		event.position = get_spawn_position(data.spawn_behavior)
		timeline.events.append(event)
	return start_time + count * interval

func get_spawn_position(behavior: SpawnBehaviorData) -> Vector2:
	print_debug('getting spawn position')
	match behavior.location:
		SpawnBehaviorData.Location.ANY_EDGE:
			return get_offscreen_spawn_position()
		SpawnBehaviorData.Location.LEFT_OR_RIGHT_EDGE:
			return get_left_right_spawn_position()
		SpawnBehaviorData.Location.TOP_EDGE:
			return get_random_top_position()
		_:
			return Vector2.ZERO

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
