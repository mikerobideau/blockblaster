extends CPUParticles2D
class_name Projectile

func _ready():
	emitting = true
	await finished
	queue_free()
