extends Node2D

@onready var foot_detect_area = $TransformReset/FootDetectArea
@onready var detach_line = $DetachLine
@onready var foot_detect_shape = $TransformReset/FootDetectArea/FootDetectShape

@export var foot_detect_radius = 0.0 : set = set_foot_detect_radius, get = get_foot_detect_radius

var aim_pos = Vector2(0, 0)
var bodies_inside = []
var aim_pos_snap_pos_ratio = 0.0
var snap_pos = Vector2(0, 0)

func set_foot_detect_radius(value):
	foot_detect_shape.shape.radius = value
	print(value)

func get_foot_detect_radius():
	return foot_detect_shape.shape.radius

func _process(delta: float) -> void:
	foot_detect_area.global_position = aim_pos
	global_position = lerp(aim_pos, snap_pos, aim_pos_snap_pos_ratio)
	
	if GameState.active && !bodies_inside.is_empty():
		snap_pos = bodies_inside[0].global_position
	
	detach_line.modulate.a = aim_pos_snap_pos_ratio
	if aim_pos_snap_pos_ratio > 0.0:
		detach_line.set_point_position(1, transform.affine_inverse() * aim_pos)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch || event is InputEventScreenDrag:
		if event.index == 0:
			aim_pos = get_viewport_transform().affine_inverse() * event.position + Vector2(100, -75)
	elif event is InputEventMouse:
		aim_pos = event.position

func _on_foot_detect_area_body_entered(body: Node2D) -> void:
	if !body.is_in_group('feet'):
		return
	
	bodies_inside.append(body)
	update_snapping()

func _on_foot_detect_area_body_exited(body: Node2D) -> void:
	if !body.is_in_group('feet'):
		return
	
	bodies_inside.erase(body)
	update_snapping()

func update_snapping() -> void:
	if !GameState.active:
		return
	
	if bodies_inside.is_empty():
		get_tree().create_tween().tween_property(self, 'aim_pos_snap_pos_ratio', 0.0, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	else:
		get_tree().create_tween().tween_property(self, 'aim_pos_snap_pos_ratio', 1.0, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
