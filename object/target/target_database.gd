extends RefCounted
class_name TargetDatabase

static var data := {
	Target.TargetType.METEOR: preload("res://resource/target/meteor.tres"),
	Target.TargetType.ENEMY_SHIP: preload("res://resource/target/enemy_ship.tres"),
	Target.TargetType.MINION: preload("res://resource/target/minion.tres")
}

static func find(type: Target.TargetType) -> TargetData:
	return data[type]
	
static func random_follower() -> int:
	var candidates := []
	for key in data.keys():
		var d: TargetData = data[key]
		if d.movement is TrackEnemyMovement:
			candidates.append(key)
	return candidates.pick_random() if candidates.size() > 0 else -1
