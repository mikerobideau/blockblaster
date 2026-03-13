extends RefCounted
class_name TargetDatabase

static var data := {
	Target.TargetType.METEOR: preload("res://resource/target/meteor.tres"),
	Target.TargetType.ENEMY_SHIP: preload("res://resource/target/enemy_ship.tres"),
	Target.TargetType.PATROL: preload("res://resource/target/patrol.tres"),
	Target.TargetType.HOMING: preload("res://resource/target/homing.tres"),
	Target.TargetType.POPUP: preload("res://resource/target/popup.tres")
}

static func find(type: Target.TargetType) -> TargetData:
	return data[type]
