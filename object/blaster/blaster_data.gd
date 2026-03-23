extends Resource
class_name BlasterData

enum Pattern { LINE, RING, SPREAD, PARALLEL_SPREAD }

# Shared
@export var name: String
@export var scene: PackedScene       # energy/projectile scene to spawn
@export var scale := Vector2(1, 1)
@export var damage := 1
@export var speed := 500
@export var color: Color

# Player only
@export var icon: Texture2D
@export var energy_icon: Texture2D
@export var radius: int
@export var ultimate_damage: int
@export var ultimate_radius: int
@export var ultimate_duration: int

# Enemy only
@export var sound: Sound.Effect
@export var autostart := true
@export var pattern := Pattern.LINE
@export var projectile_count := 1
@export var burst_size := 1
@export var burst_delay := 0.2
@export var fire_timeout := 5
