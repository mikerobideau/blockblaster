extends Resource
class_name WaveData

enum Mood {
	CALM,
	MODERATE,
	INTENSE
}

@export var mood: Mood
@export var enemy_groups: Array[EnemyGroupData]
@export var wait_interval: float
