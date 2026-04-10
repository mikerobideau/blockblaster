extends Node2D
class_name Zone

@onready var corridor = $Corridor
@onready var walls = $Walls

var rng: RandomNumberGenerator
var width = 1920
var height = 1080
var bounds = PackedVector2Array([
	Vector2(-width, -height),
	Vector2(width, -height),
	Vector2(width, height),
	Vector2(-width, height),
])

func _ready():
	corridor.polygon = _make_turn(width/2, height / 2)
	#var walls = Geometry2D.exclude_polygons(bounds, corridor.polygon)
	#_build_walls(walls)

func _build_walls(polys: Array):
	for child in walls.get_children():
		child.queue_free()

	for poly in polys:
		var p = Polygon2D.new()
		p.polygon = poly
		walls.add_child(p)

func _make_straight(w: float, h: float) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-w, -h),
		Vector2(w, -h),
		Vector2(w, h),
		Vector2(-w, h),
	])

func _make_turn(w: float, h: float) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-h, -w),
		Vector2(0, -w),
		Vector2(0, -h),
		Vector2(w, -h),
		Vector2(w, w),
		Vector2(-h, w),
	])

func generate_terrain_polygon(width: float, depth: float, is_ceiling: bool) -> PackedVector2Array:
	var poly := PackedVector2Array()
	var segments := 40                 # number of points along the horizontal
	var macro_height := 300.0          # height of big shapes like arches, bowls, n's
	var micro_height := 20.0           # small jaggedness

	var shape := randi_range(0, 2)    # 0 = flat, 1 = arch ∩, 2 = bowl ∪
	var edge := []

	# --- generate horizontal edge points ---
	for i in range(segments + 1):
		var t := i / float(segments)
		var x := t * width
		var y := 0.0

		# macro shape
		match shape:
			0:
				y = 0
			1:
				y = -sin(t * PI) * macro_height
			2:
				y = sin(t * PI) * macro_height

		# micro detail
		y += randf_range(-micro_height, micro_height)

		# orient for floor vs ceiling
		if is_ceiling:
			y = abs(y)    # ceiling goes downward from top
		else:
			y = -abs(y)   # floor goes upward from baseline

		edge.append(Vector2(x, y))

	# --- build closed polygon ---
	for p in edge:
		poly.append(p)

	if is_ceiling:
		# extend upward to close polygon
		poly.append(Vector2(width, -depth))
		poly.append(Vector2(0, -depth))
	else:
		# extend downward to close polygon
		poly.append(Vector2(width, depth))
		poly.append(Vector2(0, depth))

	return poly
	
func add_micro_detail(points: PackedVector2Array) -> PackedVector2Array:
	var result := PackedVector2Array()

	var min_subdivisions := 1
	var max_subdivisions := 10
	var y_variation := 10.0

	for i in range(points.size() - 1):
		var a = points[i]
		var b = points[i + 1]

		result.append(a)

		var subdivisions = randi_range(min_subdivisions, max_subdivisions)
		for j in range(1, subdivisions + 1):
			var t := j / float(subdivisions + 1)
			var p := a.lerp(b, t)
			p.y += rng.randf_range(-y_variation, y_variation)
			result.append(p)

	result.append(points[-1])
	return result
