extends Node2D
class_name Zone

@onready var floor = $Floor
@onready var ceiling = $Ceiling

var rng: RandomNumberGenerator

func _ready():
	floor.polygon = generate_terrain_polygon(1920, 50, false)
	floor.polygon = add_micro_detail(floor.polygon)
	ceiling.polygon = generate_terrain_polygon(1920, 50, true)
	ceiling.polygon = add_micro_detail(ceiling.polygon)

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

func shape_flat(width, base_y):
	var pts := PackedVector2Array()
	pts.append(Vector2(0, base_y))
	pts.append(Vector2(width, base_y + randf_range(-20, 20)))
	return pts
	
func shape_slope(width, base_y):
	print_debug('slope')
	var pts := PackedVector2Array()
	var end_y = base_y + randf_range(-150, 150)
	pts.append(Vector2(0, base_y))
	pts.append(Vector2(width, end_y))
	return pts
	
func shape_arch(width, base_y):
	print_debug('arch')
	var pts := PackedVector2Array()
	var mid_y = base_y - randf_range(100, 250)

	pts.append(Vector2(0, base_y))
	pts.append(Vector2(width * 0.5, mid_y))
	pts.append(Vector2(width, base_y))

	return pts
	
func shape_bowl(width, base_y):
	print_debug('bowl')
	var pts := PackedVector2Array()
	var mid_y = base_y + randf_range(100, 250)

	pts.append(Vector2(0, base_y))
	pts.append(Vector2(width * 0.5, mid_y))
	pts.append(Vector2(width, base_y))

	return pts
	
func shape_stairs(width, base_y):
	print_debug('stairs')
	var pts := PackedVector2Array()
	var steps = randi_range(3, 6)
	var step_w = width / steps
	var y = base_y

	pts.append(Vector2(0, y))

	for i in range(steps):
		y += randf_range(-80, 80)
		var x = (i + 1) * step_w
		pts.append(Vector2(x, y))

	return pts

func shape_zigzag(width, base_y):
	var pts := PackedVector2Array()
	var segments = randi_range(4, 7)
	var seg_w = width / segments

	pts.append(Vector2(0, base_y))

	for i in range(1, segments):
		var x = i * seg_w
		var y = base_y + (1 if i % 2 == 0 else -1) * randf_range(80, 180)
		pts.append(Vector2(x, y))

	pts.append(Vector2(width, base_y))
	return pts

func sample_original(points: PackedVector2Array, x: float) -> Vector2:
	for i in range(points.size() - 1):
		var a = points[i]
		var b = points[i + 1]
		if x >= a.x and x <= b.x:
			var t = (x - a.x) / (b.x - a.x)
			return a.lerp(b, t)
	return points[0]
