extends Camera2D

var shake_length := 1.0
var shake_timeout := 0.0
var shake_amplitude := 0.0
var shake_target := Vector2()
var zoom_target := 0.0
var shock_timeout := 0.0
var zoom_uniform := 1.0
var zoom_uniform_offset := 0.0

func _process(delta: float) -> void:
	shake_timeout -= delta
	shock_timeout -= delta
	
	if (shake_timeout > 0):
		if (shock_timeout <= 0):
			var rand_amplitude = shake_timeout / shake_length * shake_amplitude
			shake_target = Vector2(randf_range(-rand_amplitude, rand_amplitude), randf_range(-rand_amplitude, rand_amplitude))
			shock_timeout = randf_range(0.03, 0.04)
			zoom_target = shake_timeout / shake_length * randf_range(-0.1, 0.1) * rand_amplitude * 0.01

		offset = offset.lerp(shake_target, 15.0 * delta * shock_timeout * 20.0)
		zoom_uniform_offset = lerp(zoom_uniform_offset, zoom_target, 15.0 * delta * shock_timeout * 20.0)
	else:
		offset = offset.lerp(Vector2(), 15.0 * delta)
		zoom_uniform_offset = lerp(zoom_uniform_offset, 0.0, 15.0 * delta)
	
	zoom = Vector2(
		zoom_uniform + zoom_uniform_offset,
		zoom_uniform + zoom_uniform_offset
	)

func shake(length, amplitude):
	shake_timeout = length
	shake_length = length
	shake_amplitude = amplitude
