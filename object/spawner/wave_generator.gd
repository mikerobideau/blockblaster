extends Node
class_name WaveGenerator

var Timeline = preload("res://object/spawner/timeline.gd")
var TimelineEvent = preload("res://object/spawner/timeline_event.gd")

var padding := 100

func create(budget: int, total_time: float) -> WaveData:
	var budget_variation_min = 0.1
	var budget_variation_max = 0.3
	var base_interval := 5.0
	var interval_variation := 0
	var t = 0.0
	var wave = WaveData.new()
	wave.resource_name = 'wave'
	wave.timeline 	= Timeline.new()
	
	while t < total_time and budget > 0:
		var interval = base_interval + randf_range(-interval_variation, interval_variation)
		var tick_budget = clamp(randi_range(int(budget*budget_variation_min), int(budget*budget_variation_max)), 1, budget)
		var formation = Database.formation.find_random()
		#print_debug('Spawning ' + formation.resource_name + ' formation')
		var shared_pos := get_spawn_position(formation, 0) if formation.has_shared_position else Vector2.INF
		var type = formation.targets.pick_random()
		var data = Database.target.find_by_type(type)
		for i in range(formation.count):
			var spawn_time: float = t + i * formation.stream_interval
			_add_timeline_event(wave.timeline, spawn_time, type, data, formation, i, shared_pos)
			#_add_gold_event(wave.timeline, spawn_time, 1)
		budget -= data.difficulty * formation.count * formation.cost_multiplier
		t += interval
	
	return wave

func _add_timeline_event(timeline: Timeline, t: float, type: Target.TargetType, data: TargetData, formation: Formation, i: int, shared_pos: Vector2):
	var event := TimelineEvent.new()
	event.time = t
	event.scene = type
	event.position = shared_pos if formation.has_shared_position else get_spawn_position(formation, i)
	if data.movement != null:
		if data.movement is TravelToPointMovement:
			event.waypoint = get_waypoint(formation, event.position)
	else:
		push_warning('Attempted to add timeline event with no movement')
	if formation.pattern == formation.SpawnPattern.APPEAR:
		event.telegraph = true
	timeline.events.append(event)

func _add_gold_event(timeline: Timeline, t: float, count: int):
	var event := TimelineEvent.new()
	event.time = t
	event.position = get_onscreen_position()
	event.is_gold = true
	event.gold_count = count
	timeline.events.append(event)

func _add_leader_formation(timeline: Timeline, type: Target.TargetType, formation: Formation, start_time: float, interval: float, index: int):
	var data = Database.target.find_by_type(type)
	var leader_pos = get_spawn_position(formation, index)
	var follower_count = randi_range(3, 5)

	#print_debug('Adding leader at ' + str(start_time))
	var leader_event := TimelineEvent.new()
	leader_event.is_leader = true
	leader_event.time = start_time
	leader_event.scene = type
	leader_event.position = leader_pos
	timeline.events.append(leader_event)

	#TODO: Refactor random follower with new approach involving formations
	#var follower_type = target_db.random_follower()
	for i in range(follower_count):
		var follower_event_time = start_time + 1
		#print_debug('adding follower event at ' + str(follower_event_time))
		var event := TimelineEvent.new()
		event.time = follower_event_time 
		#event.scene = follower_type
		event.follow_leader = true
		event.position = leader_pos + Vector2(
			randf_range(-40, 40),
			randf_range(-40, 40)
		)
		timeline.events.append(event)

	return start_time + interval

func get_spawn_position(formation: Formation, i: int) -> Vector2:
	match formation.pattern:
		Formation.SpawnPattern.RANDOM:
			return get_offscreen_spawn_position()
		Formation.SpawnPattern.TOP:
			return get_random_top_position()
		Formation.SpawnPattern.BOTTOM:
			return get_random_bottom_position()
		Formation.SpawnPattern.LEFT:
			return get_random_left_position()
		Formation.SpawnPattern.RIGHT:
			return get_random_right_position()
		Formation.SpawnPattern.PINCER:
			return get_pincer_position(i)
		Formation.SpawnPattern.TOP_MARCH:
			return get_top_march_position(i, formation.count)
		Formation.SpawnPattern.APPEAR:
			return get_onscreen_position()
		_:
			return Vector2.ZERO

func get_waypoint(formation: Formation, spawn_pos: Vector2) -> Vector2:
	match formation.pattern:
		Formation.SpawnPattern.TOP_MARCH:
			return Vector2(spawn_pos.x, Constant.SCREEN_HEIGHT + padding)
		_:
			push_warning('Unable to determine waypoint because there was no matching formation pattern')
			return _random_waypoint()

func _random_waypoint():
	return Vector2(
		randf_range(Constant.SCREEN_WIDTH * 0.25, Constant.SCREEN_WIDTH * 0.75),
		randf_range(Constant.SCREEN_HEIGHT * 0.25, Constant.SCREEN_HEIGHT * 0.6)
	)

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

func get_onscreen_position() -> Vector2:
	return Vector2(randf_range(padding, Constant.SCREEN_WIDTH - padding), randf_range(padding, Constant.SCREEN_HEIGHT - padding))

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
	
func get_pincer_position(i: int):
	return get_random_right_position() if i % 2 == 0 else get_random_left_position()

func get_top_march_position(i: int, count: int) -> Vector2:
	var spacing = Constant.SCREEN_WIDTH / (count + 1.0)
	return Vector2(spacing * (i + 1), padding)
