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
	print_debug('Ammo _ready — texture: ', texture)
	print_debug('Ammo _ready — sprite: ', sprite)
	if texture:
		sprite.texture = texture
		print_debug('Ammo _ready — sprite.texture after set: ', sprite.texture)
	print_debug('sprite visible: ', sprite.visible)
	print_debug('sprite modulate: ', sprite.modulate)
	print_debug('sprite z_index: ', sprite.z_index)

func _physics_process(delta: float):
	position += direction * speed * delta
