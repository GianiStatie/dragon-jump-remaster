class_name CardUI
extends Control

@onready var container: MarginContainer = $MarginContainer
@onready var texture: TextureRect = $MarginContainer/TextureRect
@onready var label: Label = $MarginContainer/TextureRect/Label

var powerup_type: String = ""


func draw(type: String, exists: bool = false) -> void:
	powerup_type = type
	
	label.text = type
	texture.self_modulate = Constants.POWERUPS[type]["color"]
	
	if not exists:
		play_draw_new_animation()
	else:
		play_draw_same_animation()


func shift_by(offsets: Array):
	var margin_names := [
		"margin_left",
		"margin_top",
		"margin_right",
		"margin_bottom"
		]
	
	for i in range(4):
		var current = container.get_theme_constant(margin_names[i])
		var new_value = current + offsets[i]
		container.add_theme_constant_override(margin_names[i], new_value)


func play_draw_new_animation():
	container.position = Vector2(600.0, 290.0)
	container.scale = Vector2(0.2, 0.2)
	
	var tween = self.create_tween()
	tween.tween_property(container, "position", Vector2(-56.0, 584.0), 0.1)
	tween.chain().tween_property(container, "position", Vector2(0.0, 468.0), 0.05)
	tween.tween_property(container, "scale", Vector2(1.0, 1.0), 0.15)


func play_draw_same_animation():
	container.position = Vector2(-20.0, 448.0)
	container.modulate = Color(1.0, 1.0, 1.0, 0.5)
	
	var tween = self.create_tween()
	tween.tween_property(container, "position", Vector2(0.0, 468.0), 0.35)
	tween.tween_property(container, "modulate", Color.WHITE, 0.35)
