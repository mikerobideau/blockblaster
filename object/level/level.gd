extends Node2D
class_name Level

@onready var waves = $Waves

const NUMBER_OF_WAVES = 3

var wave_factory = WaveFactory.new()
var waves_defeated := 0

func _ready() -> void:
	spawn_wave()
	
func spawn_wave():
	var wave = wave_factory.create()
	wave.defeated.connect(_on_wave_defeated)
	waves.add_child(wave)
	
func _on_wave_defeated():
	waves_defeated += 1
	if waves_defeated == NUMBER_OF_WAVES:
		level_clear()
	else:
		spawn_wave()
	
func level_clear():
	print_debug('Level clear!')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
