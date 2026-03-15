extends RefCounted
class_name TargetDatabase

static var data := {
	Target.TargetType.METEOR: preload("res://resource/target/meteor.tres"),
	Target.TargetType.ENEMY_SHIP: preload("res://resource/target/enemy_ship.tres"),
}

static func find(type: Target.TargetType) -> TargetData:
	return data[type]
