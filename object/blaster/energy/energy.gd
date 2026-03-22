extends Ammo
class_name Energy

@export var radius: int

func _physics_process(delta: float):
	position += direction * speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area is Target:
		if !area.is_defeated:
			area.take_damage(damage)
			queue_free()
