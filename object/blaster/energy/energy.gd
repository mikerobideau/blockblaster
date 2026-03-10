extends Ammo
class_name Energy

@export var radius: int

func _ready():
	direction = direction.normalized()
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float):
	position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body is Area2D:
		if body.has_method('take_damage'):
			body.take_damage(damage, false)
			queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is Target:
		area.take_damage(damage)
		Sound.play('enemy_hit')
		queue_free()
		
