extends Ability
class_name BarrelRoll

var spin_speed := 1200
	
func _physics_process(delta: float):
	if not active:
		return
	ship.rotation += deg_to_rad(spin_speed) * delta
