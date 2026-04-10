# terrain_renderer.gd
# Reads terrain data from TerrainGenerator and draws ceiling and floor
# as filled polygons that scroll with the world.
# Attach to a Node2D in your level scene, below the background CanvasLayer.

class_name TerrainRenderer
extends Node2D

@export var generator: NodePath

# Rock/wall colour for ceiling and floor geometry
@export var ceiling_color: Color = Color(0.08, 0.10, 0.14)
@export var floor_color:   Color = Color(0.06, 0.09, 0.12)

var generator_node: TerrainGenerator
var ceiling_polygon: Polygon2D
var floor_polygon:   Polygon2D


func _ready() -> void:
	generator_node = get_node(generator)
	generator_node.terrain_updated.connect(rebuild_geometry)

	ceiling_polygon = Polygon2D.new()
	ceiling_polygon.color = ceiling_color
	add_child(ceiling_polygon)

	floor_polygon = Polygon2D.new()
	floor_polygon.color = floor_color
	add_child(floor_polygon)


func rebuild_geometry() -> void:
	if generator_node.sample_xs.size() < 2:
		return

	var viewport_h := get_viewport_rect().size.y
	var xs      := generator_node.sample_xs
	var ceils   := generator_node.ceiling_ys
	var floors  := generator_node.floor_ys
	var count   := xs.size()

	# Ceiling polygon: top edge at y=0, bottom edge follows ceiling curve
	var ceil_pts := PackedVector2Array()
	ceil_pts.append(Vector2(xs[0], 0.0))
	ceil_pts.append(Vector2(xs[count - 1], 0.0))
	for i in range(count - 1, -1, -1):
		ceil_pts.append(Vector2(xs[i], ceils[i]))
	ceiling_polygon.polygon = ceil_pts

	# Floor polygon: top edge follows floor curve, bottom edge at viewport bottom
	var floor_pts := PackedVector2Array()
	for i in count:
		floor_pts.append(Vector2(xs[i], floors[i]))
	floor_pts.append(Vector2(xs[count - 1], viewport_h))
	floor_pts.append(Vector2(xs[0], viewport_h))
	floor_polygon.polygon = floor_pts
