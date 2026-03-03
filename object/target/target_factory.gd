extends RefCounted
class_name TargetFactory

var TargetScene = preload("res://object/target/target.tscn")

var min_size := 50
var max_size := 100
var fragment_radius := 30

func create() -> Target:
	var scene = TargetScene.instantiate()
	scene.radius = randf_range(min_size, max_size)
	return scene

func create_fragment() -> Target:
	var scene = TargetScene.instantiate()
	scene.radius = fragment_radius
	scene.is_fragment = true
	scene.number_of_fragments = 0
	return scene
