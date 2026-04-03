extends Resource
class_name TargetData

@export var type: Target.TargetType
@export var scene: PackedScene
@export var difficulty: int
@export var min_wave := 1
@export var loot_table: LootTable
@export var scale := Vector2(1, 1)
@export var is_variable_scale := false #ignore scale and let spawner determine scale
@export var health: int = 3
@export var is_leader := false
@export var randomize_rotation := false
@export var spawn_behavior: SpawnBehaviorData
@export var movement: MovementData
@export var blaster: BlasterData
@export var shake_on_damage := true
@export var debris_color := Color.WHITE
@export var debris_initial_velocity_min := 200
@export var debris_initial_velocity_max := 300
@export var debris_scale_amount_min := 2
@export var debris_scale_amount_max := 10
@export var debris_sphere_radius := 128
