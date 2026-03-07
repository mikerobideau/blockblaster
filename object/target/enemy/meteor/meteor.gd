extends Area2D
class_name Meteor

signal defeated(target: Area2D)

const DEFAULT_SPEED = 100

@onready var sprite = $Sprite2D
@onready var hit_box = $HitBox

@export var radius := 100
@export var bullseye_radius = 10
@export var speed: float = DEFAULT_SPEED
@export var health: float = 10
@export var is_fragment := false
@export var number_of_fragments = 3
@export var direction: Vector2

var size: Vector2
var base_polygon: PackedVector2Array

func _ready():
	rotation = randf() * TAU
	base_polygon = hit_box.polygon
	_resize()
	_start()
	
func _start():
	direction = _random_up_direction()

func _physics_process(delta: float):
	position += direction * speed * delta

func _random_up_direction():
	var x = deg_to_rad(randf_range(0, 180))
	return Vector2(cos(x), sin(x)).normalized()

func _resize():
	if sprite.texture:
		var texture_size = sprite.texture.get_size()
		sprite.scale = size / texture_size
	
	var scaled_polygon := PackedVector2Array()
	for p in base_polygon:
		scaled_polygon.append(Vector2(
			p.x * sprite.scale.x,
			p.y * sprite.scale.y
		))
	
	hit_box.polygon = scaled_polygon

func take_damage(amount: int):
	health = clamp(health - amount, 0, health)
	if health <= 0:
		defeat()

func _on_area_entered(area: Area2D) -> void:
	if area is Ship:
		area.take_damage(1)

func defeat():
	defeated.emit(self)
	queue_free()
