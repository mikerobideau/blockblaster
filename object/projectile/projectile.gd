extends Area2D
class_name Ammo

@onready var hit_box = $HitBox
@onready var sprite = $Sprite2D

@export var damage := 10
@export var radius := 5
@export var color := Color.GREEN
@export var speed := 800

var direction := Vector2.ZERO

func _ready():
	direction = direction.normalized()
	hit_box.shape.radius = radius
	
	if sprite.texture:
		var texture_size = sprite.texture.get_size()
		sprite.scale = Vector2(radius, radius) / texture_size
		
	_init()

func _physics_process(delta: float):
	position += direction * speed * delta
