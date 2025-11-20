extends AnimatedSprite2D

var animation_done := false
var audio_done := false


func _on_animation_finished() -> void:
	animation_done = true
	if audio_done and animation_done:
		queue_free()


func _on_audio_stream_player_2d_finished() -> void:
	audio_done = true
	if audio_done and animation_done:
		queue_free()
