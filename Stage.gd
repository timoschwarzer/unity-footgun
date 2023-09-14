extends Control

const FlyingObject = preload('res://FlyingObject.tscn')
const CrosshairImprint = preload('res://CrosshairImprint.tscn')

@onready var flying_objects_container = $FlyingObjectsContainer
@onready var crosshair = $Crosshair
@onready var score_label = $UIRoot/ScoreLabel
@onready var highscore_label = $UIRoot/TryAgain/VBoxContainer/HighscoreLabel
@onready var try_again = $UIRoot/TryAgain
@onready var camera = $Camera
@onready var animation_player = $UIRoot/TryAgain/AnimationPlayer
@onready var tutorial_label = $UIRoot/TutorialLabel

const FREQUENCY_MIN = 0.2
const FREQUENCY_MAX = 1.0
const FREQUENCY_STEP = 0.02
const MAX_FOOT_DETECT_RADIUS = 450.0
const MAX_FOOT_DETECT_RADIUS_HIGHSCORE_THRESHOLD = 10000.0

var tutorial_done := false
var frequency = FREQUENCY_MAX
var spawn_timeout = 0.0
var score = 0
var displayed_score: int = 0
var highscore: int = 0
var touch_shot_scheduled := false

func _process(delta: float) -> void:
	if GameState.active:
		spawn_timeout -= delta
		
		if Input.is_action_just_pressed('shoot') || touch_shot_scheduled:
			touch_shot_scheduled = false
			var crosshair_imprint_instance = CrosshairImprint.instantiate()
			crosshair_imprint_instance.global_position = crosshair.global_position
			add_child(crosshair_imprint_instance)
			
			var space = get_world_2d().direct_space_state
			var query_parameters = PhysicsPointQueryParameters2D.new()
			query_parameters.position = crosshair.global_position
			var objects_under_crosshair = space.intersect_point(query_parameters, 4)
			
			var closest: FlyingObject = null
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
				
				if closest.is_in_group('feet'):
					score = max(0, score - highscore * 0.5)
					score_label.modulate = Color.RED
					get_tree().create_tween().tween_property(score_label, 'modulate', Color.WHITE, 1.0)
				else:
					var added_points = randi_range(100, 200)
					score += added_points
					
					if !tutorial_done:
						tutorial_done = true
						get_tree().create_tween().tween_property(tutorial_label, 'modulate', Color(1.0, 1.0, 1.0, 0.0), 0.5)
				
				if score < 1:
					end_game()
					
				get_tree().create_tween().tween_property(self, 'displayed_score', score, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
				highscore = max(highscore, score)
				camera.shake(0.3, 100)
				update_foot_detect_radius()
			else:
				camera.shake(0.2, 40)

		if spawn_timeout < 0:
			spawn_flying_object()
			spawn_timeout = frequency
	
	score_label.text = '%sK €' % make_score_string(displayed_score)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch && event.index == 1 && event.pressed:
		touch_shot_scheduled = true

func make_score_string(value):
	var score_string = str(value)
	for i in range(score_string.length() - 3, 0, -3):
		score_string = score_string.insert(i, '.')
	return score_string

func spawn_flying_object():
	var viewport_size = get_viewport_rect().size
	var instance := FlyingObject.instantiate()
	instance.global_position = Vector2(randf_range(100, viewport_size.x - 100), viewport_size.y + 50)
	instance.linear_velocity = Vector2(randf_range(-300, 300), randf_range(-viewport_size.y * 0.8, -viewport_size.y * 1.2))
	instance.angular_velocity = randf_range(-1.5, 1.5)
	flying_objects_container.add_child(instance)
	
	if randi() % 3 == 0 && score > 0:
		instance.become_foot()
	else:
		instance.become_money()

func end_game():
	GameState.active = false
	try_again.modulate.a = 0
	try_again.visible = true
	highscore_label.text = 'Highscore: %sK €' % make_score_string(highscore)
	get_tree().create_tween().tween_property(crosshair, 'aim_pos_snap_pos_ratio', 0.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	get_tree().create_tween().tween_property(try_again, 'modulate', Color.WHITE, 0.3).set_delay(1.0)
	animation_player.play('amogus')

func restart_game():
	frequency = FREQUENCY_MAX
	score = 0
	displayed_score = 0
	highscore = 0
	GameState.active = true
	update_foot_detect_radius()

func update_foot_detect_radius():
	crosshair.foot_detect_radius = min((highscore / MAX_FOOT_DETECT_RADIUS_HIGHSCORE_THRESHOLD), 1.0) * MAX_FOOT_DETECT_RADIUS

func _on_yes_button_pressed() -> void:
	if GameState.active:
		return
	
	restart_game()
	
	var tween = get_tree().create_tween()
	tween.tween_property(try_again, 'modulate', Color.TRANSPARENT, 0.3)
	tween.finished.connect(
		func():
			try_again.visible = false
	)
