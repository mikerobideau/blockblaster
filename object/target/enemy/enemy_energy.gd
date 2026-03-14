extends Ammo
class_name EnemyEnergy

func _ready():
	direction = direction.normalized()
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float):
	position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body is Ship:
		body.apply_hit()
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is Ship:
		print_debug('Taking energy damage ' + str(damage))
		area.take_damage(damage)
