extends RefCounted
class_name TargetFactory

var TargetScene = preload("res://object/target/target.tscn")

func create() -> Target:
	return TargetScene.instantiate()
