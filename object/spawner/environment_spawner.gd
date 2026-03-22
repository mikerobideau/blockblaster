extends Node2D
class_name EnvironmentSpawner

signal gold_collected(gold: Gold)
signal health_collected(health: LootHealth)
signal loot_blaster_collected(loot_blaster: LootBlaster)

var Meteor = preload("res://object/target/visual/environmental/meteor.tscn")

var scene: PackedScene
var interval_min := 1
var interval_max := 4
var loot_resolver := LootResolver.new()
var blaster: Blaster
var ship: Ship

func start():
	while true:
		await get_tree().create_timer(randf_range(interval_min, interval_max), false).timeout
		var data = Database.target.find_by_type(Target.TargetType.METEOR)
		var instance_data = data.duplicate()
		var scene = data.scene.instantiate()
		scene.data = data
		scene.global_position = _get_spawn_position()
		scene.defeated.connect(_on_target_defeated)
		add_child(scene)

func _get_spawn_position() -> Vector2:
	var side = randi() % 4
	match side:
		0: return Vector2(randf_range(0, Constant.SCREEN_WIDTH), -100)
		1: return Vector2(randf_range(0, Constant.SCREEN_WIDTH), Constant.SCREEN_HEIGHT + 100)
		2: return Vector2(-100, randf_range(0, Constant.SCREEN_HEIGHT))
		3: return Vector2(Constant.SCREEN_WIDTH + 100, randf_range(0, Constant.SCREEN_HEIGHT))
		_: return Vector2.ZERO

func _on_target_defeated(target: Target):
	if target.data and target.data.loot_table:
		loot_resolver.resolve(
			target.data.loot_table,
			target.global_position,
			self,
			blaster,
			ship
		)
		
func set_blaster(b: Blaster):
	blaster = b
	
func set_ship(s: Ship):
	ship = s
