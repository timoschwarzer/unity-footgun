extends Node2D

@onready var foot_detect_area = $TransformReset/FootDetectArea

var bodies_inside = []
var mouse_pos_snap_pos_ratio = 0.0
var snap_pos = Vector2(0, 0)

func _process(delta: float) -> void:
	foot_detect_area.global_position = get_global_mouse_position()
	global_position = lerp(get_global_mouse_position(), snap_pos, mouse_pos_snap_pos_ratio)
	
	if !bodies_inside.is_empty():
		snap_pos = bodies_inside[0].global_position

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
	if bodies_inside.is_empty():
		var tween = get_tree().create_tween()
		tween.tween_property(self, 'mouse_pos_snap_pos_ratio', 0.0, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(self, 'mouse_pos_snap_pos_ratio', 1.0, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
