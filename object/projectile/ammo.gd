extends Area2D
class_name Ammo

@onready var hit_box = $HitBox
@onready var sprite = $Sprite2D
@export var damage := 1
@export var texture: Texture2D
@export var color := Color.GREEN
@export var speed := 800

var direction := Vector2.ZERO

func _physics_process(delta: float):
	position += direction * speed * delta
