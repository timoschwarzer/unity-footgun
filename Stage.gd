extends Node2D

const FlyingObject = preload('res://FlyingObject.tscn')
const CrosshairImprint = preload('res://CrosshairImprint.tscn')

@onready var flying_objects_container = $FlyingObjectsContainer
@onready var crosshair = $Crosshair

const FREQUENCY_MIN = 0.2
const FREQUENCY_MAX = 1.0
const FREQUENCY_STEP = 0.02

var frequency = FREQUENCY_MAX
var spawn_timeout = 0.0
var score = 0

func _process(delta: float) -> void:
	spawn_timeout -= delta
	
	if Input.is_action_just_pressed('shoot'):
		var crosshair_imprint_instance = CrosshairImprint.instantiate()
		crosshair_imprint_instance.global_position = crosshair.global_position
		add_child(crosshair_imprint_instance)
		
		var space = get_world_2d().direct_space_state
		var query_parameters = PhysicsPointQueryParameters2D.new()
		query_parameters.position = crosshair.global_position
		var objects_under_crosshair = space.intersect_point(query_parameters, 4)
		
		var closest = null
		var closest_distance = null
		
		for hit in objects_under_crosshair:
			if !(hit.collider is FlyingObject):
				continue
			
			var distance = crosshair.global_position.distance_squared_to(hit.collider.global_position)
			if closest == null || distance < closest_distance:
				closest = hit.collider
				closest_distance = distance
		
		if closest:
			closest.explode()
			frequency = max(FREQUENCY_MIN, frequency - FREQUENCY_STEP)

	if spawn_timeout < 0:
		spawn_flying_object()
		spawn_timeout = frequency

func spawn_flying_object():
	var viewport_size = get_viewport_rect().size
	var instance := FlyingObject.instantiate()
	instance.global_position = Vector2(randf_range(0, viewport_size.x), viewport_size.y + 50)
	instance.linear_velocity = Vector2(randf_range(-300, 300), randf_range(-viewport_size.y * 0.8, -viewport_size.y * 1.5))
	instance.angular_velocity = randf_range(-1.5, 1.5)
	flying_objects_container.add_child(instance)
	
	if randi() % 3 == 0:
		instance.become_foot()
