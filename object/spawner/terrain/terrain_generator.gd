# terrain_generator.gd
# Generates ceiling and floor Y values at any world X coordinate.
# Uses two FastNoiseLite samplers — one for ceiling, one for floor.
# Profiles are blended smoothly at zone transitions.
# Attach to a Node in your level scene.

class_name TerrainGenerator
extends Node

# Emitted when enough new terrain has been generated ahead of the camera
signal terrain_updated

@export var camera: NodePath

# Pixels of terrain to generate ahead of the camera right edge
@export var lookahead: float = 800.0

# Horizontal resolution — one sample every N pixels
@export var sample_step: float = 16.0

var camera_node: Camera2D
var viewport_w: float
var viewport_h: float

# Active and previous profiles for blending
var active_profile: TerrainProfile
var previous_profile: TerrainProfile

# World X where the current blend started
var blend_start_x: float = 0.0

# How far into the current blend we are (0 = fully previous, 1 = fully active)
var blend_progress: float = 1.0

# Generated terrain data: world_x -> {ceiling_y, floor_y}
# Stored as parallel arrays for efficient iteration
var sample_xs:       PackedFloat32Array = PackedFloat32Array()
var ceiling_ys:      PackedFloat32Array = PackedFloat32Array()
var floor_ys:        PackedFloat32Array = PackedFloat32Array()

# Rightmost X we have generated so far
var generated_up_to: float = 0.0

# Noise instances — separate for ceiling and floor so they move independently
var ceiling_noise: FastNoiseLite
var floor_noise:   FastNoiseLite


func _ready() -> void:
	camera_node = get_node(camera)
	viewport_w  = get_viewport().get_visible_rect().size.x
	viewport_h  = get_viewport().get_visible_rect().size.y

	ceiling_noise = FastNoiseLite.new()
	ceiling_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	ceiling_noise.seed = randi()

	floor_noise = FastNoiseLite.new()
	floor_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	floor_noise.seed = randi()

	# Default to open water until a profile is set
	active_profile  = TerrainProfile.make_open_water()
	previous_profile = active_profile
	blend_progress  = 1.0

	# Seed initial terrain from world X = 0
	generated_up_to = 0.0
	generate_ahead()


func _process(_delta: float) -> void:
	if camera_node == null:
		return
	generate_ahead()
	cull_behind()


# ---- Profile transitions ------------------------------------------------

func set_profile(profile: TerrainProfile) -> void:
	if profile == active_profile:
		return
	previous_profile = active_profile
	active_profile   = profile
	blend_start_x    = generated_up_to
	blend_progress   = 0.0


# ---- Terrain sampling ---------------------------------------------------

func get_ceiling_y(world_x: float) -> float:
	return sample_terrain(world_x).x


func get_floor_y(world_x: float) -> float:
	return sample_terrain(world_x).y


# Returns Vector2(ceiling_y, floor_y) at a given world X.
# Blends between previous and active profile during transitions.
func sample_terrain(world_x: float) -> Vector2:
	var t := blend_progress if blend_progress >= 1.0 else _blend_t(world_x)

	var prev := _sample_profile(previous_profile, world_x)
	var curr := _sample_profile(active_profile,   world_x)

	var ceiling_y := lerpf(prev.x, curr.x, t)
	var floor_y   := lerpf(prev.y, curr.y, t)

	# Enforce minimum passage height
	var profile := active_profile if t > 0.5 else previous_profile
	var mid      := (ceiling_y + floor_y) / 2.0
	var half_min := profile.min_passage_height / 2.0
	if floor_y - ceiling_y < profile.min_passage_height:
		ceiling_y = mid - half_min
		floor_y   = mid + half_min

	return Vector2(ceiling_y, floor_y)


func _sample_profile(profile: TerrainProfile, world_x: float) -> Vector2:
	var ceil_n := ceiling_noise.get_noise_1d(world_x * profile.ceiling_frequency)
	var floor_n := floor_noise.get_noise_1d(world_x * profile.floor_frequency)

	var ceil_y  := profile.ceiling_baseline + ceil_n * profile.ceiling_amplitude
	var floor_y := viewport_h - profile.floor_baseline + floor_n * profile.floor_amplitude

	return Vector2(ceil_y, floor_y)


func _blend_t(world_x: float) -> float:
	if active_profile == null or active_profile.blend_distance <= 0.0:
		return 1.0
	var t := (world_x - blend_start_x) / active_profile.blend_distance
	blend_progress = clamp(t, 0.0, 1.0)
	return blend_progress


# ---- Generation and culling ---------------------------------------------

func generate_ahead() -> void:
	var cam_right := camera_node.global_position.x + viewport_w / 2.0
	var target    := cam_right + lookahead
	var changed   := false

	while generated_up_to < target:
		var x      := generated_up_to
		var result := sample_terrain(x)
		sample_xs.append(x)
		ceiling_ys.append(result.x)
		floor_ys.append(result.y)
		generated_up_to += sample_step
		changed = true

	if changed:
		terrain_updated.emit()


func cull_behind() -> void:
	var cam_left := camera_node.global_position.x - viewport_w / 2.0
	var cull_x   := cam_left - viewport_w

	while sample_xs.size() > 0 and sample_xs[0] < cull_x:
		sample_xs.remove_at(0)
		ceiling_ys.remove_at(0)
		floor_ys.remove_at(0)
