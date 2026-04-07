extends Node2D
class_name EnvironmentSpawner

signal gold_collected(gold: Gold)
signal health_collected(health: LootHealth)
signal loot_blaster_collected(loot_blaster: LootBlaster)
signal loot_ability_collected(loot_ability: LootAbility)

const ZONE_WIDTH = 1920

@export var resources: Array[Resource] = [
	preload("res://resource/target/anemone.tres")
]
@export var camera_path: NodePath
@export var spawn_lookahead := 200.0
@export var gap_min := 300.0
@export var gap_max := 700.0
@export var despawn_margin := 200.0
@export var ground_height = 0.0
@export var spawn_band_top := 0.55
@export var spawn_band_bottom := 0.92

var blaster: PlayerBlaster
var ship: Ship
var camera: Camera2D
var viewport_w: float
var viewport_h: float
var next_spawn_x: float
var rng := RandomNumberGenerator.new()
var loot_resolver := LootResolver.new()
var current_biome := "shallows"
var last_zone_right_edge: float = 0.0

func _ready():
	viewport_w = get_viewport_rect().size.x
	viewport_h = get_viewport_rect().size.y
	rng.randomize()
	spawn_zone(last_zone_right_edge)
	
func _process(delta: float):
	if camera == null or resources.is_empty():
		return
		
	if !next_spawn_x:
		next_spawn_x = camera.global_position.x + viewport_w / 2 + spawn_lookahead
		
	var cam_right = camera.global_position.x + get_viewport_rect().size.x / 2
		
	if last_zone_right_edge < cam_right + spawn_lookahead:
		spawn_zone(next_spawn_x)
		next_spawn_x += viewport_w + spawn_lookahead
	
func spawn_cluster(origin_x: float):
	var profile = get_biome_profile(current_biome)
	var primary_pool = profile[0]
	var secondary_pool = profile[1]
	
	if primary_pool.is_empty():
		return
		
	var anchor_count = profile[2]
	var filler_count = profile[3]
	var spread_x = profile[4]
	var height_variance = profile[5]
	
	var anchors_placed = 0
	while anchors_placed < anchor_count:
		var x := origin_x + rng.randf_range(0.0, spread_x)
		var y = get_spawn_y(height_variance)
		spawn_object(primary_pool, x, y)
		anchors_placed += 1
		
	#TODO: Add filler objects
	
func spawn_zone(x: int):
	var zone = preload("res://object/zone/zone.tscn").instantiate()
	zone.rng = rng
	add_child(zone)
	zone.global_position.x = last_zone_right_edge
	last_zone_right_edge += ZONE_WIDTH
	
func spawn_object(pool: Array[Resource], x: float, y: float):
	if pool.is_empty():
		return
	var data: TargetData = pool[rng.randi() % resources.size()]
	var obj: Target = data.scene.instantiate()
	obj.data = data
	var ground_y = get_viewport_rect().size.y - ground_height
	obj.global_position = Vector2(x, ground_y)
	obj.defeated.connect(_on_target_defeated)
	add_child(obj)
	
func get_spawn_y(height_variance: float):
	var band_top: = viewport_h * spawn_band_top
	var band_bottom = viewport_h * spawn_band_bottom
	var base_y = rng.randf_range(band_top, band_bottom)
	base_y += rng.randf_range(-height_variance, height_variance)
	return clamp(base_y, band_top, band_bottom)

func _on_target_defeated(target: Target):
	if target.data and target.data.loot_table:
		loot_resolver.resolve(
			target.data.loot_table,
			target.global_position,
			self,
			blaster,
			ship
		)

# ---- Biome profiles -----------------------------------------------------
# Returns [primary_pool, secondary_pool, anchor_count, filler_count, spread_x, height_variance]
#
# Biome character:
#   shallows     — loose, airy, wide spread, few anchors
#   reef         — dense, tall, tight clusters, lots of fillers
#   midnight     — sparse, isolated pillars, almost no fillers
#   hydrothermal — tight angry clusters around vent anchors
#   bioluminescent — medium density, high vertical variance for floating forms
 
func get_biome_profile(biome: String) -> Array:
	match biome:
		"shallows":
			return [resources, resources,
					2, 3, 500.0, 20.0]
		"reef":
			return [resources, resources,
					4, 6, 300.0, 60.0]
		"midnight":
			return [resources, resources,
					1, 1, 200.0, 10.0]
		"hydrothermal":
			return [resources, resources,
					3, 2, 180.0, 15.0]
		"bioluminescent":
			return [resources, resources,
					2, 4, 350.0, 80.0]
		_:
			return [resources, resources,
					2, 3, 500.0, 20.0]
