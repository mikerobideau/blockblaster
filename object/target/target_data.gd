extends Resource
class_name TargetData

@export var scene: PackedScene
@export var health: int
@export var difficulty: int
@export var randomize_rotation := false
@export var movement: MovementData
@export var blaster: EnemyBlasterData
@export var supported_patterns: Array[Pattern.Type]
