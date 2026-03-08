extends RefCounted
class_name TargetFactory

var EnemyShipScene = preload("res://object/target/enemy/enemy/enemy_ship/enemy_ship.tscn")
var MeteorScene = preload("res://object/target/enemy/meteor/meteor.tscn")
var CrystalScene = preload("res://object/target/enemy/crystal/crystal.tscn")

func create_crystal() -> Crystal:
	return CrystalScene.instantiate()

func create_meteor() -> Meteor:
	var min_size := 50
	var max_size := 250
	var meteor = MeteorScene.instantiate()
	var size = randf_range(50, 250)
	meteor.size = Vector2(size, size)
	meteor.number_of_fragments = randf_range(0, 5)
	return meteor

func create_meteor_fragment() -> Meteor:
	var scene = MeteorScene.instantiate()
	scene.is_fragment = false
	return scene

func create_enemy_ship() -> EnemyShip:
	return EnemyShipScene.instantiate()
