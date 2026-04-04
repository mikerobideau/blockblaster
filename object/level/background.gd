# background.gd
# Attach to a ColorRect that sits inside a CanvasLayer (layer = -1).
# The CanvasLayer handles screen pinning — no camera tracking needed.
# This script drives the shader biome transitions including shimmer colour.

extends ColorRect

@export var blend_speed := 0.8

# Each biome entry: [color_top, color_bottom, shimmer_color]
const BIOMES := {
	"shallows":       [Color(0.05, 0.25, 0.45), Color(0.02, 0.12, 0.28), Color(0.50, 0.90, 1.00)],
	"reef":           [Color(0.04, 0.20, 0.38), Color(0.01, 0.08, 0.20), Color(0.30, 0.85, 0.80)],
	"midnight":       [Color(0.02, 0.08, 0.22), Color(0.00, 0.02, 0.08), Color(0.10, 0.40, 0.70)],
	"hydrothermal":   [Color(0.15, 0.06, 0.12), Color(0.05, 0.01, 0.04), Color(0.80, 0.30, 0.10)],
	"bioluminescent": [Color(0.02, 0.10, 0.25), Color(0.00, 0.04, 0.12), Color(0.20, 0.95, 0.75)],
}

var current_biome := "shallows" : set = set_biome

var _mat: ShaderMaterial
var _time := 0.0

var _current_a        := Color(0.05, 0.25, 0.45)
var _current_b        := Color(0.02, 0.12, 0.28)
var _current_shimmer  := Color(0.50, 0.90, 1.00)
var _target_a         := Color(0.05, 0.25, 0.45)
var _target_b         := Color(0.02, 0.12, 0.28)
var _target_shimmer   := Color(0.50, 0.90, 1.00)


func _ready() -> void:
	_mat = material as ShaderMaterial
	size = get_viewport_rect().size
	position = Vector2.ZERO
	set_biome(current_biome)


func _process(delta: float) -> void:
	_time += delta
	_current_a       = _current_a.lerp(_target_a, blend_speed * delta)
	_current_b       = _current_b.lerp(_target_b, blend_speed * delta)
	_current_shimmer = _current_shimmer.lerp(_target_shimmer, blend_speed * delta)
	_mat.set_shader_parameter("color_a",       _current_a)
	_mat.set_shader_parameter("color_b",       _current_b)
	_mat.set_shader_parameter("shimmer_color", _current_shimmer)
	_mat.set_shader_parameter("time",          _time)


func set_biome(biome_name: String) -> void:
	current_biome = biome_name
	if biome_name not in BIOMES:
		push_warning("Background: unknown biome '%s'" % biome_name)
		return
	var palette = BIOMES[biome_name]
	_target_a       = palette[0]
	_target_b       = palette[1]
	_target_shimmer = palette[2]
