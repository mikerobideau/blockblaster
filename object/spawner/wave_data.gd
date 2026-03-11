extends Resource
class_name WaveData

enum Mood {
	CALM,
	MODERATE,
	INTENSE
}

@export var mood: Mood
@export var timeline: Timeline
