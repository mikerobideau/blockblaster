# terrain_profile.gd
# A Resource that defines the procedural terrain parameters for one zone type.
# Create instances of this in the Godot Inspector (New Resource > TerrainProfile)
# and assign them to the TerrainGenerator per zone.
#
# Usage: File > New Resource > TerrainProfile, then tune in Inspector.

class_name TerrainProfile
extends Resource

# --- Ceiling ---
# How far from the top of the screen the ceiling baseline sits (pixels)
@export var ceiling_baseline: float = 80.0
# How much the ceiling moves up and down around the baseline
@export var ceiling_amplitude: float = 20.0
# How frequently the ceiling undulates (higher = more jagged)
@export var ceiling_frequency: float = 0.002

# --- Floor ---
# How far from the bottom of the screen the floor baseline sits (pixels)
@export var floor_baseline: float = 120.0
# How much the floor moves up and down around the baseline
@export var floor_amplitude: float = 40.0
# How frequently the floor undulates
@export var floor_frequency: float = 0.003

# --- Passage ---
# Minimum gap between ceiling and floor (pixels) — prevents the cave closing completely
@export var min_passage_height: float = 180.0

# --- Transition ---
# How many pixels it takes to fully blend from the previous profile into this one
@export var blend_distance: float = 600.0


# Convenience constructors for each zone type.
# Call these from code, or create .tres files in the Inspector.

static func make_open_water() -> TerrainProfile:
	var p := TerrainProfile.new()
	p.ceiling_baseline  = 40.0
	p.ceiling_amplitude = 10.0
	p.ceiling_frequency = 0.001
	p.floor_baseline    = 80.0
	p.floor_amplitude   = 20.0
	p.floor_frequency   = 0.001
	p.min_passage_height = 900.0   # effectively open — no real ceiling/floor constraint
	p.blend_distance    = 800.0
	return p

static func make_reef() -> TerrainProfile:
	var p := TerrainProfile.new()
	p.ceiling_baseline  = 60.0
	p.ceiling_amplitude = 15.0
	p.ceiling_frequency = 0.002
	p.floor_baseline    = 220.0
	p.floor_amplitude   = 80.0
	p.floor_frequency   = 0.004
	p.min_passage_height = 300.0
	p.blend_distance    = 500.0
	return p

static func make_cave() -> TerrainProfile:
	var p := TerrainProfile.new()
	p.ceiling_baseline  = 200.0
	p.ceiling_amplitude = 80.0
	p.ceiling_frequency = 0.005
	p.floor_baseline    = 220.0
	p.floor_amplitude   = 90.0
	p.floor_frequency   = 0.005
	p.min_passage_height = 160.0
	p.blend_distance    = 400.0
	return p

static func make_trench() -> TerrainProfile:
	var p := TerrainProfile.new()
	p.ceiling_baseline  = 40.0
	p.ceiling_amplitude = 8.0
	p.ceiling_frequency = 0.001
	p.floor_baseline    = 400.0
	p.floor_amplitude   = 120.0
	p.floor_frequency   = 0.006
	p.min_passage_height = 200.0
	p.blend_distance    = 600.0
	return p

static func make_canopy() -> TerrainProfile:
	var p := TerrainProfile.new()
	p.ceiling_baseline  = 260.0
	p.ceiling_amplitude = 100.0
	p.ceiling_frequency = 0.004
	p.floor_baseline    = 80.0
	p.floor_amplitude   = 25.0
	p.floor_frequency   = 0.002
	p.min_passage_height = 200.0
	p.blend_distance    = 500.0
	return p
