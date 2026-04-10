# environment_spawner.gd
# Streams procedurally generated clusters of environmental objects into the world.
# Objects spawn ON the terrain curves from TerrainGenerator rather than a flat line.
# Attach to a Node2D in your level scene.

extends Node2D

@export var camera: NodePath
@export var generator: NodePath

@export var scenes_shallows_primary:        Array[PackedScene] = []
@export var scenes_shallows_secondary:      Array[PackedScene] = []
@export var scenes_reef_primary:            Array[PackedScene] = []
@export var scenes_reef_secondary:          Array[PackedScene] = []
@export var scenes_cave_primary:            Array[PackedScene] = []
@export var scenes_cave_secondary:          Array[PackedScene] = []
@export var scenes_midnight_primary:        Array[PackedScene] = []
@export var scenes_midnight_secondary:      Array[PackedScene] = []
@export var scenes_hydrothermal_primary:    Array[PackedScene] = []
@export var scenes_hydrothermal_secondary:  Array[PackedScene] = []
@export var scenes_bioluminescent_primary:  Array[PackedScene] = []
@export var scenes_bioluminescent_secondary:Array[PackedScene] = []

@export var spawn_lookahead:  float = 400.0
@export var cluster_gap_min:  float = 400.0
@export var cluster_gap_max:  float = 900.0
@export var despawn_margin:   float = 200.0

var camera_node:    Camera2D
var generator_node: TerrainGenerator
var viewport_w:     float
var next_spawn_x:   float
var current_biome:  String = "shallows"
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	camera_node    = get_node(camera)
	generator_node = get_node(generator)
	viewport_w     = get_viewport_rect().size.x
	rng.randomize()
	next_spawn_x = viewport_w + spawn_lookahead


func _process(_delta: float) -> void:
	if camera_node == null:
		return

	var cam_right := camera_node.global_position.x + viewport_w / 2.0
	var cam_left  := camera_node.global_position.x - viewport_w / 2.0

	while next_spawn_x < cam_right + spawn_lookahead:
		spawn_cluster(next_spawn_x)
		next_spawn_x += rng.randf_range(cluster_gap_min, cluster_gap_max)

	for child in get_children():
		if child.global_position.x < cam_left - despawn_margin:
			child.queue_free()


func set_biome(biome_name: String) -> void:
	current_biome = biome_name


# ---- Cluster spawning ---------------------------------------------------

func spawn_cluster(origin_x: float) -> void:
	var profile       := get_biome_profile(current_biome)
	var primary_pool:   Array = profile[0]
	var secondary_pool: Array = profile[1]
	var anchor_count:   int   = profile[2]
	var filler_count:   int   = profile[3]
	var spread_x:       float = profile[4]

	if primary_pool.is_empty():
		return

	# Anchors spawn on the floor
	for i in anchor_count:
		var x := origin_x + rng.randf_range(0.0, spread_x)
		var y := get_floor_y(x)
		place_object(primary_pool, x, y)

	# Fillers: mix of floor and ceiling objects depending on biome
	var filler_origin_x := origin_x + rng.randf_range(0.0, spread_x * 0.6)
	for i in filler_count:
		if secondary_pool.is_empty():
			break
		var x := filler_origin_x + rng.randf_range(-80.0, 80.0)
		# Cave and canopy place some objects on the ceiling
		var on_ceiling := current_biome in ["cave", "canopy"] and rng.randf() < 0.4
		var y := get_ceiling_y(x) if on_ceiling else get_floor_y(x)
		place_object(secondary_pool, x, y, on_ceiling)


func place_object(pool: Array, x: float, y: float, inverted: bool = false) -> void:
	if pool.is_empty():
		return
	var scene: PackedScene = pool[rng.randi() % pool.size()]
	var obj: Node2D = scene.instantiate()
	obj.global_position = Vector2(x, y)
	# Flip objects that grow from the ceiling
	if inverted:
		obj.scale.y = -1.0
	add_child(obj)


# ---- Terrain helpers ----------------------------------------------------

func get_floor_y(world_x: float) -> float:
	if generator_node == null:
		return get_viewport_rect().size.y - 80.0
	return generator_node.get_floor_y(world_x)


func get_ceiling_y(world_x: float) -> float:
	if generator_node == null:
		return 80.0
	return generator_node.get_ceiling_y(world_x)


# ---- Biome profiles -----------------------------------------------------
# [primary_pool, secondary_pool, anchor_count, filler_count, spread_x]

func get_biome_profile(biome: String) -> Array:
	match biome:
		"shallows":
			return [scenes_shallows_primary, scenes_shallows_secondary,      2, 3, 500.0]
		"reef":
			return [scenes_reef_primary, scenes_reef_secondary,              4, 6, 300.0]
		"cave":
			return [scenes_cave_primary, scenes_cave_secondary,              3, 5, 200.0]
		"midnight":
			return [scenes_midnight_primary, scenes_midnight_secondary,      1, 1, 200.0]
		"hydrothermal":
			return [scenes_hydrothermal_primary, scenes_hydrothermal_secondary, 3, 2, 180.0]
		"bioluminescent":
			return [scenes_bioluminescent_primary, scenes_bioluminescent_secondary, 2, 4, 350.0]
		_:
			return [scenes_shallows_primary, scenes_shallows_secondary,      2, 3, 500.0]
