extends Area2D
class_name Ammo

enum Source { PLAYER, ENEMY }

@onready var hit_box = $HitBox
@onready var sprite = $Sprite2D

@export var source: Source = Source.PLAYER
@export var damage := 1
@export var texture: Texture2D
@export var speed := 800
@export var radius: int

var direction := Vector2.ZERO

func _ready():
	if texture:
		sprite.texture = texture
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float):
	position += direction * speed * delta

func set_texture(t: Texture2D):
	texture = t
	if sprite:
		sprite.texture = t

func _on_body_entered(body: Node) -> void:
	if body is Area2D and body.has_method('take_damage'):
		body.take_damage(damage, false)
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	match source:
		Source.PLAYER:
			if area is Target and not area.is_defeated:
				area.take_damage(damage)
				queue_free()
		Source.ENEMY:
			if area is Ship:
				area.take_damage(damage)
				queue_free()
