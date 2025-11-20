extends AnimatedSprite2D

@onready var text := $Text
@onready var audio := $AudioStreamPlayer2D

var audio_done = false
var animation_done = false


func _ready() -> void:
	audio.play()
	
	var t_rot = randf_range(-0.1, 0.1)
	text.rotation += t_rot
	
	var t_pos_x = randf_range(-2, 2)
	var t_pos_y = randf_range(-2, 2)
	text.position += Vector2(t_pos_x, t_pos_y)
	
	var tween = self.create_tween()
	var t_scale = randf_range(-0.02, 0.0)
	var target = text.scale + Vector2(t_scale, t_scale)
	text.scale = Vector2.ZERO
	
	tween.tween_property(text, "scale", target, 0.2)


func _on_animation_finished() -> void:
	animation_done = true
	if audio_done and animation_done:
		queue_free()


func _on_audio_stream_player_2d_finished() -> void:
	audio_done = true
	if audio_done and animation_done:
		queue_free()
