extends RefCounted
class_name TargetFactory

var TargetScene = preload("res://object/target/target.tscn")
var WimpyScene = preload("res://object/target/enemy/wimpy/wimpy.tscn")
var MeteorScene = preload("res://object/target/enemy/meteor/meteor.tscn")
var CrystalScene = preload("res://object/target/enemy/crystal/crystal.tscn")

func create_crystal() -> Target:
	return CrystalScene.instantiate()

func create_meteor() -> Meteor:
	var min_size := 50
	var max_size := 250
	var meteor = MeteorScene.instantiate()
	var size = randf_range(50, 250)
	meteor.size = Vector2(size, size)
	meteor.number_of_fragments = randf_range(0, 5)
	return meteor

func create_meteor_fragment() -> Target:
	var scene = MeteorScene.instantiate()
	scene.is_fragment = false
	return scene

func create_wimpy() -> Wimpy:
	return WimpyScene.instantiate()
