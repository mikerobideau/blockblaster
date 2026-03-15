extends Resource
class_name TimelineEvent

@export var time: float
@export var scene: Target.TargetType
@export var position: Vector2
@export var is_leader := false
@export var follow_leader := false
@export var waypoint: Vector2
