extends Resource
class_name TargetData

@export var type: Target.TargetType
@export var scene: PackedScene
@export var scale := Vector2(1, 1)
@export var health: int = 3
@export var difficulty: int
@export var is_leader := false
@export var randomize_rotation := false
@export var spawn_behavior: SpawnBehaviorData
@export var movement: MovementData
@export var blaster: EnemyBlasterData
@export var shake_on_damage := true
@export var yellow_burst_on_defeat := true
@export var debris_texture_1: Texture2D
@export var debris_texture_2: Texture2D
@export var debris_initial_velocity_min := 500
@export var debris_initial_velocity_max := 700
@export var debris_scale_amount_min := 0.05
@export var debris_scale_amount_max := 0.2
@export var debris_sphere_radius := 128.0
