extends Node2D

const ROTATION_RANDOMNESS = TAU * 0.07

@onready var sprite := $Sprite

func _ready() -> void:
	sprite.rotation = randf_range(-ROTATION_RANDOMNESS, ROTATION_RANDOMNESS)
