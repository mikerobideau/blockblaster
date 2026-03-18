extends Node
class_name WaveGenerator

var Timeline = preload("res://object/spawner/timeline.gd")
var TimelineEvent = preload("res://object/spawner/timeline_event.gd")

var padding := 100

func create(budget: int, total_time: float, ) -> WaveData:
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
		var type = formation.targets.pick_random()
		var data = Database.target.find_by_type(type)
		for i in range(formation.count):
			_add_timeline_event(wave.timeline, t, type, data, formation)
		budget -= data.difficulty * formation.count * formation.cost_multiplier
		t += interval
	
	return wave

func _add_timeline_event(timeline: Timeline, t: int, type: Target.TargetType, data: TargetData, formation: Formation):
	var event := TimelineEvent.new()
	event.time = t
	event.scene = type
	event.position = get_spawn_position(formation)
	if data.movement is TravelToPointMovement:
		event.waypoint = _random_waypoint()
	timeline.events.append(event)

func _add_leader_formation(timeline: Timeline, type: Target.TargetType, formation: Formation, start_time: float, interval: float):
	var data = Database.target.find_by_type(type)
	var leader_pos = get_spawn_position(formation)
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

func get_spawn_position(formation: Formation) -> Vector2:
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
	
func _random_waypoint():
	return Vector2(
		randf_range(Constant.SCREEN_WIDTH * 0.25, Constant.SCREEN_WIDTH * 0.75),
		randf_range(Constant.SCREEN_HEIGHT * 0.25, Constant.SCREEN_HEIGHT * 0.6)
	)
