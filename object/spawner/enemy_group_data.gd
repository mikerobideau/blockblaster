extends Resource
class_name EnemyGroupData

enum EnemyType {
	METEOR,
	ENEMY_SHIP,
	POPUP
}

@export var enemy_type: EnemyType
@export var min_count: int
@export var max_count: int
@export var wait_inverval: float
