class_name Card
extends Control

@onready var container: MarginContainer = $MarginContainer

var powerup_type: String = ""


func draw(type: String, is_same: bool = false) -> void:
	powerup_type = type
	if not is_same:
		play_draw_new_animation()
	else:
		play_draw_same_animation()


func play_draw_new_animation():
	container.position = Vector2(600.0, 290.0)
	container.scale = Vector2(0.2, 0.2)
	
	var tween = self.create_tween()
	tween.tween_property(container, "position", Vector2(-56.0, 584.0), 0.1)
	tween.chain().tween_property(container, "position", Vector2(0.0, 468.0), 0.1)
	tween.tween_property(container, "scale", Vector2(1.0, 1.0), 0.2)


func play_draw_same_animation():
	container.position = Vector2(-20.0, 448.0)
	container.modulate = Color(1.0, 1.0, 1.0, 0.5)
	
	var tween = self.create_tween()
	tween.tween_property(container, "position", Vector2(0.0, 468.0), 0.35)
	tween.tween_property(container, "modulate", Color.WHITE, 0.35)
