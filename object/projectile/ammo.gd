extends Area2D
class_name Ammo

@onready var hit_box = $HitBox
@onready var sprite = $Sprite2D

@export var damage := 1
@export var texture: Texture2D
@export var speed := 800

var direction := Vector2.ZERO

# In Ammo._ready()
func _ready():
	if texture:
		sprite.texture = texture

func _physics_process(delta: float):
	position += direction * speed * delta

func set_texture(texture: Texture2D):
	self.texture = texture
	if sprite:
		sprite.texture = texture
