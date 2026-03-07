extends Ammo
class_name EnemyEnergy

func _init():
	radius = 15
	damage = 1
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float):
	position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body is Ship:
		print_debug('body is ship')
		body.apply_hit()
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area is Ship:
		area.take_damage(damage)
