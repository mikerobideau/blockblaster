extends Resource
class_name BlasterData

enum Pattern { LINE, RING, SPREAD, PARALLEL_SPREAD }

# Shared
@export var name: String
@export var scene: PackedScene
@export var scale := Vector2(1, 1)
@export var damage := 1
@export var speed := 500
@export var fire_timeout := 5.0

@export var icon: Texture2D
@export var sound: Sound.Effect
@export var ultimate_damage: int
@export var ultimate_duration: int
@export var autostart := true
@export var pattern := Pattern.LINE
@export var projectile_count := 1
@export var burst_size := 1
@export var burst_delay := 0.2
