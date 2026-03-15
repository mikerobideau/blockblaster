extends Resource
class_name SpawnBehaviorData

enum Location {
	ANY_EDGE,
	LEFT_OR_RIGHT_EDGE,
	TOP_EDGE
}

@export var location: Location
