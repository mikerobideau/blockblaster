extends Ammo
class_name Energy

func _init():
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float):
	position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body is Target:
		body.take_damage(damage, false)
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is EnemyShip or area is Meteor:
		area.take_damage(damage)
		queue_free()
