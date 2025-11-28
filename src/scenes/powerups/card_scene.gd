class_name CardUI
extends Control

@onready var container: MarginContainer = $MarginContainer
@onready var texture: TextureRect = $MarginContainer/TextureRect
@onready var label: Label = $MarginContainer/TextureRect/Label

var is_splitscreen: bool = false
var powerup_type: String = ""
var scales = {
	"single_player": [0.72, Vector2.ONE],
	"split_screen": [0.57, Vector2(0.75, 0.75)]
}
var y_scale: float
var container_scale: Vector2


func _ready() -> void:
	if not is_splitscreen:
		y_scale = scales["single_player"][0]
		container_scale = scales["single_player"][1]
	else:
		y_scale = scales["split_screen"][0]
		container_scale = scales["split_screen"][1]


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
	var y_size = self.size.y
	
	container.position = Vector2(600.0, y_size*0.45)
	container.scale = Vector2(0.2, 0.2)
	
	var tween = self.create_tween()
	tween.tween_property(container, "position", Vector2(-56.0, y_size*0.9), 0.1)
	tween.chain().tween_property(container, "position", Vector2(0.0, y_size*y_scale), 0.05)
	tween.tween_property(container, "scale", container_scale, 0.15)


func play_draw_same_animation():
	var y_size = self.size.y
	
	container.position = Vector2(-20.0, y_size * y_scale)
	container.modulate = Color(1.0, 1.0, 1.0, 0.5)
	container.scale = container_scale
	
	var tween = self.create_tween()
	tween.tween_property(container, "position", Vector2(0.0, y_size * y_scale), 0.35)
	tween.tween_property(container, "modulate", Color.WHITE, 0.35)
