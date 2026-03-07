extends Area2D
class_name Ammo

@onready var hit_box = $HitBox
@onready var sprite = $Sprite2D

@export var damage := 1
@export var radius := 5
@export var color := Color.GREEN
@export var speed := 800

var direction := Vector2.ZERO
var texture: Texture2D

func _ready():
	direction = direction.normalized()
	
	var shape = hit_box.shape as CircleShape2D
	if shape:
		shape.radius = radius
	
	if sprite.texture:
		sprite.scale = (Vector2(radius, radius) * 2) / sprite.texture.get_size()
	
	_init()

func _physics_process(delta: float):
	position += direction * speed * delta
