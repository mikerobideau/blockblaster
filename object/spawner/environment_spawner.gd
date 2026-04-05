extends Node2D
class_name EnvironmentSpawner

signal gold_collected(gold: Gold)
signal health_collected(health: LootHealth)
signal loot_blaster_collected(loot_blaster: LootBlaster)
signal loot_ability_collected(loot_ability: LootAbility)

@export var resources: Array[Resource] = [
	preload("res://resource/target/anemone.tres")
]
@export var camera_path: NodePath
@export var spawn_lookahead := 200.0
@export var gap_min := 300.0
@export var gap_max := 700.0
@export var despawn_margin := 200.0
@export var ground_height = 0.0

var blaster: PlayerBlaster
var ship: Ship
var camera: Camera2D
var viewport_w: float
var next_spawn_x: float
var rng := RandomNumberGenerator.new()
var loot_resolver := LootResolver.new()

func _ready():
	viewport_w = get_viewport_rect().size.x
	rng.randomize()
	next_spawn_x = viewport_w + spawn_lookahead
	
func _process(delta: float):
	if camera == null or resources.is_empty():
		return
		
	var cam_right = camera.global_position.x + viewport_w / 2.0
	var cam_left = camera.global_position.x - viewport_w/ 2.0
	
	while next_spawn_x < cam_right + spawn_lookahead:
		spawn_object(next_spawn_x)
		next_spawn_x += rng.randf_range(gap_min, gap_max)
		
	for child in get_children():
		if child.global_position.x < cam_left - despawn_margin:
			child.queue_free()
	
func spawn_object(world_x: float):
	var data: TargetData = resources[rng.randi() % resources.size()]
	var obj: Target = data.scene.instantiate()
	obj.data = data
	var ground_y = get_viewport_rect().size.y - ground_height
	obj.global_position = Vector2(world_x, ground_y)
	obj.defeated.connect(_on_target_defeated)
	add_child(obj)

func _on_target_defeated(target: Target):
	if target.data and target.data.loot_table:
		loot_resolver.resolve(
			target.data.loot_table,
			target.global_position,
			self,
			blaster,
			ship
		)
