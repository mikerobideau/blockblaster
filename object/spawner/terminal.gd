extends Area2D
class_name Terminal

func _on_area_entered(area: Area2D) -> void:
	if area is EnemyShip:
		area.queue_free()
