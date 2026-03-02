extends Node
class_name Wave

signal defeated()

const WAVE_SIZE := 3
var target_factory := TargetFactory.new()
var targets_defeated: Array[Target] = []

func _ready():
	spawn()
	
func spawn():
	for i in range(WAVE_SIZE):
		var target = target_factory.create()
		target.position = random_position()
		target.defeated.connect(_on_target_defeated)
		add_child(target)
		
func _on_target_defeated(target: Target):
	if !targets_defeated.has(target):
		targets_defeated.append(target)
	if targets_defeated.size() == WAVE_SIZE:
		defeated.emit()

func random_position() -> Vector2:
	return Vector2(randi() % Constant.SCREEN_WIDTH, randi() % Constant.SCREEN_HEIGHT)
