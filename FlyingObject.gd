extends RigidBody2D
class_name FlyingObject

@onready var animation_player := $AnimationPlayer
@onready var explode_particles := $ExplodeParticles
@onready var sprite := $Sprite

var exploded = false

func become_foot():
	sprite.texture = preload('res://assets/foot.png')
	add_to_group('feet')

func _process(delta: float) -> void:
	explode_particles.global_rotation = 0.0
	
	if global_position.y > get_viewport_rect().size.y + 200:
		queue_free()

func explode():
	if exploded:
		return
	
	exploded = true
	set_collision_layer_value(1, false)
	animation_player.play('explode')
